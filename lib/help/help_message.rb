# frozen_string_literal: true

# HelpMessage provides formatted usage instructions for the strikerC command-line tool.
# It is responsible for printing the help content including available options, strategies,
# and deck configurations.
class HelpMessage
  def self.print
    puts header
    puts option_flags
    puts strategy_flags
    puts deck_flags
  end

  def self.header
    "Usage: strikerC [options]\nOptions:"
  end

  def self.option_flags
    <<~OPTIONS
      --help                                   Show this help message
      --version                                Display the program version
      -h, --number-of-hands <number>           Number of hands to play
    OPTIONS
  end

  def self.strategy_flags
    <<~STRATEGIES
      -M, --mimic                              Use the mimic dealer strategy
      -B, --basic                              Use the basic strategy
      -N, --neural                             Use the neural strategy
      -L, --linear                             Use the linear regression strategy
      -P, --polynomial                         Use the polynomial regression strategy
      -H, --high-low                           Use the high-low count strategy
      -W, --wong                               Use the Wong count strategy
    STRATEGIES
  end

  def self.deck_flags
    <<~DECKS
      -1, --single-deck                        Use a single deck of cards
      -2, --double-deck                        Use a double deck of cards
      -6, --six-shoe                           Use a six-deck shoe
    DECKS
  end
end
