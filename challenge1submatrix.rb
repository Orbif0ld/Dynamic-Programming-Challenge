=begin

Recursive algorithm to find the largest submatrix containing only ones. The
initial matrix only contains 1s and 0s.

Although this solution uses memoization, it's time complexity is still exponential,
because the subproblems are all of the possible submatrices. Nevertheless memoization
speeds up the process. However, memoization requires
an exponential amount of space.

The initial matrix is represented by an array of rows. Rows are arrays too.

Example:

matrix = [[1,1,0,1], [1,1,0,1], [0,1,0,1]] represents

1101
1101
0101

My code leaves the initial matrix unchaged and creates no other matrices. Instead
represents submatrices as sets rows and cols. If the matrix has 3 rows and 4
columns, rows = (0...3).to_set and cols = (0...4).to_set.

I take care never to mutate rows and cols. (Accidental
mutation would be very bad here.)

=end

require 'set' # used for rows and cols
require 'colorize' # used for colored printing
require 'benchmark' # used for demo, see end of file

def make_key rows, cols
    # rows, cols are sets
    # generates an immutable value from rows and cols
    # for use as a key in a hash
    (rows.to_a.sort.to_s + cols.to_a.sort.to_s).to_sym
end

def zero_pos rows, cols, matrix
    # returns the position of a zero in the submatrix
    # of matrix, defined by rows and cols
    # returns nil, if there is no zero
    num_rows = matrix.length
    num_cols = matrix.empty? ? 0 : matrix[0].length
    for x in (0...num_rows).select {|a| rows.include? a}
        for y in (0...num_cols).select {|a| cols.include? a}
            return [x,y] if matrix[x][y]==0
        end
    end
    return nil
end

def has_zero? rows, cols, matrix
    # true if there is a zero in the submatrix
    # of matrix, that is defined by rows and cols
    (zero_pos rows, cols, matrix)==nil ? false : true
end

def make_smaller row, row_num ### also works for columns
    # create a new set which is equal to the
    # set resulting from removing row_number from the set row
    # leaves the set row unchanged
    row.clone.delete row_num
end

def remove_zeros rows, cols, matrix, lookup=nil
    # recursively removes zeros from
    # the submatrix of matrix, defined by rows and cols
    # returns [rows, cols] where rows and cols define the largest submatrix
    # of the original submatrix, that contains only ones
    # lookup is a hash. if supplied, used for storing computed subproblems
    
    num_rows = matrix.length
    num_cols = matrix.empty? ? 0 : matrix[0].length
    
    return nil if num_rows==0 or num_cols==0
    
    key = make_key rows, cols
    
    return lookup[key] if (lookup!=nil and lookup.has_key? key)
    
    return [rows, cols] if !has_zero? rows, cols, matrix
    
    first_zero = zero_pos rows, cols, matrix
    first_zero_row = first_zero[0]
    first_zero_col = first_zero[1]
    results = [
        remove_zeros(make_smaller(rows, first_zero_row), cols, matrix, lookup),
        remove_zeros(rows, make_smaller(cols, first_zero_col), matrix, lookup)]
        
    best = results.max {|a, b| a[0].length*a[1].length <=> b[0].length*b[1].length}
    
    lookup[key] = best if lookup!=nil
    
    return best
end

def find_largest_submatrix_containing_only_ones matrix, memoize=true
    # recursively removes zeros from matrix
    # returns [rows, cols] where rows and cols define the largest submatrix
    # of matrix, that contains only ones
    # if memoize=true computed subproblems are stored for reuse
    # memoization makes this code faster, but requires more space
    lookup = Hash.new if memoize
    num_rows = matrix.length
    num_cols = matrix.empty? ? 0 : matrix[0].length
    rows = (0...num_rows).to_set
    cols = (0...num_cols).to_set
    remove_zeros rows, cols, matrix, lookup
end

### utility methods ###

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

def print_matrix matrix
    matrix.each {|row| row.each {|val| print val}; puts}
end

def print_submatrix rows, cols, matrix
    # prints matrix
    # values that are in submatrix are printed in green
    # all other values are printed in red
    num_rows = matrix.length
    num_cols = matrix.empty? ? 0 : matrix[0].length
    for x in 0...num_rows
        for y in 0...num_cols
            if rows.include? x and cols.include? y
                print matrix[x][y].to_s.green
            else
                print matrix[x][y].to_s.red
            end
        end
        puts
    end
end

### demonstration ###

#matrix = [[1,1,0,1], [1,1,0,1], [0,1,0,1]]
#matrix = [[1, 1, 0, 1], [1, 1, 1, 1], [1, 0, 1, 0], [1, 1, 0, 1]]

matrix = random_binary_matrix 10, 10, 0.5

print_matrix matrix
puts

result = find_largest_submatrix_containing_only_ones matrix, memoize=true
size = result[0].length * result[1].length
print_submatrix result[0], result[1], matrix
puts
puts "largest submatrix size: #{size}"
puts

Benchmark.bm(15) do |x|
    x.report("memoize=true") {find_largest_submatrix_containing_only_ones matrix, memoize=true}
    x.report("memoize=false") {find_largest_submatrix_containing_only_ones matrix, memoize=false}
end