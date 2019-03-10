-- Allow user to draw one or more straight lines by clicking end points.
-- Author: Andrew Trevorrow (andrew@trevorrow.com), Apr 2016.

local g = golly()
local gp = require "gplus"

local oldline = {}
local firstcell = {}    -- pos and state of the 1st cell clicked
local init_drawstate = g.getoption("drawingstate")

local function update_d(x, y)
	for i = 1, 3  do 
		for j = 1, 3 do 
			val = g.getcell(x - i + 2, y - j + 2)
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
			elseif val == 3 or val == 8 then 
				return 2
			end 
		end 
	end 

	return 0
end 
--------------------------------------------------------------------------------
local function virtual_coordinatemanipaltion(x1, y1, x2, y2)
	local dx = x2 - x1 
	local dy = y2 - y1 
	
	local angle = math.atan2(dy, dx);
	
	angle = angle * 180 / math.pi
	angle = math.floor(0.5 + angle / 90) * 90
	angle = angle / (180 / math.pi)
	
	local r = math.sqrt(dx * dx + dy * dy)
	
	dx = r * math.cos(angle)
	dy = r * math.sin(angle)
	
	local t = {}
	t[1] = x1
	t[2] = y1 
	t[3] = math.floor(0.5 + x1 + dx)
	t[4] = math.floor(0.5 + y1 + dy)
    
	return t
	
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

local function drawline(x1, y1, x2, y2, d_state)
	t = virtual_coordinatemanipaltion(x1, y1, x2, y2)
	x1 = t[1]
	y1 = t[2]
	x2 = t[3]
	y2 = t[4]
	drawstate = update_drawstate(init_drawstate, d_state)
	drawstate = update_drawstate(drawstate, d_state)
	drawstate = update_drawstate(drawstate, d_state)
    -- draw a line of cells from x1,y1 to x2,y2 using Bresenham's algorithm;
    -- we also return the old cells in the line so we can erase line later
    local oldcells = {}
    -- note that x1,y1 has already been drawn
    if x1 == x2 and y1 == y2 then
        g.update()
        return oldcells
    end
    
    local dx = x2 - x1
    local ax = math.abs(dx) * 2
    local sx = 1
    if dx < 0 then sx = -1 end
    
    local dy = y2 - y1
    local ay = math.abs(dy) * 2
    local sy = 1
    if dy < 0 then sy = -1 end

    if ax > ay then
        local d = ay - (ax / 2)
        while x1 ~= x2 do
            oldcells[#oldcells+1] = {x1, y1, g.getcell(x1, y1)}
			drawstate = update_drawstate(drawstate, d_state)
            g.setcell(x1, y1, drawstate)
            if d >= 0 then
                y1 = y1 + sy
                d = d - ax
            end
            x1 = x1 + sx
            d = d + ay
        end
    else
        local d = ax - (ay / 2)
        while y1 ~= y2 do
            oldcells[#oldcells+1] = {x1, y1, g.getcell(x1, y1)}
			drawstate = update_drawstate(drawstate, d_state)
            g.setcell(x1, y1, drawstate)
            if d >= 0 then
                x1 = x1 + sx
                d = d - ay
            end
            y1 = y1 + sy
            d = d + ax
        end
    end
    
    oldcells[#oldcells+1] = {x2, y2, g.getcell(x2, y2)}
	drawstate = update_drawstate(drawstate, d_state)
    g.setcell(x2, y2, drawstate)
    g.update()
    return oldcells
end

--------------------------------------------------------------------------------

local function eraseline(oldcells)
    for _, t in ipairs(oldcells) do
        g.setcell( table.unpack(t) )
    end
end

--------------------------------------------------------------------------------

function drawlines()
    local started = false
    local oldmouse = ""
    local startx, starty, endx, endy
	local d_state = 0
    while true do
        local event = g.getevent()
        if event:find("click") == 1 then
            -- event is a string like "click 10 20 left altctrlshift"
            local evt, x, y, butt, mods = gp.split(event)
            oldmouse = x .. ' ' .. y
			if butt == "left" then 
				if started then
					-- draw permanent line from start pos to end pos
					endx = tonumber(x)
					endy = tonumber(y)
					drawline(startx, starty, endx, endy, d_state)
					-- this is also the start of another line
					startx = endx
					starty = endy
					started = false 
					oldline = {}
					firstcell = {}
				else
					-- start first line
					startx = tonumber(x)
					starty = tonumber(y)
					firstcell = { startx, starty, g.getcell(startx, starty) }
					init_drawstate = g.getcell(startx, starty)
					d_state = update_d(startx, starty)
					--g.setcell(startx, starty, drawstate)
					g.update()
					started = true
					g.show("Click where to end this line (and start another line)...")
				end
			else
				g.exit()
			end 
        else
            -- event might be "" or "key m none"
            if #event > 0 then g.doevent(event) end
            local mousepos = g.getxy()
            if started and #mousepos == 0 then
                -- erase old line if mouse is not over grid
                if #oldline > 0 then
                    eraseline(oldline)
                    oldline = {}
                    g.update()
                end
            elseif started and #mousepos > 0 and mousepos ~= oldmouse then
                -- mouse has moved, so erase old line (if any) and draw new line
                if #oldline > 0 then eraseline(oldline) end
                local x, y = gp.split(mousepos)
                oldline = drawline(startx, starty, tonumber(x), tonumber(y), d_state)
                oldmouse = mousepos
            end
        end
    end
end

--------------------------------------------------------------------------------

g.show("Click where to start line...")
local oldcursor = g.getcursor()
g.setcursor("Draw")

local status, err = xpcall(drawlines, gp.trace)
if err then g.continue(err) end
-- the following code is executed even if error occurred or user aborted script

g.setcursor(oldcursor)
if #oldline > 0 then eraseline(oldline) end
if #firstcell > 0 then
    local x, y, s = table.unpack(firstcell)
    g.setcell(x, y, s)
end