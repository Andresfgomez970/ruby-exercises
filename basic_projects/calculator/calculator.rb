# frozen_string_literal: true

# basic caculator class
class Calculator
  def add(num_or_arr, *others)
    case [num_or_arr, others]
    # add when for input like add(a, b, c, d, ...)
    in [Numeric, [Numeric, *]] if others.all? {|n| n.is_a?(Numeric)}
      num_or_arr + others.sum()
    # add when for input like add(a, [b, c, d, ...])
    in [Numeric, [[Numeric, *]]] if others[0].all? {|n| n.is_a?(Numeric)}
      num_or_arr + others[0].sum()
    # add when for input like add([a, b , c, d, ...], [b, c, d, ...])
    in [[Numeric, *], [Numeric, *]] if others.all? {|n| n.is_a?(Numeric)} && num_or_arr.all? {|n| n.is_a?(Numeric)}
      num_or_arr.sum() + others.sum()
    # add when for input like add([a, b , c, d, ...], b, c, d, ...)
    in [[Numeric, *], [[Numeric, *]]] if others[0].all? {|n| n.is_a?(Numeric)} && num_or_arr.all? {|n| n.is_a?(Numeric)}
      num_or_arr.sum() + others[0].sum()
    # add when for input like add([a, b , c, d, ...])
    in [[Numeric, *], []] if num_or_arr.all? {|n| n.is_a?(Numeric)}
      num_or_arr.sum()
    # error for input like add(Numeric)
    in [Numeric, []] 
      puts 'please enter at least two parameters to sum up'
    # the rest are errors
    else 
      puts 'please enter valid input to sum up'
    end
  end


  def multiply(number, *others)
    case [number, others]
    # add when for input like add(a, b, c, d, ...)
    in [Numeric, [Numeric, *]] if others.all? {|n| n.is_a?(Numeric)}
      number * others.reduce(:*)
    else 
      puts 'please enter valid input to multiply'
    end
  end
end

if __FILE__ == $0
  calculator = Calculator.new
  puts calculator.add(2, 5)
  puts calculator.add(2, 2, 3)
  puts calculator.add(2, [2, 3])

  puts calculator.add([1, 2], 3, 1)
  puts calculator.add([1, 2], [3, 1])

  puts calculator.add([2, 5])

  puts calculator.add(2)
  puts calculator.add(['1', '2'])

  puts calculator.multiply(2, 5)
  puts calculator.multiply(2, 5, 10, 3)

end



