# frozen_string_literal: true
require 'colorize'

# Basic utils module
module BasicUtils
  def gets_message(message)
    puts message
    gets.chomp
  end

  def choose_option(message, options)
    option = gets_message(message) until options.include?(option)
    option
  end

  def valid_yn_answer?(answer)
    %w[y n].include?(answer)
  end

  def exit_game?
    answer = gets_message('Do you want to finish the game? (y/n)')
    answer = gets_message('please enter a valid option: (y/n)') until valid_yn_answer?(answer)
    answer == 'y'
  end
end

# Table class to draw the game
class ConnectFourTable
  include BasicUtils

  def initialize
    default_initialize
  end

  def default_initialize
    @chip_spaces = default_chip_spaces
    @steps = [[1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1]]
  end

  def default_chip_spaces
    Array.new(6) { Array.new(7, ' ') }
  end

  def one_level_row(color_row = Array.new(7, ' '))
    color_row.each.reduce('|') { |sum, color| "#{sum}   #{color}  \t|" }
  end

  # Fcuntionality to draw all a row  of three levels
  def draw_row(color_row)
    # Fist level
    row = "#{one_level_row}\n#{one_level_row(color_row)}\n#{one_level_row}"
    # support below
    puts "#{'-' * Integer(@chip_spaces[0].length * 8.25)}  \n"
    puts row
  end

  def draw_choose_column
    res = "\n"
    res = ('0'..'6').to_a.each.reduce(res) { |sum, column| "#{sum}   #{column}  \t" }
    res += "\n\n"
    res = Array.new(7, 'v').each.reduce(res) { |sum, column| "#{sum}   #{column}  \t" }
    res += "\n\n"
    puts res
  end

  def reverse_index(array, index)
    array.length - index - 1
  end

  def draw_line
    puts "#{'-' * Integer(@chip_spaces[0].length * 8.25)}  \n"
  end

  def draw_color_table
    draw_choose_column
    @chip_spaces.length.times do |index|
      reverse_i = reverse_index(@chip_spaces, index)
      draw_row(@chip_spaces[reverse_i])
    end
    # draw last support above
    draw_line
  end

  def draw_select_message
    select_message = "\nPlease select a column to throw your chip (see the numers above) \n\n"
    puts select_message
  end

  def draw_table
    draw_color_table
    draw_select_message
  end

  def full?
    @chip_spaces.all? { |row| row.all? { |value| value != ' ' } }
  end

  def next_pos_n_steps(init_pos, step, n_steps)
    row_i = init_pos[0] + step[0] * n_steps
    col_i = init_pos[1] + step[1] * n_steps
    return nil if row_i >= @chip_spaces.length || col_i >= @chip_spaces[0].length

    @chip_spaces[row_i][col_i]
  end

  def four_line?(init_pos, step)
    line = (0..3).to_a.map { |n_steps| next_pos_n_steps(init_pos, step, n_steps) }
    line.all? { |value| value == line[0] && ![nil, ' '].include?(line[0]) }
  end

  def four_connected?
    @chip_spaces.length.times do |row_i|
      @chip_spaces[0].length.times do |column_i|
        @steps.each do |step|
          return true if four_line?([row_i, column_i], step)
        end
      end
    end
    false
  end

  def valid_column?(column)
    return false unless column.match(/\d+/)

    @chip_spaces[@chip_spaces.length - 1][Integer(column)] == ' '
  end

  def select_column_to_throw(player_name)
    msg = "#{player_name} turn"
    n_columns = (@chip_spaces[0].length - 1).to_s
    column = choose_option(msg, ('0'..n_columns).to_a)
    valid_column?(column) ? column : select_column_to_throw(player_name)
  end

  def throw_to_column(column, mark)
    column = Integer(column)
    void_space = @chip_spaces.map { |row| row[column] == ' ' }
    first_free_y = void_space.each_index.select { |i| void_space[i] == true }[0]
    @chip_spaces[first_free_y][column] = mark
  end
end

# default class for user of a simple game
class GameUser
  attr_accessor :name, :score

  def initialize(init_values = {})
    @name = init_values.fetch(:name, 'default_name')
    @score = init_values.fetch(:score, 0)
  end
end

# user for the connect four game
class ConnectFourUser < GameUser
  attr_reader :mark

  def initialize(init_values = {})
    super(init_values)
    @mark = init_values.fetch(:mark, 'o')
  end
end

# class to keep the connect four game
class ConnectFourGame
  include BasicUtils

  def initialize(player1 = ConnectFourUser.new({ mark: 'x'.red }), player2 = ConnectFourUser.new({ mark: 'o'.blue }),
                 table = ConnectFourTable.new)
    @player1 = player1
    @player2 = player2
    @table = table
    @someone_won_state = false
  end

  def someone_won?
    @table.four_connected?
  end

  def play_turn(current_player)
    column = @table.select_column_to_throw(current_player.name)
    @table.throw_to_column(column, current_player.mark)
    @table.draw_table
  end

  def game_ends?
    @someone_won_state = someone_won?
    @someone_won_state || @table.full?
  end

  def change_players(current_player)
    current_player == @player1 ? @player2 : @player1
  end

  def play_round
    @table.draw_table
    current_player = @player1
    until game_ends?
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

# p ConnectFourTable.new.four_connected? if __FILE__ == $PROGRAM_NAME
# ConnectFourGame.new.create_players if __FILE__ == $PROGRAM_NAME
ConnectFourGame.new.play_game if __FILE__ == $PROGRAM_NAME


# colores
# vs PC
# indicate mark
# indicate win first
