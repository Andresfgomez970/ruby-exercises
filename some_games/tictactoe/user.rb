# frozen_string_literal: true

# User class to save people playing
class User
  ##
  # This is a basic user class
  attr_accessor :name, :score

  def initialize(name, score=0)
    @name = name
    @score = score
  end
end

# Class for users of the tictactoe game
class TicTacToeUser < User
  ##
  # This is an user class for a tictatoe game
  attr_accessor :mark

  def initialize(name, mark, score=0)
    super(name, score)
    @mark = mark
  end

  def ==(other)
    @name == other.name && @score == other.score && @mark == other.mark 
  end
end
