#
# This class implements common operations for (undirected) graphs. IT requires that its descendants use
# attributes @edges and @vertices to keep track of the number of edges and vertices in the graph.
# It also includes augmented with graph algorithms for depth-first and breadth-first search and
# others that rely only on Graph interface operations and hence can be placed here and inherited by
# descendants.
#
# Author: C. Fox
# Version: June 2017

$LOAD_PATH.unshift "../Containers" unless $LOAD_PATH.include?("../Containers")
$LOAD_PATH.unshift "." unless $LOAD_PATH.include?(".")

require "LinkedStack"
require "LinkedQueue"

class Graph
  
  # Make the edge and vertex counts acccessible
  attr_reader :edges, :vertices
  
  # Iterate over the edges in a graph g reachable from v depth-first recursively
  def dfs(v)
    raise ArgumentError, "No such vertex" if v < 0 or vertices <= v
    is_visited = []
    visit = lambda do |v|
      each_edge(v) do |v,w|
        next if is_visited[w]
        yield v,w
        is_visited[w] = true
        visit.call(w)
      end
    end
    yield -1,v
    is_visited[v] = true
    visit.call(v)
  end
  
  # Iterate over the edges in a graph g reachable from v depth-first using a stack
  Edge = Struct.new(:v, :w)
  def stack_dfs(v)
    raise ArgumentError, "No such vertex" if v < 0 or vertices <= v
    stack = LinkedStack.new
    is_visited = []
    stack.push(Edge.new(-1,v))
    while !stack.empty? do
      edge = stack.pop
      next if is_visited[edge.w]
      yield edge.v,edge.w
      is_visited[edge.w] = true
      each_edge(edge.w) do |w,x|
        stack.push(Edge.new(w,x)) if !is_visited[x]
      end
    end
  end
  
  # Iterate over the edges in a graph g reachable from v breadth-first using a queue
  def bfs(v)
    raise ArgumentError, "No such vertex" if v < 0 or vertices <= v
    queue = LinkedQueue.new
    is_visited = []
    queue.enter(Edge.new(-1,v))
    while !queue.empty? do
      edge = queue.leave
      next if is_visited[edge.w]
      yield edge.v,edge.w
      is_visited[edge.w] = true
      each_edge(edge.w) do |w,x|
        queue.enter(Edge.new(w,x)) if !is_visited[x]
      end
    end
  end
  
  # Return true iff there is path between the v1 and v2 vertices in graph g
  def path?(v1,v2)
    return false if v1 < 0 or vertices <= v1
    return false if v2 < 0 or vertices <= v2
    dfs(v1) do |v,w|
      return true if w == v2
    end
    false
  end
  
  # Find the shortest path in graph g between v and w
  def shortest_path(v,w)
    raise ArgumentError unless path?(v,w) 
    to_edge = []
    bfs(w) { |v1,v2| to_edge[v2] = v1 }
    result = []
    x = v
    while x != w
      result << x
      x = to_edge[x]
    end
    result << x
  end
  
  # Return true iff graph g is connected
  def connected?
    is_visited = []
    dfs(0) { |v,w| is_visited[w] = true }
    0.upto(vertices-1) { |i| return false unless is_visited[i] }
    true
  end
  
  # Return a graph that is a spanning tree of connected graph g
  def spanning_tree
    raise ArgumentError unless connected?
    result = (self.class.to_s == "ArrayGraph") ?
      ArrayGraph.new(vertices) :
      LinkedGraph.new(vertices)
    dfs(0) { |v,w| result.add_edge(v,w) if 0 <= v }
    result
  end
  
end
