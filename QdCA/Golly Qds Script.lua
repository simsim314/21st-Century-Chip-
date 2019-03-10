
local g = golly()

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

Point = class(function(pt,x,y,z)
   pt:set(x,y,z)
 end)

local function eq(x,y)
  return math.abs(x - y) < 0.000001
end

function Point.eq(p1,p2)
  return eq(p1[1],p2[1]) and eq(p1[2],p2[2]) and eq(p1[3],p2[3])
end

function Point.get(p)
  return p[1],p[2],p[3]
end

-- vector addition is '+','-'
function Point.add(p1,p2)
  return Point(p1[1]+p2[1], p1[2]+p2[2], p1[3]+p2[3])
end

function Point.sub(p1,p2)
  return Point(p1[1]-p2[1], p1[2]-p2[2], p1[3]-p2[3])
end

-- unitary minus  (e.g in the expression f(-p))
function Point.unm(p)
  return Point(-p[1], -p[2], -p[3])
end

-- scalar multiplication and division is '*' and '/' respectively
function Point.mul(s,p)
  return Point( s*p[1], s*p[2], s*p[3] )
end

function Point.div(p,s)
  return Point( p[1]/s, p[2]/s, p[3]/s )
end

-- dot product is '..'
function Point.concat(p1,p2)
  return p1[1]*p2[1] + p1[2]*p2[2] + p1[3]*p2[3]
end

-- cross product is '^'
function Point.pow(p1,p2)
   return Point(
     p1[2]*p2[3] - p1[3]*p2[2],
     p1[3]*p2[1] - p1[1]*p2[3],
     p1[1]*p2[2] - p1[2]*p2[1]
   )
end

function Point.normalize(p)
  local l = p:norm()
  p[1] = p[1]/l
  p[2] = p[2]/l
  p[3] = p[3]/l
end

function Point.set(pt,x,y,z)
  if type(x) == 'table' and getmetatable(x) == Point then
     local po = x
     x = po[1]
     y = po[2]
     z = po[3]
  end
  pt[1] = x
  pt[2] = y
  pt[3] = z 
end

function Point.translate(pt,x,y,z)
   pt[1] = pt[1] + x
   pt[2] = pt[2] + y
   pt[3] = pt[3] + z 
end

function Point.tostring(p)
  return string.format('(%f,%f,%f)',p[1],p[2],p[3])
end

local function sqr(x) return x*x end

function Point.norm(p)
  return math.sqrt(sqr(p[1]) + sqr(p[2]) + sqr(p[3]))
end

function states_to_potential(points, measure_point)
	
	local force = Point(0., 0., 0.)
		
	for i = 1, #points do 
		local p = Point()
		p:set(points[i])
		p = p:sub(measure_point)
		
		r = p:norm()
		p = p:div(sqr(r))
		force = force:add(p)

	end 
	
	return force:norm()	
end 

Qd = class(function(pt, p1, p2, p3, d)
   pt.p1 = p1 
   pt.p2 = p2 
   pt.p3 = p3 
   pt.d = d 
   pt.active = 1 
 end)

function Qd.set(qd, qd1)
	qd.p1:set(qd1.p1)
	qd.p2:set(qd1.p2)
	qd.p3:set(qd1.p3)
	qd.d = qd1.d
end 

function Qd.move(qd, p)
	qd.p1 = qd.p1:add(p)
	qd.p2 = qd.p2:add(p)
	qd.p3 = qd.p3:add(p)
end 
 
function Qd.getPoint(p)
	if p.active == 1 then 
		return p.p1
	end 
	
	if p.active == 2 then 
		return p.p2
	end 
	
	return p.p3
end 

function Qd.tostring(p)
	if p.active == 1 then 
		return "0,"
	elseif p.active == 2 then 
		return "1,"
	else 
		return "2,"
	end 
end 

function add_bit(Qs)
	for i = 1, #Qds do
		Q = Qs[i]
		if Q.active == 1 then 
			Q.active = 2
			return 
		elseif Q.active == 2 then 
			Q.active = 3
			return 
		else 
			Q.active = 1
		end 
	end 
end 

function generate_rule(p1, p2, p3, idx)

	qd_init = Qd(p1, p2, p3, 1)
	Qds = {}

	for i = 1, 3 do 
		for j = 1, 3 do 
			local qd1 = Qd(p1, p2, p3, 1)
			qd1:set(qd_init)
			qd1:move(Point(qd_init.d * j, qd_init.d * i, 0))
			Qds[#Qds + 1] = qd1
			--print(Qds[#Qds].p1:tostring(), Qds[#Qds].p2:tostring())
		end 
	end 

	potential_list = {} 

	for i = 1, 3^9 do 

		l = Qds[5]:tostring()
		..Qds[2]:tostring()
		..Qds[3]:tostring()
		..Qds[6]:tostring()
		..Qds[9]:tostring()
		..Qds[8]:tostring()
		..Qds[7]:tostring()
		..Qds[4]:tostring()
		..Qds[1]:tostring()
		
		local points = {}
		local measure_point = Qds[5]:getPoint()
		
		for j = 1,9 do 
			if j ~= 5 then 
				points[#points + 1] = Qds[j]:getPoint()
			end 
		end 
		
		potential = states_to_potential(points, measure_point)
		potential_list[l] = potential
		add_bit(Qds)
	end 

	
	for k, v in pairs(potential_list) do
		first = string.sub(k, 1, 1)
		
		local_potentials = {}
		
		for i = 1, 3 do 
			newk = tostring(i - 1)..string.sub(k, 2, k:len())
			local_potentials[#local_potentials + 1] = potential_list[newk]
		end 
		
		table.sort(local_potentials)
		
		if local_potentials[1] == local_potentials[2] then
			return false 
		end 
	end 
	
	local file = io.open("C:\\Users\\SimSim314\\Documents\\visual studio 2012\\Projects\\BellmanWin\\Desktop\\golly-3.2-win-32bit\\Rules\\".. "Qd01" .. tostring(idx).. ".rule", "w")
	
	file:write("@RULE Qd01" .. tostring(idx) .. "\n\n"..p1:tostring()..p2:tostring()..p3:tostring().."\n\n@TABLE\nn_states:3\nneighborhood:Moore\nsymmetries:none\n\n")
	--worked_out = {}
	--potential_list

	for k, v in pairs(potential_list) do
		first = string.sub(k, 1, 1)
		
		best = -1
		bestv = 10000000
		
		for i = 1, 3 do 
			newk = tostring(i - 1)..string.sub(k, 2, k:len())
			vi = potential_list[newk]

			if vi < bestv then 
				bestv = vi
				best = i 
			end 
		end 
			
		file:write(k..tostring(best - 1), "\n")
	end

	file:write("\n\n@COLORS\n0 0 0 0     black\n1 255 255 255   red\n2 255 255 0   yellow")
	file:close()
	
	return true
end 

function is_interesting_pop(step_size)
	g.setstep(step_size)
	pop = tonumber(g.getpop())
	
	g.step()
	pop0 = tonumber(g.getpop())
	
	if pop0 > 1.8*pop then 
		return false
	end 
	
	g.step()
	pop1 = tonumber(g.getpop())
	
	g.step()
	pop2 = tonumber(g.getpop())
	
	if pop2 == 0 then 
		return false 
	end 
	d1 = pop1 - pop0
	d2 = pop2 - pop0 
	
	if d2 < 0 or d1 < 0 then 
		return true
	end 
	
	if d2 > 1.6 * d1 then 
		return false 
	else 
		return true 
	end 
	
end 


function is_interesting_box(step_size)
	g.setstep(step_size)
	
	g.step()
	box = g.getrect()
	
	if box == nil then 
		return false 
	end 
	pop0 = box[3] * box[4]
	
	g.step()
	box = g.getrect()
	if box == nil then 
		return false 
	end 
	pop1 = box[3] * box[4]
	
	g.step()
	box = g.getrect()
	if box == nil then 
		return false 
	end 
	pop2 = box[3] * box[4]
	
	if pop2 == 0 then 
		return false 
	end 
	d1 = pop1 - pop0 
	d2 = pop2 - pop0
	
	if d2 < 0 or d1 < 0 then 
		return false
	end 
	
	if d2 > 1.7 * d1 then 
		return true 
	else 
		return false
	end 
	
end 
idx = 0
res={}

while true do 
	
	p1 = Point(math.random(), math.random(),  math.random())
	p2 = Point(math.random(), math.random(),  math.random())
	p3 = Point(math.random(), math.random(),  math.random())

	if generate_rule(p1, p2, p3, idx) then 
		idx =  idx + 1
		
		g.new("")
		g.setbase(2)

		g.setrule("Qd01" .. tostring(idx))
		g.select({-50, -50, 100, 100})
		g.randfill(50)
		local pop = tonumber(g.getpop())
		
		g.fit()
		g.update()
		
		if is_interesting_pop(4) then 
			g.fit()
			g.update()
		
			if is_interesting_pop(8) then 
				g.fit()
				g.update()
				if is_interesting_box(8) then 
					if g.getcells({-100, -100, 200, 200}) > 50 then 
						g.show("SUCCESS")
						return 
					end 
					
				end 
			end 
		end 

		if idx % 100 == 0 then 
			
			g.new("")
			
			for i = 1, 100 do 
				g.putcells(res[i], 200 * i)
			end 
			
			g.save(tostring(idx) + ".rle", "rle")
			
		else 
			res[1 + idx % 100] = g.getcells()
		end 
	end 	
end 