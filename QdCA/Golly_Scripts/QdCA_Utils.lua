local g = golly()

local function update_d(x, y)
	for i = 1, 3  do 
		for j = 1, 3 do 
			val = g.getcell(x - i + 1, y - j + 1)
			if val == 1 or val == 6 then 
				return 0
			elseif val == 2 or val == 7 then 
				return 1 
			end 
		end 
	end 

	for i = 1, 5  do 
		for j = 1, 5 do 
			val = g.getcell(x - i + 3, y + 3 - j)
			if val == 1 or val == 6 then 
				return 0
			elseif val == 2 or val == 7 then 
				return 1 
			end 
		end 
	end 

	return 0
end 