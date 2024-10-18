require 'json'
require 'net/http'
require 'uri'

# General constants
STRIKER_WHO_AM_I = "striker-ruby"
STRIKER_VERSION = "v01.02.02"
TIME_LAYOUT = "%Y-%m-%d %H:%M:%S %z"

# Define the maximum sizes for string fields
MAX_STRING_SIZE = 128
MAX_BUFFER_SIZE = 4096
MAX_MEMORY_SIZE = 1048576

# Simulation constants
MAXIMUM_NUMBER_OF_HANDS = 1000000000
MINIMUM_NUMBER_OF_HANDS = 100
DEFAULT_NUMBER_OF_HANDS = 1000000
DATABASE_NUMBER_OF_HANDS = 1000000

# Betting constants
MAXIMUM_BET = 80
MINIMUM_BET = 2

STATUS_DOT = 25000
STATUS_LINE = 1000000

# Structure to store HTTP response
class MemoryStruct
  attr_accessor :memory, :size

  def initialize
    @memory = ''
    @size = 0
  end
end

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

# Function to convert boolean to string
def bool_to_string(b)
  b ? 'true' : 'false'
end

# Callback function for HTTP response (equivalent to writeMemoryCallback in C++)
def write_memory_callback(body, memory_struct)
  memory_struct.memory += body
  memory_struct.size += body.size
  body.size
end

# Parse JSON for string values
def parse_aux_string(json, tag)
  if json[tag]
    json[tag]
  else
    puts "Error fetching rules table item: #{tag}"
    exit(1)
  end
end

# Parse JSON for boolean values
def parse_aux_bool(json, tag, default_value)
  json.key?(tag) ? json[tag] : default_value
end

# Parse JSON for integer values
def parse_aux_int(json, tag, default_value)
  json.key?(tag) ? json[tag].to_i : default_value
end

# Parse JSON for double values
def parse_aux_double(json, tag, default_value)
  json.key?(tag) ? json[tag].to_f : default_value
end
