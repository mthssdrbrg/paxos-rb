require 'spec_helper'

module Paxos
	describe Learner do

		let :learner do
			Learner.new(3)
		end

		describe '#receive_accepted' do

			it 'one' do
				learner.receive_accepted(1, [1, '1'], 'foo').should be_nil
			end

			it 'two' do
				learner.receive_accepted(1, [1, '1'], 'foo').should be_nil
				learner.receive_accepted(2, [1, '1'], 'foo').should be_nil
			end

			it 'three' do
				learner.receive_accepted(1, [1, '1'], 'foo').should be_nil
				learner.receive_accepted(2, [1, '1'], 'foo').should be_nil
				learner.receive_accepted(3, [1, '1'], 'foo').should eq('foo')
			end

			it 'duplicates' do
				learner.receive_accepted(1, [1, '1'], 'foo').should be_nil
				learner.receive_accepted(2, [1, '1'], 'foo').should be_nil
				learner.receive_accepted(2, [1, '1'], 'foo').should be_nil
				learner.receive_accepted(2, [1, '1'], 'foo').should be_nil
				learner.receive_accepted(3, [1, '1'], 'foo').should eq('foo')
			end

			it 'ignore one' do
				learner.receive_accepted(1, [2, '2'], 'foo').should be_nil
				learner.receive_accepted(2, [2, '2'], 'foo').should be_nil
				learner.receive_accepted(3, [1, '1'], 'bar').should be_nil
				learner.receive_accepted(4, [2, '2'], 'foo').should eq('foo')
			end

			it 'ignore old' do
				learner.receive_accepted(1, [2, '2'], 'foo').should be_nil
				learner.receive_accepted(2, [2, '2'], 'foo').should be_nil
				learner.receive_accepted(2, [1, '1'], 'bar').should be_nil
				learner.receive_accepted(4, [2, '2'], 'foo').should eq('foo')
			end

			it 'override old' do
				learner.receive_accepted(1, [1, '1'], 'bar').should be_nil
				learner.receive_accepted(1, [2, '2'], 'foo').should be_nil
				learner.receive_accepted(2, [2, '2'], 'foo').should be_nil
				learner.receive_accepted(3, [2, '2'], 'foo').should eq('foo')				
			end
		end
	end
end
