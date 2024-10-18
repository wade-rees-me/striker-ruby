require_relative 'strategy'
require_relative '../cards/shoe'
require_relative '../cards/hand'
require_relative '../arguments/report'
require_relative '../cards/wager'
require_relative '../arguments/parameters'
require_relative '../table/rules'

class Player
  attr_accessor :parameters, :rules, :number_of_cards, :wager, :splits, :strategy, :report, :seen_cards

  def initialize(parameters, rules, number_of_cards)
    @parameters = parameters
    @rules = rules
    @number_of_cards = number_of_cards
    @strategy = Strategy.new(parameters.playbook, number_of_cards)
    @wager = Wager.new
    @splits = []
    @report = Report.new
    @seen_cards = Array.new(13, 0)
  end

  def shuffle
    @seen_cards.fill(0)
  end

  def place_bet(mimic)
    @splits.clear
    @wager.reset
    @wager.amount_bet = mimic ? MINIMUM_BET : @strategy.get_bet(@seen_cards)
  end

  def insurance
    if @strategy.get_insurance(@seen_cards)
      @wager.insurance_bet = @wager.amount_bet / 2
    end
  end

  def play(up, shoe, mimic)
    return if @wager.is_blackjack?

    if mimic
      while !mimic_stand
        draw_card(@wager, shoe.draw_card)
      end
      return
    end

    @strategy.do_play(@seen_cards, @wager.have_cards, @wager.is_pair? ? @wager.get_card_pair : nil, up)
    if @rules.surrender && @strategy.get_surrender(@seen_cards, @wager.have_cards, up)
      @strategy.clear
      @wager.surrender
      return
    end

    if (@rules.double_any_two_cards || [10, 11].include?(@wager.hand_total)) && @strategy.get_double(@seen_cards, @wager.have_cards, up)
      @strategy.clear
      @wager.double_bet
      draw_card(@wager, shoe.draw_card)
      return
    end

    if @wager.is_pair? && @strategy.get_split(@seen_cards, @wager.get_card_pair, up)
      @strategy.clear
      split = Wager.new
      @wager.split_hand(split)
      @splits.push(split)

      if @wager.is_pair_of_aces? && !@rules.resplit_aces && !@rules.hit_split_aces
        draw_card(@wager, shoe.draw_card)
        draw_card(split, shoe.draw_card)
        return
      end

      draw_card(@wager, shoe.draw_card)
      play_split(@wager, shoe, up)
      draw_card(split, shoe.draw_card)
      play_split(split, shoe, up)
      return
    end

    stand = @strategy.get_stand(@seen_cards, @wager.have_cards, up)
    @strategy.clear
    until @wager.is_busted? || stand
      # puts "hit #{wager.hand_total}"
      draw_card(@wager, shoe.draw_card)
      stand = @strategy.get_stand(@seen_cards, @wager.have_cards, up)
      # puts "stand #{stand}"
    end
  end

  def play_split(wager, shoe, up)
    if @rules.double_after_split && @strategy.get_double(@seen_cards, wager.have_cards, up)
      wager.double_bet
      draw_card(wager, shoe.draw_card)
      return
    end

    if wager.is_pair?
      if wager.is_pair_of_aces? && @rules.resplit_aces && @strategy.get_split(@seen_cards, wager.get_card_pair, up)
        split = Wager.new
        @splits.push(split)
        wager.split_hand(split)
        draw_card(wager, shoe.draw_card)
        play_split(wager, shoe, up)
        draw_card(split, shoe.draw_card)
        play_split(split, shoe, up)
        return
      end
    end

    stand = @strategy.get_stand(@seen_cards, wager.have_cards, up)
    until wager.is_busted? || stand
      draw_card(wager, shoe.draw_card)
      stand = @strategy.get_stand(@seen_cards, wager.have_cards, up)
    end
  end

  def draw_card(hand, card)
    show_card(card)
    hand.draw_card(card)
  end

  def show_card(card)
    @seen_cards[card.offset] += 1
  end

  def busted_or_blackjack?
    return @wager.is_busted? || @wager.is_blackjack? if @splits.empty?

    @splits.all?(&:is_busted?)
  end

  def payoff(dealer_blackjack, dealer_busted, dealer_total)
    if @splits.empty?
      payoff_hand(@wager, dealer_blackjack, dealer_busted, dealer_total)
    else
      @splits.each do |split|
        payoff_split(split, dealer_busted, dealer_total)
      end
    end
  end

  def payoff_hand(wager, dealer_blackjack, dealer_busted, dealer_total)
    if wager.did_surrender?
      @report.total_bet += wager.amount_bet
      @report.total_won -= wager.amount_bet / 2
      return
    end

    if dealer_blackjack
      wager.won_insurance
      wager.push if wager.is_blackjack?
      wager.lost unless wager.is_blackjack?
    else
      wager.lost_insurance
      if wager.is_blackjack?
        wager.won_blackjack(@rules.blackjack_pays, @rules.blackjack_bets)
      elsif wager.is_busted?
        # puts "busted #{wager.hand_total}"
        wager.lost
      elsif dealer_busted || wager.hand_total > dealer_total
        wager.won
      elsif dealer_total > wager.hand_total
        wager.lost
      else
        wager.push
      end
    end

    @report.total_bet += wager.amount_bet + wager.insurance_bet
    @report.total_won += wager.amount_won + wager.insurance_won
  end

  def payoff_split(wager, dealer_busted, dealer_total)
    if wager.is_busted?
      wager.lost
    elsif dealer_busted || wager.hand_total > dealer_total
      wager.won
    elsif dealer_total > wager.hand_total
      wager.lost
    else
      wager.push
    end

    @report.total_won += wager.amount_won
    @report.total_bet += wager.amount_bet
  end

  def mimic_stand
    return false if @wager.is_soft_17?

    @wager.hand_total >= 17
  end
end
