require_relative 'card'

class Shoe
  attr_reader :number_of_cards

  SUITS = ['spades', 'diamonds', 'clubs', 'hearts']
  RANKS = {
    'two' => 2, 'three' => 3, 'four' => 4, 'five' => 5,
    'six' => 6, 'seven' => 7, 'eight' => 8, 'nine' => 9,
    'ten' => 10, 'jack' => 10, 'queen' => 10, 'king' => 10, 'ace' => 11
  }
  KEYS = ['2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A']

  def initialize(number_of_decks, penetration)
    @cards = []
    number_of_decks.times do
      SUITS.each do |suit|
        RANKS.each_with_index do |(rank, value), offset|
          @cards << Card.new(suit, rank, KEYS[offset], value, offset)
        end
      end
    end
    @number_of_cards = @cards.size
    @next_card = @number_of_cards
    @last_discard = @number_of_cards
    @cut_card = (@number_of_cards * penetration).to_i
    @force_shuffle = false
    shuffle
  end

  def draw_card
    if @next_card >= @number_of_cards
      @force_shuffle = true
      shuffle_random
    end
    card = @cards[@next_card]
    @next_card += 1
    card
  end

  def shuffle
    @last_discard = @number_of_cards
    @force_shuffle = false
    shuffle_random
  end

  def should_shuffle?
    @last_discard = @next_card
    @next_card >= @cut_card || @force_shuffle
  end

  def is_ace?(card)
    card.ace?
  end

  def display
    puts '-' * 80
    @cards.each_with_index do |card, index|
      puts format('%03d: ', index) + card.display
    end
    puts '-' * 80
  end

  private

  def shuffle_random
    @cards.shuffle!
    @next_card = 1
  end
end
