# frozen_string_literal: true
require 'json'

# User class to save people playing
class User
  ##
  # This is a basic user class
  attr_accessor :name, :score

  def initialize(name, score = 0)
    @name = name
    @score = score
  end
end

# Extend index method
class String
  def indices(str_to_match)
    result = []
    offset = 0
    index = self.index(str_to_match, offset)
    until index.nil?
      result.push(index)
      offset = index + str_to_match.length
      index = self.index(str_to_match, offset)
    end
    result
  end
end

# Basic utils module
module BasicUtils
  def gets_message(message)
    puts message
    gets.chomp
  end

  def another_round?
    answer = gets_message('Do you want to play another round? (y/n)')
    answer = gets_message('Please enter a valid option: (y/n)') while answer != 'y' && answer != 'n'
    answer == 'n'
  end

  def load_game?
    answer = gets_message('Do you want to load your user info? (y/n)')
    answer = gets_message('Please enter a valid option: (y/n)') while answer != 'y' && answer != 'n'
    answer == 'y'
  end
end

# This class will include all functionalities to draw a hangman name
class HangManDraw
  def initialize
    @wrong_number = 0
    @max_wrong = 9
    @init_game = 1
  end

  def down_platform
    @wrong_number.positive? ? '......................' : '                       '
  end

  def platform_stick
    @wrong_number > 1 ? '.' : ' '
  end

  def middle_spaces
    '         '
  end

  def over_platform
    rope_part = @wrong_number > 2 ? '.' : ''
    result = @wrong_number > 2 ? '...........' : ''
    3.times { result += "\n#{platform_stick}#{middle_spaces}#{rope_part}" }
    result
  end

  def head
    res = "#{platform_stick}#{middle_spaces}"
    @wrong_number > 3 ? "#{res}o" : "#{res} "
  end

  def arms
    res = "#{platform_stick}#{middle_spaces[0, middle_spaces.length / 2]}"
    if @wrong_number == 4
      "#{res}......"
    elsif @wrong_number > 4 && @wrong_number < 9
      "#{res}..........."
    elsif @wrong_number == 9
      "#{res}........... \t DEAD!!! YOU HAVE LOST! :("
    else
      res.to_s
    end
  end

  def torso
    torso_part = @wrong_number > 5 ? '.' : ' '
    result = ''
    4.times { result += "#{platform_stick}#{middle_spaces}#{torso_part}\n" }
    result
  end

  def legs
    right_leg = @wrong_number > 6 ? '.' : ' '
    left_leg = @wrong_number > 7 ? '.' : ' '
    res = ''
    res += "#{platform_stick}#{' ' * (middle_spaces.length - 1)}#{left_leg} #{right_leg}\n"
    res += "#{platform_stick}#{' ' * (middle_spaces.length - 2)}#{left_leg}   #{right_leg}"
    res
  end

  def welcome_mesage
    if @init_game == 1
      @init_game = 0
      'Welcome to hangman game and thanks for playing'
    else
      "\n"
    end
  end

  def remaining_tries
    if @wrong_number < @max_wrong 
      "You still have #{@max_wrong - @wrong_number} tries our of #{@max_wrong}"
    else
      'You have exhausted the number of tries'
    end
  end

  def draw_body
    puts remaining_tries
    puts welcome_mesage
    puts over_platform
    puts head
    puts arms
    puts torso
    puts legs
    puts down_platform
  end
end

# Main class that contains the game
class Hangman < HangManDraw
  include BasicUtils

  def initialize(filename = 'google-10000-english-no-swears.txt')
    super()
    standart_init(filename)
  end

  def standart_init(filename = 'google-10000-english-no-swears.txt')
    @filename = filename
    @word_file = File.open(@filename)
    @n_lines = @word_file.count
    @round_word = select_random_word
    @guessed_word = '_' * @round_word.length
    @users = []
    @rounds = 0
    @characters = ('a'..'z').to_a
    @characters_chosen = Array.new(@characters.length, '_')
    @save = false
  end

  def select_random_word
    @word_file.rewind
    rand(1..@n_lines).times { @word_file.readline }
    @word_file.readline.gsub("\n", '')
  end

  def draw_word_picker
    to_print_characters = @guessed_word.split('')
    to_print_word = to_print_characters.reduce('') { |to_print, char| to_print + "#{char} " }
    to_print_word = "\n#{to_print_word}\n"
    @characters.each_with_index do |c, i|
      to_print_word += (i % 6).zero? ? "\n#{c} #{@characters_chosen[i]}   " : "#{c} #{@characters_chosen[i]}   "
    end
    puts to_print_word
  end

  def draw_final_mesage
    match_condition = @guessed_word == @round_word
    puts 'Congrats!! You have won!' if match_condition
    puts "Try again! The correct word was #{@round_word}" if !match_condition && @wrong_number == @max_wrong
  end

  def draw_save_message
    puts "Thanks for saving #{@users[0].name}, see you again soon" if @save
  end

  def draw_board
    draw_body
    draw_word_picker
    draw_final_mesage
  end

  def enter_name
    name = gets_message('Plase enter the name of the player to play')
    @users.push(User.new(name))
  end

  def update_game_state(char)
    if char != 'save'
      matches = @round_word.indices(char)
      matches.each { |match_i| @guessed_word[match_i] = char }
      @wrong_number += 1 if matches.length.zero?
      @users[0].score += 1 if @guessed_word == @round_word
      index_char = @characters.join.index(char)
      @characters_chosen[index_char] = matches.length.positive? ? 'o' : 'x'
    else
      @save = true
    end
  end

  def guessed_char
    char = gets_message("\nPlease guess a character for the above spaces or save by typing 'save'").downcase
    char = gets_message('Please select a valid character').downcase until char.match?(/^[a-z]$/) || char == 'save'
    char
  end

  def save_game?
    ans = gets_message('Do you want to save your progress (y/n)?')
    ans = gets_message('Please select a valid option (y/n)') until ans == 'y' || ans == 'n'
    ans == 'y'
  end

  def save_game
    if @save
      draw_save_message
      save_to_json
      exit
    end
  end

  def play_round
    display_score('partial')
    while @wrong_number < @max_wrong && @guessed_word != @round_word && !@save
      draw_board
      char = guessed_char
      update_game_state(char)
    end
    save_game
    draw_board
    @rounds += 1
  end

  def play_recursive
    play_round

    if another_round?
      @save = true if save_game?
      save_game
      end_game
    else
      reset_for_new_game
      play_recursive
    end
  end

  def reset_for_new_game
    @round_word = select_random_word
    @guessed_word = '_' * @round_word.length
    @wrong_number = 0
    @characters_chosen = Array.new(@characters.length, '_')
  end

  def end_game
    display_score('final')
    puts "Thanks for playing #{@users[0].name}!"
  end

  def display_score(string)
    puts "\n------------ The #{string} score is ------------"
    puts "    win rate (#{@users[0].score}/#{@rounds}): #{@users[0].score} wins in #{@rounds} rounds\n\n"
  end

  def load_game
    try_times = 0
    begin
      init_from_json("output/hangman_#{@users[0].name}.json")
    rescue TypeError
      puts e
      @users[0].name = gets_message('Please enter your user name again to find the file')
      try_times += 1
      retry
    end
  end

  def prepare_game
    enter_name
    load_game if load_game?
  end

  def play_game
    prepare_game
    play_recursive
  end

  def to_json(*_args)
    JSON.dump ( {
      json_class: self.class.name,
      data: {
        filename: @filename, round_word: @round_word,
        guessed_word: @guessed_word, users: { name: @users[0].name, score: @users[0].score },
        rounds: @rounds, wrong_number: @wrong_number,
        characters_chosen: @characters_chosen
      }
    })
  end

  def save_to_json
    Dir.mkdir('output') unless Dir.exist?('output')
    File.open("output/hangman_#{@users[0].name}.json", 'w') do |f|
      f.write(to_json)
    end
  end

  def fetch_state_game(data_json)
    @wrong_number = data_json['data']['wrong_number']
    @round_word = data_json['data']['round_word']
    @guessed_word = data_json['data']['guessed_word']
    @rounds = data_json['data']['rounds']
		@characters_chosen = data_json['data']['characters_chosen']
  end

  def fetch_user_info(data_json)
    @users.push(User.new(data_json['data']['users']['name'], data_json['data']['users']['score']))
  end

  def init_from_json(json_filename)
    data_json = JSON.parse(File.read(json_filename))
    standart_init(data_json['data']['filename'])
    fetch_state_game(data_json)
    fetch_user_info(data_json)
    # substract in order to count correcly, this permits
    #  to enter again to play_round and have a correct number
    #  of rounds
    @rounds -= 1 if @wrong_number == @max_wrong
  end
end


Hangman.new.play_game
# p JSON.pretty_generate(Hangman.new)