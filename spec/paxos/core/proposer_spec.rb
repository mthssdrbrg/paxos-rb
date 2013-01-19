require 'spec_helper'

module Paxos
	describe Proposer do

		let(:quorum_size) { 3 }
		let(:messenger) { mock(Messenger) }
		let :proposer do
			Proposer.new('A', quorum_size, messenger)
		end

		describe '#prepare' do

			it 'sends correctly prepared proposal' do
				messenger.should_receive(:send_prepare).with([1, 'A']).once

				proposer.prepare
			end

			it 'sends correct proposal second time' do
				messenger.should_receive(:send_prepare).with([1, 'A']).once.ordered
				messenger.should_receive(:send_prepare).with([2, 'A']).once.ordered

				proposer.prepare
				proposer.prepare
			end

			it 'sends correct proposal after receiving external promise' do
				messenger.should_receive(:send_prepare).with([6, 'A']).once

				proposer.receive_promise('a', [5, 'ext'], nil, nil)
				proposer.prepare
			end
		end

		describe '#receive_promise' do

			before(:each) do
				messenger.stub(:send_prepare)
			end

			it 'sends proposal and value when received promises from quorum of acceptors' do
				messenger.should_receive(:send_accept).with([1, 'A'], 'foo').once
				messenger.should_receive(:on_leadership_acquired).once

				proposer.prepare

				proposer.receive_promise('a', [1, 'A'], nil, 'foo')
				proposer.receive_promise('b', [1, 'A'], nil, 'foo')
				proposer.receive_promise('c', [1, 'A'], nil, 'foo')

				proposer.leader?.should be_true
			end

			it 'ignores promise with incorrect proposal' do
				messenger.should_not_receive(:send_accept).with(any_args)
				proposer.prepare

				proposer.receive_promise('a', [1, 'A'], nil, nil)
				proposer.receive_promise('b', [1, 'A'], nil, nil)
				proposer.receive_promise('c', [2, 'A'], nil, nil)
			end

			it 'sends newly proposed value when received promises from quorum of acceptors' do
				messenger.should_receive(:on_leadership_acquired).once.ordered
				messenger.should_receive(:send_accept).with([2, 'A'], 'bar').once.ordered

				proposer.prepare
				proposer.prepare

				proposer.receive_promise('a', [2, 'A'], nil, nil)
				proposer.receive_promise('b', [2, 'A'], 1, 'bar')
				proposer.receive_promise('c', [2, 'A'], nil, nil)
			end

			it 'correctly handles multiple promises' do
				messenger.should_receive(:on_leadership_acquired).once.ordered
				messenger.should_receive(:send_accept).with([6, 'A'], 'bar').once.ordered

				proposer.receive_promise('a', [5, 'B'], nil, nil)
				proposer.prepare

				proposer.receive_promise('a', [6, 'A'], 1, 'abc') # .should be_nil
				proposer.receive_promise('b', [6, 'A'], 3, 'bar') # .should be_nil
				proposer.receive_promise('c', [6, 'A'], 2, 'def') # .should eq([[6, 'uid'], 'bar'])
			end

			it 'correctly handles duplicated promises' do
				messenger.should_receive(:on_leadership_acquired).once.ordered
				messenger.should_receive(:send_accept).with([6, 'A'], 'bar').once.ordered

				proposer.receive_promise('a', [5, 'B'], nil, nil)
				proposer.prepare

				proposer.receive_promise('a', [6, 'A'], 1, 'abc')
				proposer.receive_promise('b', [6, 'A'], 3, 'bar')
				proposer.receive_promise('b', [6, 'A'], 3, 'bar')
				proposer.receive_promise('c', [6, 'A'], 2, 'def')
			end

			it 'correctly handles old / "expired" promises' do
				messenger.should_receive(:on_leadership_acquired).once.ordered
				messenger.should_receive(:send_accept).with([6, 'A'], 'bar').once.ordered

				proposer.receive_promise('a', [5, 'B'], nil, nil)
				proposer.prepare

				proposer.receive_promise('a', [6, 'A'], 1, 'abc')
				proposer.receive_promise('b', [6, 'A'], 3, 'bar')
				proposer.receive_promise('c', [5, 'B'], 4, 'baz')
				proposer.receive_promise('d', [6, 'A'], 2, 'def')
			end
		end
	end
end
