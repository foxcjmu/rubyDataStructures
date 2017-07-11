#
# This is the interface class for directed graphs. This superclass requires that its descents use
# attributes @edges and @vertices to keep track of the number of edges and vertices in the graph.
#
# This class is opened and augmented with graph algorithms for depth-first and breadth-first search and
# others that rely only on the Graph interface operations and hence can be placed here and inherited by
# descendents.
#
# Author: C. Fox
# Version: June 2017

$LOAD_PATH.unshift "../Containers" unless $LOAD_PATH.include?("../Containers")
$LOAD_PATH.unshift "." unless $LOAD_PATH.include?(".")

require "LinkedStack"
require "LinkedQueue"

class Digraph
  
  # Make the edge and vertex counts accessible
  attr_reader :edges, :vertices
  
  # Put an edge {v,w} into the graph
  def add_edge(v,w)
    raise NotImplementedError
  end
  
  # Return true iff there is an edge {v,w} in the graph
  def edge?(v,w)
    raise NotImplementedError
  end
  
  # Iterate over the edges adjacent to v
  def each_edge(v)
    raise NotImplementedError
  end
  
end

############################  Graph Algorithms ##############################
# Reopen the class and add several graph algorithm that are then inherited by
# descendents (ArrayGraph and LinkedGraph).

class Digraph
  
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
  
  # Iterate over the edges in a graph g reachable from v breadth-first using a queue
  Edge = Struct.new(:v, :w)
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
    return false if v1 < 0 or @vertices <= v1
    return false if v2 < 0 or @vertices <= v2
    dfs(v1) do |v,w|
      return true if w == v2
    end
    false
  end
  
  # Return an array listing a topological sort of g, nil
  # if the g is not a DAG; uses the set reduction algorithm
  def topo
    # count the predecessors of each vertex
    num_predecessors = Array.new(@vertices,0)
    0.upto(@vertices-1) do |v|
      each_edge(v) { |v,w| num_predecessors[w] += 1 }
    end

    # the vertices with no predecessors can go in the result
    result = []
    num_predecessors.each_with_index do |count,v|
      result << v if count == 0
    end

    # remove result list vertices from the graph (virtually)
    i = 0
    while i < result.size
      each_edge(result[i]) do |v,w|
        num_predecessors[w] -= 1 if 0 < num_predecessors[w]
        result << w if num_predecessors[w] == 0
      end
      i += 1
    end

    # return the result or nil if there are cycles
    return nil if result.size != @vertices
    result
  end

  # Return an array listing a topological sort of g, or nil if
  # g is not a DAG; uses DFS
  def sort
    visiting  = 1
    visited   = 2
    mark = []
    result = []
    is_cycle = false
    visit = lambda do |v|
      return is_cycle = true if mark[v] == visiting
      mark[v] = visiting
      each_edge(v) { |v,w| visit.call(w) unless mark[w] == visited }
      result.unshift(v)
      mark[v] = visited
    end

    0.upto(@vertices-1) do |v|
      next if mark[v] == visited
      visit.call(v)
      return nil if is_cycle
    end
    return result
  end
end
