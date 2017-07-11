#
# A TreeSet uses a BinarySearrchTree to hold the values in the set.
# Values in a TreeSet must be Comparable.
#
# Author: C. Fox
# Version: June 2017

require "test/unit"
require "AVLTree"

class TreeSet
  
  # Set up a new TreeSet
  def initialize
    @tree = AVLTree.new
  end
  
  ################## Container Operations ###################
  
  # Return the number of entities in the set
  def size
    @tree.size
  end
  
  # Say whether this set is empty
  def empty?
    @tree.size == 0
  end
  
  # Make the set empty
  def clear
    @tree.clear
  end
  
  ################### Collection Operations #################
  
  # Return an external iterator object for this set
  def iterator()
    @tree.iterator()
  end

  # Return true iff an element is present in this set
  def contains?(element)
    @tree.contains?(element)
  end
  
  # Return true iff this set is the same as another
  def ==(other)
    return false unless other
    return false unless @tree.size == other.size
    @tree.each { |e| return false unless other.contains?(e) }
    true
  end
  
  ##################### Set Operations ######################
  
  # Return true iff every member of set is a member of self
  def subset?(set)
    return false unless set
    set.each { |e| return false unless contains?(e) }
    true
  end
  
  # Put element into this set; replace it if it is already there
  # @return: element
  def insert(element)
    @tree.add(element)
  end
  
  # Take an element out of this set
  # @return: the removed element
  def delete(element)
    @tree.remove(element)
  end
  
  # Return the intersection of this set with set
  def &(set)
    result = TreeSet.new
    @tree.each_preorder { |x| result.insert(x) if set.contains?(x) }
    result
  end
  
  # Return the union of this set with set
  def +(set)
    result = TreeSet.new
    @tree.each { |x| result.insert(x) }
    set.each { |x| result.insert(x) }
    result
  end
  
  # Return the relative complement of this set with set
  def -(set)
    result = TreeSet.new
    @tree.each { |x| result.insert(x) unless set.contains?(x) }
    result
  end
  
  # Show the contents of the set
  def to_s
    "{" + @tree.to_s + "}"
  end
  
  ################### Enumerable Operations ################
  
  def each(&b)
    @tree.each { |x| b.call(x) }
  end
  
end

####################### Unit Tests #########################

class TestTreeSet < Test::Unit::TestCase
  def test_basic
    s = TreeSet.new
    t = TreeSet.new
    assert_equal(0, s.size)
    assert(s.empty?)
    assert(!s.contains?(:a))
    assert(t==s)
    assert(s==t)
    s.insert(:m)
    assert_equal(1, s.size)
    assert(!s.empty?)
    s.insert(:g)
    s.insert(:t)
    s.insert(:g)
    s.insert(:c)
    s.insert(:k)
    s.insert(:w)
    s.insert(:p)
    s.insert(:k)
    assert_equal(7, s.size)
    assert(s.contains?(:m))
    assert(s.contains?(:w))
    assert(s.contains?(:c))
    assert(!s.contains?(:a))
  end
  
  def test_set_ops
    a = TreeSet.new
    b = TreeSet.new
    aUb = TreeSet.new
    aIb = TreeSet.new
    aCb = TreeSet.new
    empty_set = TreeSet.new
    [8, 3, 7, 4, 1, 2, 8, 5, 6, 9, 10, 1].each { |x| a.insert(x) }
    assert_equal(10, a.size)
    [9, 10, 14, 12, 15, 8, 11, 13, 10].each { |x| b.insert(x) }
    [9, 2, 4, 1, 8, 5, 3, 7, 6, 11, 15, 12, 10, 13, 14].each { |x| aUb.insert(x) }
    assert(aUb==a+b)
    assert(aUb==b+a)
    [10, 8, 9].each { |x| aIb.insert(x) }
    assert(aIb==a&b)
    assert(aIb==b&a)
    [7, 3, 5, 2, 1, 3, 6, 4].each { |x| aCb.insert(x) }
    assert(aCb==a-b)
    refute(aCb==b-a)
    assert(aUb.subset?(a))
    assert(aUb.subset?(b))
    assert(aUb.subset?(aUb))
    assert(aUb.subset?(aIb))
    assert(aUb.subset?(aCb))
    assert(aUb.subset?(empty_set))
    assert(!a.subset?(b))
    assert(!a.subset?(aUb))
    assert(!b.subset?(a))
    assert(!b.subset?(aUb))
    assert(!empty_set.subset?(a))
    assert(empty_set.subset?(empty_set))
    assert(!a.subset?(nil))
  end
  
  def test_iterators
    a = TreeSet.new
    [8, 3, 7, 4, 1, 2, 8, 5, 6, 9, 10, 1].each { |x| a.insert(x) }
    iter = a.iterator
    count = 1
    while !iter.empty?
      assert_equal(count,iter.current)
      iter.next
      count += 1
    end
  end
end