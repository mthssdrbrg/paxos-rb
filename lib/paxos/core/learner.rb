module Paxos
	module Core
		class Learner

			attr_accessor :quorum_size
			attr_reader :final_value, :final_proposal_id

			def initialize(quorum_size, messenger)
				@quorum_size 			 = quorum_size
				@messenger				 = messenger

				@proposals 				 = {} # maps proposal_id => [accept_count, retain_count, value]
				@acceptors 				 = {} # maps acceptor_uid => last_accepted_proposal_id
				@final_value 			 = nil
				@final_proposal_id = nil
			end

			def complete?
				!!@final_proposal_id
			end

			def receive_accepted(from_uid, proposal_id, accepted_value)
				return unless @final_value.nil?

				if @proposals.nil?
					@proposals = {}
					@acceptors = {}
				end

				last_proposal = @acceptors[from_uid]

				return unless proposal_id > last_proposal # old message

				@acceptors[from_uid] = proposal_id

				decrement_retain_count(last_proposal) unless last_proposal.nil?

				unless @proposals.include?(proposal_id)
					@proposals[proposal_id] = [0, 0, accepted_value]
				end

				target = @proposals[proposal_id]

				raise ValueMismatchError, 'for single proposal' unless accepted_value == target[2]

				target[0] += 1
				target[1] += 1

				if target.first == @quorum_size
					reached_consensus(proposal_id, accepted_value)
				end
			end

			private

			def decrement_retain_count(proposal_id)
				old_proposal = @proposals[proposal_id]
				old_proposal[1] -= 1

				if old_proposal[1].zero?
					@proposals.delete(proposal_id)
				end
			end

			def reached_consensus(proposal_id, accepted_value)
				@final_value = accepted_value
				@final_proposal_id = proposal_id
				@proposals.clear && @proposals = nil
				@acceptors.clear && @acceptors = nil

				@messenger.on_resolution(proposal_id, accepted_value)
			end
		end
	end
end
