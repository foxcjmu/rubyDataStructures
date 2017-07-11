#
# AVL trees are balanced binary search trees.
#
# Author: C. Fox
# Version: 6/2017

require "test/unit"
require "BinarySearchTree"

class AVLTree < BinarySearchTree

  # Redefine the Node class to include a height variable and various
  # additional methods necessary for keeping the tree balanced.
  class Node
    attr_accessor :value, :left, :right, :height
    # Create a new node with various fields; default is a leaf node
    def initialize(value, left = nil, right = nil)
      @value, @left, @right = value, left, right
      set_height
    end

    # Determine the height of a node based on the heights of its children.
    def set_height
      left_height = @left ? @left.height : -1
      right_height = @right ? @right.height : -1
      @height = (left_height < right_height ? right_height : left_height) + 1
    end

    # Determine the balance at a node based on the heights of its children.
    # In an AVL tree, balanced is maintained in the range -1..1.
    def balance()
      left_height = @left ? @left.height : -1
      right_height = @right ? @right.height : -1
      return left_height - right_height
    end

    # Rearrange the current node if its balance is 2 or -2 to maintain
    # the AVL tree invariant. After rebalancing, reset the height, which
    # may have changed.
    def rebalance
      case balance
      when 2
        if @left.balance == -1 then rotateLR else rotateR end
      when -2
        if @right.balance == 1 then rotateRL else rotateL end
      end
      set_height
    end

    # Recursively add a value to the tree rooted at this node. Once a value
    # has been added, the rebalance the tree as necessary.
    def add(value)
      case
      when value == @value
        @value = value
        return
      when value < @value
        if @left
          @left.add(value)
        else
          @left = Node.new(value)
        end
      else # value > @value
        if @right
          @right.add(value)
        else
          @right = Node.new(value)
        end
      end
      rebalance
    end

    # Recursively find a value and remove it. Once a value has been
    # removed, rebalance the tree as necessary.
    def remove(value)
      case
      when value < @value
        return self unless @left
        @left = @left.remove(value)
      when value > @value
        return self unless @right
        @right = @right.remove(value)
      else # value == @value
        return @left unless @right
        return @right unless @left
        @value, @right = @right.remove_successor
      end
      rebalance
      return self
    end

    # Find the successor of the removed value, delete its node,
    # and return the value so it can replace the deleted value.
    def remove_successor
      if @left
        result, @left = @left.remove_successor
        rebalance
        return result, self
      end
      return @value, @right
    end

    # Rebalance by making the left child the root.
    def rotateR
      newRight = Node.new(@value, @left.right, @right);
      @value = @left.value;
      @left = @left.left;
      @right = newRight
    end

    # Rebalance by making the right child of the left child the root.
    def rotateLR
      newRight = Node.new(@value, @left.right.right, @right)
      @value, @left.right, @right = @left.right.value, @left.right.left, newRight
      @left.set_height
    end

    # Rebalance by making the right child the root.
    def rotateL
      newLeft = Node.new(@value, @left, @right.left);
      @value, @right, @left = @right.value, @right.right, newLeft
    end

    # Rebalance by making the  left child of the right child the root.
    def rotateRL
      newLeft = Node.new(@value, @left, @right.left.left)
      @value, @right.left, @left = @right.left.value, @right.left.right, newLeft
      @right.set_height
    end

  end # Node ###################################################################

  # @inv: for every node:
  #  - if node.left, then node.left.value <= node.value
  #  - if node.right, then node.value <= node.right.value
  #  - node balance is in the range -1..1

  # Set up an empty tree.
  def initialize
    @root, @count = nil, 0
  end

  # Redefine height to use Node@height.
  def height
    return 0 unless @root
    @root.height
  end

  # Insert the element into the AVL tree, or replace it with
  # the element if a value equal to element is already present.
  def add(value)
    if @root == nil
      @root = Node.new(value)
      @count = 1
    end
    @count += 1 unless contains?(value)
    @root.add(value)
  end

  # Remove the element from the tree, or do nothing if it is not present.
  def remove(value)
    return unless contains?(value)
    @root = @root.remove(value)
    @count -= 1
  end

  # Override this method from BinaryTree to show balance factors.
  def to_string(node,depth)
    result = "  "*depth + (node ? "#{node.value} (#{node.balance})" : "-") + "\n"
    return result unless node
    return result unless node.left || node.right
    result += to_string(node.left, depth+1)
    result += to_string(node.right, depth+1)
  end

end # AVLTree

#########################  Unit Tests ##########################

class TestBinarySearchTree < Test::Unit::TestCase
  def test_basic_ops
    t = AVLTree.new
    assert(t.empty?)
    assert_equal(nil, t.get("a"))
    assert_equal(0, t.height)
    t = AVLTree.new
    t.add("a")
    assert(!t.empty?)
    assert(t.contains?("a"))
    assert(!t.contains?("b"))
    assert_equal("a", t.get("a"))
    assert_equal(nil, t.get("b"))
    t.add("e")
    t.add("c")
    t.add("b")
    t.add("a")
    assert_equal("a", t.get("a"))
    assert_equal("c", t.get("c"))
    assert_equal("e", t.get("e"))
    assert_equal(nil, t.get("f"))
    t.add("m")
    t.add("j")
    t.add("p")
    t.add("w")
    t.add("s")
    t.add("g")
    t.add("d")
    t.add("w")
    assert_equal(11, t.size)
    assert_equal(3, t.height)
    assert(t.contains?("j"))
    assert(t.contains?("s"))
    s = ""
    t.each { |ch| s += ch }
    assert_equal('abcdegjmpsw', s)
    t.remove("f")
    assert_equal(11, t.size)
    assert_equal(3, t.height)
    assert(t.contains?("j"))
    assert(t.contains?("s"))
    s = ""
    t.each { |ch| s += ch }
    assert_equal('abcdegjmpsw', s)
    t.remove("d")
    assert_equal(10, t.size)
    assert_equal(3, t.height)
    assert(t.contains?("j"))
    assert(t.contains?("s"))
    s = ""
    t.each { |ch| s += ch }
    assert_equal('abcegjmpsw', s)
    t.remove("w")
    assert_equal(9, t.size)
    assert_equal(3, t.height)
    assert(t.contains?("j"))
    assert(t.contains?("s"))
    s = ""
    t.each { |ch| s += ch }
    assert_equal('abcegjmps', s)
    t.remove("e")
    assert_equal(8, t.size)
    assert_equal(3, t.height)
    assert(t.contains?("j"))
    assert(t.contains?("s"))
    s = ""
    t.each { |ch| s += ch }
    assert_equal('abcgjmps', s)
    t.remove("j")
    assert_equal(7, t.size)
    assert_equal(3, t.height)
    assert(t.contains?("c"))
    assert(t.contains?("s"))
    s = ""
    t.each { |ch| s += ch }
    assert_equal('abcgmps', s)
    t.remove("m")
    assert_equal(6, t.size)
    assert_equal(2, t.height)
    assert(t.contains?("c"))
    assert(t.contains?("s"))
    s = ""
    t.each { |ch| s += ch }
    assert_equal('abcgps', s)
    t.remove("a")
    assert_equal(5, t.size)
    assert_equal(2, t.height)
    assert(t.contains?("c"))
    assert(t.contains?("s"))
    s = ""
    t.each { |ch| s += ch }
    assert_equal('bcgps', s)
    t.remove("g")
    assert_equal(4, t.size)
    assert_equal(2, t.height)
    assert(t.contains?("c"))
    assert(t.contains?("s"))
    s = ""
    t.each { |ch| s += ch }
    assert_equal('bcps', s)
    t.remove("c")
    assert_equal(3, t.size)
    assert_equal(1, t.height)
    assert(t.contains?("p"))
    assert(t.contains?("s"))
    s = ""
    t.each { |ch| s += ch }
    assert_equal('bps', s)
    t.clear
    assert_equal(0,t.size)
    t.add("a")
    assert_equal(1,t.size)
    assert_equal(0,t.height)
    t.remove("a")
    assert(t.empty?)
  end
end