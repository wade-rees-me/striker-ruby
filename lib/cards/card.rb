# frozen_string_literal: true

# Represents a playing card used in a game of Blackjack.
# Stores suit, rank, key identifier, and numeric value.
class Card
  attr_reader :suit, :rank, :key, :value

  def initialize(suit, rank, key, value)
    @suit = suit
    @rank = rank
    @key = key
    @value = value
  end

  def ace?
    value == 11
  end

  def display
    puts "#{rank} of #{suit} {#{value}}"
  end
end
