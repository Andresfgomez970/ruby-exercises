class Node
  include Comparable

  attr_accessor :left, :right, :value

  def initialize(value, left = nil, right = nil)
    @value = value
    @left = left
    @right = right
  end

  def >(otherNode)
    self.value > otherNode.value
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

  def ==(otherNode)
    self.value == otherNode.value
  end

  def !=(otherNode)
    self.value != otherNode.value
  end


end

class Tree
  def initialize(array)
    array = array.uniq
    @root = build_tree(array)
    @h_dummy = 0 
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

  def level_order(initial_node = @root)
    res = []
    queque = []
    actual_node  = initial_node
    queque.push(initial_node)
    until queque.length.zero?
      if block_given?
        yield actual_node
      else
        res.push(actual_node.value)
      end
      queque.shift
      queque.push(actual_node.left) unless actual_node.left.nil?
      queque.push(actual_node.right) unless actual_node.right.nil?
      actual_node = queque[0]
    end
    res unless block_given?
  end

  # Wrote recursively too
  def level_order_recursive(queque=[@root], &block)
    if queque.length.zero?
      return nil
    else
      actual_node = queque[0]
      block.call actual_node
      queque.shift
      queque.push(actual_node.left) unless actual_node.left.nil?
      queque.push(actual_node.right) unless actual_node.right.nil?
      level_order_recursive(queque, &block)
    end
  end

  def inorder(node = @root, &block)
    if node.nil?
      return
    end

    inorder(node.left, &block)
    block.call node
    inorder(node.right, &block)
  end

  def preorder(node = @root, &block)
    if node.nil?
      return
    end

    block.call node
    preorder(node.left, &block)
    preorder(node.right, &block)
  end

  def postorder(node = @root, &block)
    if node.nil?
      return
    end

    postorder(node.left, &block)
    postorder(node.right, &block)
    block.call node
  end

  def insert(value)
    insert_node = Node.new(value)
    actual_node  = @root
    insert_state = false

    until insert_state
      if actual_node == insert_node
        insert_state = true
      elsif actual_node > insert_node
        if actual_node.left.nil?
          actual_node.left = insert_node
          insert_state = true
        end
        actual_node = actual_node.left
      else
        if actual_node.right.nil?
          actual_node.right = insert_node
          insert_state = true
        end
        actual_node = actual_node.right
      end
    end
  end

  def delete(value)
    delete_node = Node.new(value)
    queque = Array.new(1, @root)
    delete_state = false
    until delete_state
      if queque[-1] == delete_node
        delete_state = true
        if queque[-1].right.nil? && queque[-1].left.nil?
          @root = nil if queque[-1] == @root
          queque[-2].right = nil if queque[-1] > queque[-2]
          queque[-2].left = nil if queque[-1] < queque[-2]
        elsif queque[-1].right.nil? ^ queque[-1].left.nil?
          if queque[-1].right.nil?
            queque[-2].right = queque[-1].left if queque[-2].right == queque[-1]
            queque[-2].left = queque[-1].left if queque[-2].left == queque[-1]
          else
            queque[-2].right = queque[-1].right if queque[-2].right == queque[-1]
            queque[-2].left = queque[-1].righ if queque[-2].left == queque[-2]
          end
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
        if queque[-1] > delete_node
          actual_node = queque[-1].left
        else
          actual_node = queque[-1].right
        end
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
p tree.height(Node.new(2))
p tree.depth(Node.new(2))
tree.insert(0)
tree.insert(-1)
p tree.balanced?
tree.rebalance
p tree.balanced?