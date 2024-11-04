class Card
  attr_reader :suit, :rank, :value, :offset

  def initialize(suit, rank, value, offset)
    @suit = suit
    @rank = rank
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
