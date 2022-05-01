class LinkedList
  attr_accessor :head, :tail

  def initialize(head = nil, tail = nil)
    @head = head
    @tail = tail
  end

  def append(value)
    new_node = Node.new(value)
    if @tail.nil?
      @head = new_node
      @tail = new_node
    else
      @tail.next = new_node
      @tail = new_node
    end
  end

  def prepend(value)
    new_node = Node.new(value)
    if @head.nil?
      @head = new_node
      @tail = new_node
    else
      new_node.next = @head
      @head = new_node
    end
  end

  def size
    res = 0
    next_node = @head 
    until next_node.nil?
      next_node = next_node.next
      res += 1
    end
    res
  end

  def at(index)
    next_node = @head
    index.times do |a|
      next_node = next_node.next unless next_node.nil?    
    end
    index >= 0 ? next_node : nil 
  end

  def pop
    new_last_node = at(size - 2)
    # save last before change it
    last = new_last_node.next

    # make new last the last
    @tail = new_last_node
    new_last_node.next = nil
    
    last
  end

  def each
    next_node = @head
    (0..size - 1).each do |i|
      yield next_node
      next_node = next_node.next
    end
  end

  def each_with_index
    c = 0
    each do |node|
      yield c, node
      c += 1
    end
  end

  def contains?(value)
    each do |node|
      return true if node.data == value
    end
    false
  end

  def find(value)
    each_with_index do |index, node|
      return index if node.data == value
    end
    nil
  end

  def to_s
    res = "[#{@head.nil? ? 'nil(head)' : "#{@head.data}(head)"}] -> "
    each do |node|
      res += "[#{node.data}] -> "
    end
    res += "[#{@tail.nil? ? 'nil(tail)' : "#{@tail.data}(tail)"}] -> "
    res += 'nil'
  end

  def insert_at(value, index)
    node_to_be_shifted = at(index)
    node_before_insert = at(index -1)
    if node_before_insert.nil? && index == 0
      prepend(value)
    elsif node_before_insert.nil? && node_to_be_shifted.nil?
      puts "insert is not possible in index #{index}"
      exit
    else
      node_before_insert.next = Node.new(value)
      node_before_insert.next.next = node_to_be_shifted      
    end
  end

  def remove_at(index)
    before_to_node_to_remove = at(index - 1)
    next_to_node_to_remove = at(index + 1)
    if before_to_node_to_remove.nil? && next_to_node_to_remove.nil?
      if at(index).nil?
        puts 'Nothing to remove'
        exit
      else
        @head = nil
        @tail = nil
      end
    elsif before_to_node_to_remove.nil?
      @head = next_to_node_to_remove
    else
      next_to_node_to_remove = at(index + 1)
      before_to_node_to_remove.next = next_to_node_to_remove
    end
  end

end

class Node
  attr_accessor :next, :data


  def initialize(data, next_node = nil)
    @data = data
    @next = next_node
  end
end


linked_list = LinkedList.new

(0..3).each do |i|
  linked_list.append(i)
end

puts linked_list
puts "\nnsize of linked_list: #{linked_list.size}"

value = 0
puts "\nlinked list at #{value}:"
p linked_list.at(value)

value = 1
puts "linked list at #{value}:"
p linked_list.at(value)

value = 2
puts "linked list at #{value}:"
p linked_list.at(value)

value = 3
puts "linked list at #{value}:"
p linked_list.at(value)


puts "\npop method used:"
puts "pop return: #{linked_list.pop}" 
puts "final linked list: #{linked_list}"

puts "\neach implementation"
linked_list.each {|node| p node}

puts "\nusing contains"
value = 1
puts "linked_list.contains?(#{value}): #{linked_list.contains?(value)}"
value = 10
puts "linked_list.contains?(#{value}): #{linked_list.contains?(value)}"

puts "\nusing find"
value = 1
puts "linked_list.find(#{value}): #{linked_list.find(value)}"
value = 10
puts "linked_list.find(#{value}): #{linked_list.find(value)}"

puts "\nto_s"
puts "linked_list.to_s: #{linked_list.to_s}" 

value, index = -1, 1
puts "\ninsert_at(#{value}, #{index}) used"
linked_list.insert_at(value, index)
puts "linked_list.to_s: #{linked_list.to_s}" 

index = 0
puts "\nremove_at(#{index}) used"
linked_list.remove_at(index)
puts "linked_list.to_s: #{linked_list.to_s}" 


index = 1
puts "\nremove_at(#{index}) used"
linked_list.remove_at(index)
puts "linked_list.to_s: #{linked_list.to_s}" 


index = 0
puts "\nremove_at(#{index}) used"
linked_list.remove_at(index)
puts "linked_list.to_s: #{linked_list.to_s}" 

index = 0
puts "\nremove_at(#{index}) used"
linked_list.remove_at(index)
puts "linked_list.to_s: #{linked_list.to_s}" 

index = 0
puts "\nremove_at(#{index}) used"
linked_list.remove_at(index)
puts "linked_list.to_s: #{linked_list.to_s}" 



