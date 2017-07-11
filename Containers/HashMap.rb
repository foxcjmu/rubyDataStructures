# A HashMap uses a HashTable to hold the values in the map.
# Keys in the key-value pair used in a HashMap must have
# appropriate hash and == functions.
#
# Author: C. Fox
# Version: June 2017

require "test/unit"
require "HashTable"

class HashMap
  
  ###################  Object Operations ###################
  
  DEFAULT_TABLE_SIZE = 91
  
  # Set up a new HashMap
  def initialize(size=DEFAULT_TABLE_SIZE)
    @table = HashTable.new(size)
  end
  
  # Print the contents of this map
  def to_s
    @table.to_s
  end
  
  ################## Container Operations ###################
  
  # Return the number of entities in the map
  def size
    @table.size
  end
  
  # Say whether this hashmap is empty
  def empty?
    @table.size == 0
  end
  
  # Make the map empty
  def clear
    @table.clear
  end
  
  ################### Collection Operations #################
  
  # Return an external iterator object for this map
  def iterator
    @table.iterator
  end
  
  # Return true iff this map is the same as another
  def ==(other)
    return false unless other
    return false unless @table.size == other.size
    @table.each do |k,v|
      return false unless other[k] == v
    end
    true
  end
  
  ##################### Map Operations ######################
  
  # Return the value with the indicated key, or nil if none
  def [](key)
    @table.get(key)
  end
  
  # Add a key-value pair to the map.
  def []=(key, value)
    @table.insert(key, value)
  end
  
  # Remove the pair with the designated key from the map,
  # or do nothing if key not present.
  def delete(key)
    @table.delete(key)
  end
  
  # Return true iff the key is present in the map
  def has_key?(key)
    @table.get(key) != nil
  end
  
  # Return true iff the value is present in the map
  def has_value?(value)
    @table.each do | k, v |
      return true if v == value
    end
    false
  end
  
  # Return true iff an element is present in this map
  alias contains? has_value?

  # Iterator over keys
  def key_iterator
    @table.key_iterator
  end
  
  ################### Enumerable Operations ################
  
  def each(&b)
    @table.each { |k,v| b.call(k, v) }
  end
  
end

####################### Unit Tests #########################

class TestHashMap < Test::Unit::TestCase
  def test_basic
    s = HashMap.new
    t = HashMap.new
    assert_equal(0, s.size)
    assert(s.empty?)
    assert(!s.has_key?(:a))
    assert(!s.has_value?(4))
    assert(t==s)
    assert(s==t)
    s[:m] = 8
    assert_equal(1, s.size)
    assert(!s.empty?)
    assert(s.has_key?(:m))
    assert(s.has_value?(8))
    s[:g] = 1
    s[:t] = 32
    s[:g] = 2
    s[:c] = 1
    s[:k] = 256
    s[:w] = 64
    s[:p] = 16
    s[:k] = 4
    assert_equal(7, s.size)
    assert_equal(nil, s[:none])
    assert_equal(1, s[:c])
    assert_equal(2, s[:g])
    assert_equal(4, s[:k]) 
    assert_equal(8, s[:m])
    assert_equal(16,s[:p])
    assert_equal(32,s[:t])
    assert_equal(64,s[:w])
    assert(s.has_key?(:k))
    assert(s.has_key?(:w))
    assert(s.has_key?(:c))
    assert(!s.has_key?(:a))
    t[:p] = 16
    t[:c] = 1
    t[:g] = 2
    t[:k] = 4
    t[:w] = 64
    refute(s==t)
    refute(t==s)
    t[:t] = 32
    t[:m] = 8
    assert(s==t)
    assert(t==s)
    assert_equal(nil, s.delete(:a))
    s.delete(:w)
    assert_equal(6, s.size)
    refute(s==t)
    s.delete(:c)
    s.delete(:m)
    assert_equal(4, s.size)
  end
  
  def test_iterators
    s = HashMap.new
    s[:m] = 8
    s[:t] = 32
    s[:g] = 2
    s[:c] = 1
    s[:w] = 64
    s[:p] = 16
    s[:k] = 4
    assert(s.has_key?(:k))
    assert(s.has_key?(:w))
    assert(s.has_key?(:c))
    assert(!s.has_key?(:a))
    assert(s.has_value?(32))
    assert(s.has_value?(2))
    assert(s.contains?(1))
    assert(!s.contains?(7))
    count = 0
    s.each { |key, value| count += 1 }
    assert_equal(7,count)
    iter = s.iterator
    count = 0
    while !iter.empty?
      array = iter.current
      count += 1
      iter.next
    end
    assert_equal(7,count)
    iter = s.key_iterator
    s.each do |key,value| 
      assert_equal(key, iter.current)
      assert_equal(value, s[iter.current])
      iter.next
    end
  end
  
end