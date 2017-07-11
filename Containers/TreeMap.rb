#
# A TreeMap uses a BinarySearrchTree to hold the values in the map.
# Keys in the key-value pair used in a TreeMap must be comparable.
#
# Author: C. Fox
# Version: June 2017

require "test/unit"
require "TwoThreeTree"

class TreeMap
  
  ###################### Pair Class ########################
  # The Tree map holds the key-value pair in a pair class
  # whose comparisons operations use the key only.
  
  Pair = Struct.new(:key, :value)
  
  class Pair
    include Comparable
    def <=>(other)
      self.key <=> other.key
    end
  end
    
  ###################  Object Operations ###################
  
  # Set up a new TreeMap
  def initialize
    @tree = TwoThreeTree.new
  end
  
  # Print the contents of this map
  def to_s
    result = "[ "
    @tree.each do | pair |
      result += "("+ pair.key.to_s + "," + pair.value.to_s + ") "
    end
    result + "]"
  end
  
  ################## Container Operations ###################
  
  # Return the number of entities in the map
  def size
    @tree.size
  end
  
  #say whether this map is empty
  def empty?
    @tree.size == 0
  end
  
  # Make the map empty
  def clear
    @tree.clear
  end
  
  ################### Collection Operations #################
  
  # Return an external iterator object for this map
  def iterator()
    TreeMapIterator.new(@tree)
  end
  
  # Return true iff this map is the same as another
  def ==(other)
    return false unless other
    return false unless @tree.size == other.size
    @tree.each do |this_pair|
      return false unless other[this_pair.key] == this_pair.value
    end
    true
  end
  
  ##################### Map Operations ######################
  
  # Return the value with the indicated key, or nil if none
  def [](key)
    dummy = Pair.new(key,nil)
    pair = @tree.get(dummy)
    return nil unless pair
    pair.value
  end
  
  # Add a key-value pair to the map; replace the value if a pair with the key is already present
  # @return: value
  def []=(key, value)
    pair = Pair.new(key,value)
    @tree.add(pair)
    value
  end
  
  # Remove the pair with the designated key from the map, or do nothing if key not present
  def delete(key)
    dummy = Pair.new(key,nil)
    @tree.remove(dummy)
  end
  
  # Return true iff the key is present in the map
  def has_key?(key)
    dummy = Pair.new(key,nil)
    @tree.get(dummy)
  end
  
  # Return true iff the value is present in the map
  def has_value?(value)
    each do | k, v |
      return true if v == value
    end
    false
  end
  
  # Return true iff an element is present in this map
  alias contains? has_value?

  ################### Enumerable Operations ################
  
  def each(&b)
    @tree.each do |pair|
      b.call(pair.key, pair.value)
    end
  end
  
  ################### External Iterators ###################
  
  class TreeMapIterator
    
    # Set up a new tree map iterator
    # @pre: tree is a BinarySearchTree
    def initialize(tree)
      raise ArgumentError, "Bad iterator argument" unless tree.class == TwoThreeTree
      @tree_iterator = tree.iterator
      rewind
    end
    
    # Prepare for an iteration
    # @post: current == first item in Collection if !empty?
    def rewind
      @tree_iterator.rewind
    end
    
    # See whether iteration is complete
    def empty?
      @tree_iterator.empty?
    end
    
    # Obtain the current piar as an array with the key and value
    # @result: current element or nil if empty?
    def current
      return nil if empty?
      pair = @tree_iterator.current
      [pair.key, pair.value]
    end
  
    # Move to the next element
    # @result: next element or nil if empty?
    def next
      @tree_iterator.next
    end
  end
  
  #################### Helper Functions ####################
  
  protected
  
  # Make and return a duplicate of this map's BinarySearchTree
  def dup_tree
    @tree.dup
  end
  
end

####################### Unit Tests #########################

class TestTreeMap < Test::Unit::TestCase
  def test_basic
    s = TreeMap.new
    t = TreeMap.new
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
    s.delete(:a)
    s.delete(:w)
    assert_equal(6, s.size)
    refute(s==t)
    s.delete(:c)
    s.delete(:m)
    assert_equal(4, s.size)
  end
  
  def test_iterators
    s = TreeMap.new
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
    power = 1
    s.each do | key, value |
      assert_equal(power, s[key])
      power *= 2
    end
    iter = s.iterator
    power = 1
    while !iter.empty?
      array = iter.current
      assert_equal(power,array[1])
      assert_equal(power,s[array[0]])
      iter.next
      power *= 2
    end
  end
  
end