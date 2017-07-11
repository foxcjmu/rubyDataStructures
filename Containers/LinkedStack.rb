#
# Linked stack implementation.
#
# Author: C. Fox
# Version: June 2017

require "test/unit"

class UnderflowError < StandardError; end  # for pop and top

class LinkedStack
  
  # Create a node class for making a linked list
  Node = Struct.new(:item, :next)
  
  # @inv: @count == 0 if and only if @topNode == nil
  
  # Set the item count to 0 and the list head to nil
  def initialize
    @topNode = nil    # head of list where top is stored
    @count = 0        # how many items are in the stack
  end
  
  ################ Container Operations #################
  
  # Return the current size of the stack
  def size
    @count
  end
  
  # Say whether this stack is empty
  def empty?
    @count == 0
  end
  
  # Remove all elements from the stack
  def clear
    initialize
  end
  
  ################## Stack Operations ###################
  
  # Put a new item on the top of the stack
  # @post: size = old.size+1 and top == item
  # @result: size
  def push(item)
    @topNode = Node.new(item, @topNode)
    @count += 1
  end
  
  # Remove and return the top item on the stack
  # @pre: !empty?
  # @post: size == old.size-1
  def pop
    raise UnderflowError, "pop" if empty?
    @count -= 1
    topItem = @topNode.item;
    @topNode = @topNode.next;
    topItem
  end
  
  # Return the top item on the stack
  # @pre: !empty?
  # @post: size == old.size
  def top
    raise UnderflowError, "top" if empty?
    @topNode.item
  end
end

##################### Unit Tests #######################

class TestLinkedStack < Test::Unit::TestCase
  def test_container_ops
    s = LinkedStack.new
    assert(s.empty?)
    assert_equal(0, s.size)
    (1..3).each { |i| s.push(i) }
    assert(!s.empty?)
    assert_equal(3, s.size)
    s.clear
    assert(s.empty?)
    assert_equal(0, s.size)
  end
  
  def test_stack_ops
    s = LinkedStack.new
    assert_raises(UnderflowError) { s.pop }
    assert_raises(UnderflowError) { s.top }
    (1..20).each { |i| s.push(i) }
    assert_equal(20, s.top)
    assert_equal(20, s.pop)
    assert_equal(19, s.size)
    assert_equal(19, s.top)
  end
end