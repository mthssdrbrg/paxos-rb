require 'paxos/messenger'
require 'paxos/proposer'
require 'paxos/acceptor'
require 'paxos/learner'
require 'paxos/node'

module Paxos

  class ProposalId < Struct.new(:number, :uid)
    include Comparable

    def <=>(other)
      return nil if other.nil? or not (other.respond_to?(:number) && other.respond_to?(:uid))

      if number > other.number
        1
      elsif number < other.number
        -1
      elsif number == other.number
        uid <=> other.uid
      end
    end
  end

	class ValueMismatchError < ArgumentError
	end
end
