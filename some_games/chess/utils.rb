# frozen_string_literal: true

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

  def save_game?
    answer = gets_message('Do you want to save the game? (y/n)')
    answer = gets_message('please enter a valid option: (y/n)') until valid_yn_answer?(answer)
    answer == 'y'
  end

  def load_game?
    answer = gets_message('Do you want to load a saved game? (y/n)')
    answer = gets_message('please enter a valid option: (y/n)') until valid_yn_answer?(answer)
    answer == 'y'
  end

  def exit_game?
    answer = gets_message('Do you want to finish the game? (y/n)')
    answer = gets_message('please enter a valid option: (y/n)') until valid_yn_answer?(answer)
    answer == 'y'
  end

  def heaviside(x_val)
    return 0 if x_val.negative?
    return 0.5 if x_val.zero?
    return 1 if x_val.positive?
  end

  def reverse_index(array, index)
    array.length - index - 1
  end
end

# add functionatalities to the array class
class Array
  def sum_array(array)
    each_with_index.map { |elem, i| elem + array[i] } if length == array.length
  end
end
