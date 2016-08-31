# coding: utf-8

require 'date'

module Sunscout
  module SolarLog
    # High-level binding to the SolarLog HTTP API
    # @example Basic usage
    #   require 'sunscout'
    #   sl = Sunscout::SolarLog::SolarLog.new('http://10.60.1.10', timezone: 'CEST')
    #   puts "AC power: #{ sl.power_ac }W (DC: #{ sl.power_dc }W, Efficiency #{ (sl.efficiency*100).round(0) }%)"
    #   puts "Remaining power: #{ sl.power_available }W"
    class SolarLog
      # Timestamp of the data.
      # @return [DateTime]
      attr_reader :time

      # AC power in W
      # @return [Fixnum]
      attr_reader :power_ac
      # DC power in W
      # @return [Fixnum]
      attr_reader :power_dc
      # Maximum DC power in W
      # @return [Fixnum]
      attr_reader :power_total

      # AC voltage in V
      # @return [Fixnum]
      attr_reader :voltage_ac
      # DC voltage in V
      # @return [Fixnum]
      attr_reader :voltage_dc

      # Today's yield in Wh
      # @return [Fixnum]
      attr_reader :yield_day
      # Yesterday's yield in WH
      # @return [Fixnum]
      attr_reader :yield_yesterday 
      # This month's yield in Wh
      # @return [Fixnum]
      attr_reader :yield_month 
      # This year's yield in Wh
      # @return [Fixnum]
      attr_reader :yield_year
      # Total yield in Wh
      # @return [Fixnum]
      attr_reader :yield_total

      # Current consumption in W
      # @return [Fixnum]
      attr_reader :consumption_ac
      # Today's consumption in Wh
      # @return [Fixnum]
      attr_reader :consumption_day 
      # Yesterday's consumption in Wh
      # @return [Fixnum]
      attr_reader :consumption_yesterday 
      # This month's consumption in Wh
      # @return [Fixnum]
      attr_reader :consumption_month 
      # This year's consumption in Wh
      # @return [Fixnum]
      attr_reader :consumption_year 
      # Total consumption in Wh
      # @return [Fixnum]
      attr_reader :consumption_total

      # Initialize a new instance of the class.
      # 
      # This also immediately queries data from the SolarLog API.
      #
      # @param host [String] URI of the SolarLog web interface
      # @param timezone [String] Timezone (or offset) which the SolarLog station resides in.
      #   If none is specified, assume UTC.
      def initialize(host, timezone: '+0000')
        client = Sunscout::SolarLog::Client.new(host)
        data = client.get_data

        # SolarLog returns the time a) without a timezone indicator and b) as whatever the station is configured.
        # Hence, the user has to specify what timezone it is in - otherwise we'll just fall back to UTC.
        time = "#{ data.fetch(:time) } #{ timezone }"
        @time = DateTime.strptime(time, '%d.%m.%y %H:%M:%s %Z')

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
      #   solar_log.power_available #=> -100
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

