# frozen_string_literal: true

# default class for user of a simple game
class GameUser
  attr_accessor :name, :score

  def initialize(init_values = {})
    @name = init_values.fetch(:name, 'default_name')
    @score = init_values.fetch(:score, 0)
  end
end

# user for the connect four game
class ChessGameUser < GameUser
  attr_reader :mark, :chess_color

  def initialize(init_values = {})
    super(init_values)
    @chess_color = init_values.fetch(:chess_color, 'white')
  end
end
