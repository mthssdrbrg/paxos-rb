$: << File.expand_path('../../lib', __FILE__)

require 'paxos'
require 'multi_paxos'

RSpec.configure do |config|
	config.color_enabled = true
end
