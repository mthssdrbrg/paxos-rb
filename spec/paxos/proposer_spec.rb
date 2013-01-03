require 'spec_helper'

module Paxos
	describe Proposer do

		let(:quorum_size) { 3 }
		let :proposer do
			Proposer.new('uid', quorum_size, 'foo')
		end

		describe '#prepare' do

			it 'returns correctly prepared proposal' do
				proposer.prepare.should == [1, 'uid']
			end

			it 'returns correct proposal second time' do
				proposer.prepare
				proposer.prepare.should == [2, 'uid']
			end

			it 'returns correct proposal after receiving external promise' do
				proposer.receive_promise('a', [5, 'ext'], nil, nil)
				proposer.prepare.should == [6, 'uid']
			end
		end

		describe '#receive_promise' do

			it 'returns proposal and value when received promises from quorum of acceptors' do
				proposer.prepare

				proposer.receive_promise('a', [1, 'uid'], nil, nil).should be_nil
				proposer.receive_promise('b', [1, 'uid'], nil, nil).should be_nil
				proposer.receive_promise('c', [1, 'uid'], nil, nil).should eq([[1, 'uid'], 'foo'])

				proposer.leader?.should be_true
			end

			it 'ignores promise with wrong proposal' do
				proposer.prepare

				proposer.receive_promise('a', [1, 'uid'], nil, nil).should be_nil
				proposer.receive_promise('b', [1, 'uid'], nil, nil).should be_nil
				proposer.receive_promise('c', [2, 'uid'], nil, nil).should be_nil
			end

			it 'returns newly proposed value when received promises from quorum of acceptors' do
				proposer.prepare
				proposer.prepare

				proposer.receive_promise('a', [2, 'uid'], nil, nil).should be_nil
				proposer.receive_promise('b', [2, 'uid'], 1, 'bar').should be_nil
				proposer.receive_promise('c', [2, 'uid'], nil, nil).should eq([[2, 'uid'], 'bar'])
			end

			it 'correctly handles multiple promises' do
				proposer.receive_promise('a', [5, 'other'], nil, nil)
				proposer.prepare

				proposer.receive_promise('a', [6, 'uid'], 1, 'abc').should be_nil
				proposer.receive_promise('b', [6, 'uid'], 3, 'bar').should be_nil
				proposer.receive_promise('c', [6, 'uid'], 2, 'def').should eq([[6, 'uid'], 'bar'])
			end

			it 'correctly handles duplicated promises' do
				proposer.receive_promise('a', [5, 'other'], nil, nil)
				proposer.prepare

				proposer.receive_promise('a', [6, 'uid'], 1, 'abc').should be_nil
				proposer.receive_promise('b', [6, 'uid'], 3, 'bar').should be_nil
				proposer.receive_promise('b', [6, 'uid'], 3, 'bar').should be_nil
				proposer.receive_promise('c', [6, 'uid'], 2, 'def').should eq([[6, 'uid'], 'bar'])
			end

			it 'correctly handles old / "expired" promises' do
				proposer.receive_promise('a', [5, 'other'], nil, nil)
				proposer.prepare

				proposer.receive_promise('a', [6, 'uid'], 1, 'abc').should be_nil
				proposer.receive_promise('b', [6, 'uid'], 3, 'bar').should be_nil
				proposer.receive_promise('c', [5, 'other'], 4, 'baz').should be_nil
				proposer.receive_promise('d', [6, 'uid'], 2, 'def').should eq([[6, 'uid'], 'bar'])
			end
		end
	end
end
