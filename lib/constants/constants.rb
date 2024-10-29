require 'json'
require 'net/http'
require 'uri'

# General constants
STRIKER_WHO_AM_I = "striker-ruby"
STRIKER_VERSION = "v01.02.02"
TIME_LAYOUT = "%Y-%m-%d %H:%M:%S %z"

# Define the maximum sizes for string fields
#MAX_STRING_SIZE = 128
#MAX_BUFFER_SIZE = 4096
#MAX_MEMORY_SIZE = 1048576

# Simulation constants
MAXIMUM_NUMBER_OF_HANDS = 250000000000
MINIMUM_NUMBER_OF_HANDS = 100
DEFAULT_NUMBER_OF_HANDS = 250000000
DATABASE_NUMBER_OF_HANDS = 250000000

# Betting constants
MINIMUM_BET = 2
MAXIMUM_BET = 80

STATUS_DOT = 25000
STATUS_LINE = 1000000

# Function to get environment variables
def get_rules_url
  ENV['STRIKER_URL_RULES']
end

def get_strategy_url
  ENV['STRIKER_URL_ACE']
end

def get_simulation_url
  ENV['STRIKER_URL_SIMULATION']
end

