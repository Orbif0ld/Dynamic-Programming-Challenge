=begin

Dynamic programming approach to finding the largest block of 1s inside a binary matrix.
In this code the matrix remains unchanged. Instead I use indices to indicate
ranges of rows and columns.

* Subproblem: for some range of columns and some range of rows of the original matrix,
    find the largest block of of 1s.
* Topological order: from smallest to largest range
* Number of subproblems: if there are m rows and n columns, there are m choose 2 ranges
    of rows and n choose 2 ranges of columns. Therefore there are O(N^2) subproblems, where
    N = m*n is the size of the matrix.
* Time per subproblem (not counting recursion): to check whether a matrix has a zero takes
    O(N) time
* Total runtime: the total runtime with memoize=true is O(N^3). If memoize=false, the recursion
    can no longer be left out of the calculation and the runtime becomes exponential.
* Memory usage: there are O(N^2) subproblems which will be stored, if memoize=true

Matrices are represented by arrays of rows. Rows are arrays too.

example:

matrix = [[1,1,0,1], [1,1,0,1], [0,1,0,1]] represents

1101
1101
0101

=end

require 'colorize' # used for green numbers in print_block
require 'benchmark' # to time the memoized and non-memoized versions, see end of file

def has_zero? i,j,k,l, matrix
    # checks if the intersection of rows i through j and columns
    # k through l contain a zero
    for x in i..j do
        for y  in k..l do
            return true if matrix[x][y]==0
        end
    end
    false
end

def largest_block i, j, k, l, matrix, lookup=nil
    # finds largest rectangular block of ones in
    # the intersection of rows i through j and columns k through l
    # lookup is a hash for storing computed subproblems
    # returns an array of size 5; first element is the size of the block, the next two elements
    # i, j indicate the included rows i..j and the last two elements k, l indicate the
    # included columns k..l that constitute the block
    
    key = "#{i},#{j},#{k},#{l}"
    
    return lookup[key] if (lookup!=nil and lookup.has_key?(key)) # have I already computed this subproblem?
    
    if !has_zero?(i,j,k,l, matrix) then
        res = [(j-i+1)*(l-k+1), i , j, k, l]
        lookup[key] = res
        return res # no more zeros in this matrix. lets see if its the biggest!
    end
    
    results = [ # try removing the left or rightmost column or the top or bottom row
        largest_block(i+1,j,k,l,matrix,lookup),
        largest_block(i,j-1,k,l,matrix,lookup),
        largest_block(i,j,k+1,l,matrix,lookup),
        largest_block(i,j,k,l-1,matrix,lookup)]
        
    best = results.max {|a,b| a <=> b} # and check which of these resulted in the largest submatrix
    
    lookup[key] = best if lookup!=nil # store the result, so as not to have to compute it again
    
    return best
    
end

def find_largest_block matrix, memoize=true
    # finds the largest block filled with all ones
    # set memoize to true for speed
    # set memoize to false to save space
    # returns an array of size 5; first element is the size of the block, the next two elements
    # i, j indicate the included rows i..j and the last two elements k, l indicate the
    # included columns k..l that constitute the block
    num_rows = matrix.length
    num_cols = matrix.empty? ? 0 : matrix[0].length
    lookup = Hash.new if memoize
    
    largest_block(0, num_rows-1, 0, num_cols-1, matrix, lookup)
end

### utility methods ###

def print_matrix matrix
    matrix.each {|row| row.each {|val| print val}; puts}
end

def print_block i,j,k,l, matrix
    # prints the matrix. numbers in the intersection of rows i through j
    # and columns k through l appear in green.
    num_rows = matrix.length
    num_cols = matrix.empty? ? 0 : matrix[0].length
    for x in 0...num_rows do
        for y in 0...num_cols do
            if (i..j).include? x and (k..l).include? y then
                print matrix[x][y].to_s.green
            else
                print matrix[x][y].to_s
            end
        end
        puts
    end
end

def random_binary_matrix num_rows, num_cols, p_zero
    # creates a random binary matrix
    matrix = []
    rnd = Random.new
    (0...num_rows).each do
        row = []
        (0...num_cols).each do
            row.push(rnd.rand(1.0) < p_zero ? 0 : 1)
        end
        matrix.push(row)
    end
    return matrix
end

### demonstration ###

matrix = random_binary_matrix 5, 8, 0.1 # number_of_rows, number_of_columns, probability_to_set_an_entry_to_zero

print_matrix matrix
puts

result = find_largest_block(matrix, memoize=true)
print_block result[1], result[2], result[3], result[4], matrix
puts
puts "the largest block has #{result[0]} 1s"
puts

Benchmark.bm(15) do |x|
    x.report("memoize=true") {find_largest_block(matrix, memoize=true)} # fast but needs memory O(N^2) memory
    x.report("memoize=false") {find_largest_block(matrix, memoize=false)} # slow, but needs less memory
end
