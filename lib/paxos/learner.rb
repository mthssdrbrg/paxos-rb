class Learner

	def initialize(quorum_size)
		@proposals = {}
		@acceptors = {}
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

		if last_proposal != nil
			old_proposal = @proposals[last_proposal]
			old_proposal[1] -= 1
			if old_proposal[1].zero?
				@proposals.delete(last_proposal)
			end
		end

		unless @proposals.include?(proposal_id)
			@proposals[proposal_id] = [0, 0, accepted_value]
		end

		t = @proposals[proposal_id]

		raise ValueMismatchError, 'for single proposal' unless accepted_value == t[2]

		t[0] += 1
		t[1] += 1

		if t.first == @quorum_size
			@accepted_value = accepted_value
			@accepted_proposal_id = proposal_id
			@proposals.clear && @proposals = nil
			@acceptors.clear && @acceptors = nil
			@complete = true
		end

		@accepted_value
	end
end
