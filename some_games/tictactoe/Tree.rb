# frozen_string_literal: true
require_relative 'tictactoe'
require_relative 'utils'
require_relative 'table'
require_relative 'user'

# this describe the needed info for the nodes in a minmax algorithm
class TicTacToeNode
  attr_accessor :user, :table_before_actual_move, :actual_move, :next_nodes

  def initialize(user, table_before_actual_move, actual_move)
    @user = user
    @table_before_actual_move = table_before_actual_move
    @actual_move = actual_move
    @next_nodes = []
    @last_node = nil
  end
end

# This will have the functions to develop a tree in the tictactoe game
class TicTacToeTree
  attr_accessor :root

  def initialize(users, ind_user, table_before_actual_move, actual_move)
    @users = users
    @root = TicTacToeNode.new(users[ind_user], table_before_actual_move, actual_move)
  end

  def possible_next_steps(user, table_before_actual_move, actual_move)
    table_before_actual_move.update_symbols(actual_move, user.mark)
    table_before_actual_move.get_symbols.map { |sym| sym.is_a?(Integer) ? sym - 1 : nil  }.compact
  end

  def add_correct_next_nodes(node)
    possible_next_steps = possible_next_steps(node.user, node.table_before_actual_move, node.actual_move)
    # new table_before_actual_move
    node.table_before_actual_move.update_symbols(node.actual_move, node.user.mark)
    # exchange user
    node.user = @users[0] == node.user ? @users[1] : @users[0]

    node.next_nodes = possible_next_steps.map { |new_actual_move| TicTacToeNode.new(node.user, node.table_before_actual_move, new_actual_move) }
    # @next_nodes.each { |node| node.last_node = self }
    node.next_nodes
  end
end

user1 = TicTacToeUser.new('user1', 'x')
user2 = TicTacToeUser.new('user1', 'o')

users = [user1, user2]
tictactoe_game = TicTacToe.new([user1, user2], Table.new)
# tictactoe_game.table.update_symbols(1, 'x')
# tictactoe_game.table.draw_table

tictactoe_tree = TicTacToeTree.new(users, 0, tictactoe_game.table, 1)
tictactoe_tree.add_correct_next_nodes(tictactoe_tree.root)
tictactoe_game.table.draw_table

