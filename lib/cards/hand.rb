# frozen_string_literal: true

# Represents a hand of cards in a Blackjack game.
# Tracks card totals, checks for special hands (e.g., blackjack, pair),
# and handles logic such as soft totals and busts.
class Hand
  attr_reader :hand_total

  def initialize
    @cards = []
    @hand_total = 0
    @soft_ace = 0
  end

  def reset
    @hand_total = 0
    @soft_ace = 0
    @cards.clear
  end

  def draw_card(card)
    @cards << card
    calculate_total
    card
  end

  def blackjack?
    @cards.size == 2 && @hand_total == 21
  end

  def pair?
    @cards.size == 2 && @cards[0].value == @cards[1].value
  end

  def card_pair
    @cards[0]
  end

  def pair_of_aces?
    pair? && @cards[0].ace?
  end

  def busted?
    @hand_total > 21
  end

  def soft?
    @soft_ace.positive?
  end

  def soft_seventeen?
    @hand_total == 17 && soft?
  end

  def split_pair
    raise 'Error: Trying to split a non-pair' unless pair?

    card = @cards.pop
    calculate_total
    card
  end

  private

  def calculate_total
    @hand_total = 0
    @soft_ace = 0

    @cards.each do |card|
      @hand_total += card.value
      @soft_ace += 1 if card.value == 11
    end

    # Adjust hand total if it's over 21 and there are soft aces
    while @hand_total > 21 && @soft_ace.positive?
      @hand_total -= 10
      @soft_ace -= 1
    end
  end
end
