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

# The table for the given game
class Table
  attr_accessor :colors, :matchs, :pointers

  def initialize
    default_initialize
  end

  def default_initialize
    @color_to_pick = %w[a b c d e f g h]
    @colors = default_colors
    @matchs = default_matchs
    @pointers = default_pointer
  end

  def default_colors
    Array.new(12) { Array.new(4, '\'') }
  end

  def default_matchs
    Array.new(12) { Array.new(2, 0) }
  end

  def default_pointer
    result = Array.new(12, ' ')
    result[0] = '<'
    result
  end

  ##
  # Table define a class that constains the data which is drawn in the
  #  game
  def draw_row(color_row, match_row, pointer)
    row = color_row.each.reduce('|') { |sum, color| "#{sum}   #{color}  \t|" }
    row += "  #{match_row[0]}  -  #{match_row[1]} o  #{pointer}\n"
    puts "#{'-' * 33}  \n"
    puts row
  end

  def draw_color_table
    12.times do |index|
      i = @colors.size - index - 1
      draw_row(@colors[i], @matchs[i], @pointers[i])
    end
    puts "#{'-' * 33}  \n"
  end

  def draw_color_picker
    select_message = "\nPlease select a 4 length code with the colors below (e.g. abcd)\n\n"
    row = @color_to_pick.first(4).each.reduce(select_message) do |sum, color|
      "#{sum}   #{color}  \t"
    end
    row2 = @color_to_pick.last(4).each.reduce("\n\n") { |sum, color| "#{sum}   #{color}  \t" }
    puts "#{row} #{row2} \n\n"
  end

  def draw_table
    draw_color_table
    draw_color_picker
  end
end

# Basic utils module
module BasicUtils
  def gets_message(message)
    puts message
    gets.chomp
  end

  def exit_game?
    answer = gets_message('Do you want to finish the game? (y/n)')
    p answer
    answer = gets_message('please enter a valid option: (y/n)') while answer != 'y' && answer != 'n'
    answer == 'y'
  end
end

# Class for the principal functions of the game
class MaterMind
  include BasicUtils

  def initialize
    @users = []
    @table = Table.new
    @back_table = Table.new
    @secret_code = generate_random_code
    @rounds = 0
    @guesser_state = false
    @colors = %w[a b c d e f g h]
    @possible_colors = @colors.repeated_permutation(4).to_a
    @filter_colors = @colors.repeated_permutation(4).to_a
  end

  def enter_name
    name1 = if @guesser_state
              gets_message('Plase enter the name of the user that will guess the code')
            else
              'computer'
            end
    @users.push(User.new(name1))
  end

  def prepare_game
    enter_name
    unless @guesser_state
      @table.draw_table
      puts 'Please enter a code so that the machine can guess it'
      parse_code(gets.chomp).join
    end
    puts "\n \tLet the game begin #{@users[0].name}!!"
  end

  def parse_code(input)
    arr_input = input.split('')
    reinput_message = 'Please enter a valid code: length of 4 and composed with the letters shown'
    until arr_input.all? { |e| e.between?('a', 'h') } && arr_input.length == 4
      input = gets_message(reinput_message)
      arr_input = input.split('')
    end
    arr_input
  end

  def computer_generated_code
    ('a'..'f').to_a.sample(4)
  end

  def possible_matches(chosen_colors)
    response_for_chosen_color = []
    @filter_colors.each do |colors|
      match_result = match_info(colors.join, chosen_colors.join)
      response_for_chosen_color.push(match_result)
    end
    response_for_chosen_color
  end

  def computer_guessed_code(number)
    if number.zero?
      'aabb'.split('')
    else
      @filter_colors = @possible_colors.select { |colors| match_info(colors.join) == @table.matchs[number - 1] }
      @filter_colors = @filter_colors.compact

      scores = []
      possible_colors = @possible_colors.dup
      possible_colors -= @table.colors

      possible_colors.each do |chosen_colors|
        response_for_chosen_color = possible_matches(chosen_colors)
        scores_for_chosen_color = response_for_chosen_color.each_with_object(Hash.new(0)) { |o, h| h[o] += 1 }
        final_score = scores_for_chosen_color.values.min
        scores.push(final_score)
      end
      # chose max min score
      max_score = scores[scores.each_with_index.max[1]]

      # select all colors with score >= max_score
      colors_to_chose = []
      scores.each_with_index do |score, index|
        colors_to_chose.push(possible_colors[index]) if score >= max_score
      end

      # select from @filter_colors wheneverpossible
      possible_colors_in_filter_colors = colors_to_chose.select { |colors| @filter_colors.include?(colors) }
      if possible_colors_in_filter_colors.length.positive?
        possible_colors_in_filter_colors[0]
      else
        colors_to_chose[0]
      end
    end
  end

  def receive_movement_input(number)
    if @guesser_state
      parse_code(gets.chomp)
    else
      computer_guessed_code(number)
    end
  end

  def match_info(input, code_to_match = @secret_code)
    correct_chars = 0
    organize_chars = 0

    code_to_match.split('').each_with_index do |char, i|
      correct_chars += 1 if input.include?(char)
      organize_chars += 1 if input[i] == char
    end
    [correct_chars, organize_chars]
  end

  def update_match_in_table(input, number)
    @back_table.matchs = @table.matchs.dup
    @table.matchs[number] = match_info(input)
  end

  def update_pointers_in_table(number)
    @table.pointers[number] = ' '
    @table.pointers[number + 1] = '<' if number + 1 < @table.colors.size
  end

  def update_table_after_movement(input, number)
    @table.colors[number] = input
    update_match_in_table(input, number)
    update_pointers_in_table(number)
  end

  def generate_random_code
    ('a'..'h').to_a.sample(4).join
  end

  def draw_change
    if @guesser_state
      @table.draw_table
    else
      @table.draw_color_table
      puts "The machine is planning the next guess ...  buahaha \n\n"
    end
  end

  def play_movement(number)
    draw_change
    input = receive_movement_input(number)
    update_table_after_movement(input, number)
    draw_change
    input
  end

  def play_round
    display_score('partial')
    12.times do |index|
      input = play_movement(index)
      if input.join == @secret_code
        @users[0].score += 1
        break
      end
    end
    @rounds += 1
  end

  def reset_for_new_game
    @table.default_initialize
    if @guesser_state
      @secret_code = generate_random_code
    else
      @table.draw_color_picker
      puts 'Please enter a code so that the machine can guess it'
      @secret_code = parse_code(gets.chomp).join
    end
  end

  def play_recursive
    play_round

    if exit_game?
      end_game
    else
      reset_for_new_game
      play_recursive
    end
  end

  def gueeser?
    answer = gets_message('Do you want to be the guesser (1) or the code creator (2)')
    answer = gets_message('please enter a valid option: 1 or 2') while answer != '1' && answer != '2'
    @guesser_state = answer == '1'
    @guesser_state
  end

  def play_game
    gueeser?
    prepare_game
    play_recursive
  end

  def end_game
    display_score('final')
    puts "Thanks for playing #{@users[0].name}!"
  end

  def display_score(string)
    puts "\n------------ The #{string} score is ------------"
    puts "    win rate (#{@users[0].score}/#{@rounds}): #{@users[0].score} wins in #{@rounds} rounds\n\n"
  end
end

MaterMind.new.play_game
