require_relative 'hand.rb'
class Player
  attr_accessor :hand

  def initialize(cards)
    @hand = Hand.new cards
  end

end
