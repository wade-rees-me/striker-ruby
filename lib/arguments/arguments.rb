# frozen_string_literal: true

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
    '-M' => :mimic,
    '--mimic' => :mimic,
    '-B' => :basic,
    '--basic' => :basic,
    '-N' => :neural,
    '--neural' => :neural,
    '-L' => :linear,
    '--linear' => :linear,
    '-P' => :polynomial,
    '--polynomiam' => :polynomial,
    '-H' => :high_low,
    '--high-low' => :high_low,
    '-W' => :wong,
    '--wong' => :wong,
    '-1' => :single_deck,
    '--single-deck' => :single_deck,
    '-2' => :double_deck,
    '--double-deck' => :double_deck,
    '-6' => :six_shoe,
    '--six-shoe' => :six_shoe
  }.freeze

  def self.initialize(args)
    @args = args
    @results = {} # ✅ initialize the hash here
  end

  def self.parse(flag, flags)
    raise "Error: Invalid argument: #{flag}" unless FLAG_MAP.key?(flag)

    flags[FLAG_MAP[flag]] = true
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
class Arguments
  attr_reader :number_of_hands

   STRATEGY_MAP = {
    mimic: 'mimic',
    basic: 'basic'
  }

   DECK_MAP = {
    single: 1,
    double: 2,
    shoe: 6
  }

  def initialize(args)
    @flags = {}
    @number_of_hands = NUMBER_OF_HANDS_DEFAULT
    initialize_flags
    FlagParser.initialize(args)
    parse_arguments(args)
  end

  # Helper method to initialize flags
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
    if @flags[:double_deck]
      2
    elsif @flags[:six_shoe]
      6
    else
      1
    end
  end

  private

  def parse_arguments(args)
    skip_next = false
    args.each_with_index do |arg, i|
      if skip_next
        skip_next = false
        next
      end

      case arg
      when '-h', '--number-of-hands'
        @number_of_hands = args[i + 1].to_i
        validate_number_of_hands
        skip_next = true
      when '--help'
        print_help_message
        exit
      when '--version'
        print_version
        exit
      else
        FlagParser.parse(arg, @flags)
      end
    end
  end

  def validate_number_of_hands
    return unless @number_of_hands < NUMBER_OF_HANDS_MINIMUM || @number_of_hands > NUMBER_OF_HANDS_MAXIMUM

    raise "Number of hands must be between #{NUMBER_OF_HANDS_MINIMUM} and #{NUMBER_OF_HANDS_MIXIMUM}"
  end

  def print_version
    puts "#{STRIKER_WHO_AM_I}: version: #{STRIKER_VERSION}"
  end

  def print_help_message
    puts <<-HELP
      Usage: strikerC [options]
      Options:
        --help                                   Show this help message
        --version                                Display the program version
        -h, --number-of-hands <number of hands>  The number of hands to play in this simulation
        -M, --mimic                              Use the mimic dealer player strategy
        -B, --basic                              Use the basic player strategy
        -N, --neural                             Use the neural player strategy
        -L, --linear                             Use the liner regression player strategy
        -P, --polynomial                         Use the polynomial regression player strategy
        -H, --high-low                           Use the high low count player strategy
        -W, --wong                               Use the Wong count player strategy
        -1, --single-deck                        Use a single deck of cards and rules
        -2, --double-deck                        Use a double deck of cards and rules
        -6, --six-shoe                           Use a six deck shoe of cards and rules
    HELP
  end
end
