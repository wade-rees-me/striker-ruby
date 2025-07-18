# frozen_string_literal: true

require_relative '../help/help_message'

# The FlagParser class is responsible for handling the parsing of command-line flags
# for the striker program. It takes in a flag as an argument and updates the
# corresponding flag in a provided hash. If an invalid flag is provided, it raises
# an error.
#
# Example usage:
#   FlagParser.parse('-M', flags)
#
# This class helps decouple the flag parsing logic from the main Arguments class,
# improving readability and maintainability of the code.
class FlagParser
  FLAG_MAP = {
    '-M' => :mimic_flag,
    '--mimic' => :mimic_flag,
    '-B' => :basic_flag,
    '--basic' => :basic_flag,
    '-N' => :neural_flag,
    '--neural' => :neural_flag,
    '-L' => :linear_flag,
    '--linear' => :linear_flag,
    '-P' => :polynomial_flag,
    '--polynomial' => :polynomial_flag,
    '-H' => :high_low_flag,
    '--high-low' => :high_low_flag,
    '-W' => :wong_flag,
    '--wong' => :wong_flag,
    '-1' => :single_deck_flag,
    '--single-deck' => :single_deck_flag,
    '-2' => :double_deck_flag,
    '--double-deck' => :double_deck_flag,
    '-6' => :six_shoe_flag,
    '--six-shoe' => :six_shoe_flag
  }.freeze

  def self.initialize(args)
    @args = args
    @results = {} # ✅ initialize the hash here
  end

  def self.parse(flag, flags)
    if FLAG_MAP.key?(flag)
      flags[FLAG_MAP[flag]] = true
    else
      puts "Error: Invalid argument: #{flag}"
      HelpMessage.print
      exit
    end
  end
end

# The Arguments class is responsible for parsing and managing command-line arguments
# passed to the program. It processes different flags and provides easy access to
# the configurations needed for the simulation.
#
# Example usage:
#   arguments = Arguments.new(ARGV)
#   puts arguments.number_of_hands
#
# This class helps in making the command-line interface user-friendly by
# providing useful defaults and handling user input gracefully.
# # frozen_string_literal: true
class Arguments
  attr_reader :number_of_hands

  STRATEGY_MAP = {
    mimic_flag: 'mimic',
    linear_flag: 'linear',
    polynomial_flag: 'polynomial',
    neural_flag: 'neural',
    basic_flag: 'basic',
    high_low_flag: 'high-low',
    wong_flag: 'wong'
  }.freeze

  DECK_MAP = {
    single_deck_flag: 'single-deck',
    double_deck_flag: 'double-deck',
    six_shoe_flag: 'six-shoe'
  }.freeze

  def initialize(args)
    @flags = {}
    @number_of_hands = NUMBER_OF_HANDS_DEFAULT
    initialize_flags
    FlagParser.initialize(args)
    parse_arguments(args)
  end

  def initialize_flags
    @mimic_flag = false
    @basic_flag = false
    @neural_flag = false
    @linear_flag = false
    @polynomial_flag = false
    @high_low_flag = false
    @wong_flag = false
    @single_deck_flag = false
    @double_deck_flag = false
    @six_shoe_flag = false
  end

  def strategy
    STRATEGY_MAP.find { |key, _| @flags[key] }&.last || 'basic'
  end

  def decks
    DECK_MAP.find { |key, _| @flags[key] }&.last || 'single-deck'
  end

  def number_of_decks
    if @flags[:double_deck_flag]
      2
    elsif @flags[:six_shoe_flag]
      6
    else
      1
    end
  end

  private

  def parse_arguments(args)
    args.each_with_index do |arg, i|
      next if @skip_next

      case arg
      when '-h', '--number-of-hands' then handle_number_of_hands(args[i + 1])
      when '--help'                  then exit_with_help
      when '--version'               then exit_with_version
      else FlagParser.parse(arg, @flags)
      end
    end
  end

  def handle_number_of_hands(value)
    @number_of_hands = value.to_i
    validate_number_of_hands
    @skip_next = true
  end

  def exit_with_help
    HelpMessage.print
    exit
  end

  def exit_with_version
    puts "#{STRIKER_WHO_AM_I}: version: #{STRIKER_VERSION}"
    exit
  end

  def validate_number_of_hands
    return unless @number_of_hands < NUMBER_OF_HANDS_MINIMUM || @number_of_hands > NUMBER_OF_HANDS_MAXIMUM

    raise "Number of hands must be between #{NUMBER_OF_HANDS_MINIMUM} and #{NUMBER_OF_HANDS_MAXIMUM}"
  end
end
