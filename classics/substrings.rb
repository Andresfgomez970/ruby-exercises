dictionary = ["below","down","go","going","horn","how","howdy","it","i","low","own","part","partner","sit"]
phrase = "Howdy partner, sit down! How's it going?"

def substrings(phrase, dictionary)
	phrase = phrase.downcase
	word_count = dictionary.map do |word| 
		[word, phrase.scan(word).length] if phrase.scan(word).length > 0 	
	end
	word_count.compact.to_h
end

p substrings(phrase, dictionary)