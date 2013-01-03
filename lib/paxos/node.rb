require 'forwardable'

class Node
	extend Forwardable

	def_delegators :@proposer, :prepare, :observe_proposal, :receive_promise, :set_proposal
	def_delegators :@acceptor, :receive_accept_request

	def initialize(proposer, acceptor, learner, &callback)
		@proposer = proposer
		@acceptor = acceptor
		@learner = learner
		@on_resolution = callback
	end

	def change_quorum_size(new_quorum_size)
		@proposer.quorum_size = new_quorum_size
		@learner.quorum_size = new_quorum_size
	end

	def set_on_resolution_callback(&callback)
		@on_resolution = callback
	end

	# Proxy method for @acceptor
	def receive_prepare(proposal_id)
		@proposer.observe_proposal(proposal_id)
		@acceptor.receive_prepare(proposal_id)
	end

	# Proxy method for @learner
	def receive_accepted(acceptor_uid, proposal_id, accepted_value)
		r = @learner.receive_accepted(acceptor_uid, proposal_id, accepted_value)

		if @learner.complete?
			@on_resolution.call(@learner.accepted_proposal_id, @learner.accepted_value)
		end

		r
	end
end
