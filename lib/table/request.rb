# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

class Request
  attr_accessor :json_response

  def initialize
    @json_response = NULL
  end

  def fetch_json(url)
    uri = URI.parse(url)
    response = Net::HTTP.get(uri)
    response = unescape_json(response)
    response = strip_quotes(response)
    @json_response = JSON.parse(response)
  rescue StandardError => e
    puts "Error fetching JSON: #{e.message}"
    exit(1)
  end
end
