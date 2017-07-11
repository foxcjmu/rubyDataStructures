#
# An ArrayDequeues uses an array to implement a Dequeue. The array is 
# dynamic so it never becomes full. A 'circular' array technique is 
# used to avoid shifting data in the array.
#
# Author: C. Fox
# Version: June 2017

require "test/unit"

class UnderflowError < StandardError; end

class ArrayDequeue
  
  # @inv: 0 <= @count <= @store.size
  #       1 <= @store.size
  #       0 <= @front_index < @store.size
  
  # Make a new dequeue
  # @pre: 0 < capacity
  def initialize(capacity=10)
    raise ArgumentError, "Capacity must be at least 1" unless 0 < capacity
    @store = Array.new(capacity)
    @front_index = 0
    @count = 0
  end
  
  ############### Container Operations ################
   
   # Return the number of items in the dequeue
   def size
     @count
   end
   
   # Say whether this dequeue is empty
   def empty?
     @count == 0
   end

   # Make the dequeue empty
   def clear
     initialize
   end
  
  ################ Dequeue Operations #################
   
  # Add an item to the front of the dequeue
  # @post: size = old.size+1
  #        if !old.empty? then rear == rear
  #        if old.empty? then front == rear == item 
  # @return: size
  def enter_front(item)
    #expand the store if necessary
    @store += @store if @count == @store.size
    # now add the item
    @front_index = (@front_index == 0) ? @store.size-1 : @front_index-1
    @store[@front_index] = item
    @count += 1
  end

  # Add an item to the rear of a dequeue
  # @post: size = old.size+1
  #        if !old.empty? then front == front
  #        if old.empty? then front == rear == item 
  # @return: size
  def enter_rear(item)
    #expand the store if necessary
    @store += @store if @count == @store.size
    # now add the item
    @store[(@front_index + @count) % @store.size] = item
    @count += 1
  end

  # Remove and return the front element
  # @pre: not empty?
  # @post: size == old.size-1
  #        old.rear == rear
  def leave_front()
    raise UnderflowError, "leave_front" if empty?
    result = @store[@front_index]
    @front_index = (@front_index + 1) % @store.size
    @count -= 1
    result
  end

  # Remove and return the rear element
  # @pre: not empty?
  # @post: size == old.size-1
  #        old.front == front
  def leave_rear()
    raise UnderflowError, "leave_rear" if empty?
    @count -= 1
    @store[(@front_index+@count) % @store.size]
  end

  # Return, but do not remove, the front element
  # @pre: not empty?
  # @post: size == old.size
  def front()
    raise UnderflowError, "front" if empty?
    @store[@front_index]
  end

  # Return, but do not remove, the rear element
  # @pre: not empty?
  # @post: size == old.size
  def rear()
    raise UnderflowError, "rear" if empty?
    @store[(@front_index+@count-1) % @store.size]
  end
end

################### Unit Tests ######################

class TestArrayDequeue < Test::Unit::TestCase
  def test_container_ops
    d = ArrayDequeue.new(10)
    assert(d.empty?)
    assert_equal(0, d.size)
    (1..8).each { |i| d.enter_rear(i) }
    assert(!d.empty?)
    assert_equal(8, d.size)
    d.clear
    assert(d.empty?)
    assert_equal(0, d.size)
  end
  
  def test_dequeue_ops
    d = ArrayDequeue.new
    assert_raises(UnderflowError) { d.leave_front }
    assert_raises(UnderflowError) { d.front }
    assert_raises(UnderflowError) { d.leave_rear }
    assert_raises(UnderflowError) { d.rear }
    (1..20).each { |i| d.enter_rear(i) }
    ("a".."k").each { |i| d.enter_front(i) }
    assert_equal("k", d.front)
    assert_equal(20, d.rear)
    assert_equal(31, d.size)
    20.downto(1).each { |i| assert_equal(i, d.leave_rear) }
    assert_equal(11, d.size)
    ("a".."k").each { |i| assert_equal(i, d.leave_rear) }
    assert(d.empty?)
    20.downto(1).each { |i| d.enter_front(i) }
    (1..20).each { |i| assert_equal(i, d.leave_front) }
  end
end