module Paxos
	module Core
		module Messenger

			def send_prepare(proposal_id)
			end

			def send_promise(to_uid, proposal_id, previous_id, accepted_value)
			end

			def send_accept(proposal_id, proposal_value)
			end

			def send_accepted(to_uid, proposal_id, accepted_value)
			end

			def on_resolution(proposal_id, value)
			end
		end
	end
end
