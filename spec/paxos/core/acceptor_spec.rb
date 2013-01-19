require 'spec_helper'

module Paxos
	describe Acceptor do

		let(:messenger) { mock(Messenger) }
		let :acceptor do
			Acceptor.new(messenger)
		end

		describe '#receive_prepare' do

			it 'sends correct values' do
				messenger.should_receive(:send_promise).with('A', 1, nil, nil).once

				acceptor.receive_prepare('A', 1)
			end

			it 'sends correct promised_id and previous_id second time' do
				messenger.should_receive(:send_promise).with('A', 1, nil, nil).once.ordered
				messenger.should_receive(:send_promise).with('A', 2, 1, nil).once.ordered

				acceptor.receive_prepare('A', 1)
				acceptor.receive_prepare('A', 2)
			end

			it 'sends nack for old proposal_id' do
				messenger.should_receive(:send_promise).with('A', 2, nil, nil).once.ordered
				messenger.should_receive(:send_prepare_nack).with('A', 1, 2).once.ordered

				acceptor.receive_prepare('A', 2)
				acceptor.receive_prepare('A', 1)
			end
		end

		describe '#receive_accept_request' do

			it 'sends accepted value and correct promised_id and previous_id' do
				messenger.should_receive(:send_promise).with('A', 1, nil, nil).once.ordered
				messenger.should_receive(:send_accepted).with('A', 1, 'foo').once.ordered
				messenger.should_receive(:send_promise).with('A', 2, 1, 'foo').once.ordered

				acceptor.receive_prepare('A', 1)
				acceptor.receive_accept_request('A', 1, 'foo')
				acceptor.receive_prepare('A', 2)
			end

			it 'ignores old proposal id' do
				messenger.should_receive(:send_promise).with('A', 2, nil, nil).once.ordered
				messenger.should_receive(:send_accepted).with('A', 2, 'foo').once.ordered
				messenger.should_receive(:send_prepare_nack).with('A', 1, 2).once.ordered

				acceptor.receive_prepare('A', 2)
				acceptor.receive_accept_request('A', 2, 'foo')
				acceptor.receive_prepare('A', 1)
			end

			it 'handles prepared accept request' do
				messenger.should_receive(:send_promise).with('A', 1, nil, nil).once.ordered
				messenger.should_receive(:send_accepted).with('A', 1, 'foo').once.ordered

				acceptor.receive_prepare('A', 1)
				acceptor.receive_accept_request('A', 1, 'foo')
			end

			it 'handles unprepared accept request' do
				messenger.should_receive(:send_accepted).with('A', 1, 'foo').once.ordered

				acceptor.receive_accept_request('A', 1, 'foo')
			end

			it 'ignores accept request with old proposal id' do
				messenger.should_receive(:send_promise).with('A', 5, nil, nil).once.ordered
				messenger.should_receive(:send_accept_nack).with('A', 1, 5).once.ordered

				acceptor.receive_prepare('A', 5)
				acceptor.receive_accept_request('A', 1, 'foo')
			end

			it 'handles duplicated accept requests' do
				messenger.should_receive(:send_accepted).with('A', 1, 'foo').twice.ordered

				acceptor.receive_accept_request('A', 1, 'foo')
				acceptor.receive_accept_request('A', 1, 'foo')
			end

			it 'ignores old proposal after accept' do
				messenger.should_receive(:send_accepted).with('A', 5, 'foo').once.ordered
				messenger.should_receive(:send_prepare_nack).with('A', 1, 5).once.ordered

				acceptor.receive_accept_request('A', 5, 'foo')
				acceptor.receive_prepare('A', 1)
			end
		end
	end
end
