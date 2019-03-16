import golly as g 

rule_name = "Test"
n_states = "100"
neighborhood = "Moore"
symmetries = "rotate4reflect"

idxs = [(0, 0), (0, -1), (1, -1), (1, 0), (1, 1), (0, 1), (-1, 1), (-1, 0), (-1, -1)]
lines = [] 
variables = {}

def cell_to_string(cell, ids, val = -1):
	global variables
	
	if not (cell in variables):
		return str(cell)
	
	if val == 0:
		return "0"
	
	if val > 0:
		if cell in variables: 
			return "a1" + str(cell) 
		else:
			return str(cell) 
		
	ids[cell] += 1
	return "a" + str(ids[cell]) + str(cell)

def XY_toline(x, y):
	global variables
	ids = {}
	
	for i in variables:
		ids[i] = 0
	
	res = ""
	
	for i, j, in idxs:
		res += cell_to_string(g.getcell(x + i, y + j), ids) + ","
		
	res += cell_to_string(g.getcell(x + 10, y), ids, g.getcell(x, y)) + "\n"
		
	return res 

def add_rule(lines, res):
	if not (res in lines):
		lines.append(res)
	
def scanXY(x, y, islast, lines):
	res = ""
	for i in range(10):
		for j in range(10):
			if g.getcell(x + i, y + j) != 0:
				if not islast:
					add_rule(lines, XY_toline(x + i, y + j))
					
			elif g.getcell(x + i + 10, y + j) != 0:
				add_rule(lines, XY_toline(x + i, y + j))

	return res
	
def scanX(y, lines, stage, vars):

	if stage == 0:
		if g.getcell(0, y) == 0:
			if len(g.getcells([0, y, 10, 1])) != 0:
				stage = 2
			else:
				return 0 
		else:
			stage = 1 
			
	if stage == 1:
		if g.getcell(0, y) == 0:
			stage = 2
		else:
			vars[g.getcell(0, y)] = [g.getcell(10, y)] 
			
			dx = 20
			while g.getcell(dx, y) != 0:
				vars[g.getcell(0, y)].append(g.getcell(dx, y))
				dx += 10
			
			return stage
	
	stage = 2
	
	dx = 0 	
	while len(g.getcells([dx, y, 10, 10])) != 0:
		dx += 10
	
	for i in range(0, dx, 10):
		scanXY(i, y, i == dx - 10, lines)

	return stage
	

def scan(lines):
	global variables
	
	rect = g.getrect()
	maxY = rect[1] + rect[3]
	y = int(rect[1] / 10) * 10 - 10 
	res = ""
	stage = 0 
	
	while y < maxY:
		stage = scanX(y, lines, stage, variables)
		y += 10 
	
	for l in lines: 
		res += l
		
	return res

pre_rule = '''@RULE %s

@TABLE
n_states:%s
neighborhood:%s
symmetries:%s

''' % (rule_name, n_states, neighborhood, symmetries)

all_rules = scan(lines)

for k in variables:
	for i in range(8):
		
		pre_rule += "var a" + str(i + 1) + str(k) + " = {"
		lv = variables[k]
		
		for j in range(len(lv)):
			pre_rule += str(lv[j])
			
			if j == len(lv) - 1:
				pre_rule += "}"
			else: 
				pre_rule += ","
				
		pre_rule += "\n"
		
g.setclipstr(pre_rule + all_rules)