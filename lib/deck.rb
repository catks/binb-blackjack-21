require_relative 'cards.rb'
class Deck
  attr_accessor :cards

  def initialize(qtd_decks: 1 , qtd_card: 4 * qtd_decks)
    cards_qtd = CARDS_VALUE.dup #Clona o array de valor para criarmos um array de quantidade
    cards_qtd.each{|key,value| cards_qtd[key] = qtd_card}
    @cards = cards_qtd
  end

  def get_card
    possible_cards = @cards.keys.select{|key| @cards[key] > 0 }
    card = possible_cards.sample
    @cards[card] = @cards[card] - 1
    card
  end
end
