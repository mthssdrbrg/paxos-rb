require 'spec_helper'

module Paxos
	describe Acceptor do

		let :acceptor do
			Acceptor.new
		end

		describe '#receive_prepare' do

			it 'first' do
				acceptor.receive_prepare(1).should eq([1, nil, nil])
			end

			it 'no_value_two' do
				acceptor.receive_prepare(1)
				acceptor.receive_prepare(2).should eq([2, 1, nil])
			end

			it 'ignores old proposal' do # no value ignore old
				acceptor.receive_prepare(2)
				acceptor.receive_prepare(1).should be_nil
			end

			it 'value two' do
				acceptor.receive_prepare(1)
				acceptor.receive_accept_request(1, 'foo')
				acceptor.receive_prepare(2).should eq([2, 1, 'foo'])
			end

			it 'value ignore old' do
				acceptor.receive_prepare(2)
				acceptor.receive_accept_request(2, 'foo')
				acceptor.receive_prepare(1).should be_nil
			end

			it 'handles prepared accept' do # prepared accept
				acceptor.receive_prepare(1)
				acceptor.receive_accept_request(1, 'foo').should eq([1, 'foo'])
			end

			it 'handles unprepared accept' do # unprepared accept
				acceptor.receive_accept_request(1, 'foo').should eq([1, 'foo'])
			end

			it 'ignores accept with old proposal id' do # ignored accept
				acceptor.receive_prepare(5)
				acceptor.receive_accept_request(1, 'foo').should be_nil
			end

			it 'handles duplicated accepts' do # duplicte accept
				acceptor.receive_accept_request(1, 'foo').should eq([1, 'foo'])
				acceptor.receive_accept_request(1, 'foo').should eq([1, 'foo'])
			end

			it 'ignore old proposal after accept' do # ignore after accept
				acceptor.receive_accept_request(5, 'foo')
				acceptor.receive_prepare(1).should be_nil
			end
		end
	end
end
