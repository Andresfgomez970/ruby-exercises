def caesar_cipher(string, shift)
	diff = 'z'.ord - 'a'.ord + 1

	new_string =	string.split("").map do |char|
		if char.between?('a', 'z')
	 		((char.ord - 'a'.ord + shift) % diff + 'a'.ord).chr			
		elsif char.between?('A', 'Z')
			((char.ord - 'A'.ord + shift) % diff + 'A'.ord).chr			
		else
			char
	 	end
	end
	new_string.join
end

if __FILE__ == $0
	p caesar_cipher("What a string!", 5)
end