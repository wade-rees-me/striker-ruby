# frozen_string_literal: true

require_relative 'arguments/arguments'
require_relative 'table/rules'
require_relative 'table/strategy'
require_relative 'arguments/parameters'
require_relative 'simulator/simulator'
require_relative 'constants/constants'
require_relative 'xlog/xlog'

def main
  initialize_xlogs
  print_start_message
  parameters, rules, strategy = initialize_arguments
  simulator = initialize_simulator(parameters, rules, strategy)
  report = initialize_report(parameters)

  print_arguments(parameters, rules)
  run_simulation(simulator, report)
  report.finish
  report_print(report)
  report_insert(report)
end

def initialize_xlogs
  if Xlog.init_syslog
    Xlog.log_info('Started simulation at %s', Time.now)
    Xlog.log_error('Error loading deck at %s', Time.now)
    Xlog.log_fatal('Fatal crash at %s', Time.now)
    Xlog.close_syslog
  else
    puts 'Failed to initialize syslog'
  end
end

def print_start_message
  puts "Start: #{STRIKER_WHO_AM_I}"
end

def initialize_arguments
  arguments = Arguments.new(ARGV)
  parameters = Parameters.new(arguments.decks, arguments.strategy, arguments.number_of_decks, arguments.number_of_hands)
  rules = Rules.new(arguments.decks)
  strategy = Strategy.new(arguments.decks, arguments.strategy, arguments.number_of_decks)
  [parameters, rules, strategy]
end

def initialize_report(parameters)
  Report.new(parameters)
end

def initialize_simulator(parameters, rules, strategy)
  Simulator.new(parameters, rules, strategy)
end

def run_simulation(simulator, report)
  simulator.simulator_run_once
  report.merge(simulator.report)
end

def print_arguments(parameters, rules)
  puts '  -- arguments -------------------------------------------------------------------'
  parameters.print
  rules.print
  puts '  --------------------------------------------------------------------------------'
end

def report_print(report)
  puts '  -- results ---------------------------------------------------------------------'
  report.print
  puts '  --------------------------------------------------------------------------------'
end

def report_insert(report)
  puts '  -- insert ----------------------------------------------------------------------'
  report.insert
  puts '  --------------------------------------------------------------------------------'
end

main if __FILE__ == $PROGRAM_NAME
