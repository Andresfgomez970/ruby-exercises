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

  def inorder(node = @root, &block)
    return if node.nil?

    inorder(node.left, &block)
    block.call node
    inorder(node.right, &block)
  end

  def preorder(node = @root, &block)
    return if node.nil?

    block.call node
    preorder(node.left, &block)
    preorder(node.right, &block)
  end

  def postorder(node = @root, &block)
    return if node.nil?

    postorder(node.left, &block)
    postorder(node.right, &block)
    block.call node
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
      insert_state = update_insert_state
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

  def delete(value)
    delete_node, queque, delete_state = fetch_delete_control_var(value)
    until delete_state
      if queque[-1] == delete_node
        delete_state = true
        if queque[-1].no_child?
          delete_leaf_node(queque)  # verfigy if change is deep or shallo
        elsif queque[-1].one_child?
          delete_stick_node(queque)
        else
          leafs = []
          level_order_recursive {|e| leafs.push(e) if e.right.nil? && e.left.nil?}
          min_dist = leafs.map{ |lf| (delete_node.value - lf.value).abs }.min
          final_leafs = leafs.filter { |lf| (delete_node.value - lf.value).abs == min_dist}
          final_leaf = final_leafs[0] > final_leafs[1] ? final_leafs[0] : final_leafs[1]
          delete(final_leaf.value)
          queque[-1].value = final_leaf.value
        end
      else
        actual_node = next_node(actual_node, delete_node)
        queque.push(actual_node)
      end
    end
  end

  def get_actual_node(node)
    actual_node = @root
    while actual_node != node
      if node < actual_node
        actual_node = actual_node.left
      else
        actual_node = actual_node.right
      end
    end
    return actual_node
  end

  def heights(node = @root, leafs = false)
    if leafs == false
      leafs = []
      level_order_recursive {|e| leafs.push(e) if e.right.nil? && e.left.nil?}
    end  

    hs = []
    leafs.each do |leaf|
      h = 0
      next_node = node
      while next_node != leaf
        h += 1
        if leaf < next_node
          next_node = next_node.left
        else
          next_node = next_node.right
        end
      end
      hs.push(h)
    end

    hs
  end

  def height(node = @root)
    leafs = []
    block = Proc.new {|e| leafs.push(e) if e.right.nil? && e.left.nil?}
    node = get_actual_node(node)
    level_order(node, &block)
    hs = heights(node, leafs)
    hs.max
  end

  def depth(node)
    d = 0
    actual_node = @root
    while actual_node != node
      d += 1
      if node < actual_node
        actual_node = actual_node.left
      else
        actual_node = actual_node.right
      end
    end
    d
  end

  def balanced?
    hs = heights() 
    hs_diff = hs.map{|h| (h - hs.max).abs }
    hs_diff.all?{|h| h < 2}
  end

  def rebalance
    data = level_order()
    data = data.sort
    @root = build_tree(data) 
  end
end


tree = Tree.new([1, 2, 3, 4, 5, 6, 7])
p tree.level_order
# p tree.height(Node.new(2))
# p tree.depth(Node.new(2))
# tree.insert(0)
# tree.insert(-1)
# p tree.balanced?
# tree.rebalance
# p tree.balanced?