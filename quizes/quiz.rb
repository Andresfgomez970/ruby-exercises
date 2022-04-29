def palindrome?(a)
  if a.length == 1
    true
  elsif a.length == 2
    val = a[0] == a[-1]
  else
    val = (a[0] == a[-1]) ? palindrome?(a[1, a.length - 2]) : false
  end
end

var = 'anitalavalatina'
p "#{var} is palindrome? #{palindrome?(var)}"

var = 'andres'
p "#{var} is palindrome? #{palindrome?(var)}"

def bottles_of_beer(n)
  if n == 0
    puts "No more bottles of beer on the wall!"
  else
    puts "#{n} bottles of beer on the wall!"
    bottles_of_beer(n - 1)
  end
end

bottles_of_beer(10)

def fibbonaci(n)
  if n == 1
    0
  elsif n == 2
    1
  else
    fibbonaci(n - 2) + fibbonaci(n - 1)
  end
end

p fibbonaci(6)
p fibbonaci(7)

def array_flatten(array, index = 0)
  if index == array.length && array[-1] != Array
    array
  else
    if array[index].class != Array
      array_flatten(array, index + 1)
    else
      element_to_unpack = array[index]
      array.delete_at(index)
      array.insert(index, *element_to_unpack)
      array_flatten(array, index)
    end
  end
end

p array_flatten([[[1, 2], [3, 4]]])
p array_flatten([[1, [8, 9]], [3, 4]] )


$roman_mapping = {
  1000 => "M",
  900 => "CM",
  500 => "D",
  400 => "CD",
  100 => "C",
  90 => "XC",
  50 => "L",
  40 => "XL",
  10 => "X",
  9 => "IX",
  5 => "V",
  4 => "IV",
  1 => "I"
}

$roman_to_i_dict = $roman_mapping.map {|value, key| [key, value]}.to_h

def integer_to_roman(value, roman='')
  if value > 9327
    p 'That number is too big for the roman notation'
  end

  if value == 0
    roman
  else
    hash = $roman_mapping.select {|v, k| v <= value}.compact
    subtract_value = hash.keys.max
    add_string = hash[hash.keys.max]
    integer_to_roman(value - subtract_value, roman.concat(add_string))
  end
end

p integer_to_roman(3730)

def roman_to_integer(roman, res = 0)
  if roman == ''
    res
  else
    value = $roman_to_i_dict[roman[-1]]
    next_value = $roman_to_i_dict.fetch(roman[-2], Float::INFINITY)
    res += value <= next_value  ? value : -1 * value
    roman_to_integer(roman[0, roman.length - 1], res)
  end
end

p roman_to_integer('MMMDCCXXX')

def roman_to_integer2(roman, res = 0)
  if roman == ''
    res
  else
    value = $roman_to_i_dict[roman[0]]
    next_value = $roman_to_i_dict.fetch(roman[1], 0)
    res += value >= next_value ? value : -1 * value
    roman_to_integer2(roman[1, roman.length], res)
  end
end

roman_to_integer2('MMMDCCXXX')
