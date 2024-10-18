class Dealer
  attr_accessor :hand, :hit_soft_17

  def initialize(hit_soft_17 = true)
    @hit_soft_17 = hit_soft_17
    @hand = Hand.new
    reset
  end

  def reset
    @hand.reset
  end

  def draw_card(card)
    @hand.draw_card(card)
  end

  def play(shoe)
    while !should_stand
      draw_card(shoe.draw_card)
    end
  end

  private

  def should_stand
    return false if @hit_soft_17 && @hand.is_soft_17?
    @hand.hand_total >= 17
  end
end
