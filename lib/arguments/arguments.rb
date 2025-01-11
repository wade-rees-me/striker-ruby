class Arguments
  attr_reader :number_of_hands

  def initialize(args)
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
    @number_of_hands = DEFAULT_NUMBER_OF_HANDS

    parse_arguments(args)
  end

  def get_strategy
    return "mimic" if @mimic_flag
    return "polynomial" if @polynomial_flag
    return "linear" if @linear_flag
    return "neural" if @neural_flag
    return "high-low" if @high_low_flag
    return "wong" if @wong_flag
    "basic"
  end

  def get_decks
    return "double-deck" if @double_deck_flag
    return "six-shoe" if @six_shoe_flag
    "single-deck"
  end

  def get_number_of_decks
    return 2 if @double_deck_flag
    return 6 if @six_shoe_flag
    1
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
      when "-h", "--number-of-hands"
        @number_of_hands = args[i + 1].to_i
        if @number_of_hands < MINIMUM_NUMBER_OF_HANDS || @number_of_hands > MAXIMUM_NUMBER_OF_HANDS
          raise "Number of hands must be between #{MINIMUM_NUMBER_OF_HANDS} and #{MAXIMUM_NUMBER_OF_HANDS}"
        end
        skip_next = true
      when "-M", "--mimic"
        @mimic_flag = true
      when "-B", "--basic"
        @basic_flag = true
      when "-N", "--neural"
        @neural_flag = true
      when "-L", "--linear"
        @linear_flag = true
      when "-P", "--polynomial"
        @polynomial_flag = true
      when "-H", "--high-low"
        @high_low_flag = true
      when "-W", "--wong"
        @wong_flag = true
      when "-1", "--single-deck"
        @single_deck_flag = true
      when "-2", "--double-deck"
        @double_deck_flag = true
      when "-6", "--six-shoe"
        @six_shoe_flag = true
      when "--help"
        print_help_message
        exit
      when "--version"
        print_version
        exit
      else
        raise "Error: Invalid argument: #{arg}"
      end
    end
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
