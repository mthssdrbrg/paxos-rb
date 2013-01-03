require 'spec_helper'

module Paxos
	describe Proposer do

		let :proposer do
			Proposer.new('uid', 3, 'foo')
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

			it 'empty' do
				proposer.prepare

				proposer.receive_promise('a', [1, 'uid'], nil, nil).should be_nil
				proposer.receive_promise('b', [1, 'uid'], nil, nil).should be_nil
				proposer.receive_promise('c', [1, 'uid'], nil, nil).should eq([[1, 'uid'], 'foo'])
			end

			it 'ignore' do
				proposer.prepare

				proposer.receive_promise('a', [1, 'uid'], nil, nil).should be_nil
				proposer.receive_promise('b', [1, 'uid'], nil, nil).should be_nil
				proposer.receive_promise('c', [2, 'uid'], nil, nil).should be_nil
			end

			it 'single' do
				proposer.prepare
				proposer.prepare

				proposer.receive_promise('a', [2, 'uid'], nil, nil).should be_nil
				proposer.receive_promise('b', [2, 'uid'], 1, 'bar').should be_nil
				proposer.receive_promise('c', [2, 'uid'], nil, nil).should eq([[2, 'uid'], 'bar'])
			end

			it 'multi' do
				proposer.receive_promise('a', [5, 'other'], nil, nil)
				proposer.prepare

				proposer.receive_promise('a', [6, 'uid'], 1, 'abc').should be_nil
				proposer.receive_promise('b', [6, 'uid'], 3, 'bar').should be_nil
				proposer.receive_promise('c', [6, 'uid'], 2, 'def').should eq([[6, 'uid'], 'bar'])
			end

			it 'duplicate' do
				proposer.receive_promise('a', [5, 'other'], nil, nil)
				proposer.prepare

				proposer.receive_promise('a', [6, 'uid'], 1, 'abc').should be_nil
				proposer.receive_promise('b', [6, 'uid'], 3, 'bar').should be_nil
				proposer.receive_promise('b', [6, 'uid'], 3, 'bar').should be_nil
				proposer.receive_promise('c', [6, 'uid'], 2, 'def').should eq([[6, 'uid'], 'bar'])
			end

			it 'old' do
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
