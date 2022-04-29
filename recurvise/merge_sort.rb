def merge(a, b)
  max_index = a.length + b.length - 1
  merge = Array.new(max_index) 
  j, k = 0, 0
  (0..max_index).each do |i|
    if k >= b.length || (j < a.length && a[j] < b[k])
      merge[i] = a[j]
      j += 1
    else
      merge[i] = b[k]
      k += 1
    end
  end
  merge
end

def merge_sort(array)
  if array.length == 1
    array
  else
    r, q = array.length.divmod(2)
    left = merge_sort(array[0, r + q])
    right = merge_sort(array[r + q, array.length])
    merge(left, right)
  end
end
