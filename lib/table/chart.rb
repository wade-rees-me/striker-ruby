class Chart
  TABLE_SIZE = 21
  VALUE_COUNT = 13

  # Inner class representing a row in the chart
  class ChartRow
    attr_accessor :key, :values

    def initialize
      @key = "--"
      @values = Array.new(VALUE_COUNT, "---")
    end
  end

  def initialize(name)
    @name = name
    @rows = Array.new(TABLE_SIZE) { ChartRow.new }
    @next_row = 0
  end

  # Insert a key-value pair into the chart
  def insert(key, up, value)
    index = get_row(key)
    if index.nil?
      if @next_row >= TABLE_SIZE
        raise "No more space in the chart"
      end
      index = @next_row
      @rows[index].key = key.upcase
      @next_row += 1
    end
    @rows[index].values[up] = value.upcase
  end

  # Retrieve a value from the chart
  def get_value(key, up)
    index = get_row(key)
    raise "Cannot find value in #{@name} for #{key} vs #{up}" if index.nil?

    @rows[index].values[up]
  end

  # Print the chart
  def print_chart()
    puts @name
    puts "--------2-----3-----4-----5-----6-----7-----8-----9-----T-----J-----Q-----K-----A---"
    @rows[0...@next_row].each do |row|
      print "#{row.key} : "
      row.values.each do |value|
        print "#{value.ljust(4)}, "
      end
      puts
    end
    puts "------------------------------------------------------------------------------------"
  end

  private

  # Get the index of a row with the given key
  def get_row(key)
    key_upcase = key.upcase
    @rows[0...@next_row].each_with_index do |row, index|
      return index if row.key == key_upcase
    end
    nil
  end
end

## Example usage
#chart = Chart.new("Example Chart")
#
## Insert some values
#chart.insert("A", 2, "Hit")
#chart.insert("B", 3, "Stand")
#chart.insert("A", 4, "Double")
#
## Retrieve a value
#value = chart.get_value("A", 2)
#puts "Value at A, 2: #{value}"
#
## Print the chart
#chart.print

