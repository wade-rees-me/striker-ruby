require 'net/http'
require 'json'
require 'uri'

class Strategy
  attr_accessor :playbook, :counts, :bets, :insurance, :soft_double, :hard_double, :pair_split, :soft_stand, :hard_stand

  def initialize(decks, strategy, number_of_cards)
    @number_of_cards = number_of_cards
    fetch_json("http://localhost:57910/striker/v1/strategy")
    fetch_table(decks, strategy)
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
        @counts = json_payload['counts']
        @bets = json_payload['bets']
        @insurance = json_payload['insurance']
        @soft_double = json_payload['soft-double']
        @hard_double = json_payload['hard-double']
        @pair_split = json_payload['pair-split']
        @soft_stand = json_payload['soft-stand']
        @hard_stand = json_payload['hard-stand']
        puts @hard_stand
        return
      end
    end
  rescue JSON::ParserError
    puts 'Error parsing strategy table payload'
    exit(1)
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
    process_value(table[total.to_s][up.offset], true_count, false)
  end

  def get_split(seen_cards, pair, up)
    true_count = get_true_count(seen_cards, get_running_count(seen_cards))
    process_value(@pair_split[pair.value.to_s][up.offset], true_count, false)
  end

  def get_stand(seen_cards, total, soft, up)
    true_count = get_true_count(seen_cards, get_running_count(seen_cards))
    table = soft ? @soft_stand : @hard_stand
    process_value(table[total.to_s][up.offset], true_count, true)
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
end

