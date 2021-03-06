# frozen_string_literal: true

# Wrote recursively too
def level_order_recursive(queque, &block)
  if queque.length.zero?
    nil
  else
    actual_node = queque[0]
    block.call actual_node
    queque.shift
    queque.push(actual_node.left) unless actual_node.left.nil?
    queque.push(actual_node.right) unless actual_node.right.nil?
    level_order_recursive(queque, &block)
  end
end

# Defining general utils generally used in objects
module ObjectUtils
  def near_objects_by_attribute(object_list, compare_object, attribute)
    min_dist = object_list.map { |obj| (compare_object.send(attribute) - obj.send(attribute)).abs }.min
    object_list.filter { |lf| (compare_object.value - lf.value).abs == min_dist }
  end
end

# class with that represents a node in the tree
class Node
  include Comparable

  attr_accessor :left, :right, :value

  def initialize(value, left = nil, right = nil)
    @value = value
    @left = left
    @right = right
  end

  def >(other)
    value > other.value
  end

  def >=(other)
    value >= other.value
  end

  def <(other)
    value < other.value
  end

  def <=(other)
    value <= other.value
  end

  def ==(other)
    value == other.value
  end

  def !=(other)
    value != other.value
  end

  def no_child?
    @right.nil? && @left.nil?
  end

  def one_child?
    @right.nil? ^ @left.nil?
  end
end

# Defining class of the balanced tree
class Tree
  include ObjectUtils

  attr_accessor :root

  def initialize(array)
    array = array.uniq
    @root = build_tree(array)
  end

  def build_tree(array)
    mid = array.length / 2
    node = Node.new(array[mid])
    return node if array.length == 1
    return nil if array.length.zero?

    node.left = build_tree(array[0, mid])
    node.right = build_tree(array[mid + 1, array.length])

    node
  end

  def add_to_queque(queque, actual_node)
    queque.push(actual_node.left) unless actual_node.left.nil?
    queque.push(actual_node.right) unless actual_node.right.nil?
    queque
  end

  def level_order(initial_node = @root)
    res = []
    queque = [initial_node]
    until queque.length.zero?
      block_given? ? (yield queque[0]) : res.push(queque[0].value)
      queque = add_to_queque(queque, queque[0])
      queque.shift
    end
    res unless block_given?
  end

  def inorder(node = @root, res = [], &block)
    return if node.nil?

    inorder(node.left, res, &block)
    block_given? ? block.call(node) : res.push(node.value)
    inorder(node.right, res, &block)
    res unless block_given?
  end

  def preorder(node = @root, res = [], &block)
    return if node.nil?

    block_given? ? block.call(node) : res.push(node.value)
    preorder(node.left, res, &block)
    preorder(node.right, res, &block)
    res unless block_given?
  end

  def postorder(node = @root, res = [], &block)
    return if node.nil?

    postorder(node.left, res, &block)
    postorder(node.right, res, &block)
    block_given? ? block.call(node) : res.push(node.value)
    res unless block_given?
  end

  def fetch_insert_control_var(value)
    [Node.new(value), @root, false]
  end

  def update_insert_state(actual_node, insert_node)
    actual_node.left.nil? || actual_node.right.nil? || actual_node == insert_node
  end

  def insert(value)
    insert_node, actual_node, insert_state = fetch_insert_control_var(value)

    until insert_state
      insert_state = update_insert_state(actual_node, insert_node)
      if actual_node > insert_node
        actual_node.left.nil? ? actual_node.left = insert_node : actual_node = actual_node.left
      else
        actual_node.right.nil? ? actual_node.right = insert_node : actual_node = actual_node.right
      end
    end
  end

  def fetch_delete_control_var(value)
    [Node.new(value), [@root], false]
  end

  def delete_leaf_node(queque)
    @root = nil if queque[-1] == @root
    queque[-2].right = nil if queque[-1] > queque[-2]
    queque[-2].left = nil if queque[-1] < queque[-2]
  end

  def delete_stick_node(queque)
    node_a = queque[-1]
    node_b = queque[-2]

    assign = node_a.right.nil? ? node_a.left : node_a.right
    node_b.right = assign if node_b.right == node_a
    node_b.left = assign if node_b.left == node_a
  end

  def next_node(actual_node, target_node)
    actual_node > target_node ? actual_node.left : actual_node.right
  end

  def get_leafs(node = @root)
    leafs = []
    block = proc { |e| leafs.push(e) if e.right.nil? && e.left.nil? }
    node = get_actual_node(node)
    level_order(node, &block)
    leafs.push(node) if (node.one_child? || node.no_child?) && node == @root
    leafs
  end

  def delete_branch_node(queque)
    leafs = get_leafs
    final_leafs = near_objects_by_attribute(leafs, queque[-1], 'value')
    final_leaf = final_leafs[0] > final_leafs[1] ? final_leafs[0] : final_leafs[1]
    delete(final_leaf.value)
    queque[-1].value = final_leaf.value
  end

  def delete_given_node(queque)
    if queque[-1].no_child?
      delete_leaf_node(queque) # verfigy if change is deep or shallo
    elsif queque[-1].one_child?
      delete_stick_node(queque)
    else
      delete_branch_node(queque)
    end
  end

  def delete(value)
    delete_node, queque, delete_state = fetch_delete_control_var(value)
    until delete_state
      if queque[-1] == delete_node
        delete_state = true
        delete_given_node(queque)
      else
        queque.push(next_node(queque[-1], delete_node))
      end
    end
  end

  def get_actual_node(node)
    actual_node = @root
    actual_node = node < actual_node ? actual_node.left : actual_node.right while actual_node != node
    actual_node
  end

  def heights(initial_node = @root)
    hs = []
    get_leafs(get_actual_node(initial_node)).each do |leaf|
      hs.push(0)
      actual_node = get_actual_node(initial_node)
      while actual_node != leaf
        hs[-1] += 1
        actual_node = next_node(actual_node, leaf)
      end
    end
    hs
  end

  def height(node = @root)
    heights(node).max
  end

  def depth(target_node)
    d = 0
    actual_node = @root
    while actual_node != target_node
      d += 1
      actual_node = next_node(actual_node, target_node)
    end
    d
  end

  def balanced?
    hs = heights
    hs_diff = hs.map { |h| (h - hs.max).abs }
    hs_diff.all? { |h| h < 2 }
  end

  def rebalance
    data = level_order
    data = data.sort
    @root = build_tree(data)
  end

  def pretty_print(node = @root, prefix = '', is_left=true)
    pretty_print(node.right, "#{prefix}#{is_left ? '???   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '????????? ' : '????????? '}#{node.value}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '???   '}", true) if node.left
  end
end

tree = Tree.new([1, 2, 3, 4, 5, 6, 7])
puts 'initial tree'
tree.pretty_print

puts 'Level order'
p tree.level_order

puts 'Inorder'
p tree.inorder

puts 'Preorder'
p tree.preorder

puts 'Postorder'
p tree.postorder

puts 'insert 0'
tree.insert(0)
tree.pretty_print

puts 'delete 7'
tree.delete(7)
tree.pretty_print

puts 'delete 6'
tree.delete(6)
tree.pretty_print

puts 'delete 4'
tree.delete(4)
tree.pretty_print

puts "\nheight at from node #{tree.root.value} : #{tree.height}"
node = Node.new(2)
puts "height at from node #{node.value} : #{tree.height(node)}"

node = Node.new(2)
puts "\ndepth from node #{node.value} : #{tree.depth(node)}"
node = Node.new(1)
puts "depth from node #{node.value} : #{tree.depth(node)}"

puts "\nIs the actual tree balance? #{tree.balanced? ? 'yes' : 'no'}"

puts "\nApplying tree rebalance:"
tree.rebalance
tree.pretty_print
puts "Is the actual tree balance? #{tree.balanced? ? 'yes' : 'no'}"
