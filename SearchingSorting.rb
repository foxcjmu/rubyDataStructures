# Ruby versions of standard algorithms for searching and sorting.
# Author: C. Fox
# Version: July 2017

require "test/unit"

module SearchingSorting
  
  ############### Searching Algorithms ##################
  
  # Return the maximum value in array
  # @pre: array.size > 0
  # @return: nil if precondition is violated
  def max(array)
    return nil if array.empty?
    result = array[0]
    array[1..-1].each { |v| result = v if result < v }
    result
  end
  
  # Return the min and max in array
  # @pre: !a.empty
  # @return: nil if precondition is violated
  def find_extremes(a)
    return nil if a.empty?
    return a, a if a.size == 1
    j, k = 0, a.size-1;
    while j < k
      a[j], a[k] = a[k], a[j] if a[k] < a[j]
      j += 1
      k -= 1
    end
    if j == k
      j += 1
      a[j], a[k] = a[k], a[j] if a[j] < a[k]
    end
    m1, m2 = a[0], a[j]
    a[1..k].each {|x| m1 = x if x < m1 }
    a[(j+1)..-1].each { |x| m2 = x if m2 < x }
    return m1, m2
  end

  # Return true if key is in array
  # Standard sequential search
  def find(key, array)
    array.each do | element |
      return true if key == element
    end
    false
  end

  # Recursive binary search to find the index of an element, or nil if not present
  # @pre: array is sorted
  def recursive_binary_search(array, key)
    return nil if array.empty?
    m = array.size/2
    return m if key == array[m]
    return recursive_binary_search(array[0...m],key) if key < array[m]
    index = recursive_binary_search(array[m+1..-1],key)
    index ? m+1+index : nil
  end
  
  # Non-recursive binary search to find the index of an element, or nil if not present
  # @pre: array is sorted
  def binary_search(array, key)
    lb, ub = 0, array.size-1
    while (lb <= ub)
      m = (ub+lb)/2
      return m if key == array[m]
      if key < array[m]
        ub = m-1
      else
        lb = m+1
      end
    end
    return nil
  end
    
  def max_char_sequence(string)
    return 0 if string.empty?
    max_len = 0
    this_len = 1
    last_char = nil
    string.each_char do | this_char |
      if this_char == last_char
        this_len += 1
      else
        max_len = this_len if max_len < this_len
        this_len = 1
      end
      last_char = this_char
    end
    return (max_len < this_len) ? this_len : max_len
  end
  
  ################### Sorting Algorithms ####################
  
  # Return true iff the array is sorted in increaasing order
  def is_sorted?(array)
    (1...array.size).each do | index |
      return false if array[index] < array[index-1]
    end
    true
  end
  
  # Standard bubble sort algorithm
  def bubble_sort(array)
    (1...array.size).reverse_each do | j |
      1.upto(j).each do | i |
        if array[i] < array[i-1]
          array[i], array[i-1] = array[i-1], array[i]
        end
      end
    end
    array
  end
  
  # Selection sort that repeatedly finds the mimimum
  def selection_sort(array)
    0.upto(array.size-2).each do | j |
      min_index = j
      (j+1).upto(array.size-1).each do | i |
        min_index = i if array[i] < array[min_index]
      end
      array[j], array[min_index] = array[min_index], array[j]
    end
    array
  end
  
  # Selection sort that repeatedly finds the maximum
  def selection_sort2(array)
    (array.size-1).downto(1).each do | j |
      max_index = j
      (0...j).each do | i |
        max_index = i if array[max_index] < array[i]
      end
      array[j], array[max_index] = array[max_index], array[j]
    end
    array
  end
  
  # Standard linear insertion sort iwth no sentinel
  def insertion_sort(array)
    (1...array.size).each do | j |
      element = array[j]
      i = j
      while 0 < i && element < array[i-1]
        array[i] = array[i-1]
        i -= 1
      end
      array[i] = element
    end
    array
  end

  # Standard linear insertion sort with a sentinel
  def sentinel_insertion_sort(array)
    # first put the minimum value in location 0
    min_index = 0;
    (1...array.size).each do | index |
      min_index = index if array[index] < array[min_index]
    end
    array[0], array[min_index] = array[min_index], array[0]
  
    # now insert elements into the sorted portion
    (2...array.size).each do | j |
      element = array[j]
      i = j
      while (element <=> array[i-1]) == -1
        array[i] = array[i-1]
        i -= 1
      end
      array[i] = element
    end
    array
  end
   
  # Standard linear shell sort with powers of three for the increment
  def shell_sort(array)
    # compute the starting value of h
    h = 1;
    h = 3*h + 1 while h < array.size/9
 
    # insertion sort using decreasing values of h
    while 0 < h do
      (h...array.size).each do | j |
        element = array[j]
        i = j
        while 0 < i && element < array[i-h]
          array[i] = array[i-h]
          i -= h
        end
        array[i] = element
      end
      h /= 3
    end
    array
  end
  
  # Standard merge sort recursive helper function
  # Sort src array in two halves between lo and hi-1, and
  # then merge the halves into dst between lo and hi-1
  def merge_into(src, dst, lo, hi)
    return if hi-lo < 2
    m = (lo+hi)/2
    merge_into(dst, src, lo, m)
    merge_into(dst, src, m, hi)
    j = lo; k = m
    (lo...hi).each do | i |
      if j < m and k < hi
        if src[j] < src[k]
          dst[i] = src[j]; j += 1
        else
          dst[i] = src[k]; k += 1
        end
      elsif j < m
        dst[i] = src[j]; j += 1
      else # k < hi
        dst[i] = src[k]; k += 1
      end
    end
  end
  private :merge_into
  
  # Standard merge sort with an auxiliary array of size n
  def merge_sort(array)
    merge_into(array.dup, array, 0, array.size)
    array
  end

  # Standard quicksort helper function using the last value as the pivot
  def quick(array, lb, ub)
    return if ub <= lb
    pivot = array[ub]
    i, j = lb-1, ub
    loop do
      loop do i += 1; break if pivot <= array[i]; end
      loop do j -= 1; break if j <= lb || array[j] <= pivot; end
      array[i], array[j] = array[j], array[i]
      break if j <= i
    end
    array[j], array[i], array[ub] = array[i], pivot, array[j]
    quick(array,lb,i-1)
    quick(array,i+1,ub)
  end
  private :quick

  # Standard quicksort with no improvements
  def quicksort(array)
    quick(array, 0, array.size-1)
    array
  end
  
  # Quicksort helper function with the median-of-three improvement
  def quick_m3(array, lb, ub)
    return if ub <= lb
    
    # find sentinels and the median for the pivot
    m = (lb+ub)/2
    array[lb], array[m] = array[m], array[lb] if array[m] < array[lb]
    array[m], array[ub] = array[ub], array[m] if array[ub] < array[m]
    array[lb], array[m] = array[m], array[lb] if array[m] < array[lb]

    # if the sub-array is size 3 or less, it is now sorted
    return if ub-lb < 3

    # put the median just shy of the end of the list
    array[ub-1], array[m] = array[m], array[ub-1]

    pivot = array[ub-1]
    i, j = lb, ub-1
    loop do
      loop do i += 1; break if pivot <= array[i]; end
      loop do j -= 1; break if array[j] <= pivot; end
      array[i], array[j] = array[j], array[i]
      break if j <= i
    end
    array[j], array[i], array[ub-1] = array[i], pivot, array[j]
    quick_m3(array,lb,i-1)
    quick_m3(array,i+1,ub)
  end
  private :quick_m3
  
  # Quicksort with the median of three improvement
  def quicksort_m3(array)
    quick_m3(array, 0, array.size-1)
    array
  end
 
  # Quicksort helper function with the median-of-three improvement
  # and using insertion sort for small sublists at the end.
  def quick_m3isort(array, lb, ub)
    return if ub-lb <= 12
    
    # find sentinels and the median for the pivot
    m = (lb+ub)/2
    array[lb], array[m] = array[m], array[lb] if array[m] < array[lb]
    array[m], array[ub] = array[ub], array[m] if array[ub] < array[m]
    array[lb], array[m] = array[m], array[lb] if array[m] < array[lb]
  
    # put the median just shy of the end of the list
    array[ub-1], array[m] = array[m], array[ub-1]
  
    pivot = array[ub-1]
    i, j = lb, ub-1
    loop do
      loop do i += 1; break if pivot <= array[i]; end
      loop do j -= 1; break if array[j] <= pivot; end
      array[i], array[j] = array[j], array[i]
      break if j <= i
    end
    array[j], array[i], array[ub-1] = array[i], pivot, array[j]
    quick_m3isort(array,lb,i-1)
    quick_m3isort(array,i+1,ub)
  end
  private :quick_m3isort

  # Quicksort with the median-of-three improvement and insertion sorting
  # small sublists.
  def quicksort_m3isort(array)
    quick_m3isort(array, 0, array.size-1)
    insertion_sort(array)
    array
  end

  # Standard heapsort helper function
  # make array with max_index into a heap starting at i
  def sift_down(array, i, max_index)
    tmp = array[i]
    j = 2*i + 1
    while j <= max_index
      j += 1 if j < max_index && array[j] < array[j+1]
      break if array[j] <= tmp
      array[i] = array[j]
      i, j = j, 2*j + 1
    end
    array[i] = tmp
  end
  private :sift_down

  # Standard heapsort
  def heap_sort(array)
    # make the entire array into a heap
    max_index = array.size-1
    ((max_index-1)/2).downto(0).each do | i | 
      sift_down(array,i,max_index)
    end

    # repeatedly remove the root and remake the heap
    loop do
      array[0], array[max_index] = array[max_index], array[0]
      max_index -= 1
      break if max_index <= 0
      sift_down(array, 0, max_index)
    end
    array
  end

  ############## Rubyesque Algorithms ###############

  def r_quicksort(array)
    return array if array.size < 2
    pivot = array.pop
    left, right = array.partition { | element | element < pivot }
    return r_quicksort(left) + [pivot] + r_quicksort(right)
  end
 
  def built_in_sort(array)
    return array.sort!
  end

  def time_sort(name, array, sort_func)
    a = array.dup
    t1 = Time.now
    sort_func.call(a)
    puts "   Elapsed time for #{name}: #{Time.now-t1}"
  end

  def time_algorithms
    array_size = 2500
    while array_size < 500000
      a = (1..array_size).to_a
      puts "Sorting a sorted array of size #{array_size}"
      if (array_size < 6000)
        time_sort("Bubble sort\t\t\t", a, method(:bubble_sort))
        time_sort("Selection sort\t\t", a, method(:selection_sort))
        time_sort("Quicksort\t\t\t", a, method(:quicksort))
      end
      time_sort("Insertion sort\t\t", a, method(:insertion_sort))
      time_sort("Shell sort\t\t\t", a, method(:shell_sort))
      time_sort("Merge sort\t\t\t", a, method(:merge_sort))
      time_sort("Quicksort with median of 3\t", a, method(:quicksort_m3))
      time_sort("Heap sort\t\t\t", a, method(:heap_sort))
        
      a.shuffle!
      puts "Sorting an unsorted array of size #{array_size}"
      if (array_size < 6000)
        time_sort("Bubble sort\t\t\t", a, method(:bubble_sort))
        time_sort("Selection sort\t\t", a, method(:selection_sort))
        time_sort("Insertion sort\t\t", a, method(:insertion_sort))
      end
      time_sort("Quicksort\t\t\t", a, method(:quicksort))
      time_sort("Shell sort\t\t\t", a, method(:shell_sort))
      time_sort("Merge sort\t\t\t", a, method(:merge_sort))
      time_sort("Quicksort with median of 3\t", a, method(:quicksort_m3))
      time_sort("Heap sort\t\t\t", a, method(:heap_sort))
        
      array_size *= 2
    end
  end
end

####################  Unit Tests #####################
#=begin
class TestSearching < Test::Unit::TestCase
  include SearchingSorting
 
  def test_max
    a = (0..1000).to_a
    a.shuffle!
    assert_equal(1000, max(a))
  end
 
  def tet_extremes
    assert_equal(find_extremes([]),nil)
    assert_equal(find_extremes([2],[2,2]))
    assert_equal(find_extremes([9,6,5,3,2,1,2,7],[1,9]))
  end 
  
  def test_find
    a = (0..1000).to_a
    a.shuffle!
    assert(find(500,a))
    refute(find(-1,a))
  end
   
  def test_binary_search
    a = (0..1000).to_a
    assert_equal(nil, recursive_binary_search(a,1001))
    assert_equal(0, recursive_binary_search(a,0))
    assert_equal(1000, recursive_binary_search(a,1000))
    assert_equal(487, recursive_binary_search(a,487))  
    assert_equal(nil, binary_search(a,1001))
    assert_equal(0, binary_search(a,0))
    assert_equal(1000, binary_search(a,1000))
    assert_equal(487, binary_search(a,487))  
    
  end
  
  def test_max_char_sequence
    assert_equal(0, max_char_sequence(""))
    assert_equal(1, max_char_sequence("a"))
    assert_equal(1, max_char_sequence("abc"))
    assert_equal(3, max_char_sequence("abbbc"))
    assert_equal(5, max_char_sequence("aaaaabbbcccc"))
    assert_equal(5, max_char_sequence("abbccccc"))
  end
  
  def test_sorts
    a = (0..1543).to_a + (0..300).to_a
    a.shuffle!
    c = a.sort
    refute(is_sorted?(a))
    assert_equal(c,bubble_sort(a.dup))
    assert_equal(c,selection_sort(a.dup))
    assert_equal(c,selection_sort2(a.dup))
    assert_equal(c,insertion_sort(a.dup))
    assert_equal(c,sentinel_insertion_sort(a.dup))
    assert_equal(c,shell_sort(a.dup))
    assert_equal(c,merge_sort(a.dup))
    assert_equal(c,quicksort(a.dup))
    assert_equal(c,quicksort_m3(a.dup))
    assert_equal(c,quicksort_m3isort(a.dup))
    assert_equal(c,heap_sort(a.dup))
      
    assert_equal(c,r_quicksort(a.dup))
  end

  def time_sort(name, array, sort_func)
    a = array.dup
    refute(is_sorted?(a))
    t1 = Time.now
    sort_func.call(a)
    puts "Elapsed time for #{name}: #{Time.now-t1}"
  end
  
  def test_timing
    a = (0..200517).to_a
    a.shuffle!
    refute(is_sorted?(a))
=begin
    puts
#    time_sort("Bubble sort\t\t\t", a, method(:bubble_sort))
#    time_sort("Selection sort\t\t\t", a, method(:selection_sort))
#    time_sort("Insertion sort\t\t\t", a, method(:insertion_sort))
#    time_sort("Sentinel insertion sort\t", a, method(:sentinel_insertion_sort))
#    time_sort("Shell sort\t\t\t", a, method(:shell_sort))
    time_sort("Built-in sort\t\t\t", a, method(:built_in_sort))
    time_sort("Rubyesque quicksort\t\t", a, method(:r_quicksort))
    time_sort("Merge sort\t\t\t", a, method(:merge_sort))
    time_sort("Quicksort with median of 3++\t", a, method(:quicksort_m3isort))
    time_sort("Quicksort with median of 3\t", a, method(:quicksort_m3))
    time_sort("Quicksort\t\t\t", a, method(:quicksort))
    time_sort("Heap sort\t\t\t", a, method(:heap_sort))
=end
  end
end
#=end