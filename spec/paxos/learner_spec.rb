require 'spec_helper'

module Paxos
	describe Learner do

		let(:quorum_size) { 3 }
		let :learner do
			Learner.new(quorum_size)
		end

		describe '#receive_accepted' do

			it 'is not complete if it has not learned from a quorum of acceptors' do
				learner.receive_accepted(1, [1, '1'], 'foo').should be_nil

				learner.complete?.should be_false
			end

			it 'is not complete if it has not learned from a quorum of acceptors' do
				learner.receive_accepted(1, [1, '1'], 'foo').should be_nil
				learner.receive_accepted(2, [1, '1'], 'foo').should be_nil

				learner.complete?.should be_false
			end

			it 'learns value after receiving accepted from a quorum of acceptors' do
				learner.receive_accepted(1, [1, '1'], 'foo').should be_nil
				learner.receive_accepted(2, [1, '1'], 'foo').should be_nil
				learner.receive_accepted(3, [1, '1'], 'foo').should eq('foo')

				learner.complete?.should be_true
			end

			it 'correctly handles duplicate proposal ids from acceptor(s)' do
				learner.receive_accepted(1, [1, '1'], 'foo').should be_nil
				learner.receive_accepted(2, [1, '1'], 'foo').should be_nil
				learner.receive_accepted(2, [1, '1'], 'foo').should be_nil
				learner.receive_accepted(2, [1, '1'], 'foo').should be_nil
				learner.receive_accepted(3, [1, '1'], 'foo').should eq('foo')

				learner.complete?.should be_true
			end

			it 'ignores old proposal from one acceptor' do
				learner.receive_accepted(1, [2, '2'], 'foo').should be_nil
				learner.receive_accepted(2, [2, '2'], 'foo').should be_nil
				learner.receive_accepted(3, [1, '1'], 'bar').should be_nil
				learner.receive_accepted(4, [2, '2'], 'foo').should eq('foo')

				learner.complete?.should be_true
			end

			it 'ignores old proposal when a newer one exists for same acceptor' do
				learner.receive_accepted(1, [2, '2'], 'foo').should be_nil
				learner.receive_accepted(2, [2, '2'], 'foo').should be_nil
				learner.receive_accepted(2, [1, '1'], 'bar').should be_nil
				learner.receive_accepted(4, [2, '2'], 'foo').should eq('foo')

				learner.complete?.should be_true
			end

			it 'overrides old proposal when given an updated one from same acceptor' do
				learner.receive_accepted(1, [1, '1'], 'bar').should be_nil
				learner.receive_accepted(1, [2, '2'], 'foo').should be_nil
				learner.receive_accepted(2, [2, '2'], 'foo').should be_nil
				learner.receive_accepted(3, [2, '2'], 'foo').should eq('foo')

				learner.complete?.should be_true
			end
		end
	end
end
