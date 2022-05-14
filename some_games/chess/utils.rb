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