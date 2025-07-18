# frozen_string_literal: true

class Report
  attr_accessor :total_rounds, :total_hands, :total_blackjacks, :total_doubles, :total_splits, :total_splits_ace, :total_wins,
                :total_pushes, :total_loses, :total_bet, :total_won, :start, :end, :duration

  # Constructor
  def initialize(parameters)
    @name = parameters&.name
    @version = parameters&.version
    @playbook = parameters&.playbook
    @simulator = parameters&.processor
    @strategy = parameters&.strategy
    @decks = parameters&.decks
    @epoch = parameters&.epoch
    @threads = 1
    initialize_time
    initialize_totals
  end

  def initialize_totals
    @total_rounds = 0
    @total_hands = 0
    @total_bet = 0
    @total_won = 0
    @total_blackjacks = 0
    @total_doubles = 0
    @total_splits = 0
    @total_splits_ace = 0
    @total_wins = 0
    @total_pushes = 0
    @total_loses = 0
  end

  def initialize_time
    @start = Time.now.to_i
    @end = 0
    @duration = 0
    @advantage = 0.0
    @per_billion = 0.0
  end

  def merge(other)
    @total_rounds    += other.total_rounds
    @total_hands     += other.total_hands
    @total_bet       += other.total_bet
    @total_won       += other.total_won
    @total_blackjacks += other.total_blackjacks
    @total_doubles   += other.total_doubles
    @total_splits    += other.total_splits
    @total_splits_ace += other.total_splits_ace
    @total_wins      += other.total_wins
    @total_loses     += other.total_loses
    @total_pushes    += other.total_pushes
  end

  def finish
    @end = Time.now.to_i
    @duration = @end - @start
    @advantage = @total_won.to_f / @total_bet * 100.0
    @per_billion = @duration * BILLION / @total_hands
  end

  def print
    puts format('    %-26s: %17s', 'Number of hands', format('%d', @total_hands).to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1,'))
    puts format('    %-26s: %17s', 'Number of rounds', format('%d', @total_rounds).to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1,'))
    average_bet = format('%+8.3f average bet per hand', @total_bet.to_f / @total_hands)
    puts format('    %-26s: %17s %s', 'Total bet', format('%d', @total_bet).to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1,'), average_bet)
    average_won = format('%+8.3f average bet won hand', @total_won.to_f / @total_hands)
    puts format('    %-26s: %17s %s', 'Total won', format('%d', @total_won).to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1,'), average_won)
    average_blackjacks = format('%+08.3f %% of total hands', @total_blackjacks.to_f / @total_hands * 100.0)
    puts format('    %-26s: %17s %s', 'Number of blackjacks', format('%d', @total_blackjacks).to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1,'), average_blackjacks)
    average_doubles = format('%+08.3f %% of total hands', @total_doubles.to_f / @total_hands * 100.0)
    puts format('    %-26s: %17s %s', 'Number of doubles', format('%d', @total_doubles).to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1,'), average_doubles)
    average_splits = format('%+08.3f %% of total hands', @total_splits.to_f / @total_hands * 100.0)
    puts format('    %-26s: %17s %s', 'Number of splits', format('%d', @total_splits).to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1,'), average_splits)
    average_splits_ace = format('%+08.3f %% of total hands', @total_splits_ace.to_f / @total_hands * 100.0)
    puts format('    %-26s: %17s %s', 'Number of splits - Aces', format('%d', @total_splits_ace).to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1,'), average_splits_ace)
    average_wins = format('%+08.3f %% of total hands', @total_wins.to_f / @total_hands * 100.0)
    puts format('    %-26s: %17s %s', 'Number of wins', format('%d', @total_wins).to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1,'), average_wins)
    average_pushes = format('%+08.3f %% of total hands', @total_pushes.to_f / @total_hands * 100.0)
    puts format('    %-26s: %17s %s', 'Number of pushes', format('%d', @total_pushes).to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1,'), average_pushes)
    average_loses = format('%+08.3f %% of total hands', @total_loses.to_f / @total_hands * 100.0)
    puts format('    %-26s: %17s %s', 'Number of loses', format('%d', @total_loses).to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1,'), average_loses)
    puts format('    %-26s: %17s %s seconds', 'Total time', '', format('%d', @duration).to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1,'))
    puts format('    %-26s: %17s %s seconds', 'Number of threads', '', format('%d', @threads).to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1,'))
    puts format('    %-26s: %17s seconds per %s hands', 'Average time', format('%d', @per_billion).to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1,'),
                format('%d', BILLION).to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1,'))
    puts format('    %-26s: %17s %+08.3f %%', 'Player advantage', '', @advantage)
  end

  def insert
    unless my_computer?
      puts '    This code is restricted to running only on my computer.'
      return
    end

    if @total_hands < NUMBER_OF_HANDS_DATABASE
      puts format(
        "    Error: Not enough hands played (%<hands>s). Minimum required is %<min>s\n",
        hands: @total_hands.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse,
        min: NUMBER_OF_HANDS_DATABASE.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
      )
      return
    end


    uri = URI("http://#{simulations_url}/"+@simulator+"/"+@decks+"/"+@strategy)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })

    # Create the JSON object
    payload = {
      guid: @name,
      version: @version,
      simulator: @simulator,
      threads: @threads,
      playbook: @playbook,
      decks: @decks,
      strategy: @strategy,
      rounds: @total_rounds,
      hands: @total_hands,
      total_bet: @total_bet,
      total_won: @total_won,
      total_blackjacks: @total_blackjacks,
      total_doubles: @total_doubles,
      total_splits: @total_splits,
      total_splits_ace: @total_splits_ace,
      total_wins: @total_wins,
      total_loses: @total_loses,
      total_pushes: @total_pushes,
      advantage: @advantage,
      epoch: @epoch,
      start: @start,
      end: @end,
      duration: @duration,
      per_billion: @per_billion
    }.to_json

    request.body = payload

    response = http.request(request)
    if response.code != '200'
      puts "    Failed to insert simulation: #{response.code} - #{response.body}"
    else
      puts "    Simulation inserted: #{response.code}"
    end
  end
end
