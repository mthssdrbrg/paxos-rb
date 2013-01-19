require 'spec_helper'

module Paxos
  module Core

    describe ProposalId do

      describe '<=>' do

        let(:proposal_id) { ProposalId.new(0, '0') }
        let(:other_proposal_id) { ProposalId.new(1, '1') }

        it 'returns nil if other object is not comparable' do
          (proposal_id <=> nil).should be_nil
          (proposal_id <=> Object.new).should be_nil
        end

        it 'returns 1 if self is greater than other' do
          (other_proposal_id <=> proposal_id).should eq(1)
        end

        it 'returns -1 if self is less than other' do
          (proposal_id <=> other_proposal_id).should eq(-1)
        end

        it 'returns 0 if equal' do
          (proposal_id <=> proposal_id).should be_zero
          (other_proposal_id <=> other_proposal_id).should be_zero
        end
      end
    end
  end
end
