# frozen_string_literal: true

require 'json'
require 'time'
require 'securerandom'

# Parameters holds configuration values for running a simulation,
# including name, strategy, number of decks, and number of hands.
class Parameters
  attr_accessor :name, :playbook, :processor, :version, :epoch, :decks, :strategy, :number_of_decks, :number_of_hands

  # Constructor
  def initialize(decks, strategy, number_of_decks, number_of_hands)
    @name = generate_name
    @decks = decks
    @strategy = strategy
    @playbook = "#{@decks}-#{@strategy}"
    @processor = STRIKER_WHO_AM_I
    @version = STRIKER_VERSION
    @number_of_hands = number_of_hands
    @share_of_hands = number_of_hands
    @number_of_decks = number_of_decks
    @number_of_threads = 1
    @epoch = current_time
  end

  # Print method
  def print
    puts format('    %-26<field>s: %<value>s', field: 'Processor', value: @processor)
    puts format('    %-26<field>s: %<value>s', field: 'Threads', value: @number_of_threads)
    puts format('    %-26<field>s: %<value>s', field: 'Name', value: @name)
    puts format('    %-26<field>s: %<value>s', field: 'Version', value: @version)
    puts format('    %-26<field>s: %<value>s', field: 'Playbook', value: @playbook)
    puts format('    %-26<field>s: %<value>s', field: 'Decks', value: @decks)
    puts format('    %-26<field>s: %<value>s', field: 'Strategy', value: @strategy)
    puts format('    %-26s: %17s', 'Number of hands', format('%d', @number_of_hands).to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1,'))
    puts format('    %-26s: %17s', 'Thread share of hands', format('%d', @share_of_hands).to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1,'))
    puts format('    %-26<field>s: %<value>s', field: 'Epoch', value: @epoch)
  end

  private

  # Method to get the current time in the given format
  def current_time
    Time.now.strftime(TIME_LAYOUT)
  end

  # Method to generate a unique name with current date and time
  def generate_name
    t = Time.now
    "#{STRIKER_WHO_AM_I}_#{t.year}_#{t.month}_#{t.day}_#{t.to_i}"
  end
end
