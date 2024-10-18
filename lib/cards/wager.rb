class Wager < Hand
  attr_accessor :amount_bet, :amount_won, :insurance_bet, :insurance_won

  def initialize
    super()
    reset
  end

  def reset
    super()  # Reset the Hand
    @amount_bet = 0
    @amount_won = 0
    @insurance_bet = 0
    @insurance_won = 0
  end

  def split_hand(split)
    split.amount_bet = @amount_bet
    split.draw_card(split_pair)
  end

  def place_bet(bet)
    @amount_bet = (([MAXIMUM_BET, [MINIMUM_BET, bet].max].min + 1) / 2) * 2
  end

  def double_bet
    @amount_bet *= 2
  end

  def won_blackjack(pays, bet)
    @amount_won = (@amount_bet * pays) / bet
    # puts "blackajck"
  end

  def won
    @amount_won = @amount_bet
    # puts "won"
  end

  def lost
    @amount_won = -@amount_bet
    # puts "lost"
  end

  def push
    # No action needed for a push
  end

  def won_insurance
    @insurance_won = @insurance_bet * 2
  end

  def lost_insurance
    @insurance_won = -@insurance_bet
  end
end
