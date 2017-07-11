#
# Contiguous stack implementation. Ruby has dynamic arrays, so it never overflows.
#
# Author: C. Fox
# Version: 2/2017

require "test/unit"

class UnderflowError < StandardError; end # raised by pop and top

class ArrayStack

  # @inv: s.push(i).top == i
  # @inv: s.push(i).pop == old.s
  
  # Make the store into an array
  def initialize
    @store = []     # items in the stack; top is at @store[-1]
  end
  
  ############### Container Operations ################
  
  # Return the current size of the stack
  def size
    @store.size
  end
  
  # Say if this stack is empty
  def empty?
    @store.size == 0
  end

  # Remove all elements from the stack
  def clear
    @store = []
  end
  
  ################# Stack Operations ##################
  
  # Put a new value on the stack
  # @post: @store.size == old.@store.size+1
  def push(item)
    @store << item
  end
  
  # Remove and return the top item on the stack
  # @pre: !empty?
  # @post: size == old.size-1
  def pop
    raise UnderflowError, "pop" if empty?
    @store.pop
  end
  
  # Return the top item on the stack
  # @pre: !empty?
  # @post: size == old.size     
  def top
    raise UnderflowError, "top" if empty?
    @store[-1]
  end
end

#################### Unit Tests ######################

class TestArrayStack < Test::Unit::TestCase
  def test_container_ops
    s = ArrayStack.new
    assert(s.empty?)
    assert_equal(0, s.size)
    (1..3).each { |i| s.push(i) }
    assert(!s.empty?)
    assert_equal(3, s.size)
    s.clear
    assert(s.empty?)
  end
  
  def test_stack_ops
    s = ArrayStack.new
    assert_raises(UnderflowError) { s.pop }
    assert_raises(UnderflowError) { s.top }
    (1..20).each { |i| s.push(i) }
    assert_equal(20, s.top)
    assert_equal(20, s.pop)
    assert_equal(19, s.size)
    assert_equal(19, s.top)
  end
end
