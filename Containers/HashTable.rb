#
# A HashTable stores keys and the values hashed by keys.
#
# Author: C. Fox
# Version: June 2017

require "test/unit"

DEFAULT_TABLE_SIZE = 91

class HashTable
  include Enumerable
  
  # Use chaining to resolve collisions; the table is an array of list
  # heads, and this is the linked list node type
  Node = Struct.new(:key, :value, :next)
  
  # @pre: 7 <= table_size
  def initialize(table_size=DEFAULT_TABLE_SIZE)
    table_size = DEFAULT_TABLE_SIZE if table_size < 7
    @table = Array.new(table_size)
    @count = 0
  end
  
  # Table size (not the number of elements)
  def table_size
    @table.size
  end
  
  # How many elements are in the table now
  def size
    @count
  end
  
  # Set the table to empty, without changing the table size
  def clear
    @table = Array.new(@table.size)
    @count = 0
  end
  
  # Put a pair into the table, replacing any pair with the same key.
  # @pre: key has an appropriate hash function and == operation
  def insert(key, value)
    i = key.hash % @table.size
    node = @table[i]
    while node
      if key == node.key
        node.value = value
        return
      end
      node = node.next
    end
    @table[i] = Node.new(key, value, @table[i])
    @count += 1
  end
  
  # Remove a pair from the table, or do nothing if the key is not present.
  # @pre: key has an appropriate hash function and == operation
  def delete(key)
    i = key.hash % @table.size
    return unless @table[i]
    if @table[i].key == key
      @table[i] = @table[i].next
      @count -= 1
      return
    end
    node = @table[i]
    while node.next
      if key == node.next.key
        node.next = node.next.next
        @count -= 1
        return
      end
      node = node.next
    end
  end
  
  # Obtain a value from the table associated with the key.
  # @return: nil if no item equal to element is present
  # @pre: key has an appropriate hash function and == operation
  def get(key)
    i = key.hash % @table.size
    node = @table[i]
    while node
      return node.value if key == node.key
      node = node.next
    end
    nil
  end
  
  # Enumerable each operation
  def each
    @table.each do |node|
      while node
        yield node.key, node.value
        node = node.next
      end
    end
  end
  
  # Return an external value iterator for this hashtable
  def iterator
    HashTableIterator.new(@table)
  end
  
  # Return an external value iterator for this hashtable
  def key_iterator
    HashTableIterator.new(@table, false)
  end
  
  ########### External Iterator Class ##############
  
  class HashTableIterator
    
    # Make a new iterator object
    # table is the array used in the hashtable
    # iterator over keys or values: values is the default
    def initialize(table, iterate_over_values = true)
      @table = table
      @is_value = iterate_over_values
      rewind
    end
    
    # Prepare for an iteration
    # @post: current == first item in Collection if !empty?
    def rewind
      @index = 0
      @node = @table.size == 0 ? nil : @table[@index]
      while @index < @table.size and @node == nil
        @index += 1
        @node = @table[@index]
      end
    end
    
    # See whether iteration is complete
    def empty?
      @node == nil
    end
    
    # Obtain the current pair
    # @result: current element or nil if empty?
    def current
      @node == nil ? nil : (@is_value ? @node.value : @node.key)
    end
  
    # Move to the next element
    # @result: next element or nil if empty?
    def next
      return nil unless @node
      @node = @node.next
      while @index < @table.size and @node == nil
        @index += 1
        @node = @table[@index]
      end
      @node == nil ? nil : (@is_value ? @node.value : @node.key)
    end
  end
  
  ############## Helper Functions ##################
  
  def to_s
    result = ""
    each { |k, v| result += "(#{k}, #{v}) " }
    result
  end
  
  ############# Analysis Functions #################
  
  # Summarize features of the table
  def analyze
    max_chain = 0
    min_chain = @count
    num_chains = 0
    @table.each do |node|
      chain_length = 0
      num_chains += 1 if node
      while node
        node = node.next
        chain_length += 1
      end
      max_chain = chain_length if max_chain < chain_length
      min_chain = chain_length if chain_length < min_chain
    end
    "Load factor: #{1.0*@count/@table.size}\n" +
    "Table density: #{1.0*num_chains/@table.size}\n" +
    "Mimumum chain: #{min_chain}\n" +
    "Maximum chain: #{max_chain}"
  end
end

##################### Unit Tests ########################

class TestHashTable < Test::Unit::TestCase
  
  def test_ops
    t = HashTable.new
    assert(t.size == 0)
    assert_equal(0, t.size)
    assert_equal(91, t.table_size)
    t.insert("abc",1)
    t.insert("def",2)
    t.insert("ghi",3)
    t.insert("jkl",4)
    assert_equal(4, t.size)
    assert_equal(nil, t.get("jkjkj"))
    assert(nil != t.get("jkl"))
    assert_equal(4, t.size)
    t.delete("jkl")
    assert_equal(nil, t.get("jkl"))
    assert_equal(3, t.size)
    assert_equal(nil, t.get("jkl"))
    t.insert("aaa",0)
    assert_equal(0, t.get("aaa"))
    count = 0
    t.each { count+=1 }
    assert_equal(count, t.size)
    t.each { |k,v| assert(nil != t.get(k)) }
  end

  def test_chains()
    t = HashTable.new(19)
    0.upto(50) { |x| t.insert(x,"#{x}") }
    0.upto(50) { |x| assert(nil != t.get(x)) }
    assert_equal(t.count,t.size)
    iter = t.iterator
    t.each do |k,v|
      assert_equal(v, iter.current)
      refute(iter.empty?)
      iter.next
    end
    assert(iter.empty?)
    a = []
    t.each { |k,v| a[k] = v }
    assert_equal(51,a.size)
    0.upto(50) {|x| assert_equal("#{x}",a[x]) }
    t.delete(20)
    t.delete(27)
    t.delete(42)
    assert_equal(48,t.size)
    assert_equal(nil, t.get(27))
    assert_equal(t.count,t.size)
  end
end