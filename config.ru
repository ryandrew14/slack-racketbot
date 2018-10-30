# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

run Rails.application

Dynopoker.configure do |config|
  config.address = 'https://rktbot.kyle.tools/'
  config.poke_frequency = 300 # default is 1800s (30min)
end
