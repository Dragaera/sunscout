# coding: utf-8

require 'json'
require 'net/http'
require 'uri'

REQUEST_QUERY = 'getjp'
REQUEST_PAYLOAD = { 801 => { 170 => nil } }

module Sunscout
  module SolarLog
    # Low-level binding to the SolarLog HTTP API
    # @example Basic usage
    #   require 'sunscout'
    #   c = Sunscout::SolarLog::Client.new('http://10.60.1.10')
    #   data = c.get_data()
    #   puts "Current power output: #{ data[:power_ac] }W"
    class Client
      # Initialize a new instance of the class.
      # @param host [String] URI of the SolarLog web interface. 
      def initialize(host)
        @host = host
      end

      # Retrieve data from the HTTP API.
      # @return [Hash<Symbol, String|Integer>] Hash containing retrieved data
      def get_data
        uri = build_uri
        req = build_request(uri)
        data = send_request(req, uri)

        data
      end

      private
      # Create URI of HTTP endpoint
      def build_uri
        URI("#{ @host }/#{ REQUEST_QUERY }")
      end 

      # Build HTTP POST request
      # @param uri [URI] URI of HTTP endpoint
      def build_request(uri)
        req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
        req.body = JSON.dump(REQUEST_PAYLOAD)

        req
      end

      # Send HTTP request to URI
      # @param req [Net::HTTP::Post] HTTP request
      # @param uri [URI] URI of HTTP endpoint
      # @return [Hash] Raw data retrieved by HTTP API
      def send_request(req, uri)
        res = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(req)
        end

        # Todo: Exception handling:
        #   - catching in case of failure (DNS, timeout, ...)
        #   - throwing in case of API failure
        case res
        when Net::HTTPSuccess
          data = parse_data(JSON.parse(res.body))
        else
          data = {}
        end

        data
      end

      # Remap raw API data to human-readable data.
      # @param data [Hash] Raw API data
      # @return [Hash] Human-readable data
      def parse_data(data)
        data = data.fetch('801').fetch('170')

        out = {
          time:                  data.fetch('100'),
          power_ac:              data.fetch('101'),
          power_dc:              data.fetch('102'),
          voltage_ac:            data.fetch('103'),
          voltage_dc:            data.fetch('104'),
          yield_day:             data.fetch('105'),
          yield_yesterday:       data.fetch('106'),
          yield_month:           data.fetch('107'),
          yield_year:            data.fetch('108'),
          yield_total:           data.fetch('109'),
          consumption_ac:        data.fetch('110'),
          consumption_day:       data.fetch('111'),
          consumption_yesterday: data.fetch('112'),
          consumption_month:     data.fetch('113'),
          consumption_year:      data.fetch('114'),
          consumption_total:     data.fetch('115'),
          power_total:           data.fetch('116'),
        }
      end
    end
  end
end
