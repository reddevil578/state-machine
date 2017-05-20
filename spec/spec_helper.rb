require 'pry'
require 'state_machine'
Dir['./spec/support/policies/*.rb'].each { |f| require f }
Dir['./spec/support/*.rb'].each { |f| require f }
