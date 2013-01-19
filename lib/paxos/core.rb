require 'set'

require 'paxos/core/proposer'
require 'paxos/core/acceptor'
require 'paxos/core/learner'
require 'paxos/core/messenger'

module Paxos
  module Core

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
end
