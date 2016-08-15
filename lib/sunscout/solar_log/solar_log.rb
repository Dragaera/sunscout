# coding: utf-8

require 'date'

module Sunscout
  module SolarLog
    class SolarLog
      attr_reader :time
      attr_reader :power_ac, :power_dc, :power_total
      attr_reader :voltage_ac, :voltage_dc
      attr_reader :yield_day, :yield_yesterday, :yield_month, :yield_year, :yield_total
      attr_reader :consumption_ac, :consumption_day, :consumption_yesterday, :consumption_month, :consumption_year, :consumption_total

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

      def efficiency
        return 0 if @power_dc == 0
        power_ac.to_f / power_dc
      end

      def alternator_loss
        power_dc - power_ac
      end

      def usage
        return 0 if @power_ac == 0
        consumption_ac.to_f / power_ac
      end

      def power_available
        power_ac - consumption_ac
      end

      def capacity
        return 0 if power_total == 0
        power_dc / power_total
      end
    end
  end
end

