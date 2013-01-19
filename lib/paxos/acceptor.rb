module Paxos
	class Acceptor

		attr_reader :promised_id, :accepted_value, :accepted_id, :previous_id

		def initialize(messenger)
			@messenger 			= messenger

			@promised_id 		= nil
			@accepted_value = nil
			@accepted_id 		= nil
		end

		def receive_prepare(from_uid, proposal_id)
			if proposal_id == @promised_id
				# Duplicate accepted proposal
				@messenger.send_promise(from_uid, proposal_id, @accepted_id, @accepted_value)
			elsif @promised_id.nil? || proposal_id > @promised_id
				@promised_id = proposal_id
				@messenger.send_promise(from_uid, proposal_id, @previous_id, @accepted_value)
			end
		end

		def receive_accept_request(from_uid, proposal_id, value)
			if @promised_id.nil? || proposal_id >= @promised_id
				@promised_id 		= proposal_id
				@accepted_id 		= proposal_id
				@accepted_value = value
				@messenger.send_accepted(proposal_id, @accepted_value)
			end
		end
	end
end
