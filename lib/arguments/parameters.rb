require 'json'
require 'time'
require 'securerandom'

class Parameters
  MAX_STRING_SIZE = 128
  STRIKER_WHO_AM_I = 'striker-ruby'
  STRIKER_VERSION = 'v01.02.02'
  TIME_LAYOUT = '%Y-%m-%d %H:%M:%S %z'

  attr_accessor :name, :playbook, :processor, :timestamp, :decks, :strategy, :number_of_decks, :number_of_hands

  # Constructor
  def initialize(decks, strategy, number_of_decks, number_of_hands)
    @decks = decks
    @strategy = strategy
    @number_of_decks = number_of_decks
    @number_of_hands = number_of_hands

    @name = generate_name
    @playbook = "#{@decks}-#{@strategy}"
    @processor = STRIKER_WHO_AM_I
    @timestamp = get_current_time
  end

  # Print method
  def print
    puts "    %-24s: %s" % ["Name", @name]
    puts "    %-24s: %s" % ["Playbook", @playbook]
    puts "    %-24s: %s" % ["Processor", @processor]
    puts "    %-24s: %s" % ["Version", STRIKER_VERSION]
    puts "    %-24s: %d" % ["Number of hands", @number_of_hands]
    puts "    %-24s: %s" % ["Timestamp", @timestamp]
  end

  # Serialize parameters to JSON
  def serialize
    data = {
      playbook: @playbook,
      name: @name,
      processor: @processor,
      timestamp: @timestamp,
      decks: @decks,
      strategy: @strategy,
      number_of_hands: @number_of_hands,
      number_of_decks: @number_of_decks
    }
    JSON.pretty_generate(data)
  end

  private

  # Method to get the current time in the given format
  def get_current_time
    Time.now.strftime(TIME_LAYOUT)
  end

  # Method to generate a unique name with current date and time
  def generate_name
    t = Time.now
    "#{STRIKER_WHO_AM_I}_#{t.year}_#{t.month}_#{t.day}_#{t.to_i}"
  end
end

