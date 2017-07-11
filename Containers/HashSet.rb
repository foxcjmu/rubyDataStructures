#
# A HashSet uses hashing to implement a set.
#
# Author: C. Fox
# Version: June 2017

require "test/unit"
require "HashTable"

class HashSet
  
  # Set up a new HashSet
  def initialize()
    @table = HashTable.new
  end  
  
  ################# Container Operations ###################
  
  # Return the number of entities in the set
  def size
    @table.size
  end
  
  # True iff this is the empty set
  def empty?
    @table.size == 0
  end
  
  # Make the set empty
  def clear
    @table.clear
  end
  
  ################# Collection Operations ##################
  
  # Return an external iterator object for this set
  def iterator()
    @table.iterator()
  end

  # Return true iff an element is present in this set
  def contains?(element)
    @table.get(element) != nil
  end
  
  # Return true iff this set is the same as another
  def ==(other)
    return false unless other
    return false unless @table.size == other.size
    each { |e| return false unless other.contains?(e) }
    true
  end
  
  ##################### Set Operations #####################
  
  # Return true iff every member of set is a member of self
  def subset?(set)
    return false unless set
    set.each { |e| return false unless contains?(e) }
    true
  end
  
  # Put element into this set; replace it if it is already there
  # @return: element
  def insert(element)
    @table.insert(element, element)
  end
  
  # Take an element out of this set
  # @return: the removed element
  def delete(element)
    @table.delete(element)
  end
  
  # Return the intersection of this set with set
  def &(set)
    result = HashSet.new
    each { |e| result.insert(e) if set.contains?(e) }
    result
  end
  
  # Return the union of this set with set
  def +(set)
    result = HashSet.new()
    set.each { |e| result.insert(e) }
    each { |e| result.insert(e) }
    result
  end
  
  # Return the relative complement of this set with set
  def -(set)
    result = HashSet.new
    each { |e| result.insert(e) unless set.contains?(e) }
    result
  end
  
  # Show the contents of the set
  def to_s
    result = "{"
    each { |e| result += "#{ e}," }
    result = result[0..-1] if result[-1] == ","
    result + "}"
  end
  
  ################### Enumerable Operations ################
  
  def each(&b)
    @table.each { |k,v| b.call(k) }
  end
  
end

####################### Unit Tests #########################

class TestHashSet < Test::Unit::TestCase
  def test_basic
    s = HashSet.new
    t = HashSet.new
    assert_equal(0, s.size)
    assert(s.empty?)
    refute(s.contains?(:a))
    assert(t==s)
    assert(s==t)
    t.delete(:a)
    assert(t==s)
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
    t.insert(:p)
    t.insert(:c)
    t.insert(:g)
    t.insert(:k)
    t.insert(:w)
    refute(s==t)
    refute(t==s)
    t.insert(:t)
    t.insert(:m)
    assert(s==t)
    assert(t==s)
  end
 
  def test_set_ops
    a = HashSet.new
    b = HashSet.new
    aUb = HashSet.new
    aIb = HashSet.new
    aCb = HashSet.new
    empty_set = HashSet.new
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
    a = HashSet.new
    [8, 3, 7, 4, 1, 2, 8, 5, 6, 9, 10, 1].each { |x| a.insert(x) }
    iter = a.iterator
    count = 0
    while !iter.empty?
      assert(a.contains?(iter.current))
      iter.next
      count += 1
    end
    assert_equal(count,a.size)
  end
end