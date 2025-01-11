class Card
  attr_reader :suit, :rank, :key, :value

  def initialize(suit, rank, key, value)
    @suit = suit
    @rank = rank
    @key = key
    @value = value
  end

  def is_ace?
    value == 11
  end

  def display
    puts "#{rank} of #{suit} {#{value}}"
  end
end
