local g = golly()
local gp = require "gplus"

local function dir(x, y)
	for i = 1, 3  do 
		for j = 1, 3 do 
			val = g.getcell(x - i + 2, y - j + 2)
			if val ~= 0 and (i == 2 and j == 2) ~= true then 
				dx = -i + 2
				dy = -j + 2 
				return {dx, dy}
			end 
		end 
	end
	
	g.exit("Please click on edge of a wire")
end 

local function get_d(x, y)
	for i = 1, 3  do 
		for j = 1, 3 do 
			val = g.getcell(x - i + 1, y - j + 1)
			if val == 1 or val == 6 then 
				return 0
			elseif val == 2 or val == 7 then 
				return 1 
			elseif val == 3 or val == 8 then 
				return 2
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

local function update_drawstate(drawingstate, d)
	if drawingstate == 16 then 
		return 13
	elseif drawingstate == 13 then 
		return 6 + d
	elseif drawingstate == 6 + d then 
		return 1 + d
	else 
		return 16 
	end
end 

function move(x, y, state, d, dx, dy)
	return {x + dx, y + dy, update_drawstate(state, d)}
end 

function draw_not_gate()
	local d_state = 0
    while true do
        local event = g.getevent()
        if event:find("click") == 1 then
            -- event is a string like "click 10 20 left altctrlshift"
            local evt, x, y, butt, mods = gp.split(event)

			if butt == "left" then 
				x = tonumber(x)
				y = tonumber(y)
				state = g.getcell(x, y)
				d_state = get_d(x, y)
				v = dir(x, y)
				dx = v[1]
				dy = v[2]
				
				dx = dx * -1 
				dy = dy * -1 
				
				t = move(x, y, state, d_state, dy, dx)
				
				x1 = t[1]
				y1 = t[2]
				state = t[3]
				
				t = move(x, y, state, d_state,  -dy, -dx)
				x2 = t[1]
				y2 = t[2]
				
				t = move(x, y, state, d_state,  4 * dx, 4 * dy)
				x3 = t[1]
				y3 = t[2]
				
				g.setcell(x1, y1, state)
				g.setcell(x2, y2, state)
				g.setcell(x3, y3, state)
				
				for i = 1, 3 do
					t = move(x1, y1, state, d_state,  dx, dy)
					x1 = t[1]
					y1 = t[2]
					state = t[3]
				
					t = move(x2, y2, state, d_state,  dx, dy)
					x2 = t[1]
					y2 = t[2]
				
					t = move(x3, y3, state, d_state,  dx, dy)
					x3 = t[1]
					y3 = t[2]
				
					g.setcell(x1, y1, state)
					g.setcell(x2, y2, state)
					g.setcell(x3, y3, state)
				end 
				
				g.exit("Sucess! Not gate added")
			else
				g.exit("User exited")
			end 
		else 
			if #event > 0 then g.doevent(event) end
        end
    end
end

--------------------------------------------------------------------------------

g.show("Click where to start line...")
local oldcursor = g.getcursor()
g.setcursor("Draw")

local status, err = xpcall(draw_not_gate, gp.trace)
if err then g.continue(err) end
-- the following code is executed even if error occurred or user aborted script

g.setcursor(oldcursor)
if #oldline > 0 then eraseline(oldline) end
if #firstcell > 0 then
    local x, y, s = table.unpack(firstcell)
    g.setcell(x, y, s)
end