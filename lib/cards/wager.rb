class Wager < Hand
  attr_accessor :amount_bet, :amount_won, :insurance_bet, :insurance_won, :minimum_bet, :maximum_bet

  def initialize(minimum_bet, maximum_bet)
    super()
    @minimum_bet = minimum_bet
    @maximum_bet = maximum_bet
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
    @amount_bet = (([@maximum_bet, [@minimum_bet, bet].max].min + 1) / 2) * 2
  end

  def double_bet
    @amount_bet *= 2
  end

  def won_blackjack(pays, bet)
    @amount_won = (@amount_bet * pays) / bet
  end

  def won
    @amount_won = @amount_bet
  end

  def lost
    @amount_won = -@amount_bet
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
