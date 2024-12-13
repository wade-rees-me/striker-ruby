class Report
  attr_accessor :total_rounds, :total_hands, :total_blackjacks, :total_doubles, :total_splits, :total_wins, :total_pushes, :total_loses, :total_bet, :total_won, :start, :end, :duration

  def initialize
    @total_rounds = 0
    @total_hands = 0
    @total_blackjacks = 0
    @total_doubles = 0
    @total_splits = 0
    @total_wins = 0
    @total_pushes = 0
    @total_loses = 0
    @total_bet = 0
    @total_won = 0
    @start = 0
    @end = 0
    @duration = 0
  end
end
