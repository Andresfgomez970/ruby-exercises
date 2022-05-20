# frozen_string_literal: true

# utilities for two games with two players
module TwoPLayersGameUtils
  include BasicUtils

  def change_players(current_player)
    current_player == @player1 ? @player2 : @player1
  end

  def welcome_mesage
    puts "Welcome to #{self.class}, we hope you enjoy playing\n\n"
  end

  def play_round
    @table.draw_board

    until game_ends?(@current_player)
      play_turn(@current_player)
      @current_player = change_players(@current_player)
    end
    update_scores(current_player)
  end

  def update_scores(current_player)
    change_players(current_player).score += 1 if @someone_won_state
  end

  def end_save_game_message
    puts 'The game has been successfully saved ... see you later!'
    final_message
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
    welcome_mesage
    @play_mode = obtain_play_mode
    create_players
    (load_game if load_game?) if methods.include?(:load_game)
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

  def play_recursive
    play_round
    end_round

    if exit_game?
      (save if save_game?) if methods.include?(:save)
      end_game
    else
      reset_for_new_game
      play_recursive
    end
  end
end
