-----------------------------------------------------------------
-- Fireflies model
--Version 0.1
--Authors: Miguel Carrilho & Tigabu Dagne
----------------------------------------------
--PARAMETERS
---------------------------------------------
--math.randomseed(os.time()) 
TREE 	= 1
EMPTY 	= 2
OFF 	= 3
ON 		= 4
SEED	= 8
rand = Random{seed = SEED}
nEmpty 	=0
nTree 	=0
--flashCycle = Random()--random:integer(10)

-- Espaco
-- EMPTY
-- ON
-- OFF


-- Pirilampo
-- ON
-- OFF

-------------------------------------------
-- MODEL 
-------------------------------------------
 
--# space
cs = CellularSpace {
	xdim = 50,
	ydim = 50
}
 
cs:createNeighborhood{
	strategy = "moore", --moore--vonneumann
		self = false}

 
forEachCell(cs, function(cell)
	if rand:number() > 0.1 then
		cell.state = EMPTY
		nEmpty = nEmpty+1
	else
		cell.state = TREE
		nTree = nTree+1
	end
end)

--# behavior 

fireflies = Agent {
	cycle=10,
	state = OFF,
	init = function(self)
		if math.random()< 0.6 then
			self.state = ON
		end
	end,
	execute = function(self)
		local myCell		= self:getCell()
		local neighCell 	= myCell:getNeighborhood():sample()
--		local agNeigh       = neighCell:getAgent()
--		forEachNeighbor(neighCell,function(cell, neighbor)
			--when the agent finds a neighbor
			if (neighCell.past.state == ON) or (neighCell.past.state == OFF) then
				self.state 	= ON
				self.cycle	= 10
				
			else -- when cell is empty 
				if self.cycle == 0 then
					self.state = ON
					self.cycle = 10
				else 
					self.state = OFF
					self.cycle = self.cycle-1
				end
			end 
--		end)
		myCell.state = self.state
		
		-- movement rule
		--local neighCell2 	= myCell:getNeighborhood():sample()
		if neighCell.past.state == EMPTY then
			self:getCell().state = EMPTY
			self:move(neighCell)
			neighCell.state = self.state
			self.cycle = self.cycle-1
		end
	end,
}
soc = Society{
	instance = fireflies,
	quantity = 300
}
 
--# time
 
t = Timer {
	Event{action = soc},
	Event{action = cs}
}
 
--# environment
 
e = Environment {
	cs,
	soc,
	t
}
 
e:createPlacement{strategy = "random", max = 1}
 
forEachAgent(soc, function(agent)
	agent:getCell().state = agent.state
end)

-------------------------------------------
-- SIMULATION 
-------------------------------------------
 
leg = Legend {
	grouping = "uniquevalue",
	colorBar = {
		{value = EMPTY, color = "white"},
		{value = OFF, color = "black"},
		{value = TREE, color = "green"},
		{value = ON, color = "yellow"},
	}
}
 
Observer {
	subject = cs,
	attributes = {"state"},
	legends = {leg}
}
 
 
e:execute(50)
	print(nEmpty,nTree)
