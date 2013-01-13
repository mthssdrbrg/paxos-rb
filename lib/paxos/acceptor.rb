module Paxos
	module Acceptor

		def initialize(messenger)
			@messenger 			= messenger

			@promised_id 		= nil
			@accepted_value = nil
			@accepted_id 		= nil
			@previous_id 		= nil
		end

		def receive_prepare(from_uid, proposal_id)
			if (proposal_id <=> @promised_id) == 0
				# Duplicate accepted proposal
				@messenger.send_promise(from_uid, proposal_id, @previous_id, @accepted_value)
			elsif @promised_id.nil? || proposal_id > @promised_id
				@previous_id = @promised_id
				@promised_id = proposal_id

				@messenger.send_promise(from_uid, proposal_id, @previous_id, @accepted_value)
			else
				@messenger.send_prepare_nack(from_uid, proposal_id, @promised_id)
			end
		end

		def receive_accept_request(from_uid, proposal_id, value)
			if @promised_id.nil? || proposal_id >= @promised_id
				@accepted_value = value
				@promised_id = proposal_id

				@messenger.send_accepted(from_uid, proposal_id, @accepted_value)
			else
				@messenger.send_accept_nack(from_uid, proposal_id, @promised_id)
			end
		end
	end
end
