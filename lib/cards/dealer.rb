# frozen_string_literal: true

# Represents the dealer in a game of Blackjack.
# Handles drawing cards, checking soft 17 logic, and hand management.
class Dealer
  attr_accessor :hand, :hit_soft_seventeen

  def initialize(hit_soft_seventeen)
    @hit_soft_seventeen = hit_soft_seventeen
    @hand = Hand.new
    reset
  end

  def reset
    @hand.reset
  end

  def draw_card(card)
    @hand.draw_card(card)
  end

  def should_stand
    return false if @hit_soft_seventeen && @hand.soft_seventeen?

    @hand.hand_total >= 17
  end
end
