class Learner

	def initialize(quorum_size)
		@proposals = {} # maps proposal_id => [accept_count, retain_count, value]
		@acceptors = {} # maps acceptor_uid => last_accepted_proposal_id
		@quorum_size = quorum_size

		@accepted_value = nil
		@accepted_proposal_id = nil
		@complete = false
	end

	def complete?
		@complete
	end

	def receive_accepted(acceptor_uid, proposal_id, accepted_value)
		return @accepted_value unless @accepted_value.nil?

		last_proposal = @acceptors[acceptor_uid]

		return if !last_proposal.nil? && !((proposal_id <=> last_proposal) > 0) # old message

		@acceptors[acceptor_uid] = proposal_id

		decrement_retain_count(last_proposal) unless last_proposal.nil?

		unless @proposals.include?(proposal_id)
			@proposals[proposal_id] = [0, 0, accepted_value]
		end

		target = @proposals[proposal_id]

		raise ValueMismatchError, 'for single proposal' unless accepted_value == target[2]

		target[0] += 1
		target[1] += 1

		if target.first == @quorum_size # extract to own method
			reached_consensus(accepted_value, proposal_id)
		end

		@accepted_value
	end

	private

	def reached_consensus(accepted_value, proposal_id)
		@accepted_value = accepted_value
		@accepted_proposal_id = proposal_id
		@proposals.clear && @proposals = nil
		@acceptors.clear && @acceptors = nil
		@complete = true
	end

	def decrement_retain_count(proposal_id)
		old_proposal = @proposals[proposal_id]
		old_proposal[1] -= 1

		if old_proposal[1].zero?
			@proposals.delete(proposal_id)
		end
	end
end
