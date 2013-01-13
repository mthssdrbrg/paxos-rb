require 'forwardable'

module Paxos
	class Node
		extend Forwardable

		def_delegators :@proposer, :prepare, :observe_proposal, :receive_promise, :proposal=
		def_delegators :@acceptor, :receive_accept_request

		def initialize(node_uid, quorum_size, messenger)
			@proposer = Proposer.new(node_uid, quorum_size, messenger)
			@acceptor = Acceptor.new(messenger)
			@learner = Learner.new(quorum_size, messenger)
		end

		def quorum_size=(new_quorum_size)
			@proposer.quorum_size = new_quorum_size
			@learner.quorum_size = new_quorum_size
		end

		def recover(messenger)
			@messenger = messenger
		end

		def receive_prepare(from_uid, proposal_id)
			@proposer.observe_proposal(from_uid, proposal_id)
			@acceptor.receive_prepare(from_uid, proposal_id)
		end
	end
end
