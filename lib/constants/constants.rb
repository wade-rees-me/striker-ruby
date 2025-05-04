# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

# General constants
STRIKER_WHO_AM_I = 'striker-ruby'
STRIKER_VERSION = 'v03.00.00'
TIME_LAYOUT = '%Y-%m-%d %H:%M:%S %z'
MY_HOSTNAME = 'Striker'

NUMBER_OF_CARDS_IN_DECK = 52
NUMBER_OF_CORES_PHYSICAL = 24
NUMBER_OF_CORES_LOGICAL = 32
NUMBER_OF_CORES_DEFAULT = 24

# maximum size string fields
MAX_STRING_SIZE = 512
MAX_BUFFER_SIZE = 8192
MAX_MEMORY_SIZE = 536_870_912

# Simulation constants
MILLION = 1_000_000
BILLION = MILLION * 1000
NUMBER_OF_HANDS_MAXIMUM = BILLION * 10
NUMBER_OF_HANDS_MINIMUM = 1000
NUMBER_OF_HANDS_DEFAULT = MILLION * 100
NUMBER_OF_HANDS_DATABASE = MILLION * 100

# Betting constants
MINIMUM_BET = 2
MAXIMUM_BET = 20
TRUE_COUNT_BET = 2
TRUE_COUNT_MULTIPLIER = 26

# Get hostname and check if it matches
def my_computer?
  begin
    hostname = Socket.gethostname
    my_hostname = MY_HOSTNAME
    hostname == my_hostname
  rescue => e
    puts "Error getting hostname: #{e.message}"
    false
  end
end

# Function to get environment variables
def rules_url
  ENV['STRIKER_URL_RULES']
end

def charts_url
  ENV['STRIKER_URL_CHARTS']
end

def simulations_url
  ENV['STRIKER_URL_SIMULATIONS']
end

def unescape_json(str)
  str.gsub!(/\\n/, "\n")   # Convert \n to newline
  str.gsub!(/\\"/, '"')    # Convert \" to "
  str.gsub!(/\\\\/, '\\')  # Convert \\ to \
  str
end

def strip_quotes(str)
  str[1..-2] if str.start_with?('"') && str.end_with?('"')
end
