#
# Linked implementation of a digraph. This class uses the adjacency lists representation
# of directed graphs to realize a digraph with n vertices.
#
# Author: C. Fox
# Version: June 2017

$LOAD_PATH.unshift "../Containers" unless $LOAD_PATH.include?("../Containers")
$LOAD_PATH.unshift "." unless $LOAD_PATH.include?(".")

require "Digraph"
require "LinkedList"
require "test/unit"

class LinkedDigraph < Digraph
  
  # Set up the adjacency lists data structure
  def initialize(n)
    @vertices = n
    @edges = 0
    @adjacent = []
    0.upto(n-1) { |i| @adjacent[i] = LinkedList.new }
  end
  
  # Put an edge {v,w} into the graph
  def add_edge(v,w)
    raise ArgumentError, "No such vertex" if v < 0 or @vertices <= v
    raise ArgumentError, "No such vertex" if w < 0 or @vertices <= w
    @adjacent[v].insert(0,w)
    @edges += 1
  end
  
  # Return true iff there is an edge {v,w} in the graph
  def edge?(v,w)
    return false if v < 0 or @vertices <= v
    return false if w < 0 or @vertices <= w
    return @adjacent[v].contains?(w)
  end
  
  # Iterate over the edges adjacent to v
  def each_edge(v)
    raise ArgumentError, "No such vertex" if v < 0 or @vertices <= v
    @adjacent[v].each { |w| yield v,w }
  end
  
  # Represent the graph as a string
  def to_s
    result = ""
    @adjacent.each_with_index do |list,v|
      result += v.to_s + ":"
      list.each do |w|
        result += " "+w.to_s
      end
      result += "\n"
    end
    result
  end
  
end

####################  Unit Tests #####################
#=begin
class TestLinkedDigraph < Test::Unit::TestCase

  def test_graph_ops
    # test basic ops
    g = LinkedDigraph.new(20)
    assert_equal(20, g.vertices)
    assert_equal(0, g.edges)
    a = [0, 4, 7, 11, 15, 19]
    a.each { |w| g.add_edge(2,w) }
    assert_equal(a.size,g.edges)
    a.each { |w| assert(g.edge?(2,w)) }
    a.each { |w| refute(g.edge?(w,2)) }
    assert(!g.edge?(2,5))
    assert(!g.edge?(5,2))
    assert(!g.edge?(2,2))
    assert(!g.edge?(2,50))
    assert(!g.edge?(2,-3))

    # test edge iteration
    i = a.size-1
    g.each_edge(2) do |v,w|
      assert_equal(w,a[i])
      i -= 1
    end
    assert_equal(i,-1)
  end

  def test_algorithms
    g = LinkedDigraph.new(10)
    g.add_edge(0,1)
    g.add_edge(0,3)
    g.add_edge(0,2)
    g.add_edge(2,3)
    g.add_edge(2,4)
    g.add_edge(4,3)
    g.add_edge(3,5)
    g.add_edge(4,5)
    g.add_edge(6,7)
    g.add_edge(8,7)
    g.add_edge(8,9)
    g.add_edge(7,9)
    assert(!g.path?(3,6))
    assert(!g.path?(5,0))
    assert(g.path?(0,5))
    assert(g.path?(6,9))
    assert_equal([8,6,7,9,0,1,2,4,3,5], g.sort)
    assert_equal([0,6,8,2,1,7,4,9,3,5], g.topo)
    g.add_edge(5,8)
    assert_equal([6,0,1,2,4,3,5,8,7,9], g.sort)
    assert_equal([0,6,2,1,4,3,5,8,7,9], g.topo)
    g.add_edge(7,3)
    assert_equal(nil, g.topo)
    assert_equal(nil, g.sort)
  end
end
