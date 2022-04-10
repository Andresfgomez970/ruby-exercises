def bubble_sort(list)
	list_length = list.length() - 1
	for i in list_length.step(0, -1).to_a do
		for j in 0.step(i - 1, 1).to_a do
			p list
			if list[j] > list[j + 1]
				list[j], list[j + 1] = list[j + 1], list[j]
			end
		end
	end
end

bubble_sort([4, 5, 2, 3, 1])