require 'json'
require 'net/http'
require_relative '../arguments/parameters'
require_relative '../table/rules'
require_relative '../table/strategy'
require_relative 'table'
require_relative '../arguments/report'
require_relative 'simulation'
require_relative '../constants/constants'

class Simulator
  attr_accessor :parameters, :rules, :table, :report

  def initialize(params, rules, strategy)
    @parameters = params
    @rules = rules
    @table = Table.new(@parameters, @rules, strategy)
    @report = Report.new
  end

  def simulator_run_once
    db_table = Simulation.new
    puts "  Start: simulation #{@parameters.name}"

    simulator_run_simulation

    puts "  End: simulation"

    # Populate the Simulation object with the results
    db_table.playbook = @parameters.playbook
    db_table.name = @parameters.name
    db_table.simulator = STRIKER_WHO_AM_I
    db_table.summary = 'no'
    db_table.simulations = '1'
    db_table.parameters = @parameters.serialize
    db_table.rules = @rules.serialize
    db_table.rounds = @report.total_rounds.to_s
    db_table.hands = @report.total_hands.to_s
    db_table.total_bet = @report.total_bet.to_s
    db_table.total_won = @report.total_won.to_s
    db_table.total_time = @report.duration.to_s
    db_table.average_time = format('%06.2f seconds', (@report.duration * 1_000_000.0 / @report.total_hands))
    db_table.advantage = format('%+04.3f %%', ((@report.total_won.to_f / @report.total_bet) * 100))

    # Print out the results
    puts "\n  -- results ---------------------------------------------------------------------"
    puts "    Number of hands: #{@report.total_hands}"
    puts "    Number of rounds: #{@report.total_rounds}"
    puts "    Total bet: #{@report.total_bet} #{format('%+04.3f average bet per hand', @report.total_bet.to_f / @report.total_hands)}"
    puts "    Total won: #{@report.total_won} #{format('%+04.3f average win per hand', @report.total_won.to_f / @report.total_hands)}"
    puts "    Total time: #{db_table.total_time} seconds"
    puts "    Average time: #{db_table.average_time} per 1,000,000 hands"
    puts "    Player advantage: #{db_table.advantage}"
    puts "  --------------------------------------------------------------------------------"

    if @report.total_hands >= DATABASE_NUMBER_OF_HANDS
      simulator_insert(db_table, @parameters.playbook)
    end
  end

  private

  def simulator_run_simulation
    puts "    Start: #{@parameters.strategy} table session"
    @table.session(@parameters.strategy == 'mimic')
    puts "    End: table session"

    # Update report data
    @report.total_bet += @table.player.report.total_bet
    @report.total_won += @table.player.report.total_won
    @report.total_rounds += @table.report.total_rounds
    @report.total_hands += @table.report.total_hands
    @report.duration += @table.report.duration
  end

  def simulator_insert(simulation_data, playbook)
    uri = URI("http://#{get_simulation_url}/#{simulation_data.simulator}/#{playbook}/#{simulation_data.name}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
    
    # Create the JSON object
    payload = {
      playbook: simulation_data.playbook,
      name: simulation_data.name,
      simulator: simulation_data.simulator,
      summary: 'no',
      simulations: '1',
      rounds: simulation_data.rounds,
      hands: simulation_data.hands,
      total_bet: simulation_data.total_bet,
      total_won: simulation_data.total_won,
      advantage: simulation_data.advantage,
      total_time: simulation_data.total_time,
      average_time: simulation_data.average_time,
      parameters: simulation_data.parameters,
      rules: simulation_data.rules,
      payload: 'n/a'
    }.to_json

    request.body = payload

    response = http.request(request)
    if response.code != '200'
      puts "Failed to insert simulation: #{response.code} - #{response.body}"
    end
  end
end
