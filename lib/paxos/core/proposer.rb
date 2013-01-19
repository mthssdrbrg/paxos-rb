module Paxos
	module Core
		class Proposer

			attr_accessor :proposer_uid, :quorum_size

			def initialize(proposer_uid, quorum_size, messenger)
				@messenger 						= messenger
				@proposer_uid			 		= proposer_uid
				@quorum_size 					= quorum_size

				@proposed_value				= nil
				@proposal_id 					= nil
				@last_accepted_id			= nil
				@next_proposal_number = 1
				@promises_received		= Set.new
			end

			def proposal=(value)
				@proposed_value ||= value
			end

			def prepare
				@promises_received = Set.new
				@proposal_id = ProposalId.new(@next_proposal_number, @proposer_uid)

				@next_proposal_number += 1

				@messenger.send_prepare(@proposal_id)
			end

			def receive_promise(from_uid, proposal_id, previous_accepted_id, previous_accepted_value)

				if proposal_id != @proposal_id or @promises_received.include?(from_uid)
					return
				end

				@promises_received << from_uid

				if @previous_accepted_id > @last_accepted_id
					@last_accepted_id = @previous_accepted_id

					unless @previous_accepted_value.nil?
						@proposed_value = previous_accepted_value
					end
				end

				if @promises_received.length == @quorum_size
					unless @proposed_value.nil?
						@messenger.send_accept(@proposal_id, @proposed_value)
					end
				end
			end
		end
	end
end
