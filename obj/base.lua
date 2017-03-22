local monster = class("base")
local StateSystem = require "lib/roleStateSystem"
local Dropbox = require "obj/stage/dropbox"
local Coin = require "obj/stage/coin"
monster.dropRate = 0.2
monster.attackTimer = 1
monster.attackCD = 1

function monster:init(stage,x,y)
	self.x = x 
	self.y = y
	self.w = 20
	self.h = 20
	self.offy = 11
	self.offx = 0
	self.tw = 64
	self.th = 64

	self.dx =0
	self.dy = 0 
	self.ax = 1
	self.ay = 0.8
	self.speed = 1
	self.damping = 0.7

	if  love.math.random()>0.5 then
		self.direction = 1
		self.flipX = false
	else
		self.direction = -1
		self.flipX = true
	end

	self.scale = 1.5
	self.stage = stage
	self.world = stage.world

	self.hp = 30
	self.animSpeed = 1/20

	self:setup()
end

function monster:resetParameter()
end


function monster:setup()
	self:resetParameter()
	self:initAnim()
	self:initState()
	self:initBump()
	--self:initLight()
end




function monster:initAnim()	
	self.anims = {}
	for i,data in ipairs(self.animData) do
		local name,x,y,count = unpack(data)
		self.anims[name] = animation(self.animAtlas,
			(x-1)*64,(y-1)*64,
			64,64,0,0,
			(x+count-1)*64-1,y*64-1,self.animSpeed)
	end
	self.currentAnim = self.anims.idle
end

function monster:playAnim(name,loop,add,speed) --todo speed
	if self.currentAnim == self.anims[name] then return end 
	if add and self.currentAnim.isPlay then
		local func = function(anim)
			anim.onEnd = nil
			anim.onLoop = nil
			self.currentAnim = self.anims[name]
			self.currentAnim:setMode(loop and "loop" or "onetime")
		end
		self.currentAnim.onEnd = func
		self.currentAnim.onLoop = func
	else
		self.currentAnim = self.anims[name]
		self.currentAnim:setMode(loop and "loop" or "onetime")
	end
end

function monster:backToIdle(endcallback)

	local current = self.currentAnim
	local func = function()
		self.currentAnim.onLoop = nil
		self.currentAnim.onEnd = nil
		self.state:switch(self.state.current, self.state.stack["idle"])
		if endcallback then endcallback() end
	end

	if current.isPlay then
		self.currentAnim.onLoop = func
		self.currentAnim.onEnd = func
	else
		func()
		if endcallback then endcallback() end
	end
end




function monster:initState()
	self.state = StateSystem.init(self)
	for name,action in pairs(self.stateData) do
		self.state:reg(name,action,name == "idle")
	end
end





function monster:initLight()
	if not self.stage.enableLight then return end
	local x,y,w,h = self:getBumpData()
	self.block = self.stage.light:newCircle(x+w/2,y+h/2,(w+h)/4)
end

function monster:updateLight()
	if not self.block then return end
	local x,y,w,h = self:getBumpData()
	self.block.x, self.block.y = x+w/2,y+h/2
end






function monster:getBumpData()
	local x = self.x - self.w*self.scale/2
	local y = self.y - self.h*self.scale
	local w = self.w*self.scale
	local h = self.h*self.scale
	return x,y,w,h
end

function monster:setPlayerPos(x,y)
	self.x = x + self.w*self.scale/2
	self.y = y + self.h*self.scale
end

function monster:initBump()
	self.world:add(self,self:getBumpData())
end


function monster.collidefilter(me,other)
	if other.isPlayer then
		return bump.Response_Cross
	elseif other.isMonster then
		return bump.Response_Cross
	elseif other.isWall then
		return bump.Response_Bounce
	end
end


function monster:collision(cols)
	for i,col in ipairs(cols) do
		local other = col.other
		if other.isWall then
			if col.normal.y == -1 then
				self.onGround = true
				self.dy = -10
			else
				self.direction = - self.direction
				self.flipX = not self.flipX
			end
		else
			
		end
	end
end



function monster:move()
	return true
end



function monster:translate(dt)

	self.dx = self.dx + self.ax * self.direction
	self.dx = self.dx*self.damping
	if math.abs(self.dx)<0.1 then self.dx = 0 end
	self.x = self.x + self.dx*60*dt
	self.dy = self.dy + self.ay
	if math.abs(self.dy)< 0.1 then self.dy = 0 end
	self.y = self.y + self.dy*60*dt
	self.onGround = false
	local ox,oy = self:getBumpData()
	local tx,ty ,cols = self.world:move(self,ox,oy,self.collidefilter)
	self:setPlayerPos(tx,ty)
	self:collision(cols)
	self:updateLight()
end

function monster:destroy()
	self.ax = 0
	self.dx = 0
	self.dead = true
	self.world:remove(self)
	self.destroyed = true 
	self.stage.cat.score = self.stage.cat.score  + self.price*self.stage.waveManager.waveCount*10
	for i = 1, self.price do
		Coin(self)
	end
	if love.math.random() < self.dropRate then
		Dropbox(self)
	end
end


function monster:getHit(who,damage)
	self.hp = self.hp - (damage or who.damage or 10)
	playSound("jumpDie")
	if self.hp < 0 then
		self.state:switch(self.state.current, self.state.stack["die"])
	else
		self.state:switch(self.state.current, self.state.stack["hurt"])
	end
end

function monster:attack()
end

function monster:update(dt)
	if not self.dead then
		self.attackTimer = self.attackTimer - dt
		self:translate(dt)
		self.state:update()
	end
	self.currentAnim:update(dt)
end

function monster:draw()
	if self.destroyed then return end
	
	love.graphics.setColor(255, 255, 255, 255)
	if self.flipX then
		self.currentAnim:draw(
			self.x + self.tw*self.scale/2+self.offx*self.scale,
			self.y-self.th*self.scale+self.offy*self.scale,
			0,-self.scale,self.scale)
	else
		self.currentAnim:draw(
			self.x - self.tw*self.scale/2-self.offx*self.scale,
			self.y-self.th*self.scale+self.offy*self.scale,
			0,self.scale,self.scale)
	end
	
	if self.stage.debug then
		love.graphics.circle("fill", self.x, self.y, 5)
		love.graphics.setLineWidth(1)
		love.graphics.rectangle("line", self:getBumpData())
		love.graphics.print(self.state.current.name, self.x-30,self.y-self.h-self.offy-20)
	end
end

return monster