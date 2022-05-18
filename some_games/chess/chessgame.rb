# frozen_string_literal: true

require_relative 'user'
require_relative 'table'
require_relative 'utils'

# utilities for two games with two players
module TwoPLayersUtils
  def obtain_play_mode
    message = <<~HEREDOC
      Please select a playing mode

      1. Player vs Computer

      2. Player vs Player
    HEREDOC
    options = %w[1 2]
    choose_option(message, options)
  end

  def create_players
    @player1.name = gets_message('Please enter player 1 name')
    @player2.name = @play_mode == '1' ? 'computer' : gets_message('Please enter player 2 name')
  end

  def prepare_game
    @play_mode = obtain_play_mode
    create_players
  end
end

# Ches class for the game
class ChessGame
  include BasicUtils
  include TwoPLayersUtils

  def initialize(player1 = ChessGameUser.new({ chess_color: 'white' }),
                 player2 = ChessGameUser.new({ chess_color: 'black' }),
                 table = ChessTable.new)
    @player1 = player1
    @player2 = player2
    @table = table
  end

  def correct_notation_movement?(movement_str)
    movement_str.mathh(/^[a-h][1-9][a-h][1-9]$/)
  end

  def get_valid_move(player, msg = 'select a move')
    input = gets_message(msg)
    correct_notation_movement?(input) && @table.movement_valid?(input, player) ? input : get_valid_move(msg)
  end

  def play_turn(current_player)
    input = get_valid_move(current_player)
    @table.move_piece(input)
    @table.draw_board
  end

  def game_ends?
    false
  end

  def play_round
    @table.draw_board
    current_player = @player1
    until game_ends?
      play_turn(current_player)
      # current_player = change_players(current_player)
    end
    # update_scores(current_player)
  end
end

ChessGame.new.play_round
