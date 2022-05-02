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
end


tree = Tree.new([1, 2, 3, 4, 5, 6, 7])
p tree