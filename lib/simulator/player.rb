# frozen_string_literal: true

require_relative '../cards/shoe'
require_relative '../cards/hand'
require_relative '../arguments/report'
require_relative '../cards/wager'
require_relative '../table/rules'
require_relative '../table/strategy'

class Player
  attr_accessor :rules, :strategy, :number_of_cards, :wager, :splits, :report, :seen_cards, :up_card, :down_card

  def initialize(rules, strategy, number_of_cards)
    @rules = rules
    @strategy = strategy
    @number_of_cards = number_of_cards
    @wager = Wager.new(MINIMUM_BET, MAXIMUM_BET)
    @splits = []
    @report = Report.new(nil)
    @seen_cards = Array.new(13, 0)
  end

  def shuffle
    @seen_cards.fill(0)
  end

  def place_bet(mimic)
    @splits.clear
    @wager.reset
    @wager.place_bet(mimic ? MINIMUM_BET : @strategy.get_bet(@seen_cards))
  end

  def insurance
    return unless @strategy.get_insurance(@seen_cards)

    @wager.insurance_bet = @wager.amount_bet / 2
  end

  def play(up, shoe, mimic)
    if @wager.blackjack?
      @report.total_blackjacks += 1
      return
    end

    if mimic
      draw_card(@wager, shoe.draw_card) until mimic_stand
      return
    end

    if @strategy.get_double(@seen_cards, @wager.hand_total, @wager.soft?, up)
      @wager.double_bet
      draw_card(@wager, shoe.draw_card)
      @report.total_doubles += 1
      return
    end

    if @wager.pair? && @strategy.get_split(@seen_cards, @wager.card_pair, up)
      split = Wager.new(MINIMUM_BET, MAXIMUM_BET)
      @wager.split_hand(split)
      @splits.push(split)
      @report.total_splits += 1

      if @wager.pair_of_aces?
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

    stand = @strategy.get_stand(@seen_cards, @wager.hand_total, @wager.soft?, up)
    until @wager.busted? || stand
      # puts "hit #{wager.hand_total}"
      draw_card(@wager, shoe.draw_card)
      stand = @strategy.get_stand(@seen_cards, @wager.hand_total, @wager.soft?, up) unless @wager.busted?
      # puts "stand #{stand}"
    end
  end

  def play_split(wager, shoe, up)
    if wager.pair? && @strategy.get_split(@seen_cards, wager.card_pair, up)
      split = Wager.new(MINIMUM_BET, MAXIMUM_BET)
      @splits.push(split)
      @report.total_splits += 1
      wager.split_hand(split)
      draw_card(wager, shoe.draw_card)
      play_split(wager, shoe, up)
      draw_card(split, shoe.draw_card)
      play_split(split, shoe, up)
      return
    end

    stand = @strategy.get_stand(@seen_cards, wager.hand_total, wager.soft?, up)
    until wager.busted? || stand
      draw_card(wager, shoe.draw_card)
      stand = @strategy.get_stand(@seen_cards, wager.hand_total, wager.soft?, up) unless wager.busted?
    end
  end

  def draw_card(hand, card)
    show_card(card)
    hand.draw_card(card)
  end

  def show_card(card)
    @seen_cards[card.value] += 1
  end

  def busted_or_blackjack?
    return @wager.busted? || @wager.blackjack? if @splits.empty?

    @splits.all?(&:busted?)
  end

  def payoff(dealer_blackjack, dealer_busted, dealer_total)
    if @splits.empty?
      payoff_hand(@wager, dealer_blackjack, dealer_busted, dealer_total)
    else
      payoff_split(@wager, dealer_busted, dealer_total)
      @splits.each do |split|
        payoff_split(split, dealer_busted, dealer_total)
      end
    end
  end

  def payoff_hand(wager, dealer_blackjack, dealer_busted, dealer_total)
    if dealer_blackjack
      wager.won_insurance
      wager.push if wager.blackjack?
      wager.lost unless wager.blackjack?
    else
      wager.lost_insurance
      if wager.blackjack?
        wager.won_blackjack(@rules.blackjack_pays, @rules.blackjack_bets)
      elsif wager.busted?
        # puts "busted #{wager.hand_total}"
        wager.lost
        @report.total_loses += 1
      elsif dealer_busted || wager.hand_total > dealer_total
        wager.won
        @report.total_wins += 1
      elsif dealer_total > wager.hand_total
        wager.lost
        @report.total_loses += 1
      else
        wager.push
        @report.total_pushes += 1
      end
    end

    @report.total_bet += wager.amount_bet + wager.insurance_bet
    @report.total_won += wager.amount_won + wager.insurance_won
  end

  def payoff_split(wager, dealer_busted, dealer_total)
    if wager.busted?
      wager.lost
      @report.total_loses += 1
    elsif dealer_busted || wager.hand_total > dealer_total
      wager.won
      @report.total_wins += 1
    elsif dealer_total > wager.hand_total
      wager.lost
      @report.total_loses += 1
    else
      wager.push
      @report.total_pushes += 1
    end

    @report.total_won += wager.amount_won
    @report.total_bet += wager.amount_bet
  end

  def mimic_stand
    return false if @wager.soft_seventeen?

    @wager.hand_total >= 17
  end
end
