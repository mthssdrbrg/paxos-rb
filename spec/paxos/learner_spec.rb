require 'spec_helper'

module Paxos
	describe Learner do

		let(:messenger) { mock(Messenger) }
		let(:quorum_size) { 2 }
		let :learner do
			Learner.new(quorum_size, messenger)
		end

		context 'resolution' do

			it '#basic_resolution' do
				messenger.should_receive(:on_resolution).with([1, 'A'], 'foo').once

				learner.receive_accepted('A', [1, 'A'], 'foo')
				learner.final_value.should be_nil
				learner.receive_accepted('B', [1, 'A'], 'foo')
				learner.final_value.should eq('foo')
				learner.final_proposal_id.should eq([1, 'A'])
			end

			it '#ignore_after_resolution' do
				messenger.should_receive(:on_resolution).with([1, 'A'], 'foo').once

				learner.receive_accepted('A', [1, 'A'], 'foo')
				learner.final_value.should be_nil
				learner.complete?.should_not be_true

				learner.receive_accepted('B', [1, 'A'], 'foo')
				learner.final_value.should eq('foo')
				learner.final_proposal_id.should eq([1, 'A'])

				learner.receive_accepted('A', [5, 'A'], 'bar')
				learner.receive_accepted('B', [5, 'A'], 'bar')
				learner.final_value.should eq('foo')
				learner.final_proposal_id.should eq([1, 'A'])
			end

			it '#ignore_duplicated_messages' do
				messenger.should_receive(:on_resolution).with([1, 'A'], 'foo').once

				learner.receive_accepted('A', [1, 'A'], 'foo')
				learner.final_value.should be_nil
				learner.receive_accepted('A', [1, 'A'], 'foo')
				learner.final_value.should be_nil
				learner.receive_accepted('B', [1, 'A'], 'foo')
				learner.final_value.should eq('foo')
				learner.final_proposal_id.should eq([1, 'A'])
			end

			it '#ignore_old_messages' do
				messenger.should_receive(:on_resolution).with([5, 'A'], 'foo').once

				learner.receive_accepted('A', [5, 'A'], 'foo')
				learner.final_value.should be_nil
				learner.receive_accepted('A', [1, 'A'], 'foo')
				learner.final_value.should be_nil
				learner.receive_accepted('B', [5, 'A'], 'foo')
				learner.final_value.should eq('foo')
				learner.final_proposal_id.should eq([5, 'A'])
			end

			it '#overwrite_old_messages' do
				messenger.should_receive(:on_resolution).with([5, 'A'], 'foo').once

				learner.receive_accepted('A', [1, 'A'], 'bar')
				learner.final_value.should be_nil
				learner.receive_accepted('B', [5, 'A'], 'foo')
				learner.final_value.should be_nil
				learner.receive_accepted('A', [5, 'A'], 'foo')
				learner.final_value.should eq('foo')
				learner.final_proposal_id.should eq([5, 'A'])
			end
		end

		# describe '#receive_accepted' do

		# 	it 'is not complete if it has not learned from a quorum of acceptors' do
		# 		messenger.should_receive(:)

		# 		learner.receive_accepted(1, [1, '1'], 'foo').should be_nil

		# 		learner.complete?.should be_false
		# 	end

		# 	it 'is not complete if it has not learned from a quorum of acceptors' do
		# 		learner.receive_accepted(1, [1, '1'], 'foo').should be_nil
		# 		learner.receive_accepted(2, [1, '1'], 'foo').should be_nil

		# 		learner.complete?.should be_false
		# 	end

		# 	it 'learns value after receiving accepted from a quorum of acceptors' do
		# 		learner.receive_accepted(1, [1, '1'], 'foo').should be_nil
		# 		learner.receive_accepted(2, [1, '1'], 'foo').should be_nil
		# 		learner.receive_accepted(3, [1, '1'], 'foo').should eq('foo')

		# 		learner.complete?.should be_true
		# 	end

		# 	it 'correctly handles duplicate proposal ids from acceptor(s)' do
		# 		learner.receive_accepted(1, [1, '1'], 'foo').should be_nil
		# 		learner.receive_accepted(2, [1, '1'], 'foo').should be_nil
		# 		learner.receive_accepted(2, [1, '1'], 'foo').should be_nil
		# 		learner.receive_accepted(2, [1, '1'], 'foo').should be_nil
		# 		learner.receive_accepted(3, [1, '1'], 'foo').should eq('foo')

		# 		learner.complete?.should be_true
		# 	end

		# 	it 'ignores old proposal from one acceptor' do
		# 		learner.receive_accepted(1, [2, '2'], 'foo').should be_nil
		# 		learner.receive_accepted(2, [2, '2'], 'foo').should be_nil
		# 		learner.receive_accepted(3, [1, '1'], 'bar').should be_nil
		# 		learner.receive_accepted(4, [2, '2'], 'foo').should eq('foo')

		# 		learner.complete?.should be_true
		# 	end

		# 	it 'ignores old proposal when a newer one exists for same acceptor' do
		# 		learner.receive_accepted(1, [2, '2'], 'foo').should be_nil
		# 		learner.receive_accepted(2, [2, '2'], 'foo').should be_nil
		# 		learner.receive_accepted(2, [1, '1'], 'bar').should be_nil
		# 		learner.receive_accepted(4, [2, '2'], 'foo').should eq('foo')

		# 		learner.complete?.should be_true
		# 	end

		# 	it 'overrides old proposal when given an updated one from same acceptor' do
		# 		learner.receive_accepted(1, [1, '1'], 'bar').should be_nil
		# 		learner.receive_accepted(1, [2, '2'], 'foo').should be_nil
		# 		learner.receive_accepted(2, [2, '2'], 'foo').should be_nil
		# 		learner.receive_accepted(3, [2, '2'], 'foo').should eq('foo')

		# 		learner.complete?.should be_true
		# 	end
		# end
	end
end
