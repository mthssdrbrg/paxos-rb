require 'spec_helper'

module Paxos
	describe Learner do

		let(:messenger) { mock(Messenger) }
		let(:quorum_size) { 2 }
		let :learner do
			Learner.new(quorum_size, messenger)
		end

		context 'receiving accepted from quorum of acceptors' do

			it '#basic_resolution' do
				messenger.should_receive(:on_resolution).with([1, 'A'], 'foo').once

				learner.receive_accepted('A', [1, 'A'], 'foo')
				learner.final_value.should be_nil
				learner.receive_accepted('B', [1, 'A'], 'foo')

				learner.complete?.should be_true

				learner.final_value.should eq('foo')
				learner.final_proposal_id.should eq([1, 'A'])
			end

			it '#ignore_after_resolution' do
				messenger.should_receive(:on_resolution).with([1, 'A'], 'foo').once

				learner.receive_accepted('A', [1, 'A'], 'foo')
				learner.final_value.should be_nil
				learner.complete?.should_not be_true

				learner.receive_accepted('B', [1, 'A'], 'foo')

				learner.complete?.should be_true
				learner.final_value.should eq('foo')
				learner.final_proposal_id.should eq([1, 'A'])

				learner.receive_accepted('A', [5, 'A'], 'bar')
				learner.receive_accepted('B', [5, 'A'], 'bar')

				learner.complete?.should be_true
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

				learner.complete?.should be_true
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

				learner.complete?.should be_true
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

				learner.complete?.should be_true
				learner.final_value.should eq('foo')
				learner.final_proposal_id.should eq([5, 'A'])
			end
		end
	end
end
