class Report
  attr_accessor :total_rounds, :total_hands, :total_bet, :total_won, :start, :end, :duration

  def initialize
    @total_rounds = 0
    @total_hands = 0
    @total_bet = 0
    @total_won = 0
    @start = 0
    @end = 0
    @duration = 0
  end
end
