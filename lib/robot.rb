require_relative 'cards.rb'
require_relative 'deck.rb'
require_relative 'hand.rb'
class Robot
  attr_accessor :hand

  def initialize(cards, deck: Deck.new)
    @hand = Hand.new cards
    @deck = deck.clone #recebe o deck para calcular a probabilidade,se nenhum é passado ele assume que o deck padrão com apenas um baralho
  end

  def get_another_card? #Decide se a IA deve pegar outra carta
    return false if @hand.total >= 21 #Retorna falso se já atingimos 21 ou passamos dele
    #Pra cada carta que tiver no baralho vamos retirar uma da que ja possuimos
    @hand.cards.each{|card| @deck.cards[card] = @deck.cards[card] - 1 }
    card_probability = calculate_probability
    points_to_21 = 21 - @hand.total
    good_card_probability = card_probability.select{|card,value| CARDS_VALUE[card] <= points_to_21 }.values.reduce(:+)
    good_card_probability >= 50.0 #Verifica se a probabilidade for maior que 50%
  end

  private

  #Retorna um Hash com as probabilidades de pegar cada carta
  def calculate_probability
    total = @deck.cards.values.reduce(:+) #soma o total de cartas ainda possiveis
    cards_probability = @deck.cards
    cards_probability.keys.each{|card| cards_probability[card] = (cards_probability[card].to_f / total) * 100}
    cards_probability
  end
end
