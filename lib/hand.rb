require_relative 'cards'
class Hand

  attr_accessor :cards

  def initialize(cards=[])
    cards.each{|card| add_card card}
  end

  def add_card(card)
    @cards ||= []
    @cards << card
  end

  def show_hand
    puts "#{@cards.inspect} Total:#{total}"
  end

  def total
    @cards.reduce(0){|sum,card| sum + CARDS_VALUE[card]}
  end

end
