require 'paxos/proposer'
require 'paxos/acceptor'
require 'paxos/learner'
require 'paxos/node'

module Paxos

	class ValueMismatchError < ArgumentError
	end

	module NodeFactory

		def self.create!(proposer_uid, leader_uid, quorum_size, &resolution_callback)
			proposer = Proposer.new(proposer_uid, quorum_size)
			acceptor = Acceptor.new
			learner = Learner.new(quorum_size)

			Node.new(proposer, acceptor, learner, resolution_callback)
		end
	end
end
