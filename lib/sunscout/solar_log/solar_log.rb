# coding: utf-8

require 'date'

module Sunscout
  module SolarLog
    # High-level binding to the SolarLog HTTP API
    # @example Basic usage
    #   require 'sunscout'
    #   sl = Sunscout::SolarLog::SolarLog.new('http://10.60.1.10')
    #   puts "AC power: #{ sl.power_ac }W (DC: #{ sl.power_dc }W, Efficiency #{ (sl.efficiency*100).round(0) }%)"
    #   puts "Remaining power: #{ sl.power_available }W"
    class SolarLog
      # @!attribute [r] time
      #   @return [DateTime] Timestamp of the data.
      attr_reader :time
      attr_reader :power_ac, :power_dc, :power_total
      attr_reader :voltage_ac, :voltage_dc
      attr_reader :yield_day, :yield_yesterday, :yield_month, :yield_year, :yield_total
      attr_reader :consumption_ac, :consumption_day, :consumption_yesterday, :consumption_month, :consumption_year, :consumption_total

      # Initialize a new instance of the class.
      # @param host [String] URI of the SolarLog web interface
      def initialize(host)
        client = Sunscout::SolarLog::Client.new(host)
        data = client.get_data

        @time = DateTime.strptime(data.fetch(:time), '%d.%m.%y %H:%M:%s')

        @power_ac    = data.fetch :power_ac
        @power_dc    = data.fetch :power_dc
        @power_total = data.fetch :power_total

        @voltage_ac = data.fetch :voltage_ac
        @voltage_dc = data.fetch :voltage_dc

        @yield_day       = data.fetch :yield_day
        @yield_yesterday = data.fetch :yield_yesterday
        @yield_month     = data.fetch :yield_month
        @yield_year      = data.fetch :yield_year
        @yield_total     = data.fetch :yield_total

        @consumption_ac        = data.fetch :consumption_ac
        @consumption_day       = data.fetch :consumption_day
        @consumption_yesterday = data.fetch :consumption_yesterday
        @consumption_month     = data.fetch :consumption_month
        @consumption_year      = data.fetch :consumption_year
        @consumption_total     = data.fetch :consumption_total
      end

      # Efficiency of DC to AC conversion.
      # @return [Float] Efficiency as percentage between 0 and 1.
      #
      # @example
      #   solar_log.power_ac #=> 94
      #   solar_log.power_dc #=> 100
      #   solar_log.efficiency #=> 0.94
      def efficiency
        return 0 if @power_dc == 0
        power_ac.to_f / power_dc
      end

      # Loss of DC to AC conversion.
      # @return [Fixnum] Loss of alternator in Watt.
      #
      # @example
      #   solar_log.power_ac #=> 94
      #   solar_log.power_dc #=> 100
      #   solar_log.alternator_loss #=> 6
      def alternator_loss
        power_dc - power_ac
      end

      # Usage of AC power.
      # @return [Float] Usage of AC power as percentage. >1 if more power consumed than generated.
      #
      # @example Usage <100%
      #   solar_log.consumption_ac #=> 50
      #   solar_log.power_ac #=> 100
      #   solar_log.usage #=> 0.5
      #
      # @example Usage >100%
      #   solar_log.consumption_ac #=> 200
      #   solar_log.power_ac #=> 100
      #   solar_log.usage #=> 2
      def usage
        return 0 if @power_ac == 0
        consumption_ac.to_f / power_ac
      end

      # Surplus AC power.
      # @return [Fixnum] Surplus AC power in Watt. Negative if more power consumed than generated.
      #
      # @example Usage <100%
      #   solar_log.consumption_ac #=> 50
      #   solar_log.power_ac #=> 100
      #   solar_log.power_available #=> 50
      #
      # @example Usage >100%
      #   solar_log.consumption_ac #=> 200
      #   solar_log.power_ac #=> 100
      #   solar_log.power_available #=> --100
      def power_available
        power_ac - consumption_ac
      end

      # Capacity of peak power generation.
      # @return [Float] Percentage of peak power generation.
      #
      # @example
      #   solar_log.power_dc #=> 8000
      #   solar_log.power_total #=> 10000
      #   solar_log.capacity #=> 0.8
      def capacity
        return 0 if power_total == 0
        power_dc / power_total
      end
    end
  end
end

