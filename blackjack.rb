#banco de conhecimento: tabela com o valor das cartas
CARDS_VALUE = {

    "K"=> 10,

    "Q"=> 10,

    "J"=>10,

    "10"=>10,

    "9"=> 9,

    "8"=> 8,

    "7"=> 7,

    "6"=> 6,

    "5"=> 5,

    "4"=> 4,

    "3"=> 3,

    "2"=> 2,

    "A" => 1

}


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

class Deck
  attr_accessor :cards

  def initialize(qtd_decks: 1 , qtd_card: 4 * qtd_decks)
    cards_qtd = CARDS_VALUE.clone #Clona o array de valor para criarmos um array de quantidade
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

class Player
  attr_accessor :hand

  def initialize(cards)
    @hand = Hand.new cards
  end

end
# deck = Deck.new
# ia = Robot.new [deck.get_card,deck.get_card]
# ia.hand.show_hand
# puts ia.get_another_card?
#
# while ia.get_another_card?
#   ia.hand.add_card deck.get_card
#   puts ia.hand.cards.inspect
# end
# ia.hand.show_hand
exit = false

#Programa rodando
until exit == true
  deck ||= Deck.new
  ia ||= Robot.new [deck.get_card,deck.get_card]
  player ||= Player.new [deck.get_card,deck.get_card]

  player.hand.show_hand

  puts "Escolha uma opção:"
  puts %{
    1) Pegar outra carta
    2) Parar
  }

  option = gets.chomp #pego a opção
  case option
  when "1" #Pegar outra carta
    player.hand.add_card deck.get_card
  when "2" #Parar
    while ia.get_another_card?
      ia.hand.add_card deck.get_card
    end

    puts "Cartas da Máquina: "
    ia.hand.show_hand
    puts "Total Máquina:#{ia.hand.total}"
    puts "Total Jogador:#{player.hand.total}"
    gets
    system "clear"

    #Zerar o estado das varivaveis
    deck = nil
    ia = nil
    player = nil
  end


end
