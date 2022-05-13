# frozen_string_literal: true

# General utils
module Utils
  def sum_sim_array(arr1, arr2)
    arr1.map.with_index { |arr1i, i| arr1i + arr2[i] }
  end
end

# KnightNode: it consists of a refefenece to the next_node, and 
#  a next nodeobject that save all the possible moves
class KnightNode
  include Utils
  include Comparable

  attr_accessor :next_nodes, :last_node, :actual_pos

  def initialize(actual_pos = nil)
    @actual_pos = actual_pos
    @next_nodes = []
    @last_node = nil
  end

  def sum_possible_steps(pos)
    steps = [[2, 1], [2, -1], [1, 2], [1, -2], [-2, 1], [-2, -1], [-1, 2], [-1, -2]]
    steps.map { |s| sum_sim_array(pos, s) }
  end

  def calculate_correct_next_pos(pos = @actual_pos)
    possible_pos = sum_possible_steps(pos)
    possible_pos.filter { |p| p[0].between?(0, 7) && p[1].between?(0, 7) }
  end

  def add_correct_next_nodes(pos = @actual_pos)
    correct_pos = calculate_correct_next_pos(pos)
    @next_nodes = correct_pos.map { |pos_i| KnightNode.new(pos_i) }
    @next_nodes.each { |node| node.last_node = self }
  end
end

# Knightree with function for creating possible values
class KnightTree
  def initialize(init_pos, depth = 0)
    check_correct_params(init_pos, depth)
    @root = KnightNode.new(init_pos)
    @depth = depth
    build_tree
  end

  def check_correct_params(init_pos, depth)
    if !init_pos.is_a?(Array) && init_pos.length != 2
      puts 'init pos must be an array of dim 2: e.g. [1, 2]'
    elsif !depth.is_a?(Integer)
      puts 'please enter a valid depth number; it must be an integer'
    end
  end

  def update_next_depth_queque(queque)
    queque.each(&:add_correct_next_nodes)
    queque.reduce([]) { |new_queque, elm| new_queque + elm.next_nodes }
  end

  def build_tree
    queque = [@root]
    return nil if @depth.zero?

    actual_depth = 0
    while actual_depth < @depth
      actual_depth += 1
      queque = update_next_depth_queque(queque)
    end
  end

  def update_transverse_queque(queque)
    queque += !queque[0].next_nodes.nil? ? queque[0].next_nodes : []
    queque.shift
    queque
  end

  def transverse_nodes
    res = []
    queque = [@root]
    while queque != []
      block_given? ? (yield queque[0]) : res.push(queque[0].actual_pos)
      queque = update_transverse_queque(queque)
    end
    res unless block_given?
  end

  def find_node(final_pos)
    final_node = []
    transverse_nodes { |node| node.actual_pos == final_pos && final_node.length.zero? ? final_node.push(node) : nil }
    final_node == [] ? [] : final_node[0]
  end

  def find_shortest_path_in_tree(final_node)
    steps = [final_node.actual_pos]
    until final_node.last_node.nil?
      final_node = final_node.last_node
      steps << final_node.actual_pos
    end
    # correct things here
    steps.reverse
  end

  def add_depth_layer
    leafs = []
    transverse_nodes { |node| node.next_nodes == [] ? leafs.push(node) : nil }
    leafs.each(&:add_correct_next_nodes)
  end

  def find_shortest_path(final_pos)
    final_node = find_node(final_pos)
    if final_node == []
      add_depth_layer
      find_shortest_path(final_pos)
    else
      find_shortest_path_in_tree(final_node)
    end
  end
end

def knight_moves(init_pos, final_pos)
  knigh_tree = KnightTree.new(init_pos)
  knigh_tree.find_shortest_path(final_pos)
end

puts 'init: [0, 0], final: [1, 2]'
p knight_moves([0, 0], [1, 2])

puts "\n"
puts 'init: [0, 0], final: [3, 3]'
p knight_moves([0, 0], [3, 3])

puts "\n"
puts 'init: [3, 3], final: [0, 0]'
p knight_moves([3, 3], [0, 0])

puts "\n"
puts 'init: [3, 3], final: [4, 3]'
p knight_moves([3, 3], [4, 3])