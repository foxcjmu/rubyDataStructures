#
# Contiguous implementation of a graph. This class uses the adjacency matrix representation
# of undirected graphs to realize a graph with n vertices.
#
# Author: C. Fox
# Version: June 2017

$LOAD_PATH.unshift("../Containers") unless $LOAD_PATH.include?("../Containers")
$LOAD_PATH.unshift(".") unless $LOAD_PATH.include?(".")

require "Graph"
require "LinkedStack"
require "LinkedQueue"
require "test/unit"

class ArrayGraph < Graph
  
  # Set up the adjacency matrix data structure
  def initialize(n)
    @vertices = n
    @edges = 0
    @adjacent = []
    0.upto(n-1) { |i| @adjacent[i] = [] }
  end
  
  # Put an edge {v,w} into the graph
  def add_edge(v,w)
    raise ArgumentError, "No such vertex" if v < 0 or @vertices <= v
    raise ArgumentError, "No such vertex" if w < 0 or @vertices <= w
    raise ArgumentError, "No such edge" if v == w
    @adjacent[v][w] = true
    @adjacent[w][v] = true
    @edges += 1
  end
  
  # Return true iff there is an edge {v,w} in the graph
  def edge?(v,w)
    return false if v < 0 or @vertices <= v
    return false if w < 0 or @vertices <= w
    return false if v == w
    return @adjacent[v][w]
  end
  
  # Iterate over the edges adjacent to v
  def each_edge(v)
    raise ArgumentError, "No such vertex" if v < 0 or @vertices <= v
    @adjacent[v].each_with_index { |is_edge,w| yield v,w if is_edge }
  end
  
  # Represent the graph as a string
  def to_s
    result = ""
    @adjacent.each_with_index do |a,v|
      result += v.to_s + ":"
      a.each_with_index do |is_edge,w|
        result += " "+w.to_s if is_edge
      end
      result += "\n"
    end
    result
  end
  
end

####################  Unit Tests #####################
#=begin
class TestArrayGraph < Test::Unit::TestCase

  def test_graph_ops
    # test basic ops
    g = ArrayGraph.new(20)
    assert_equal(20, g.vertices)
    assert_equal(0, g.edges)
    a = [0, 4, 7, 11, 15, 19]
    a.each { |w| g.add_edge(2,w) }
    assert_equal(a.size,g.edges)
    a.each { |w| assert(g.edge?(2,w)) }
    a.each { |w| assert(g.edge?(w,2)) }
    assert(!g.edge?(2,5))
    assert(!g.edge?(5,2))
    assert(!g.edge?(2,2))
    assert(!g.edge?(2,50))
    assert(!g.edge?(2,-3))
  
    # test edge iteration
    i = 0
    g.each_edge(2) do |v,w|
      assert_equal(v,2)
      assert_equal(w,a[i])
      i += 1
    end
    assert_equal(i,a.size)
  end
  
  def test_algorithms
    g = ArrayGraph.new(10)
    g.add_edge(0,1)
    g.add_edge(0,3)
    g.add_edge(2,3)
    g.add_edge(4,3)
    g.add_edge(3,5)
    g.add_edge(4,5)
    g.add_edge(6,7)
    g.add_edge(8,7)
    g.add_edge(8,9)
    assert(!g.path?(3,6))
    assert(!g.path?(6,3))
    assert(g.path?(5,1))
    assert(g.path?(1,5))
    assert(!g.connected?)
    g.add_edge(2,8)
    g.add_edge(3,6)
    assert(g.connected?)
  
    path = g.shortest_path(0,9)
    assert_equal([0,3,2,8,9],path)
    path = g.shortest_path(5,7)
    assert_equal([5,3,6,7],path)
    h = g.spanning_tree
    assert(h.connected?)
  end

end
#=end
