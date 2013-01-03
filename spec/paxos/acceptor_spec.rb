require 'spec_helper'

module Paxos
	describe Acceptor do

		let :acceptor do
			Acceptor.new
		end

		describe '#receive_prepare' do

			it 'returns correct values' do
				acceptor.receive_prepare(1).should eq([1, nil, nil])
			end

			it 'returns correct promised_id and previous_id second time' do
				acceptor.receive_prepare(1)
				acceptor.receive_prepare(2).should eq([2, 1, nil])
			end

			it 'ignores old proposal_id' do
				acceptor.receive_prepare(2)
				acceptor.receive_prepare(1).should be_nil
			end
		end

		describe '#receive_accept_request' do

			it 'returns accepted value and correct promised_id and previous_id' do
				acceptor.receive_prepare(1)
				acceptor.receive_accept_request(1, 'foo')
				acceptor.receive_prepare(2).should eq([2, 1, 'foo'])
			end

			it 'ignores old proposal id' do
				acceptor.receive_prepare(2)
				acceptor.receive_accept_request(2, 'foo')
				acceptor.receive_prepare(1).should be_nil
			end

			it 'handles prepared accept request' do
				acceptor.receive_prepare(1)
				acceptor.receive_accept_request(1, 'foo').should eq([1, 'foo'])
			end

			it 'handles unprepared accept request' do
				acceptor.receive_accept_request(1, 'foo').should eq([1, 'foo'])
			end

			it 'ignores accept request with old proposal id' do
				acceptor.receive_prepare(5)
				acceptor.receive_accept_request(1, 'foo').should be_nil
			end

			it 'handles duplicated accept requests' do
				acceptor.receive_accept_request(1, 'foo').should eq([1, 'foo'])
				acceptor.receive_accept_request(1, 'foo').should eq([1, 'foo'])
			end

			it 'ignores old proposal after accept' do
				acceptor.receive_accept_request(5, 'foo')
				acceptor.receive_prepare(1).should be_nil
			end
		end
	end
end
