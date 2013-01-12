require 'paxos'

class MultiPaxos

	class InvalidInstanceNumberError < ArgumentError ; end

	def initialize(node_factory)
		@node_factory = node_factory
		@uid = nil
		@quorum_size = nil
		@instance_number = nil
		@node = nil
	end

	def on_proposal_resolution(instance_number, value)
	end

	def instance_number=(new_number)
		@instance_number = new_number - 1
		next_instance
	end

	def quorum_size=(new_size)
		@quorum_size = new_size
		@node.quorum_size = new_size
		# (Save durable state)
	end

	def proposed_value?
		@node.proposer.value?
	end

	def leadership?
		@node.proposer.leader?
	end

	def self.receive_action(*arguments)
		if arguments.last.is_a?(Hash)
			options = arguments.pop
		else
			options = {}
		end

		options = { :durable => true }.merge(options)

		arguments.each do |action_name|
			receive_action_name = "receive_#{action_name}".to_sym

			define_method(receive_action_name) do |*args|
				instance_number = args.shift

				if instance_number == @instance_number
					result = @node.send(action_name.to_sym, *args)
					# (Save durable state) if options[:durable] && result
					result
				end
			end
		end
	end

	# Node (receive) actions

	receive_action :promise, :prepare, :accept_request
	receive_action :accepted, :durable => false

	def proposal=(instance_number, value)
		raise InvalidInstanceNumberError if @instance_number != instance_number
		@node.proposal = value
	end

	def prepare
		result = @node.prepare
		# Save durable state
		result
	end

	# def receive_promise(instance_number, acceptor_uid, proposal_id, previous_proposal_id, previous_proposal_value)
	# 	if instance_number == @instance_number
	# 		r = @node.receive_promise(acceptor_uid, proposal_id, previous_proposal_id, previous_proposal_value)

	# 		# (Save durable state) if r
	# 		r
	# 	end
	# end

	# def receive_prepare(instance_number, proposal_id)
	# 	if instance_number == @instance_number
	# 		r = @node.receive_prepare(proposal_id)
	# 		# (Save durable state) if r
	# 		r
	# 	end
	# end

	# def receive_accept_request(instance_number, proposal_id, value)
	# 	if instance_number == @instance_number
	# 		r = @node.receive_accept_request(proposal_id, value)
	# 		# (Save durable state) if r
	# 		r
	# 	end
	# end

	# def receive_accepted(instance_number, acceptor_uid, proposal_id, accepted_value)
	# 	if instance_number == @instance_number
	# 		@node.receive_accepted(acceptor_uid, proposal_id, accepted_value)
	# 	end
	# end

	private

	def next_instance(leader_uid = nil)
		@instance_number += 1
		@node = @node_factory.create(@uid, leader_uid, @quorum_size, @on_resolution)
	end

	def on_resolution(proposal_id, value)
		current_instance_number = @instance_number
		next_instance(proposal_id[1])
		# Save durable state before #on_proposal_resolution
		on_proposal_resolution(current_instance_number, value)
	end
end
