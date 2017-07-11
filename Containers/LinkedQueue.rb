#
# Linked queue implementation.
#
# Author: C. Fox
# Version: June 2017

require "test/unit"

class UnderflowError < StandardError; end

class LinkedQueue
  
  # Create a node class for making a linked list
  Node = Struct.new(:item, :next)
  
  # @inv: @count == 0 if and only if @frontPtr == @rearPtr == nil
  
  # Set the item count to 0 and the list references to nil
  def initialize
    @frontPtr = @rearPtr = nil
    @count = 0
  end
  
  ################### Container Operations ####################
  
  # Return the current size of the queue
  def size
    @count
  end
  
  # Say whether this queue is empty
  def empty?
    @count == 0
  end
  
  # Remove all elements from the queue
  def clear
    initialize
  end
  
  #################### Queue Operations #######################
  
  # Add an item to the back of the queue
  # @post: size = old.size+1
  #        if !old.empty? then front == old.front
  #        if old.empty? then front == item
  # @result: size
  def enter(item)
    if empty?
      @frontPtr = @rearPtr = Node.new(item,nil)
    else
      @rearPtr = @rearPtr.next = Node.new(item,nil)
    end
    @count += 1
  end
  
  # Remove and return the item at the front of the queue
  # @pre: !empty?
  # @post: size == old.size-1
  def leave
    raise UnderflowError, "leave" if empty?
    @count -= 1
    frontItem = @frontPtr.item;
    @frontPtr = @frontPtr.next;
    @rearPtr = nil if empty?
    return frontItem
  end
  
  # Return the front item in the queue, but don't remove it
  # @pre: !empty?
  # @post: size == old.size
  def front
    raise UnderflowError, "front" if empty?
    return @frontPtr.item
  end
  
  # Transform to an array for testing purposes
  def to_a
    currentNode = @frontPtr
    result = []
    while currentNode
      result << currentNode.item
      currentNode = currentNode.next
    end
    return result
  end
end

##################### Unit Tests ########################

class TestArrayQueue < Test::Unit::TestCase
  def test_container_ops
    q = LinkedQueue.new
    assert(q.empty?)
    assert_equal(0, q.size)
    (1..8).each { |i| q.enter(i) }
    assert(!q.empty?)
    assert_equal(8, q.size)
    q.clear
    assert(q.empty?)
    assert_equal(0, q.size)
  end
  
  def test_queue_ops
    q = LinkedQueue.new
    assert_raises(UnderflowError) { q.leave }
    assert_raises(UnderflowError) { q.front }
    (1..20).each { |i| q.enter(i) }
    assert_equal(1, q.front)
    assert_equal(1, q.leave)
    assert_equal(19, q.size)
    (2..10).each { |i| assert_equal(i, q.leave) }
    assert_equal(10, q.size)
  end
end