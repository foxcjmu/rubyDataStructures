# Binary trees are used as implementation data structures.
#
# Author: C. Fox
# Version: 2/2017

require "test/unit"
require "LinkedStack"

class BinaryTree
  include Enumerable
  
  # Create a node class for making a linked binary tree
  Node = Struct.new(:value, :left, :right)
  
  # @inv: 0 <= count
  # @inv: root is null iff 0 == count

  # Set up a new tree; value is the datum stored at the root node
  # @pre: left and right are binary trees (not nodes)
  def initialize(value=nil, left=nil, right=nil)
    raise ArgumentError, "Left sub-tree is not a BinaryTree" unless left == nil || left.class == BinaryTree
    raise ArgumentError, "Right sub-tree is not a BinaryTree" unless right == nil || right.class == BinaryTree
    if value == nil
      @root, @count = nil, 0
    else
      @root = Node.new(value, (left ? dup_structure(left.get_structure) : nil), (right ? dup_structure(right.get_structure) : nil))
      @count = 1 + (left ? left.size : 0) + (right ? right.size : 0)
    end
  end
  
  ##################### Object Operations ###################
  
  # Return true if a tree has the same shape with the same
  # values at the nodes as another.
  def ==(other)
    return false unless other
    return false unless @count == other.size
    equal_structure?(@root,other.get_structure)
  end
  
  # List the contents of the tree in order
  def to_s
    to_string(@root,0)
  end
  
  ################## Binary Tree Operations ##################
  
  # True iff there are no nodes
  def empty?
    @count == 0
  end
  
  # Height of a node with no children is 0; height of a tree is 1+height of
  # its tallest non-empty child
  def height
    structure_height(@root)
  end
  
  # Returns the value at the root of the tree
  # @pre: !empty?
  def root_value
    raise RuntimeError, "Empty trees have no root value" unless @root
    @root.value
  end
  
  # Returns a BinaryTree that is a copy of the left subtree
  # @pre: !empty?
  def left_subtree
    raise RuntimeError, "Empty trees have no left sub-tree" if empty?
    result = BinaryTree.new
    new_root = dup_structure(@root.left)
    result.set_root(new_root)
    result
  end
  
  # Returns a BinaryTree that is a copy of the right subtree
  # @pre: !empty?
  def right_subtree
    raise RuntimeError, "Empty trees have no right sub-tree" if empty?
    result = BinaryTree.new
    new_root = dup_structure(@root.right)
    result.set_root(new_root)
    result
  end
  
  # Return the linked graph from @root.
  def get_structure
    return @root
  end

  # Returns the number of nodes in the tree
  def size
    @count
  end
  
  # Makes the tree into the empty tree
  def clear
    @root = nil
    @count = 0
  end
  
  # Returns true iff v is stored at a node in the tree
  def contains?(v)
    structure_contains?(v,@root)
  end
  
  #################### Eumerable Operations #####################
  
  def each_preorder(&block)
    each_preorder_structure(@root,block)
  end
  
  def each_inorder(&block)
    each_inorder_structure(@root,block)
  end
  
  def each_postorder(&block)
    each_postorder_structure(@root,block)
  end
  
  alias each each_inorder
  
  ######################### Iterators ##########################
  
  class PreorderIterator
    
    # Create a new iterator
    def initialize(node)
      @root = node
      @stack = LinkedStack.new
      rewind
    end
    
    # Prepare for an iteration
    # @post: current == first item in Collection if !empty?
    def rewind
      @stack.clear
      @stack.push(@root) if @root
    end
    
    # See whether iteration is complete
    def empty?
      @stack.empty?
    end
    
    # Obtain the current element
    # @result: current element or nil if empty?
    def current
      return nil if @stack.empty?
      @stack.top.value
    end
  
    # Move to the next element
    # @result: next element or nil if empty?
    def next
      node = @stack.empty? ? nil : @stack.pop
      return if node == nil
      @stack.push(node.right) if node.right != nil
      @stack.push(node.left) if node.left != nil
    end
  end
  
  # Return a new preorder external iterator
  def preorder_iterator
    PreorderIterator.new(@root)
  end
  
  class InorderIterator
      
    # Create a new iterator
    def initialize(node)
      @root = node
      @stack = LinkedStack.new
      rewind
    end
      
    # Prepare for an iteration
    # @post: current == first item in Collection if !empty?
    def rewind
      @stack.clear
      node = @root
      while node
        @stack.push(node)
        node = node.left
      end
    end
      
    # See whether iteration is complete
    def empty?
      @stack.empty?
    end
    
    # Obtain the current element
    # @result: current element or nil if empty?
    def current
      return nil if @stack.empty?
      @stack.top.value
    end
  
    # Move to the next element
    # @result: next element or nil if empty?
    def next
      node = @stack.empty? ? nil : @stack.pop.right
      while node
        @stack.push(node)
        node = node.left
      end
    end
  end
  
  # Return a new inorder external iterator
  def inorder_iterator
    InorderIterator.new(@root)
  end
    
  # The default iterator is an inorder iterator
  alias iterator inorder_iterator
  
  class PostorderIterator
      
    # Create a new iterator
    def initialize(node)
      @root = node
      @stack = LinkedStack.new
      rewind
    end
      
    # Prepare for an iteration
    # @post: current == first item in Collection if !empty?
    def rewind
      @stack.clear
      node = @root
      while node
        @stack.push(node)
        node = node.left ? node.left : node.right
      end
    end
      
    # See whether iteration is complete
    def empty?
      @stack.empty?
    end
    
    # Obtain the current element
    # @result: current element or nil if empty?
    def current
      return nil if @stack.empty?
      @stack.top.value
    end
  
    # Move to the next element
    # @result: next element or nil if empty?
    def next
      node = @stack.empty? ? nil : @stack.pop
      return if node == nil || @stack.empty?
      if node != @stack.top.right
        node = @stack.top.right
        while node
          @stack.push(node)
          node = node.left ? node.left : node.right
        end
      end
    end
  end
  
  # Return a new post order external iterator
  def postorder_iterator
    PostorderIterator.new(@root)
  end
  
  ####################### Helper Functions #######################
  
  protected
   
  # Print an indented version of the tree
  def to_string(node,depth)
    result = "  "*depth + (node ? node.value : "-") + "\n"
    return result unless node
    return result unless node.left || node.right
    result += to_string(node.left, depth+1)
    result += to_string(node.right, depth+1)
  end

  # Assign the @root of a binary tree and adjust @count
  def set_root(root)
    @root = root
    @count = structure_count(@root)
  end
  
  private
   
  # Recursively compute and return the height of a tree structure
  def structure_height(node)
    return 0 unless node
    return 0 if node.left == nil and node.right == nil
    left_height = structure_height(node.left)
    right_height = structure_height(node.right)
    ((left_height < right_height) ? right_height : left_height) + 1
  end
  
  # Recursively compute and return the number of nodes in a tree structure
  def structure_count(node)
    return 0 unless node
    return 1 + structure_count(node.left) + structure_count(node.right)
  end
  
  # Recursively make and return a copy of the linked tree structure
  def dup_structure(node)
    return nil unless node
    Node.new(node.value, dup_structure(node.left), dup_structure(node.right))
  end
  
  # Return true iff two tree structures have the same shape with the same values
  def equal_structure?(node1,node2)
    return true if node1 == nil && node2 == nil
    return false if (node1 == nil || node2 == nil)
    return false if node1.value != node2.value
    equal_structure?(node1.left,node2.left) && equal_structure?(node1.right,node2.right)
  end
  
  # Return iff a tree structure contains a value
  def structure_contains?(v, node)
    return false unless node
    return true if v == node.value
    structure_contains?(v,node.left) || structure_contains?(v,node.right)
  end
  
  # Apply a proc to the values in a tree structure in preorder
  # @pre: proc != nil
  def each_preorder_structure(node, proc)
    return unless node
    proc.call(node.value)
    each_preorder_structure(node.left,proc)
    each_preorder_structure(node.right,proc)
  end
  
  # Apply a proc to the values in a tree structure inorder
  # @pre: proc != nil
  def each_inorder_structure(node, proc)
    return unless node
    each_inorder_structure(node.left,proc)
    proc.call(node.value)
    each_inorder_structure(node.right,proc)
  end
  
  # Apply a proc to the values in a tree structure in postorder
  # @pre: proc != nil
  def each_postorder_structure(node, proc)
    return unless node
    each_postorder_structure(node.left,proc)
    each_postorder_structure(node.right,proc)
    proc.call(node.value)
  end
end

########################  Unit Tests #########################

class TestBinaryTree < Test::Unit::TestCase

  def test_basic_ops
    t = BinaryTree.new
    assert(t.empty?)
    assert_equal(0, t.size)
    assert_equal(0, t.height)
    assert_raise(RuntimeError) { t.root_value }
    assert_raise(RuntimeError) { t.left_subtree }
    assert_raise(RuntimeError) { t.right_subtree }
    t = BinaryTree.new("a")
    assert(!t.empty?)
    assert_equal(1, t.size)
    assert_equal(0, t.height)
    assert_equal("a", t.root_value)
    assert(t.left_subtree.empty?)
    assert(t.right_subtree.empty?)
    assert(t.contains?("a"))
    assert(!t.contains?("b"))
    s = BinaryTree.new("c")
    t = BinaryTree.new("b",t,s)
    assert(!t.empty?)
    assert_equal(1, t.height)
    assert_equal(3, t.size)
    assert_equal("b", t.root_value)
    assert_equal(s, t.right_subtree)
    assert(t.contains?("c"))
    assert(!t.contains?("d"))
    t = BinaryTree.new("d",t,BinaryTree.new("e"))
    assert_equal(2, t.height)
    assert_equal(5, t.size)
    assert_equal("d", t.root_value)
  end
end