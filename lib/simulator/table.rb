# frozen_string_literal: true

require_relative '../arguments/parameters'
require_relative '../table/rules'
require_relative '../table/strategy'
require_relative 'player'
require_relative '../cards/dealer'
require_relative '../cards/shoe'
require_relative '../arguments/report'

class Table
  attr_accessor :parameters, :shoe, :dealer, :player, :report

  def initialize(params, rules, strategy)
    @parameters = params
    @shoe = Shoe.new(@parameters.number_of_decks, rules.penetration)
    @dealer = Dealer.new(rules.hit_soft_seventeen)
    @player = Player.new(rules, strategy, @shoe.number_of_cards)
    @report = Report.new(nil)
  end

  def session(mimic)
    @report.start = Time.now.to_i

    while @report.total_hands < @parameters.number_of_hands
      status(@report.total_rounds, @report.total_hands)
      @shoe.shuffle
      @player.shuffle
      @report.total_rounds += 1

      until @shoe.should_shuffle?
        @report.total_hands += 1
        @dealer.reset
        @player.place_bet(mimic)

        deal_cards(@player.wager)
        @player.insurance if !mimic && @up_card.ace?

        unless @dealer.hand.blackjack?
          @player.play(@up_card, @shoe, mimic)
          unless @player.busted_or_blackjack?
            until @dealer.should_stand
              card = @shoe.draw_card
              @dealer.draw_card(card)
              @player.show_card(card)
            end
          end
        end

        @player.show_card(@down_card)
        @player.payoff(@dealer.hand.blackjack?, @dealer.hand.busted?, @dealer.hand.hand_total)
      end
    end
    print "\r"

    @report.end = Time.now.to_i
    @report.duration = @report.end - @report.start
  end

  def deal_cards(hand)
    @player.draw_card(hand, @shoe.draw_card)
    @up_card = @shoe.draw_card
    @dealer.draw_card(@up_card)
    @player.show_card(@up_card)

    @player.draw_card(hand, @shoe.draw_card)
    @down_card = @shoe.draw_card
    @dealer.draw_card(@down_card)
  end

  def show(card)
    @player.show_card(card)
  end

  private

  def status(round, hand)
    return unless (round % 100_000).zero?

    print format("\r    Rounds: [%13s] Hands: [%13s]: Simulating...",
                 round.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1,'),
                 hand.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1,'))
    $stdout.flush
  end
end
