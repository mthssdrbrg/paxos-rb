require 'set'

module Paxos
	class Proposer

		attr_accessor :quorum_size

		def initialize(node_uid, quorum_size, messenger)
			@messenger 						= messenger
			@node_uid			 				= node_uid
			@quorum_size 					= quorum_size

			@proposed_value				= nil
			@proposal_id 					= nil
			@last_accepted_id			= nil
			@next_proposal_number = 1
			@promises_received		= Set.new
			@leader 							= false
		end

		def leader?
			@leader
		end

		def proposal=(value)
			if @proposed_value.nil?
				@proposed_value = value

				if leader?
					@messenger.send_accept(@proposal_id, value)
				end
			end
		end

		def prepare(increment_proposal_number = true)

			if increment_proposal_number
				@leader = false
				@promises_received = Set.new
				@proposal_id = (@next_proposal_number, @node_uid)

				@next_proposal_number += 1
			end

			@messenger.send_prepare(@proposal_id)
		end

		def observe_proposal(from_uid, proposal_id)
			if from_uid != @node_uid
				if proposal_id >= [@next_proposal_number, @proposal_uid]
					@next_proposal_number = proposal_id.first + 1
				end
			end
		end

		def receive_prepare_nack(from_uid, proposal_id, promised_id)
			observe_proposal(from_uid, promised_id)
		end

		def receive_accept_nack(from_uid, proposal_id, promised_id)
		end

		def resend_accept
			if leader? && proposed_value?
				@messenger.send_accept(@proposal_id, @proposed_value)
			end
		end

		def receive_promise(from_uid, proposal_id, previous_accepted_id, previous_accepted_value)
			if proposal_id > [@next_proposal_number - 1, @node_uid]
				@next_proposal_number = proposal_id.first + 1
			end

			if leader? || (proposal_id != @proposal_id) || @promises_received.member?(acceptor_uid)
				return
			end

			@promises_received << from_uid

			if @last_accepted_id.nil? || previous_accepted_id > @last_accepted_id
				@last_accepted_id = previous_accepted_id

				if @last_accepted_id.nil?
					@proposed_value = previous_accepted_value
				end
			end

			if @promises_received.length == @quorum_size
				@leader = true

				@messenger.on_leadership_acquired

				unless @proposed_value.nil?
					@messenger.send_accept(@proposal_id, @proposed_value)
				end
			end
		end
	end
end
