# frozen_string_literal: true

# User class to save people playing
class User
  ##
  # This is a basic user class
  attr_accessor :name, :score

  def initialize(name)
    @name = name
    @score = 0
  end
end

# Class for users of the tictactoe game
class TicTacToeUser < User
  ##
  # This is an user class for a tictatoe game
  attr_accessor :mark

  def initialize(name, mark)
    super(name)
    @mark = mark
  end
end

# The table for the given game
class Table
  ##
  # Table define a class that constains the data which is drawn in the
  #   tictactoe game
  attr_accessor :symbols

  def initialize
    @symbols = (1..9).to_a
  end

  def draw_row(col1, col2, col3)
    puts "\t\t . \t ."
    puts "\t    #{col1} \t .   #{col2} \t .   #{col3}"
    puts "\t\t . \t ."
  end

  def draw_line
    puts "\t. . . . . . . . . . . . . ."
  end

  def draw_table
    puts "\n\n"
    draw_row(@symbols[0], @symbols[1], @symbols[2])
    draw_line
    draw_row(@symbols[3], @symbols[4], @symbols[5])
    draw_line
    draw_row(@symbols[6], @symbols[7], @symbols[8])
    puts "\n\n"
  end
end

# Basic utils module
module BasicUtils
  def gets_message(message)
    puts message
    gets.chomp
  end
end


# Class that has all the functionalities of the game
class TicTacToe
  include BasicUtils

  def initialize
    @users = []
    @table = Table.new
  end

  def enter_name(symbol)
    name1 = gets_message("Plase enter the name of the first player to play (#{symbol})")
    @users.push(TicTacToeUser.new(name1, symbol))
  end

  def prepare_game
    %w[x o].each { |s| enter_name(s) }
    puts "\nLet the game begin #{@users[0].name} and #{@users[1].name}!!"
  end

  def play_movement(draw_symbol)
    @table.draw_table
    @table.symbols[chosen_number - 1] = draw_symbol
    @table.draw_table
  end

  def chosen_number
    number = gets_message('Please enter a number')
    until number.match?(/^[0-9]$/) && @table.symbols.include?(number.to_i)
      number = gets_message('Please select a valid number')
    end
    number.to_i
  end

  def update_scores
    ## condition to select winner
    @users.each_with_index do |user, i|
      @users[i].score = (user.mark == someone_won ? user.score + 1 : user.score)
    end
  end

  def check_tictactoe(indexes)
    @table.symbols[indexes[0]] == @table.symbols[indexes[1]] &&
      @table.symbols[indexes[0]] == @table.symbols[indexes[2]]
  end

  def someone_won
    lines = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8]]

    lines.each do |line|
      return @table.symbols[line[0]] if check_tictactoe(line)
    end
    false
  end

  def play_round
    display_score('partial')
    (0..9).each do |counter|
      if counter.even?
        play_movement('x')
      else
        play_movement('o')
      end
      break if someone_won
    end
    update_scores
  end

  def exit_game?(answer)
    puts 'Do you want to finish the game? (y/n)'
    answer = gets_message('please enter a valid option: (y/n)') while answer != 'y' && answer != 'n'
    answer == 'y'
  end

  def reset_for_new_game
    @table.symbols = (1..9).to_a
    @users.each_with_index { |user, i| @users[i].mark = (user.mark == 'x' ? 'o' : 'x') }
    begin_user_name = @users.filter_map { |user| user.name if user.mark == 'x' }
    puts "\nNow user #{begin_user_name[0]} begins"
  end

  def play_recursive
    play_round

    if exit_game?(gets.chomp)
      end_game
    else
      reset_for_new_game
      play_recursive
    end
  end

  def winner_user
    if @users[0].score > @users[1].score
      @users[0].name
    elsif @users[0].score < @users[1].score
      @users[1].name
    else
      nil
    end
  end

  def win_message
    winner = winner_user
    if winner.nil? && @users[0].score != 0
      "Wow! That's a tie"
    else
      "The winner is #{winner_user}; congrats!!!"
    end
  end

  def display_score(string)
    puts "\n------------ The #{string} score is ------------"
    puts "\t#{@users[0].name} : #{@users[0].score} \t and " \
      "\t #{@users[1].name} : #{@users[1].score}"
  end

  def play_game
    prepare_game
    play_recursive
  end

  def end_game
    display_score('final')
    puts win_message
    puts "Thanks for playing #{@users[0].name} and #{@users[1].name}"
  end
end

TicTacToe.new.play_game
