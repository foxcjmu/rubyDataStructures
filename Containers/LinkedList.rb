#
# A LinkedList class implement with doubly linked circular list of elements.
#
# Author: C. Fox
# Version: June 2017

require "test/unit"

class LinkedList
  include Enumerable
  
  # Create a node class for making a doubly linked list
  Node = Struct.new(:item, :pred, :succ)
  
  # Set up an empty list
  def initialize
    @head = @cursor_index = @cursor_node = nil
    @count = 0
  end
  
  #################### Container Methods ###################
  
  # Return the number of entities in the list
  def size
    @count
  end
  
  # Say whether this list is empty
  def empty?
    @count == 0
  end
  
  # Make the list empty
  def clear
    initialize
  end
  
  ################### Collection Methods ###################
  
  # Return an external iterator object for this List
  def iterator()
    LinkedListIterator.new(self)
  end
  
  # Return true iff an element is present in this collection
  def contains?(element)
    each { |e| return true if e == element }
    return false
  end
  
  # Lists with the same values in the same order are equal
  def ==(other)
    return false if @count != other.size
    each_with_index { |e, i| return false unless e == other[i] }
    return true
  end
  
  ########## Inner Iterator Class for LinkedList ###########
  
  class LinkedListIterator
    
    # Associate this iterator with an array
    def initialize(list)
      raise ArgumentError unless list.class == LinkedList
      @list = list
      @index = 0
    end
    
    # Prepare for an iteration
    # @post: current == first item in Collection if !empty?
    def rewind
      @index = 0
    end
    
    # See whether iteration is complete
    def empty?
      @list.size <= @index
    end
    
    # Obtain the current element
    # @result: current element or nil if empty?
    def current
      @list[@index]
    end
  
    # Move to the next element
    # @result: next element or nil if empty?
    def next
      @index += 1
    end
  end
  
  ####################### List Methods #####################
  
  # Insert the indicated element at the indicated location
  # @pre: -size <= index
  # @post: size = (-old.size <= index < old.size) ? old.size+1 : index-old.size+1 
  # @result: self
  def insert(index, element)
    index = size+index if index < 0
    raise ArgumentError, "Invalid index" if index < 0
    if @count <= index
      append_nil(index-@count+1)
      @head.pred.item = element
    elsif index == 0
      @head = @head.pred = @head.pred.succ = Node.new(element,@head.pred,@head)
      @count += 1
      @cursor_index += 1 unless @cursor_index == nil
    else
      set_cursor(index)
      @cursor_node.pred.succ = @cursor_node.pred = Node.new(element,@cursor_node.pred,@cursor_node)
      @count += 1
      @cursor_index += 1
    end
    self
  end
  
  # Remove the element at index from the list
  # @pre: -size <= index
  # @post: size = (-old.size <= index < old.size) ? old.size-1 : old.size
  # @result: the deleted element or nil if no element is deleted
  def delete_at(index)
    index = size+index if index < 0
    raise ArgumentError, "Invalid index" if index < 0
    return nil if @count <= index
    if @count == 1
      result = @head.item
      initialize
    else
      set_cursor(index)
      result = @cursor_node.item
      @cursor_node.pred.succ, @cursor_node.succ.pred = @cursor_node.succ, @cursor_node.pred
      @count -= 1
      if index == 0
        @head = @cursor_node.succ 
        @cursor_index = @cursor_node = nil
      else
        @cursor_index -= 1
        @cursor_node = @cursor_node.pred
      end
    end
    result
  end
  
  # Fetch the element at the given index
  # @post: size == old.size
  # @result: (-old.size <= index < old.size) ? element at index : nil
  def [](index)
    index = size+index if index < 0
    return nil if index < 0 || @count <= index
    set_cursor(index)
    @cursor_node.item
  end
  
  # Replace a value in the list
  # @pre: -size <= index
  # @post: size = (-old.size <= index < old.size) ? old.size+1 : index-old.size+1 
  # @result: element
  def []=(index, element)
    index = size+index if index < 0
    raise ArgumentError, "Invalid index" if index < 0
    if @count <= index
      append_nil(index-@count+1)
      @head.pred.item = element
    else
      set_cursor(index)
      @cursor_node.item = element
    end
    element
  end
  
  # Find the index of an element in a list
  # @result: (element == self[index]) ? index : nil
  def index(element)
    node = @head
    (0..@count-1).each do |index|
      return index if node.item == element
      node = node.succ
    end
    nil
  end
  
  # Return a sub-list of the list
  # @pre: -size <= start_index and 0 <= length
  # @result: the portion of the list starting at index and extending for length,
  #          but not past the end of the list
  def slice(start_index, length)
    start_index = size+start_index if start_index < 0
    raise ArgumentError, "Invalid index" if start_index < 0
    raise ArgumentError, "Invlaid length" if length < 0
    result = LinkedList.new
    return result if @count <= start_index
    set_cursor(start_index)
    0.upto(length-1) do | offset |
      return result if @count <= start_index+offset
      result[offset] = @cursor_node.item
      @cursor_node = @cursor_node.succ
      @cursor_index += 1
    end
    result
  end

  ################# Enumerable Methods ###################
  
  # Implement each to that Enumerable operations will work
  def each
    node = @head
    0.upto(@count-1) do
      yield node.item
      node = node.succ
    end
  end
  
  ################### Object Methods #####################
  
  # Make a string representation of the list for debugging
  def to_s
    result = ""
    return "empty\n" if @count == 0
    node = @head
    0.upto(@count-1) do |index|
      pred_item = node.pred.item ? node.pred.item.to_s : "-"
      succ_item = node.succ.item ? node.succ.item.to_s : "-"
      node_item = node.item ? node.item.to_s : "-"
      result += "[#{index}] pred: "+pred_item+" item: "+node_item+" succ: "+succ_item+"\n"
      node = node.succ
    end
    result
  end
  
  private ################################################
  
  # Append n nil values to the list
  def append_nil(n = 1)
    return if n < 1
    if @count == 0
      @head = Node.new(nil)
      @head.pred = @head.succ = @head
      n -= 1
      @count += 1
      @cursor_index, @cursor_node = 0, @head
    end
    1.upto(n) do
      @head.pred = @head.pred.succ = Node.new(nil,@head.pred,@head)
      @count += 1
    end
  end
  
  # Move the cursor to the indicated index position
  def set_cursor(index)
    if @cursor_index == nil || (index < (@cursor_index-index).abs)
      @cursor_index, @cursor_node = 0, @head
    end
    if @count-index < (@cursor_index-index).abs
      @cursor_index, @cursor_node = @count-1, @head.pred
    end
    if @cursor_index <= index
      (@cursor_index+1).upto(index) { @cursor_node = @cursor_node.succ }
    else
      (@cursor_index-1).downto(index) { @cursor_node = @cursor_node.pred }
    end
    @cursor_index = index
  end
end

####################  Unit Tests #####################

class TestLinkedList < Test::Unit::TestCase

  def test_collection_ops
    a = LinkedList.new
    assert_equal(LinkedList, a.class)
    b = LinkedList.new
    assert(a==b)
    refute(a.contains?(4))
    assert_raises(ArgumentError) { a.insert(-1,9) }
    (0..4).each { |i| a.insert(i, i) }
    refute(a==b)
    refute(b==a)
    assert(a.contains?(3))
    assert(!a.contains?(5))
    (0..4).each { |i| b.insert(i, i) }
    assert(a==b)
    assert_equal(5, a.size)
    (0..4).each { |i| assert_equal(i, a.index(i)) }
    assert_equal(nil, a.index("blah"))
    refute(a.empty?)
    (0..4).each { |i| assert_equal(i, a[i]) }
    (0..4).each { |i| assert_equal(i, a[i-5]) }
    assert_equal(nil, a[-6])
    assert_equal(nil, a[5])
    a.insert(10,nil)
    refute(a==b)
    (0..4).each { |i| assert_equal(i, a[i]) }
    (5..10).each { |i| assert_equal(nil, a[i]) }
    assert_equal(11, a.size)
    assert_equal(0, a.clear)
    assert(a.empty?)
    assert_raises(ArgumentError) { a.insert(-1,9) }
    assert_equal('x', a[2] = 'x')
    a[0] = 'y'
    a[3], a[2], a[0], a[1] = 3, 2, 0, 1
    assert_equal(4, a.size)
    refute(a==b)
    (0..3).each { |i| assert_equal(i, a[i]) }
    assert_equal(nil, a.delete_at(7))
    assert_equal(1, a.delete_at(1))
    assert_equal(0, a[0])
    assert_equal(2, a[1])
    assert_equal(3, a[2])
    assert_equal(3, a.delete_at(2))
    assert_equal(0, a.delete_at(0))
    assert_equal(2, a.delete_at(0))
    assert_equal(nil, a.delete_at(0))
    (0..10).each { |i| a[i] = i }
    b = LinkedList.new
    (0..5).each { |i| b[i] = i+3 }
    assert(a.slice(3,6)==b)
    assert(a.slice(-8,6)==b)
  end
  
  def test_iterators
    a = LinkedList.new
    b = LinkedList.new
    (0..5).each { |i| a[i] = b[i] = i }
    a.each { |i| assert_equal(i, b[i]) }
    assert(a==b)
    assert_equal(15, a.inject(:+))
    i = a.iterator
    sum = 0
    while !i.empty?
      sum += i.current
      i.next
    end
    assert_equal(15,sum)
  end
end