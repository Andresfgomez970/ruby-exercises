# frozen_string_literal: true

require_relative 'user'
require_relative 'table'
require_relative 'utils'

# Ches class for the game
class ChessGame
  include BasicUtils
  
  def initialize(player1 = ChessGameUser.new(), player2 = ChessGameUser.new(), table = Table.new)
    @player1 = player1
    @player2 = player2
    @table = table
  end
end

ChessGameUser.new