class Card
  attr_reader :suit, :rank, :key, :value, :offset

  def initialize(suit, rank, key, value, offset)
    @suit = suit
    @rank = rank
    @key = key
    @value = value
    @offset = offset
  end

  def is_ace?
    value == 11
  end

  def display
    puts "#{rank} of #{suit} {#{value}, #{offset}}"
  end
end
