require 'json'
require 'net/http'
require 'uri'

class Rules
  MAX_STRING_SIZE = 128

  attr_accessor :playbook, :hit_soft_17, :surrender, :double_any_two_cards, :double_after_split,
                :resplit_aces, :hit_split_aces, :blackjack_pays, :blackjack_bets, :penetration

  def initialize(decks)
    @playbook = ""
    @hit_soft_17 = true
    @surrender = false
    @double_any_two_cards = true
    @double_after_split = false
    @resplit_aces = false
    @hit_split_aces = false
    @blackjack_pays = 5
    @blackjack_bets = 3
    @penetration = 0.70

    # puts get_rules_url + "/" + decks
    rules_fetch_table("http://" + get_rules_url + "/" + decks)
  end

  # Print the rules
  def print
    puts "    %-24s\n" % ["Table Rules"]
    puts "      %-24s: %s" % ["Table", @playbook]
    puts "      %-24s: %s" % ["Hit soft 17", bool_to_string(@hit_soft_17)]
    puts "      %-24s: %s" % ["Surrender", bool_to_string(@surrender)]
    puts "      %-24s: %s" % ["Double any two cards", bool_to_string(@double_any_two_cards)]
    puts "      %-24s: %s" % ["Double after split", bool_to_string(@double_after_split)]
    puts "      %-24s: %s" % ["Resplit aces", bool_to_string(@resplit_aces)]
    puts "      %-24s: %s" % ["Hit split aces", bool_to_string(@hit_split_aces)]
    puts "      %-24s: %d" % ["Blackjack bets", @blackjack_bets]
    puts "      %-24s: %d" % ["Blackjack pays", @blackjack_pays]
    puts "      %-24s: %0.3f %%" % ["Penetration", @penetration]
  end

  # Serialize the rules into a JSON string
  def serialize
    data = {
      hit_soft_17: @hit_soft_17 ? "true" : "false",
      surrender: @surrender ? "true" : "false",
      double_any_two_cards: @double_any_two_cards ? "true" : "false",
      double_after_split: @double_after_split ? "true" : "false",
      resplit_aces: @resplit_aces ? "true" : "false",
      hit_split_aces: @hit_split_aces ? "true" : "false",
      blackjack_bets: @blackjack_bets,
      blackjack_pays: @blackjack_pays,
      penetration: @penetration
    }
    JSON.pretty_generate(data)
  end

  private

  # Fetch the rules from a remote URL
  def rules_fetch_table(url)
    uri = URI.parse(url)
    response = Net::HTTP.get(uri)
    json = JSON.parse(response)

    item_payload = json['payload']
    rules_data = JSON.parse(item_payload)

    @playbook = rules_data['playbook']
    @hit_soft_17 = rules_data['hitSoft17']
    @surrender = rules_data['surrender']
    @double_any_two_cards = rules_data['doubleAnyTwoCards']
    @double_after_split = rules_data['doubleAfterSplit']
    @resplit_aces = rules_data['resplitAces']
    @hit_split_aces = rules_data['hitSplitAces']
    @blackjack_bets = rules_data['blackjackBets']
    @blackjack_pays = rules_data['blackjackPays']
    @penetration = rules_data['penetration']
  end

  # Utility function to convert boolean to string
  def bool_to_string(value)
    value ? "true" : "false"
  end

  # Placeholder for environment URL
  def get_rules_url
    ENV['STRIKER_URL_RULES']
  end
end

# Example usage:
# rules = Rules.new("single-deck")
# rules.print
# puts rules.serialize_rules
