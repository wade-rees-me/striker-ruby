class Simulation
  attr_accessor :playbook, :name, :simulator, :summary, :simulations,
                :rounds, :hands, :total_bet, :total_won, :advantage,
                :total_time, :average_time, :parameters, :rules

  def initialize
    @playbook = ''
    @name = ''
    @simulator = ''
    @summary = ''
    @simulations = ''
    @rounds = ''
    @hands = ''
    @total_bet = ''
    @total_won = ''
    @advantage = ''
    @total_time = ''
    @average_time = ''
    @parameters = ''
    @rules = ''
  end
end
