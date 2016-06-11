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

require_relative 'database.rb'
require 'table_print'
class Game

  def self.show_start_screen
    clear_screen

    puts %q{
       ____  _            _    _            _      ___  __
      |  _ \| |          | |  (_)          | |    |__ \/_ |
      | |_) | | __ _  ___| | ___  __ _  ___| | __    ) || |
      |  _ <| |/ _` |/ __| |/ / |/ _` |/ __| |/ /   / / | |
      | |_) | | (_| | (__|   <| | (_| | (__|   <   / /_ | |
      |____/|_|\__,_|\___|_|\_\ |\__,_|\___|_|\_\ |____||_|
                        _/ |
                       |__/
                                    _____
        _____                _____ |6    |
       |2    | _____        |5    || ^ ^ |
       |  ^  ||3    | _____ | ^ ^ || ^ ^ | _____
       |     || ^ ^ ||4    ||  ^  || ^ ^ ||7    |
       |  ^  ||     || ^ ^ || ^ ^ ||____9|| ^ ^ | _____
       |____Z||  ^  ||     ||____S|       |^ ^ ^||8    | _____
              |____E|| ^ ^ |              | ^ ^ ||^ ^ ^||9    |
                     |____h|              |____L|| ^ ^ ||^ ^ ^|
                                                 |^ ^ ^||^ ^ ^|
                                                 |____8||^ ^ ^|
                                                        |____6|

  Pressione 'S' para visualizar o Scoreboard
  Pressione 'Q' para sair
  Ou Pressione qualquer outra tecla para começar...}
  end

  def self.clear_screen
    Gem.win_platform? ? (system "cls") : (system "clear")
  end

  def self.verify_winner(player,ia)
     total_player = player.hand.total
     total_ia = ia.hand.total

     if total_player == total_ia
       return :draw
     end
     winner = {player:total_player,ia:total_ia}.select{|k,v| v <= 21}.max_by{|k,v| v}&.first
     winner ||= :no_winner # Se os dois passaram de 21 retornamos :no_winner se não retornamos o vencedor
  end

  def show_winner

    puts "Cartas da Máquina: "
    @ia.hand.show_hand
    puts "Total Máquina:#{@ia.hand.total}"
    puts "Total Jogador:#{@player.hand.total}"

    result = case Game.verify_winner(@player,@ia)
      when :player then "Você venceu! Parabéns"
      when :ia then "O computador ganhou"
      when :draw then "Deu empate!"
      when :no_winner then "Ninguém ganhou!"
    end
    puts result
  end

  def show_score
    puts "Vitorias: #{@player_victories}"
    puts "Empates: #{@player_draws}"
    puts "Derrotas: #{@ia_victories}"
  end

  def start
    #Programa rodando

    @player_victories = 0
    @player_draws = 0
    @ia_victories = 0
    Game.show_start_screen

    case gets.chomp
      when "S" then start_score
      when "Q" then return
      else start_game
    end

  end

  def start_score
    Game.clear_screen
    puts "SCORE 21"
    # puts "Jogador |Vitorias |Empates|Derrotas |"
    # Score.all.each do |score|
    #   puts "#{score.player} |#{score.victories} |#{score.draws}  |#{score.losses}"
    # end


    tp Score.reverse(:victories).all , {jogador:{ display_method: :player}}, {vitorias:{display_method: :victories}}, {empates:{display_method: :draws}}, {derrotas: {display_method: :losses}}
    gets
  end

  def start_game
    Game.clear_screen
    #until exit == true
    while true
      @deck ||= Deck.new
      @ia ||= Robot.new [@deck.get_card,@deck.get_card]
      @player ||= Player.new [@deck.get_card,@deck.get_card]

      @player.hand.show_hand

      puts "Escolha uma opção:"
      puts %{
        1) Pegar outra carta
        2) Parar
      }

      option = gets.chomp #pego a opção
      case option
      when "1" #Pegar outra carta
        @player.hand.add_card @deck.get_card
      when "2" #Parar
        while @ia.get_another_card?
          @ia.hand.add_card @deck.get_card
        end

        winner = Game.verify_winner(@player,@ia)
        @player_victories += 1 if winner == :player
        @player_draws += 1 if winner == :draw
        @ia_victories += 1 if winner == :ia
        show_winner
        show_score
        gets
        Game.clear_screen

        #Zerar o estado das varivaveis
        @deck = nil
        @ia = nil
        @player = nil

        #
        puts "Deseja Continuar? (S/N)"
        if gets.chomp == "N"
          puts "Qual é o seu nome?"
          nome = gets.chomp
          Score.create(player: nome,victories: @player_victories,draws: @player_draws, losses: @ia_victories)
          start_score
          break
        end
        Game.clear_screen
      end

    end
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
#exit = false
Game.new.start
