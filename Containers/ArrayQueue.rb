#
# Contiguous implementation of a queue using a dynamic array so it never becomes full.
#
# Author: C. Fox
# Version: 2/2017

require "test/unit"

class UnderflowError < StandardError; end
  
class ArrayQueue
  
  # @inv @count <= @store.size
  
  # Set up a new array queue
  def initialize(capacity = 10)
    @store, @front_index, @count = Array.new(capacity), 0, 0
  end
  
  ############### Container Operations ################
  
  # Return the number of items in the queue
  def size
    @count
  end
  
  # Say whether this queue is empty
  def empty?
    @count == 0
  end
  
  # Make the queue empty
  def clear
    initialize
  end
  
  ################## Queue Operations #################
  
  # Add an item to the back of the queue
  # @post: size = old.size+1
  #        if !old.empty? then front == old.front
  #        if old.empty? then front == item
  # @result: size
  def enter(item)
    #expand the store if necessary
    @store += @store if @count == @store.size
    # now add the item
    @store[(@front_index + @count) % @store.size] = item
    @count += 1
  end
  
  # Remove and return the item at the front of the queue
  # @pre: !empty?
  # @post: size == old.size-1
  def leave
    raise UnderflowError, "leave" if empty?
    result = @store[@front_index]
    @front_index = (@front_index + 1) % @store.size
    @count -= 1
    result
  end
  
  # Return the front item in the queue, but don't remove it
  # @pre: !empty?
  # @post: size == old.size
  def front
    raise UnderflowError, "front" if empty?
    @store[@front_index]
  end
  
  # Transform to an array for debugging purposes
  def to_a
    lastSize = @store.size - @front_index
    lastCount = (@count < lastSize) ? @count : lastSize
    result = @store[@front_index,lastCount]
    result += @store[0,@count-lastSize] if lastSize < @count
    result
  end
end

###################### Unit Tests #######################

class TestArrayQueue < Test::Unit::TestCase
  def test_container_ops
    q = ArrayQueue.new
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
    q = ArrayQueue.new
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