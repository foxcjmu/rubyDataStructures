#
# Contiguous implementation of a list that merely extends Array, which already implements
# all the Container, List, and Enumerable operations and most of the Collection operations.
#
# Author: C. Fox
# Version: 2/2017

require "test/unit"

class ArrayList < Array
  
  ############### Collection Operations #################
  
  # Create and return a new ArrayListIterator
  def iterator
    ArrayListIterator.new(self)
  end
  
  # Return an external iterator object for this Collection
  def self.iterator(array)
    raise ArgumentError unless array.class == Array
    ArrayListIterator.new(array)
  end

  # Return true iff an element is present in this collection
  alias contains? include?
  
  ######## Inner Concrete Iterator for ArrayList ########
  
  class ArrayListIterator
    
    # Associate this iterator with an array
    def initialize(array)
      raise ArgumentError unless array.class == ArrayList || array.class == Array
      @array, @index = array, 0
    end
    
    # Prepare for an iteration
    # @post: current == first item in Collection if !empty?
    def rewind
      @index = 0
    end
    
    # See whether iteration is complete
    def empty?
      @array.size <= @index
    end
    
    # Obtain the current element
    # @result: current element or nil if empty?
    def current
      @array[@index]
    end
  
    # Move to the next element
    # @result: next element or nil if empty?
    def next
      @index += 1
    end
  end
  
end

#################### Unit Tests #######################

class TestArrayList < Test::Unit::TestCase

  def test_collection_ops
    a = ArrayList.new
    assert_equal(ArrayList, a.class)
    assert(!a.contains?(5))
    (0..4).each { | i | a.insert(i, i) }
    assert_equal(5, a.size)
    assert(a.contains?(3))
    assert(!a.contains?(5))
    assert(!a.empty?)
    a.clear
    assert(a.empty?)
    a[0], a[1], a[2], a[3] = 0, 1, 2, 3
    assert_equal([0, 1, 2, 3], a)
    assert_equal(2, a.index(2))
    assert_equal([1,2], a.slice(-3,2))
    a = ArrayList.new([7, 6, 5, 4])
    assert_equal([7, 6, 5, 4], a)
    a.delete_at(2)
    assert_equal([7, 6, 4], a)
  end
  
  def test_iterators
    a = ArrayList.new([7, 6, 5, 4])
    assert_equal(22, a.inject(:+))
    i = a.iterator
    sum = 0
    while !i.empty?
      sum += i.current
      i.next
    end
    assert_equal(22,sum)
    b = (0..5).to_a
    i = ArrayList.iterator(b)
  end
end
