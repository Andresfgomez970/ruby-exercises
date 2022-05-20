# frozen_string_literal: true

# Basic utils module
module BasicUtils
  def gets_message(message)
    puts message
    gets.chomp
  end

  def valid_yn_answer?(answer)
    answer == 'y' || answer == 'n'
  end
end
