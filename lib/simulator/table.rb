require_relative '../arguments/parameters'
require_relative '../table/rules'
require_relative 'player'
require_relative '../cards/dealer'
require_relative '../cards/shoe'
require_relative '../arguments/report'

class Table
  attr_accessor :parameters, :shoe, :dealer, :player, :report

  def initialize(params, rules)
    @parameters = params
    @shoe = Shoe.new(@parameters.number_of_decks, rules.penetration)
    @dealer = Dealer.new(rules.hit_soft_17)
    @player = Player.new(@parameters, rules, @shoe.number_of_cards)
    @report = Report.new
  end

  def session(mimic)
    puts "      Start: table, playing #{@parameters.number_of_hands} hands"
    @report.start = Time.now.to_i

    while @report.total_hands < @parameters.number_of_hands
      status(@report.total_rounds, @report.total_hands)
      @shoe.shuffle
      @player.shuffle
      @report.total_rounds += 1

      while !@shoe.should_shuffle?
        @report.total_hands += 1
        @dealer.reset
        @player.place_bet(mimic)

        up_card = deal_cards(@player.wager)
        @player.insurance if !mimic && up_card.is_ace?

        unless @dealer.hand.is_blackjack?
          @player.play(up_card, @shoe, mimic)
          @dealer.play(@shoe) unless @player.busted_or_blackjack?
        end

        @player.payoff(@dealer.hand.is_blackjack?, @dealer.hand.is_busted?, @dealer.hand.hand_total)
        @player.show_card(up_card)
      end
    end

    @report.end = Time.now.to_i
    @report.duration = @report.end - @report.start
    puts "      End: table"
  end

  def deal_cards(hand)
    @player.draw_card(hand, @shoe.draw_card)
    up_card = @shoe.draw_card
    @dealer.draw_card(up_card)
    @player.draw_card(hand, @shoe.draw_card)
    @dealer.draw_card(@shoe.draw_card)
    @player.show_card(up_card)
    up_card
  end

  def show(card)
    @player.show_card(card)
  end

  private

  def status(round, hand)
    if round == 0
      print "        "
    end

    if (round + 1) % STATUS_DOT == 0
      print "."
    end

    if (round + 1) % STATUS_LINE == 0
      puts " : #{round + 1} (rounds), #{hand} (hands)"
      print "        "
    end
  end
end
