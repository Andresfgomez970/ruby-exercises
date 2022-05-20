# frozen_string_literal: true

require_relative 'user'
require_relative 'table'
require_relative 'two_players_game_utils'

# Ches class for the game
class ChessGame
  include BasicUtils
  include TwoPLayersGameUtils

  def initialize(player1 = ChessGameUser.new({ chess_color: 'white' }),
                 player2 = ChessGameUser.new({ chess_color: 'black' }),
                 table = ChessTable.new)
    @player1 = player1
    @player2 = player2
    @table = table
  end

  def correct_notation_movement?(movement_str)
    movement_str.match(/^[a-h][1-8][a-h][1-8]$/)
  end

  def valid_input?(input, player)
    correct_notation_movement?(input) && @table.movement_valid?(input, player)
  end

  def get_valid_move(player, msg = 'Please select a move')
    input = gets_message("#{msg} #{player.name}")
    new_msg = "Please select a valid move #{player.name}"
    valid_input?(input, player) ? input : get_valid_move(player, new_msg)
  end

  def play_turn(current_player)
    input = get_valid_move(current_player)
    @table.move_piece(input)
    @table.draw_board
  end

  def game_ends?(current_player)
    @someone_won_state = @table.check_mate?(current_player)
    draw = @table.draw_game?
    @someone_won_state || draw
  end

  def reset_for_new_game
    @table.default_initialize
    player1 = { name: @player1.name, score: @player1.score }
    @player1 = ChessGameUser.new({ chess_color: @player1.chess_color, name: @player2.name, score: @player2.score })
    @player2 = ChessGameUser.new({ chess_color: @player2.chess_color, name: player1[:name], score: player1[:score] })
  end

  # standard, but here
  def play_game
    prepare_game
    play_recursive
  end

  def save_to_json
    Dir.mkdir('output') unless Dir.exist?('output')
    File.open("output/chess_game_#{@player1.name}vs#{@player2.name}.json", 'w') do |f|
      f.write(to_json)
    end
  end

  def fetch_state_game(data_json); end

  def fetch_user_info(data_json); end

  def init_from_json(json_filename)
    data_json = JSON.parse(File.read(json_filename))
    standart_init(data_json['data']['filename'])
    fetch_state_game(data_json)
    fetch_user_info(data_json)
    # substract in order to count correcly, this permits
    #  to enter again to play_round and have a correct number
    #  of rounds
    @rounds -= 1 if @wrong_number == @max_wrong
  end
end
