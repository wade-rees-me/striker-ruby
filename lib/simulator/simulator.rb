# frozen_string_literal: true

require 'json'
require 'net/http'
require_relative '../arguments/parameters'
require_relative '../table/rules'
require_relative '../table/strategy'
require_relative 'table'
require_relative '../arguments/report'
require_relative '../constants/constants'

class Simulator
  attr_accessor :parameters, :rules, :table, :report

  def initialize(params, rules, strategy)
    @parameters = params
    @rules = rules
    @table = Table.new(@parameters, @rules, strategy)
    @report = Report.new(nil)
  end

  def simulator_run_once
    simulator_run_simulation
  end

  private

  def simulator_run_simulation
    @table.session(@parameters.strategy == 'mimic')

    # Update report data
    @report.total_bet += @table.player.report.total_bet
    @report.total_won += @table.player.report.total_won
    @report.total_rounds += @table.report.total_rounds
    @report.total_hands += @table.report.total_hands
    @report.total_blackjacks += @table.player.report.total_blackjacks
    @report.total_doubles += @table.player.report.total_doubles
    @report.total_splits += @table.player.report.total_splits
    @report.total_wins += @table.player.report.total_wins
    @report.total_pushes += @table.player.report.total_pushes
    @report.total_loses += @table.player.report.total_loses
    # @report.duration += @table.report.duration
  end
end
