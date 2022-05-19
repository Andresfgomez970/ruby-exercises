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
    movement_str.match(/^[a-h][1-8][a-h][1-8]$/)
  end

  def get_valid_move(player, msg = 'Please select a move')
    input = gets_message("#{msg} #{player.name}")
    new_msg = "Please select a valid move #{player.name}"
    correct_notation_movement?(input) && @table.movement_valid?(input, player) ? input : get_valid_move(player, new_msg)
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

  def change_players(current_player)
    current_player == @player1 ? @player2 : @player1
  end

  def play_round
    @table.move_piece('d1f3')
    @table.move_piece('g1g5')
    @table.draw_board
    p @player1.chess_color

    current_player = @player1
    until game_ends?(current_player)
      play_turn(current_player)
      current_player = change_players(current_player)
    end
    update_scores(current_player)
  end

  def update_scores(current_player)
    change_players(current_player).score += 1 if @someone_won_state
  end

  def end_round
    puts win_message
    display_score('partial')
  end

  def end_game
    display_score('final')
    puts win_message
    puts final_message
  end

  def display_score(string)
    puts "\n------------ The #{string} score is ------------"
    puts "\t#{@player1.name} : #{@player1.score} \t and " \
      "\t #{@player2.name} : #{@player2.score}"
  end

  def win_message
    winner = winner_user
    if winner.nil?
      "Wow! That's a tie"
    else
      "The winner is #{winner_user}; congrats!!!"
    end
  end

  def winner_user
    if @player1.score > @player2.score
      @player1.name
    elsif @player1.score < @player2.score
      @player2.name
    else
      nil
    end
  end

  def final_message
    puts "Thanks for playing #{@player1.name} and #{@player2.name}"
  end

  def reset_for_new_game
    @table.default_initialize
    copy_cat = ChessGameUser.new({ chess_color: @player1.chess_color, name: @player1.name, score: @player1.score })
    @player1 = ChessGameUser.new({ chess_color: @player1.chess_color, name: @player2.name, score: @player2.score })
    @player2 = ChessGameUser.new({ chess_color: @player2.chess_color, name: copy_cat.name, score: copy_cat.score })
  end

  def play_recursive
    play_round
    end_round

    if exit_game?
      end_game
    else
      reset_for_new_game
      play_recursive
    end
  end

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

  def play_game
    prepare_game
    play_recursive
  end
end

ChessGame.new.play_game
