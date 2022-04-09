prices = [17,3,6,9,15,8,6,1,10]

def stock_picker1(prices)
	max_profit = -Float::INFINITY
	indexes = [0, 0]
	prices.each_with_index do |buy, i|
		prices.each_with_index do |sell, j|
			if j > i
				if (sell - buy) > max_profit
					indexes[0] = i
					indexes[1] = j
					max_profit = (sell - buy)
				end
			end
		end
	end
	indexes
end

def stock_picker2(prices)
	max_profit = -Float::INFINITY
	indexes = [0, 0]
	prices.each_with_index do |sell, i|
		result = substract(sell, prices[0..i])
		if (result.max > max_profit)
			indexes = [result.each_with_index.max[1], i]
			max_profit = result.max
		end
	end
	indexes
end

def substract(value, array1)
	array1.map {|elem| value - elem}
end

def stock_picker3(prices)
	pairs = prices.each_with_index.reduce([]){ |buy_sell_pairs, (sell, index)| buy_sell_pairs += prices[0..index].product([sell])}
	pairs = pairs.map{|pair| [pair[0], pair[1], pair[1] - pair[0]]}
	triple = pairs.max_by{|triple| triple[2]}
	buy_index = prices.index{|x| x == triple[0]}
	sell_index = prices[buy_index..-1].index{|x| x == triple[1]} + buy_index
	[buy_index, sell_index]
end

def stock_picker4(prices)
	min_p, min_i = prices[0], 0
	profit = 0
	indexes = [0, 0]

	prices.each_with_index do |market_p, market_i| 
		if (market_p < min_p)
			min_p, min_i = market_p, market_i
			next
		end

		if (market_p - min_p) > profit
			profit = (market_p - min_p)
			indexes	= [min_i, market_i]
		end
	end
	indexes
end


p stock_picker1(prices)
p stock_picker2(prices)
p stock_picker3(prices)
p stock_picker4(prices)