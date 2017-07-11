#
# 2-3 trees are balanced binary search trees that can be used as implementation
# data structures.
#
# Author: C. Fox
# Version: 6/2017

require "test/unit"
require "LinkedStack"

class TwoThreeTree

  include Enumerable

  ###############################################################
  # Nodes can be either 2-nodes or 3-nodes

  private
  class Node

    attr_accessor :type,     # what kind of node this is (1, 2 or 3)
    :left,     # sub-tree for values < value1
    :value1,   # used for both 2-nodes and 3-nodes
    :mid,      # sub-tree for values > value1 and in a 3-node, < value2
    :value2,   # used only for 3-nodes
    :right     # sub-tree for values > value2
    def initialize(value, left = nil, mid = nil)
      @type, @value1, @left, @mid = 2, value, left, mid
    end

    # True iff this node is a leaf (we need only look at the
    # left sub-tree because the tree is perfectly balanced).
    def is_leaf
      return @left == nil
    end

    # Return the sub-tree with v added, and true iff count should be incremented
    def add(v)
      case
      when v < @value1
        if is_leaf
          return Node.new(@value1, Node.new(v), Node.new(@value2)), true if @type == 3
          @type, @value1, @value2 = 3, v, @value1
          return self, true
        end
        child, inc_count = @left.add(v)
        return self, inc_count if child == @left
        return Node.new(@value1, child, Node.new(@value2,@mid,@right)), true if @type == 3
        shift_right
        @type, @left, @value1, @mid = 3, child.left, child.value1, child.mid
        return self, true
      when v == @value1
        @value1 = v
        return self, false
      when @type == 2
        if is_leaf
          @type, @value2 = 3, v
          return self, true
        end
        child, inc_count = @mid.add(v)
        if child != @mid
          @type, @mid, @value2, @right = 3, child.left, child.value1, child.mid
        end
        return self, inc_count
      when v < @value2
        if is_leaf
          return Node.new(v, Node.new(@value1), Node.new(@value2)), true
        end
        child, inc_count = @mid.add(v)
        return self, inc_count if child == @mid
        return Node.new(child.value1, Node.new(@value1,@left,child.left),
        Node.new(@value2,child.mid,@right)), true
      when v == @value2
        @value2 = v
        return self, false
      else # v > @value2
        if is_leaf
          return Node.new(@value2, Node.new(@value1), Node.new(v)), true
        end
        child, inc_count = @right.add(v)
        return self, inc_count if child == @right
        return Node.new(@value2, Node.new(@value1, @left, @mid), child), true
      end
    end # add

    # Remove v from the tree or do nothing if it not present.
    # Return true iff a value is actually removed.
    def remove(v, target = nil, which = nil)

      # handle a leaf as a special case
      if is_leaf
        if target
          if which == 1
            target.value1 = @value1
          else
            target.value2 = @value1
          end
          @value1 = @value2
        else
          case
          when v < @value1
            return false
          when v == @value1
            @value1 = @value2
          when v > @value1
            return false if @type == 2
            return false if v != @value2
          end
        end
        @type -= 1
        return true
      end

      # delete from an internal node
      deletion = if target
        @left.remove(v, target, which)
      else
        case
        when v < @value1
          @left.remove(v)
        when v == @value1
          @mid.remove(v, self, 1)
        when @type == 2 || v < @value2
          @mid.remove(v)
        when v == @value2
          @right.remove(v, self, 2)
        else
          @right.remove(v)
        end
      end
      return false unless deletion

      # if any child is a 1-node, fix it
      if @left.type == 1
        if @mid.type == 3 || (@type == 3 && @right.type == 3)
          left_borrows_from_mid
          mid_borrows_from_right if @mid.type == 1
        else
          if @type == 3
            fold_left_into_mid
          else # @type == 2
            push_left_into_mid
          end
        end
      elsif @mid.type == 1
        if @left.type == 3
          mid_borrows_from_left
        elsif @type == 3
          if @right.type == 3
            mid_borrows_from_right
          else
            fold_mid_into_right
          end
        else
          push_mid_into_left
        end
      elsif @type == 3 && @right.type == 1
        if @left.type == 3 || @mid.type == 3
          right_borrows_from_mid
          mid_borrows_from_left if @mid.type == 1
        else
          fold_right_into_mid
        end
      end

      return deletion
    end # remove

    # Move the left portion of a node right
    def shift_right
      @mid, @value2, @right = @left, @value1, @mid
    end

    # Move the right part of a node to the left.
    def shift_left
      @left, @value1, @mid = @mid, @value2, @right
    end

    # Move the left child of mid into left.
    # @pre: left.type == 1; mid.type == 2 or mid.type == 3
    # @post: left.type == 2; mid.type == 1 or mid.type == 2
    def left_borrows_from_mid
      @left.type, @left.value1, @value1, @left.mid = 2, @value1, @mid.value1, @mid.left
      @mid.shift_left
      @mid.type -= 1
    end

    # Move the left child of right into mid.
    # @pre: mid.type == 1; right.type == 3
    # @post: mid.type == 2; right.type == 2
    def mid_borrows_from_right
      @mid.type, @mid.value1, @value2, @mid.mid = 2, @value2, @right.value1, @right.left
      @right.shift_left
      @right.type = 2
    end

    # Move the right child of left into mid.
    # @pre: left.type == 3; mid.type == 1
    # @post: left.type == 2; mid.type == 2
    def mid_borrows_from_left
      @mid.type, @mid.mid, @mid.value1, @mid.left = 2, @mid.left, @value1, @left.right
      @left.type, @value1 = 2, @left.value2
    end

    # Move the right child of mid into right.
    # @pre: right.type == 1; mid.type == 2 or mid.type == 3
    # @post: right.type == 2; mid.type == 1 or mid.type == 2
    def right_borrows_from_mid
      @right.type, @right.mid, @right.value1 = 2, @right.left, @value2
      if @mid.type == 3
        @right.left, @value2 = @mid.right, @mid.value2
      else
        @right.left, @value2 = @mid.mid, @mid.value1
      end
      @mid.type -= 1
    end

    # Merge left into mid then shift self left.
    # @pre: self.type == 3; left.type == 1; mid.type == 2
    # post: self.type == 2; left.type == 3; mid is the old right
    def fold_left_into_mid
      @mid.shift_right
      @mid.type, @mid.value1, @mid.left = 3, @value1, @left.left
      shift_left
      @type = 2
    end

    # Combine mid with with right them make right mid.
    # @pre: self.type == 3; mid.type == 1; right.type == 2
    # @post: self.type == 2; mid.type == 3
    def fold_mid_into_right
      @right.shift_right
      @right.type, @right.value1, @right.left = 3, @value2, @mid.left
      @type, @mid, @value2, @right = 2, @right, nil, nil
    end

    # Combing right with mid.
    # @pre: self.type == 3; right.type == 1; mid.type == 2
    # @post: self.type == 2; mid.type == 3
    def fold_right_into_mid
      @mid.type, @mid.value2, @mid.right = 3, @value2, @right.left
      @type, @value2, @right = 2, nil, nil
    end

    # Merge left 1-node with mid 2-node to make self into a 1-node with a 3-node child.
    # @pre: this.type == 2; left.type == 1; mid.type == 2
    # @post: this.type == 1; left.type == 3
    def push_left_into_mid
      @mid.shift_right
      @mid.type, @mid.value1, @mid.left = 3, @value1, @left.left
      @left = @mid
      @type = 1
    end

    # Merge mid 1-node with left 2-node to make self into a 1-node with a 3-node child.
    def push_mid_into_left
      @left.type, @left.value2, @left.right = 3, @value1, @mid.left
      @type = 1
    end

    # Iterate over this node in preorder
    def each_preorder(proc)
      proc.call(@value1)
      proc.call(@value2) if @type == 3
      @left.each_preorder(proc) if @left
      @mid.each_preorder(proc) if @mid
      @right.each_preorder(proc) if @type == 3 && @right
    end

    # Iterate over this node in in order
    def each_inorder(proc)
      @left.each_inorder(proc) if @left
      proc.call(@value1)
      @mid.each_inorder(proc) if @mid
      if @type == 3
        proc.call(@value2)
        @right.each_inorder(proc) if @right
      end
    end

    # Iterate over this node in post order
    def each_postorder(proc)
      @left.each_postorder(proc) if @left
      @mid.each_postorder(proc) if @mid
      @right.each_postorder(proc) if @type == 3 && @right
      proc.call(@value1)
      proc.call(@value2) if @type == 3
    end

    # Iterate over this node in in order
    # helper function for to_s. This function creates a string
    # representation of the tree suitable for printing. A good
    # debugging tool.
    def to_s(indent)
      tab = 4
      result = "#{@value1}"
      result += ", #{@value2}" if @type == 3
      result += "\n"
      result += " " * indent + "left tree:  "
      result += @left ? @left.to_s(indent+tab) : "-\n"
      result += " " * indent + "mid tree:   "
      result += @mid ? @mid.to_s(indent+tab) : "-\n"
      if @type == 3
        result += " " * indent + "right tree: "
        result += @right ? @right.to_s(indent+tab) : "-\n"
      end
      return result
    end

  end # Node ####################################################

  # @inv: 0 <= count
  # @inv: root is null iff 0 == count

  public

  def initialize
    @root = nil
    @count = 0
  end

  def empty?
    return @count == 0
  end

  def size
    return @count
  end

  def clear
    @count, @root = 0, nil
  end

  # 2-3 trees are perfectly height balanced so we can measure
  # any path from the root to a leaf, and there is always a left
  # subtree.
  def height
    return 0 if @root == nil
    t, result = @root, -1
    while t
      t = t.left
      result += 1
    end
    result
  end

  # return the value from the tree or nil if v is not present
  def get(v)
    t = @root
    while t
      case
      when v < t.value1 then t = t.left
      when v == t.value1 then return t.value1
      when t.type == 2 then t = t.mid
      when v < t.value2 then t = t.mid
      when v == t.value2 then return t.value2
      else t = t.right
      end
    end
    nil
  end

  def contains?(v)
    get(v) != nil
  end

  # put a new value into the tree or replace an existing value
  def add(v)
    if @root == nil
      @root = Node.new(v)
      @count = 1
      return
    end
    @root, inc_count = @root.add(v)
    @count += 1 if inc_count
  end

  # Remove a value from the tree, or do nothing if it is not present
  def remove(v)
    return unless @root
    @count -= 1 if @root.remove(v)
    @root = @root.left if @root.type == 1
  end

  # display the tree in a hierarchical list
  def to_s
    return "Empty 2-3 tree" unless @root
    "2-3 Tree\nroot: " + @root.to_s(0)
  end

  #################### Eumerable Operations #####################

  def each_preorder(&block)
    @root.each_preorder(block) if @root
  end

  def each_inorder(&block)
    @root.each_inorder(block) if @root
  end

  def each_postorder(&block)
    @root.each_postorder(block) if @root
  end

  alias each each_inorder

  ######################### Iterators ##########################

  class InorderIterator
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
        @stack.push([node,1])
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
      @stack.top[1] == 1 ? @stack.top[0].value1 : @stack.top[0].value2
    end

    # Move to the next element
    # @result: next element or nil if empty?
    def next
      if @stack.empty?
        node = nil
        return
      end
      node, which = @stack.pop
      @stack.push([node,2]) if node.type == 3 && which == 1
      node = which == 1 ? node.mid : node.right
      while node
        @stack.push([node,1])
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

end #TwoThreeTree

########################  Unit Tests #########################

class TestTwoThreeTree < Test::Unit::TestCase
  def test_basic_ops
    t = TwoThreeTree.new
    assert(t.empty?)
    assert_equal(0, t.size)
    assert_equal(0, t.height)
  end

  def test_add
    t = TwoThreeTree.new
    t.add(5)
    t.add(5)
    assert_equal(1, t.size)
    assert_equal(0, t.height)
    t.add(10)
    t.add(10)
    assert_equal(2, t.size)
    t.add(3)
    t.add(3)
    assert_equal(3, t.size)
    assert_equal(1, t.height)
    t.add(15)
    t.add(15)
    assert_equal(4, t.size)
    t.add(20)
    t.add(20)
    t.add(15)
    assert_equal(5, t.size)
    assert_equal(1, t.height)
    t.add(0)
    t.add(0)
    assert_equal(6, t.size)
    t.add(7)
    assert_equal(7, t.size)
    t.add(30)
    assert_equal(8, t.size)
    assert_equal(1, t.height)
    t.add(12)
    assert_equal(9, t.size)
    assert_equal(2, t.height)
    t.add(25)
    assert_equal(10, t.size)
    t.add(2)
    assert_equal(11, t.size)
    assert_equal(2, t.height)
  end

  def test_get
    t = TwoThreeTree.new
    t.add(5)
    t.add(10)
    t.add(3)
    t.add(30)
    t.add(15)
    t.add(20)
    t.add(25)
    t.add(0)
    t.add(35)
    t.add(40)
    assert_equal(15, t.get(15))
    assert_equal(5, t.get(5))
    assert_equal(25, t.get(25))
    assert_equal(25, t.get(25))
    assert_equal(10, t.get(10))
    assert_equal(0, t.get(0))
    assert_equal(30, t.get(30))
    assert_equal(nil, t.get(50))
    assert_equal(nil, t.get(-1))
    assert_equal(nil, t.get(17))
  end

  def test_remove
    t = TwoThreeTree.new
    t.add(30)
    t.add(40)
    t.add(25)
    t.add(25)
    t.add(50)
    t.add(20)
    t.add(22)
    t.add(27)
    t.add(24)
    t.add(35)
    t.add(10)
    t.add(45)
    t.remove(45)
    r = ""
    t.each { |x| r += "#{x}" }
    assert_equal("10202224252730354050", r)
    assert_equal(2, t.height)
    assert_equal(10, t.size)
    r = ""
    t.each_preorder { |x| r += "#{x}" }
    assert_equal("25221020243040273550", r)
    t.remove(50)
    r = ""
    t.each { |x| r += "#{x}" }
    assert_equal("102022242527303540", r)
    r = ""
    t.each_preorder { |x| r += "#{x}" }
    assert_equal("252210202430273540", r)
    assert_equal(2, t.height)
    assert_equal(9, t.size)
    t.remove(50)
    r = ""
    t.each { |x| r += "#{x}" }
    assert_equal("102022242527303540", r)
    r = ""
    t.each_preorder { |x| r += "#{x}" }
    assert_equal("252210202430273540", r)
    assert_equal(2, t.height)
    assert_equal(9, t.size)
    t.remove(40)
    r = ""
    t.each { |x| r += "#{x}" }
    assert_equal("1020222425273035", r)
    r = ""
    t.each_preorder { |x| r += "#{x}" }
    assert_equal("2522102024302735", r)
    assert_equal(2, t.height)
    assert_equal(8, t.size)
    t.remove(35)
    r = ""
    t.each { |x| r += "#{x}" }
    assert_equal("10202224252730", r)
    r = ""
    t.each_preorder { |x| r += "#{x}" }
    assert_equal("22251020242730", r)
    assert_equal(1, t.height)
    assert_equal(7, t.size)
    t.remove(24)
    r = ""
    t.each { |x| r += "#{x}" }
    assert_equal("102022252730", r)
    r = ""
    t.each_preorder { |x| r += "#{x}" }
    assert_equal("202510222730", r)
    assert_equal(1, t.height)
    assert_equal(6, t.size)
    t.remove(22)
    r = ""
    t.each { |x| r += "#{x}" }
    assert_equal("1020252730", r)
    r = ""
    t.each_preorder { |x| r += "#{x}" }
    assert_equal("2027102530", r)
    assert_equal(1, t.height)
    assert_equal(5, t.size)
    t.remove(25)
    r = ""
    t.each { |x| r += "#{x}" }
    assert_equal("10202730", r)
    r = ""
    t.each_preorder { |x| r += "#{x}" }
    assert_equal("20102730", r)
    assert_equal(1, t.height)
    assert_equal(4, t.size)
    t.remove(10)
    t.remove(10)
    r = ""
    t.each { |x| r += "#{x}" }
    assert_equal("202730", r)
    r = ""
    t.each_preorder { |x| r += "#{x}" }
    assert_equal("272030", r)
    assert_equal(1, t.height)
    assert_equal(3, t.size)
    t.remove(20)
    r = ""
    t.each { |x| r += "#{x}" }
    assert_equal("2730", r)
    r = ""
    t.each_preorder { |x| r += "#{x}" }
    assert_equal("2730", r)
    assert_equal(0, t.height)
    assert_equal(2, t.size)
    t.remove(27)
    r = ""
    t.each { |x| r += "#{x}" }
    assert_equal("30", r)
    r = ""
    t.each_preorder { |x| r += "#{x}" }
    assert_equal("30", r)
    assert_equal(0, t.height)
    assert_equal(1, t.size)
    t.remove(30)
    r = ""
    t.each { |x| r += "#{x}" }
    assert_equal("", r)
    r = ""
    t.each_preorder { |x| r += "#{x}" }
    assert_equal("", r)
    assert_equal(0, t.height)
    assert_equal(0, t.size)

    t.add(30)
    t.add(40)
    t.add(50)
    t.add(10)
    t.add(60)
    t.add(70)
    t.remove(70)
    t.remove(70)
    r = ""
    t.each { |x| r += "#{x}" }
    assert_equal("1030405060", r)
    r = ""
    t.each_preorder { |x| r += "#{x}" }
    assert_equal("3050104060", r)
    assert_equal(1, t.height)
    assert_equal(5, t.size)
    t.add(45)
    t.remove(60)
    t.remove(10)
    r = ""
    t.each { |x| r += "#{x}" }
    assert_equal("30404550", r)
    r = ""
    t.each_preorder { |x| r += "#{x}" }
    assert_equal("45304050", r)
    assert_equal(1, t.height)
    assert_equal(4, t.size)
    t.add(10)
    t.add(20)
    t.add(60)
    t.add(15)
    t.add(25)
    t.add(35)
    t.remove(30)
    r = ""
    t.each { |x| r += "#{x}" }
    assert_equal("101520253540455060", r)
    r = ""
    t.each_preorder { |x| r += "#{x}" }
    assert_equal("351510202545405060", r)
    assert_equal(2, t.height)
    assert_equal(9, t.size)
    t.add(5)
    t.add(8)
    t.add(12)
    t.add(18)
    t.add(70)
    t.remove(35)
    r = ""
    t.each { |x| r += "#{x}" }
    assert_equal("581012151820254045506070", r)
    r = ""
    t.each_preorder { |x| r += "#{x}" }
    assert_equal("154085101220182560455070", r)
    assert_equal(2, t.height)
    assert_equal(13, t.size)
    t.add(55)
    t.remove(12)
    r = ""
    t.each { |x| r += "#{x}" }
    assert_equal("581015182025404550556070", r)
    r = ""
    t.each_preorder { |x| r += "#{x}" }
    assert_equal("154085102018255060455570", r)
    assert_equal(2, t.height)
    assert_equal(13, t.size)
    t.remove(8)
    r = ""
    t.each { |x| r += "#{x}" }
    assert_equal("51015182025404550556070", r)
    r = ""
    t.each_preorder { |x| r += "#{x}" }
    assert_equal("20501551018402545605570", r)
    assert_equal(2, t.height)
    assert_equal(12, t.size)
  end

  def test_visitors
    t = TwoThreeTree.new
    t.add(30)
    t.add(40)
    t.add(25)
    t.add(25)
    t.add(50)
    t.add(20)
    t.add(22)
    t.add(27)
    t.add(24)
    t.add(35)
    t.add(10)
    r = ""
    t.each_preorder { |x| r += "#{x}" }
    assert_equal("25221020243040273550", r)
    r = ""
    t.each_inorder { |x| r += "#{x}" }
    assert_equal("10202224252730354050", r)
    r = ""
    t.each_postorder { |x| r += "#{x}" }
    assert_equal("10202422273550304025", r)
  end

  def test_inorder_iterator
    t = TwoThreeTree.new
    iter = t.iterator
    r = ""
    while !iter.empty?
      r += "#{iter.current}"
      iter.next
    end
    assert_equal("",r)

    t.add(30)
    iter = t.iterator
    r = ""
    while !iter.empty?
      r += "#{iter.current}"
      iter.next
    end
    assert_equal("30",r)

    t.add(40)
    t.add(25)
    t.add(25)
    t.add(50)
    t.add(20)
    t.add(22)
    t.add(27)
    t.add(24)
    t.add(35)
    t.add(10)
    iter = t.iterator
    r = ""
    while !iter.empty?
      r += "#{iter.current}"
      iter.next
    end
    assert_equal("10202224252730354050",r)
  end

end