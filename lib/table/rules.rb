# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'
require_relative 'request'

class Rules < Request
  attr_accessor :playbook, :hit_soft_seventeen, :surrender, :double_any_two_cards, :double_after_split,
                :resplit_aces, :hit_split_aces, :blackjack_pays, :blackjack_bets, :penetration,
                :json_response

  def initialize(decks)
    @id = ''
    @playbook = ''
    @hit_soft_seventeen = true
    @surrender = false
    @double_any_two_cards = true
    @double_after_split = false
    @resplit_aces = false
    @hit_split_aces = false
    @blackjack_pays = 5
    @blackjack_bets = 3
    @penetration = 0.70

    fetch_json("http://#{rules_url}/#{decks}")
    rules_fetch_table
  end

  # Print the rules
  def print
    puts format("    %-24s\n", 'Table Rules')
    puts format('      %-24s: %s', 'Table', @playbook)
    puts format('      %-24s: %s', 'Hit soft 17', bool_to_string(@hit_soft_seventeen))
    puts format('      %-24s: %s', 'Surrender', bool_to_string(@surrender))
    puts format('      %-24s: %s', 'Double any two cards', bool_to_string(@double_any_two_cards))
    puts format('      %-24s: %s', 'Double after split', bool_to_string(@double_after_split))
    puts format('      %-24s: %s', 'Resplit aces', bool_to_string(@resplit_aces))
    puts format('      %-24s: %s', 'Hit split aces', bool_to_string(@hit_split_aces))
    puts format('      %-24s: %d', 'Blackjack bets', @blackjack_bets)
    puts format('      %-24s: %d', 'Blackjack pays', @blackjack_pays)
    puts format('      %-24s: %0.3f %%', 'Penetration', @penetration)
  end

  # Serialize the rules into a JSON string
  def serialize
    data = {
      hit_soft_seventeen: @hit_soft_seventeen ? 'true' : 'false',
      surrender: @surrender ? 'true' : 'false',
      double_any_two_cards: @double_any_two_cards ? 'true' : 'false',
      double_after_split: @double_after_split ? 'true' : 'false',
      resplit_aces: @resplit_aces ? 'true' : 'false',
      hit_split_aces: @hit_split_aces ? 'true' : 'false',
      blackjack_bets: @blackjack_bets,
      blackjack_pays: @blackjack_pays,
      penetration: @penetration
    }
    JSON.pretty_generate(data)
  end

  private

  # Fetch the rules from a remote URL
  def rules_fetch_table
    @id = json_response['_id']
    @playbook = json_response['playbook']
    @hit_soft_seventeen = json_response['hitSoft17']
    @surrender = json_response['surrender']
    @double_any_two_cards = json_response['doubleAnyTwoCards']
    @double_after_split = json_response['doubleAfterSplit']
    @resplit_aces = json_response['resplitAces']
    @hit_split_aces = json_response['hitSplitAces']
    @blackjack_bets = json_response['blackjackBets']
    @blackjack_pays = json_response['blackjackPays']
    @penetration = json_response['penetration']
  end

  # Utility function to convert boolean to string
  def bool_to_string(value)
    value ? 'true' : 'false'
  end
end
