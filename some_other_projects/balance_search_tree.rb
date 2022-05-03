class Node
  include Comparable

  attr_accessor :left, :right, :value

  def initialize(value, left = nil, right = nil)
    @value = value
    @left = left
    @right = right
  end

  def >(otherNode)
    self.value < otherNode.value
  end

  def >=(otherNode)
    self.value >= otherNode.value
  end

  def <(otherNode)
    self.value < otherNode.value
  end

  def <=(otherNode)
    self.value <= otherNode.value
  end
end

class Tree
  def initialize(array)
    array = array.uniq
    @root = build_tree(array)
  end

  def build_tree(array)
    mid = array.length / 2
    node = Node.new(array[mid])
    return node if array.length == 1
    return nil if array.length == 0

    node.left = build_tree(array[0, mid])
    node.right = build_tree(array[mid + 1, array.length])

    node
  end

  def level_order
    queque = []
    actual_node  = @root
    queque.push(@root)
    until queque.length.zero?
      yield actual_node.value
      queque.shift
      queque.push(actual_node.left) unless actual_node.left.nil?
      queque.push(actual_node.right) unless actual_node.right.nil?
      actual_node = queque[0]
    end
  end

  def level_order_recursive(queque=[@root], &block)
    if queque.length.zero?
      return nil
    else
      actual_node = queque[0]
      block.call actual_node.value
      queque.shift
      queque.push(actual_node.left) unless actual_node.left.nil?
      queque.push(actual_node.right) unless actual_node.right.nil?
      level_order_recursive(queque, &block)
    end
  end

  def insert
  end
end


tree = Tree.new([1, 2, 3, 4, 5, 6, 7])
tree.level_order_recursive {|e| p e}