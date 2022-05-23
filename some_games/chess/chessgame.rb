# frozen_string_literal: true

require_relative 'user'
require_relative 'table'
require_relative 'two_players_game_utils'
require_relative 'serialization_utils'

# Ches class for the game
class ChessGame
  include BasicUtils
  include TwoPLayersGameUtils
  include BasicSerializable

  def initialize(player1 = ChessGameUser.new({ chess_color: 'white' }),
                 player2 = ChessGameUser.new({ chess_color: 'black' }),
                 table = ChessTable.new)
    @player1 = player1
    @player2 = player2
    @table = table
    @current_player = @player1
  end

  def correct_notation_movement?(movement_str)
    from_to_notation = /^[a-h][1-8][a-h][1-8]$/
    algebraic_notation = /((^(B|K|N|R|Q| ){1}[a-h][1-8]$)|(^(B|K|N|R|Q|e){1}x[a-h][1-8]$)|(O-O)|(O-O-O)){1}/
    movement_str.match(from_to_notation) || movement_str.mathc(algebraic_notation)
  end

  def valid_input?(input, player)
    correct_notation_movement?(input) && @table.movement_valid?(input, player) || input == 'save'
  end

  def get_valid_move(player, msg = 'Please select a move')
    input = gets_message("#{msg} #{player.name} or type 'save' to save the game")
    new_msg = "Please select a valid move #{player.name}"
    valid_input?(input, player) ? input : get_valid_move(player, new_msg)
  end

  def update_game_state(input)
    if input == 'save'
      save
      end_save_game_message
      exit
    else
      @table.update_table_state(input)
    end
  end

  def play_turn(current_player)
    input = get_valid_move(current_player)
    update_game_state(input)
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

  def save
    save_to_json
  end

  def save_to_json
    Dir.mkdir('output') unless Dir.exist?('output')
    File.open("output/#{self.class}_#{@player1.name}_and_#{@player2.name}.json", 'w') do |f|
      f.write(serialize)
    end
  end

  def load_game
    json_filename = "output/#{self.class}_#{@player1.name}_and_#{@player2.name}.json"
    unserialize(File.read(json_filename))
  end
end

if __FILE__ == $PROGRAM_NAME
  player1 = ChessGameUser.new({ name: 'andres' })
  game = ChessGame.new(player1)
  game.save_to_json
  json_filename = 'output/ChessGame_andres_and_juan.json'
  game.unserialize(File.read(json_filename))
  game.instance_variable_get(:@table).draw_board
end
