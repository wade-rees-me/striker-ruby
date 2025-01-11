require 'net/http'
require 'json'
require 'uri'
require_relative 'chart'

class Strategy
  attr_accessor :playbook, :counts, :insurance, :soft_double, :hard_double, :pair_split, :soft_stand, :hard_stand

  def initialize(decks, strategy, number_of_cards)
    @number_of_cards = number_of_cards

    @soft_double = Chart.new("Soft Double")
    @hard_double = Chart.new("Hard Double")
    @pair_split = Chart.new("Pair Split")
    @soft_stand = Chart.new("Soft Stand")
    @hard_stand = Chart.new("Hard Stand")

    fetch_json("http://localhost:57910/striker/v1/strategy")
    fetch_table(decks, strategy)

    @soft_double.print_chart()
    @hard_double.print_chart()
    @pair_split.print_chart()
    @soft_stand.print_chart()
    @hard_stand.print_chart()
    print_counts()
  end

  def fetch_json(url)
    uri = URI(url)
    response = Net::HTTP.get(uri)
    @json_response = JSON.parse(response)
  rescue StandardError => e
    puts "Error fetching JSON: #{e.message}"
    exit(1)
  end

  def fetch_table(decks, strategy)
    @json_response.each do |item|
      if item['playbook'] == decks && item['hand'] == strategy
        json_payload = JSON.parse(item['payload'])
        @playbook = json_payload['playbook']
        @insurance = json_payload['insurance']
        @counts = json_payload['counts']
        @counts.unshift(0)
        @counts.unshift(0)

        load_table(json_payload["soft-double"], @soft_double)
        load_table(json_payload["hard-double"], @hard_double)
        load_table(json_payload["pair-split"], @pair_split)
        load_table(json_payload["soft-stand"], @soft_stand)
        load_table(json_payload["hard-stand"], @hard_stand)
        return
      end
    end
  rescue JSON::ParserError
    puts 'Error parsing strategy table payload'
    exit(1)
  end

  def load_table(data, chart)
    data.each do |key, values|
      values.each_with_index do |value, index|
        chart.insert(key, index, value)
      end
    end
  end

  def get_bet(seen_cards)
    return get_true_count(seen_cards, get_running_count(seen_cards)) * TRUE_COUNT_BET
  end

  def get_insurance(seen_cards)
    true_count = get_true_count(seen_cards, get_running_count(seen_cards))
    process_value(@insurance, true_count, false)
  end

  def get_double(seen_cards, total, soft, up)
    true_count = get_true_count(seen_cards, get_running_count(seen_cards))
    table = soft ? @soft_double : @hard_double
    process_value(table.get_value(total.to_s, up.value), true_count, false)
  end

  def get_split(seen_cards, pair, up)
    true_count = get_true_count(seen_cards, get_running_count(seen_cards))
    process_value(@pair_split.get_value(pair.key, up.value), true_count, false)
  end

  def get_stand(seen_cards, total, soft, up)
    true_count = get_true_count(seen_cards, get_running_count(seen_cards))
    table = soft ? @soft_stand : @hard_stand
    process_value(table.get_value(total.to_s, up.value), true_count, true)
  end

  private

  def get_running_count(seen_cards)
    @counts.each_with_index.reduce(0) { |sum, (count, index)| sum + count * seen_cards[index] }
  end

  def get_true_count(seen_cards, running_count)
    unseen = @number_of_cards - seen_cards[2..11].sum
    unseen.positive? ? (running_count.to_f / (unseen.to_f / TRUE_COUNT_MULTIPLIER.to_f)).to_i : 0
  end

  def process_value(value, true_count, missing_value)
    return missing_value if value.nil? || value.empty?

    case value.downcase
    when 'yes', 'y' then true
    when 'no', 'n' then false
    when /^r(\d+)$/i then true_count <= Regexp.last_match(1).to_i
    else true_count >= value.to_i
    end
  rescue StandardError
    missing_value
  end

  def print_counts()
    puts @name
    puts "--------------------2-----3-----4-----5-----6-----7-----8-----9-----X-----A---"
    print "     "
    counts.each do |count|
      print "#{count.to_s.rjust(4)}, "
    end
    puts
    puts "------------------------------------------------------------------------------"
  end

end

