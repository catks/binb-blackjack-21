Dir["lib/*.rb"].each {|file| require_relative file }
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

  def puts_separator
    puts "----------------------------------------"
  end

  def show_winner

    puts "Cartas da Máquina: "
    @ia.hand.show_hand
    puts_separator
    puts "Total Máquina:#{@ia.hand.total}"
    puts "Total Jogador:#{@player.hand.total}"
    puts_separator
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
    loop do
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
  end

  def start_score
    Game.clear_screen
    puts "SCORE 21"
    # puts "Jogador |Vitorias |Empates|Derrotas |"
    # Score.all.each do |score|
    #   puts "#{score.player} |#{score.victories} |#{score.draws}  |#{score.losses}"
    # end


    #tp Score.reverse(:victories).all , {jogador:{ display_method: :player}}, {vitorias:{display_method: :victories}}, {empates:{display_method: :draws}}, {derrotas: {display_method: :losses}}
    puts_separator
    tp Score.all.sort_by{|s| [s.victories, s.draws,-s.losses]}.reverse , {jogador:{ display_method: :player}}, {vitorias:{display_method: :victories}}, {empates:{display_method: :draws}}, {derrotas: {display_method: :losses}}
    puts_separator
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
        puts_separator
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
          Game.clear_screen
          puts "Qual é o seu nome?"
          nome = gets.chomp
          Score.create(player: nome,victories: @player_victories,draws: @player_draws, losses: @ia_victories)
          start_score
          break
        end

      end
      Game.clear_screen
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
