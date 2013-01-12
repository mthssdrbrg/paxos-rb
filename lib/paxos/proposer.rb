require 'set'

module Paxos
	class Proposer

		def initialize(proposer_uid, quorum_size, proposed_value = nil)
			@proposer_uid = proposer_uid
			@proposal_id = nil
			@next_proposal_number = 1
			@accepted_id = nil
			@replied = Set.new
			@value = proposed_value
			@quorum_size = quorum_size
			@leader = false
		end

		def leader?
			@leader
		end

		def proposal=(value)
			@value ||= value
		end

		def prepare
			@leader = false
			@replied = Set.new

			@proposal_id = [@next_proposal_number, @proposer_uid]

			@next_proposal_number += 1

			@proposal_id
		end

		def observe_proposal(proposal_id)
			if proposal_id >= [@next_proposal_number, @proposal_uid]
				@next_proposal_number = proposal_id.first + 1
			end
		end

		def receive_promise(acceptor_uid, proposal_id, previous_proposal_id, previous_proposal_value)
			if (proposal_id <=> [@next_proposal_number, @proposer_uid]) >= 0
				@next_proposal_number = proposal_id.first + 1
			end

			if leader? || (proposal_id != @proposal_id) || @replied.member?(acceptor_uid)
				return
			end

			@replied << acceptor_uid

			proposal_comparison = (previous_proposal_id <=> @accepted_id)
			if proposal_comparison.nil? || proposal_comparison > 0
				@accepted_id = previous_proposal_id

				unless previous_proposal_id.nil?
					@value = previous_proposal_value
				end
			end

			if @replied.length == @quorum_size
				@leader = true
				return @proposal_id, @value
			end
		end
	end
end
