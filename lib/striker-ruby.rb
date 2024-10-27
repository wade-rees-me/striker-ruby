require_relative 'arguments/arguments'
require_relative 'table/rules'
require_relative 'table/strategy'
require_relative 'arguments/parameters'
require_relative 'simulator/simulator'
require_relative 'constants/constants'

def main
	puts "Start: #{STRIKER_WHO_AM_I}"
	arguments = Arguments.new(ARGV)
	parameters = Parameters.new(arguments.get_decks, arguments.get_strategy, arguments.get_number_of_decks, arguments.number_of_hands)
	rules = Rules.new(arguments.get_decks)
	strategy = Strategy.new(arguments.get_decks, arguments.get_strategy, arguments.get_number_of_decks * 52);
	simulator = Simulator.new(parameters, rules, strategy)

	puts "  -- arguments -------------------------------------------------------------------"
	parameters.print
	rules.print
	puts "  --------------------------------------------------------------------------------"

	simulator.simulator_run_once
	puts "End: #{STRIKER_WHO_AM_I}"
end

if __FILE__ == $0
	main
end
