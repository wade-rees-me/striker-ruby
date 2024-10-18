class Hand
  attr_reader :hand_total, :have_cards

  def initialize
    @cards = []
    @have_cards = Array.new(13, 0)
    @hand_total = 0
    @soft_ace = 0
    @hand_surrendered = false
  end

  def reset
    @hand_total = 0
    @soft_ace = 0
    @hand_surrendered = false
    @cards.clear
    @have_cards.fill(0)
  end

  def draw_card(card)
    @cards << card
    calculate_total
    card
  end

  def is_blackjack?
    @cards.size == 2 && @hand_total == 21
  end

  def is_pair?
    @cards.size == 2 && @cards[0].rank == @cards[1].rank
  end

  def get_card_pair
    @cards[0]
  end

  def is_pair_of_aces?
    is_pair? && @cards[0].rank == 'ace'
  end

  def is_busted?
    @hand_total > 21
  end

  def is_soft?
    @soft_ace > 0
  end

  def is_soft_17?
    @hand_total == 17 && is_soft?
  end

  def split_pair
    if is_pair?
      card = @cards.pop
      calculate_total
      card
    else
      raise "Error: Trying to split a non-pair"
    end
  end

  def surrender
    @hand_surrendered = true
  end

  def did_surrender?
    @hand_surrendered
  end

  private

  def calculate_total
    @hand_total = 0
    @soft_ace = 0
    @have_cards.fill(0)

    @cards.each do |card|
      @hand_total += card.value
      @soft_ace += 1 if card.value == 11
      @have_cards[card.offset] += 1
    end

    # Adjust hand total if it's over 21 and there are soft aces
    while @hand_total > 21 && @soft_ace > 0
      @hand_total -= 10
      @soft_ace -= 1
    end
  end
end