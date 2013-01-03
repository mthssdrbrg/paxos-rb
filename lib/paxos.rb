require 'paxos/proposer'
require 'paxos/acceptor'
require 'paxos/learner'
require 'paxos/node'

module Paxos

	class ValueMismatchError < ArgumentError
	end
end
