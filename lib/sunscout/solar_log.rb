# coding: utf-8

require_relative 'solar_log/client'
require_relative 'solar_log/solar_log'

module Sunscout
  # Classes to interact with SolarLog HTTP API. 
  # 
  # - {SolarLog::Client} Low-Level client which returns API data directly, remapped to human-readable keys
  # - {SolarLog::SolarLog} High-level client, which offers various convenience functions.
  # @example
  #   #!/usr/bin/env ruby
  #   # coding: utf-8
  #   
  #   require 'sunscout'
  #   
  #   puts 'Querying data from SolarLog API'
  #   solar_log = Sunscout::SolarLog::SolarLog.new('http://10.0.0.10')
  #   
  #   puts "Data from: #{ solar_log.time.iso8601 }"
  #   puts "AC Power: #{ solar_log.power_ac }W (DC Power: #{ solar_log.power_dc }W, #{ (solar_log.efficiency*100).round(0) }% efficiency, #{ solar_log.alternator_loss }W loss)"
  #   
  #   puts "Current usage: #{ solar_log.consumption_ac }W (#{ (solar_log.usage*100).round(0) }%)"
  module SolarLog
  end
end
