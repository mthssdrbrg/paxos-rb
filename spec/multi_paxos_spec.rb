require 'spec_helper'

describe MultiPaxos do

	describe '#receive_action' do

		it 'generates correct (proxy) methods' do
			multi_paxos = MultiPaxos.new(Object.new)

			multi_paxos.should respond_to(:receive_promise)
			multi_paxos.should respond_to(:receive_prepare)
			multi_paxos.should respond_to(:receive_accept_request)
			multi_paxos.should respond_to(:receive_accepted)
		end
	end
end
