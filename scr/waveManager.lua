local wave = {}

function wave:init(stage)
	self.stage = stage
	self.waveCD = 60
	self.waveTimer = self.waveCD
	self.waveCount = 0
	self:nextWave()
end

function wave:nextWave()
	self.waveCount = self.waveCount + 1
	self.waveCD = self.waveCD - 0.5
	self.waveTimer = self.waveCD
	self.monsterCount = 10 + self.waveCount
	self.waveDuring = 20
	self.stage:newMessage("Wave Start!")
	self.stage.map.layers.closedDoor.visible = false
	for i = 1, self.monsterCount do
		local func = function() self.stage:addRandomMonster() end
		delay:new(self.waveDuring/i,func)
	end
	self.sendingMonster = true
	delay:new(self.waveDuring,function()
		self.stage.map.layers.closedDoor.visible = true 
		self.sendingMonster = false 
	end)
end

function wave:update(dt)
	if not self.sendingMonster and #self.stage.monsters == 0  then
		self.stage:newMessage("Wave Clear !")
		self.sendingMonster = true
		self.waveTimer = 11
		self.stage.cat.money = self.stage.cat.money + math.ceil(self.waveTimer)
		self.stage.enableMenu = true
		self.stage.menu:newGrid()
	end

	self.waveTimer = self.waveTimer - dt
	if self.waveTimer < 0 then
		self:nextWave()
		self.stage.enableMenu = false
		self.stage.menu:removeGrid()
	end
end

function wave:shopping()


end

return wave