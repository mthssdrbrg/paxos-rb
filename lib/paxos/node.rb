require 'forwardable'

module Paxos
	class Node
		extend Forwardable

		def_delegators :@proposer, :prepare, :observe_proposal, :receive_promise, :proposal=
		def_delegators :@acceptor, :receive_accept_request

		def initialize(proposer, acceptor, learner, &callback)
			@proposer = proposer
			@acceptor = acceptor
			@learner = learner
			@on_resolution = callback
		end

		def quorum_size=(new_quorum_size)
			@proposer.quorum_size = new_quorum_size
			@learner.quorum_size = new_quorum_size
		end

		# Required after de-serializing a Node object to re-establish
		# the resolution callback handler
		# TODO: check if this is necessary for Ruby
		def on_resolution_callback(&callback)
			@on_resolution = callback
		end

		# Proxy method for @acceptor
		def receive_prepare(proposal_id)
			@proposer.observe_proposal(proposal_id)
			@acceptor.receive_prepare(proposal_id)
		end

		# Proxy method for @learner
		def receive_accepted(acceptor_uid, proposal_id, accepted_value)
			result = @learner.receive_accepted(acceptor_uid, proposal_id, accepted_value)

			if @learner.complete?
				@on_resolution.call(@learner.accepted_proposal_id, @learner.accepted_value)
			end

			result
		end
	end
end
