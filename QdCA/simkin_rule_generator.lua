--A script by michael simkin 2019 - auto generates rules using states in golly which represent variables. 
--Insert your code only between user definition start and end definitions. 
--Register your variables using the line: def:append("any", any)
--f1, f2, ..., fn - represent state 1,2,3...n in golly. 
--index_function is the part which selects what part of the rule you want to unroll in order to use the functions. 
--index_function[] = {2, 3} will unroll variables which placed in golly in the second and third place. 
--In golly you fill 8 states around some x = 0 y = 10*N. You also place the function index in x = 10 y = 10*N next to the rule. 
--Forum post here: http://conwaylife.com/forums/viewtopic.php?f=7&t=3361&p=59227&hilit=nutshell#p59227

------------------------------------Helper functions----------------------------------

-- class.lua
-- Compatible with Lua 5.1 (not 5.0).
function class(base, init)
   local c = {}    -- a new class instance
   if not init and type(base) == 'function' then
      init = base
      base = nil
   elseif type(base) == 'table' then
    -- our new class is a shallow copy of the base class!
      for i,v in pairs(base) do
         c[i] = v
      end
      c._base = base
   end
   -- the class will be the metatable for all its objects,
   -- and they will look up their methods in it.
   c.__index = c

   -- expose a constructor which can be called by <classname>(<args>)
   local mt = {}
   mt.__call = function(class_tbl, ...)
   local obj = {}
   setmetatable(obj,c)
   if init then
      init(obj,...)
   else 
      -- make sure that any stuff from the base class is initialized!
      if base and base.init then
      base.init(obj, ...)
      end
   end
   return obj
   end
   c.init = init
   c.is_a = function(self, klass)
      local m = getmetatable(self)
      while m do 
         if m == klass then return true end
         m = m._base
      end
      return false
   end
   setmetatable(c, mt)
   return c
end

Definitions = class(function(df)
  df.table_of_everything = {}
  df.table_of_keys = {}
  df.table_of_idx = {}
end)

function Definitions:append(name, value)
	
	self.table_of_everything[name] = value 
	self.table_of_keys[#self.table_of_keys + 1] = name
	self.table_of_idx[name] = #self.table_of_keys
end

function interpret(f, params)
	if #params == 0 then 
		return f()
	elseif #params == 1 then 
		return f(params[1])
	elseif #params == 2 then 
		return f(params[1], params[2])
	elseif #params == 3 then 
		return f(params[1], params[2], params[3])
	end 
end 

function index_to_function(idx)
	if idx == 1 then 
		return f1
	elseif idx == 2 then 
		return f2
	elseif idx == 3 then 
		return f3
	elseif idx == 4 then 
		return f4
	elseif idx == 5 then 
		return f5
	elseif idx == 6 then 
		return f6
	elseif idx == 7 then 
		return f7
	elseif idx == 8 then 
		return f8
	elseif idx == 9 then 
		return f9
	elseif idx == 10 then 
		return f10
	elseif idx == 11 then 
		return f11
	elseif idx == 12 then 
		return f12
	elseif idx == 13 then 
		return f13
	elseif idx == 14 then 
		return f14
	elseif idx == 15 then 
		return f15
	end 
end 

NdIterator = class(function(it, sizes)
  it.box = sizes
  it.cur = {}
  it.flags = {}
  for i = 1, #sizes do 
	it.cur[#it.cur + 1] = 1
	it.flags[#it.flags + 1] = false 
  end 
end)

function NdIterator:next()
	for i = 1, #self.box do 
		self.cur[i] = self.cur[i] + 1
		
		if self.cur[i] > self.box[i] then 
			self.cur[i] = 1
		else 
			break
		end 
	end 
end 

function NdIterator:total()
	total = 1 
	for i = 1, #self.box do 
		total = total * self.box[i]
	end 
	
	return total
end 

local def = Definitions()

--------------------------------------User definitions Start--------------------------------------

--visual compiler
local g =  golly()

--0 - empty space 
--switch - 0,1,unk,A0,A1 : 1, 2, 3, 4, 5
--hold - 0,1,unk,A0,A1 : 6, 7, 8, 9, 10
--relese  A0, A1, r,  : 11, 12, 13
--relax - A0, A1, r,  : 14, 15, 16

function from_idx(idx)
	
	if idx <= 10 then 
		idx = (idx - 1) % 5 + 1
		
		if idx == 1 then 
			return 0
		elseif idx == 2 then 
			return 1 
		elseif idx == 3 then 
			return 2 
		elseif idx == 4 then 
			return 0
		else
			return 1 
		end 
		
	else
		idx = idx - 10 
		idx = idx % 3 
		return idx 
	end 
end 

--state 1
any  = {"any"}

--state 2
live = {"live"}

--state 3
switch = {1, 2, 3, 4, 5}

--state 4
hold = {6, 7, 8, 9, 10}

--state 5
relese = {11, 12, 13}

--state 6
relax = {14, 15, 16}

--state 7
switch_hold = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}

--state 8
not_switch_hold = {0, 11, 12, 13, 14, 15, 16}

--state 9
undefined_relax = {16}

--state 10
defined_relax = {14, 15}

--state 11 
not_switch = {0, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}

def:append("any", any)
def:append("live", live)
def:append("switch", switch)
def:append("hold", hold)
def:append("relese", relese)
def:append("relax", relax)
def:append("switch_hold", switch_hold)
def:append("not_switch_hold", not_switch_hold)
def:append("undefined_relax", undefined_relax)
def:append("defined_relax", defined_relax)
def:append("not_switch", not_switch)


--switch->hold 
function f1(sw)
	return sw + 5
end 

--hold->relese
function f2(hld)
	if hld < 9 then 
		return 13 
	else 
		return hld + 2
	end 
end 

--release->relax
function f3(ease)
	return ease + 3
end 

--(defined_relax)->(defined_switch)
function f4(defax)
	return defax - 10 
end 

--switch_hold->switch
function f5(sw)
	return (from_idx(sw) + 1)
end 

--(swr1, swr2)->switch (known or unknown depending)
function f6(sw1, sw2)
	if from_idx(sw1) == from_idx(sw2) then 
		return from_idx(sw1) + 1
	else 
		return 3
	end 
end 

function f7(sw1, sw2)
	if from_idx(sw1) == from_idx(sw2)then 
		if  from_idx(sw2) ~= 2 then 
			return 2 - from_idx(sw1) 
		else 
			return 3 
		end 
	else 
		return 3
	end 
end 

function f8(sw1, sw2, sw3)
	
	arr = {sw1, sw2, sw3}
	counter = {0,0,0}
	
	for i = 1, 3 do 
		idx = from_idx(arr[i]) + 1
		counter[idx] =  counter[idx] + 1
		
		if counter[idx] == 2 then 
			return idx
		end 
	end 
	
	return 3 
end 

function f9(sw)
	return 3
end 

index_function = {{0}, {0}, {0}, {0}, {7}, {3, 7}, {4, 6}, {3, 5, 7}, {0}}
colors = {
"0 255 0: 1, 4, 6, 9, 11, 14", 
"0 150 0: 6", 
"255 255 0: 2, 5, 10, 12, 15", 
"150 150 0: 7", 
"192 192 192: 3, 8", 
"64 64 64: 13, 16"
}
--------------------------------------User definitions End--------------------------------------
---------------------Compilation part don't touch--------------------------------

for i = 1, #index_function do 
	indeces = index_function[i]

	for j = 1, #indeces do 
		index_function[i][j] = index_function[i][j] + 1
	end 
end 

function toskip(x, y)
	
	if #(g.getcells({x - 10, y, 20, 1})) >= 60 or #(g.getcells({x - 10, y, 20, 1})) == 0 then 
		return true 
	else 
		return false 
	end 
end 

golly_order = {{0, 0},{0, -1},{1, -1},{1, 0},{1, 1},{0, 1},{-1, 1},{-1, 0},{-1, -1}}
rules = {}

rect = g.getrect()
y0 = math.floor(rect[2] / 10) * 10 - 20 
y1 = math.floor((rect[2] + rect[4]) / 10) * 10 + 20 

y = y0 
total = 0 
while y < y1 do 
	
	rule = {{}, 0}
	--Fill the variables 
	if toskip(0, y) == false then 
		for i = 1, 9 do 
			rule[1][#rule[1] + 1] = g.getcell(0 + golly_order[i][1], y + golly_order[i][2])
		end 
	
		--This is the function index 
		rule[2] = g.getcell(10, y) 		
		rules[#rules + 1] = rule 
	end 
	
	y = y + 10 
end 

path = "C:\\Users\\SimSim314\\Documents\\GitHub\\21st-Century-Chip-\\QdCA\\"
local file = io.open(path.."Qd.nts", "w")

file:write("@NUTSHELL QdCA\n\n@TABLE\nstates: 17\nsymmetries: rotate4 reflect\nneighborhood: Moore\n")

for i = 1, #def.table_of_keys do 
	value = def.table_of_everything[def.table_of_keys[i]]
	
	if (value[1] == "any" or value[1] == "live") == false then 
		file:write(def.table_of_keys[i].." = (")
		for idx = 1, #value do 
			if idx == #value then 
				file:write(tostring(value[idx])..")\n")
			else 
				file:write(tostring(value[idx])..", ")
			end 
			
		end 
	end 
end 

for i = 1, #rules do 
	rule = rules[i]
	vars = rule[1] --9 variables around me 
	func_idx = rule[2] -- function index 

	input_vars = index_function[func_idx]
	local state_iterator = NdIterator({1, 1, 1, 1, 1, 1, 1, 1, 1})
		
	for j = 1, #input_vars do 
		values = def.table_of_everything[def.table_of_keys[vars[input_vars[j]]]]
		state_iterator.box[input_vars[j]] = #values
		state_iterator.flags[input_vars[j]] = true
	end 
	
	max_idx = state_iterator:total()

	for state_iterator_idx = 1, max_idx do 
		input_func = {}
		
		for j = 1, #state_iterator.box do 
			if state_iterator.flags[j] == false then 
				
				var_name = "0"
				
				if vars[j] ~= 0 then 
					var_name = def.table_of_keys[vars[j]]
				end 
				
				if j == #state_iterator.box then 
					file:write(var_name.."; ")
				else 
					file:write(var_name..", ")
				end 
							
			else
				values = def.table_of_everything[def.table_of_keys[vars[j]]]
				value = values[state_iterator.cur[j]]
				input_func[#input_func + 1] = value
				
				if j == #state_iterator.box then 
					file:write(tostring(value).."; ")
				else 
					file:write(tostring(value)..", ")
				end 
			end 
		end 
		
		value = interpret(index_to_function(func_idx), input_func)
		file:write(tostring(value).."\n")
		state_iterator:next()
	end 
end 

file:write("@COLORS\n")

for i = 1,#colors do 
	file:write(colors[i].."\n")
end 

file.close()
