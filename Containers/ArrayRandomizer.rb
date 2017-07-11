#
# Contiguous implementation of a randomizer using a dynamic array so it never becomes full.
#
# Author: C. Fox
# Version: 2/2017

require "test/unit"

class UnderflowError < StandardError; end
  
class ArrayRandomizer
  
  # Set up a new array queue
  def initialize()
    @store = []
  end
  
  ############### Container Operations ################
  
  # Return the number of items in the randomizer
  def size
    @store.size
  end
  
  # Say whether this queue is empty
   def empty?
     @store.size == 0
   end
   
  # Make the randomizer empty
  def clear
    initialize
  end
  
  ############### Randomizer Operations ###############
  
  # Add an item to the randomizer
  # @post: size = old.size + 1
  # @return: size
  def enter(item)
    @store << item
  end
  
  # Remove and return an item from the randomizer
  # @pre: not empty?
  # @post: size == @old.size - 1
  def leave
    raise UnderflowError, "leave" if empty?
    index = rand(@store.size)
    @store[-1], @store[index] = @store[index], @store[-1]
    @store.pop
  end
end
  
###################### Unit Tests #######################

class TestArrayRandomizer < Test::Unit::TestCase
  def test_container_ops
    q = ArrayRandomizer.new
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
    q = ArrayRandomizer.new
    assert_raises(UnderflowError) { q.leave }
    (1..3).each { |i| q.enter(i) }
    v1 = q.leave
    v2 = q.leave
    v3 = q.leave
    case v1
    when 1
      case v2
      when 2 then assert_equal(v3, 3)
      when 3 then assert_equal(v3, 2)
      else assert(false)
      end
    when 2
      case v2
      when 1 then assert_equal(v3, 3)
      when 3 then assert_equal(v3, 1)
      else assert(false)
      end
    when 3
      case v2
      when 1 then assert_equal(v3, 2)
      when 2 then assert_equal(v3, 1)
      else assert false
      end
    else assert(false)
    end
  end
end