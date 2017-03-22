local base = require "obj/base"
local cat = class("cat",base)
local AttackZone = require "obj/weapon/unarm"
local path = "res/anim/cat_basic.png"
cat.stateData = require "obj/player/catUnarmedState"
cat.animAtlas = love.graphics.newImage(path)

cat.animData = {
	{"idle",1,1,4},
	{"walk",1,2,8},
	{"jumpStart",1,3,2},
	{"jumpAir",3,3,2},
	{"jumpEnd",5,3,4},
	{"spinStart",1,4,3},
	{"spinAir",4,4,4},
	{"spinEnd",8,4,3},
	{"spin",1,4,10},
	{"hurt",1,5,3},
	{"dead",1,5,7},
	{"getup",8,5,2},
	{"powerShotStart",1,6,3},
	{"powerShotCharge",4,6,2},
	{"powerShotEnd",6,6,2},
	{"powerShot",1,6,7},
	{"fastShotStart",1,7,4},
	{"fastShotEnd",5,7,2},
	{"fastShot",1,7,6},
	{"flyKickStart",1,8,5},
	{"flyKickAir",6,8,2},
	{"flyKickEnd",8,8,1},
	{"flyKick",1,8,8},
	{"uppercutStart",1,9,6},
	{"uppercutAir",7,9,2},
	{"uppercutEnd",9,9,4},
	{"upperCut",1,9,13},
	{"doublePunch",1,10,10},
	{"lowKick",1,11,6},
	{"midKick",7,11,6},
	{"highKick",1,12,6},
	{"downKick",1,13,8},
	{"twoPush",1,14,8},
	{"roundKick",1,15,8},
	{"upPunch",1,16,6}
}

cat.action ={
	["ddp"] = {name = "spin",dx = 30, dy = 0, delay = 0, last = 0.5, knockoff = 10},
	["sdp"] = {name = "powerShot",dx = 30, dy = 0, delay = 0, last = 0.5, knockoff = 10},
	["adp"] = {name = "fastShot",dx = 30, dy = 0, delay = 0, last = 0.5, knockoff = 10},
	["swp"] = {name = "upperCut",dx = 30, dy = 0, delay = 0, last = 0.5, knockoff = 10},
	[" wp"] = {name = "upPunch",dx = 30, dy = 0, delay = 0, last = 0.5, knockoff = 10},
	[" p"] = {name = "doublePunch",dx = 30, dy = 0, delay = 0, last = 0.5, knockoff = 10},
	["swk"] = {name = "flyKick",dx = 30, dy = 0, delay = 0, last = 0.5, knockoff = 10},
	[" sk"] = {name = "lowKick",dx = 30, dy = 0, delay = 0, last = 0.5, knockoff = 10},
	[" k"] = {name = "midKick",dx = 30, dy = 0, delay = 0, last = 0.5, knockoff = 10},
	["wk"] = {name = "highKick",dx = 30, dy = 0, delay = 0, last = 0.5, knockoff = 10},
	["wsk"] = {name = "downKick",dx = 30, dy = 0, delay = 0, last = 0.5, knockoff = 10},
	["sdk"] = {name = "roundKick",dx = 30, dy = 0, delay = 0, last = 0.5, knockoff = 10},
	[" pk"] = {name = "twoPush",dx = 30, dy = 0, delay = 0, last = 0.5, knockoff = 10},
}

function cat:resetParameter()
	self.ax = 0
	self.ay = 0.9
	self.scale = 2
	self.w = 13
	self.h = 30
	self.offy = 10
	self.offx = -1
	self.fireCD = 0.1
	self.fireTimer = 0.1
	self.isPlayer = true
	self.speed = 1.8
	self.weaponIndex = 1
	self.staminaCD = 2
	self.hp = 100
	self.hpMax = 100
	self.staminaTimer = 0
	self.money = 0
	self.score = 0
	self.selfHeal = 0
	self.inputCD = 0.3
	self.keyinput = {" "," "," "," "," "}
	self.keyAntiCount = 0
end

function cat:toggleFlashLight()
	if self.light then
		self.stage.light:remove(self.light)
		self.light = nil
	else	
		self.light = self.stage.light:newLight(self.x,self.y,255,255,255)
		self.light.angle = Pi/6
	end
end

function cat:updateLight()
	if not self.light then return end
	if self.flipX then
		self.light.x = self.x - 10
		self.light.direction = Pi
	else
		self.light.x = self.x + 10
		self.light.direction = 0
	end
	self.light.y = self.y - self.offy - self.h/2
end

function cat.collidefilter(me,other)
	if other.isPlayer then
		return bump.Response_Slide
	elseif other.isMonster then
		return bump.Response_Cross
	elseif other.isWall then
		return bump.Response_Slide
	end
end


function cat:collision(cols)
	for i,col in ipairs(cols) do
		local other = col.other
		if other.isWall then
			if col.normal.y == -1 then
				self.onGround = true
				self.dy = 0
			elseif col.normal.y == 1 then
				self.dy = 0
			end
		elseif other.isMonster then
			--self:getHit(other)
		end
	end
end


function cat:keyMove()
	local down = love.keyboard.isDown
	local ax
	if down("d") then 
		ax = self.speed
		self.flipX = false
		self.direction = 1
	elseif down("a") then
		ax = self.speed
		self.flipX = true
		self.direction = -1
	else
		ax = 0
	end
	self.ax = ax
	if self.stage.mouseDirection then
		if self.stage.cam:toWorld(love.mouse.getPosition()) > self.x then
			self.flipX = false
			--self.direction = 1
		else
			self.flipX = true
			--self.direction = -1
		end
	end
	return ax ~=0
end

function cat:keyJump()
	local down = love.keyboard.isDown
	if down("space") or down("k") then
		self.dy = -16
		playSound("catjump")
	end
	return down("space") or down("k")
end



function cat:keyAttack()
	local attack = ""
	if love.mouse.isDown(1) or love.keyboard.isDown("j") then
		attack = attack.."p"
	end
	if love.mouse.isDown(2) or love.keyboard.isDown("i") then
		attack = attack.."k"
	end
	if attack~="" then
		local len = #self.keyinput
		local k = self.keyinput
		local k3 = k[len-2]..k[len-1]..k[len]..attack
		local k2 = k[len-1]..k[len]..attack
		local k1 = k[len]..attack
		local action = self.action[k3] or self.action[k2] or self.action[k1]
		if action then 
			self:attack(action)
			
			self.keyAntiCount = self.inputCD
			self.keyinput = {" "," "," "," "," "}
			return true
		end
	
	end

end

function cat:attack(action)
	self.attackType = action.name 
	self.attacking = true
	self.attackZone = AttackZone(self)
	--self.stage.cam:shake(0.2,10)
end




function cat:getHit(who)
	if self.falldown then return end
	if self.rolling then return end
	if self.attacking then
		if self.flipX and who.x<self.x 
			or not self.flipX and who.x>self.x then
			return
		end
	end
	if true then return end
	if self.staminaTimer > 0 then return end
	local sound  = love.audio.newSource("res/sound/cathurt.wav")
	sound:play()
	self.hp = self.hp - who.damage

	if self.hp>0 then
		--hurt
		self.staminaTimer = self.staminaCD
		if who.x>self.x then
			self.dx = -50
		else
			self.dx = 50
		end
	else
		self.hp = 0
		self.dx = 0
		self.ax = 0
		self.state:switch(self.state.current, self.state.stack["die"])
		self.stage.credits = self.stage.credits - 1
		if self.stage.credits<0 then
			self.stage.pause = true
			gooi.alert("Game Over!",function() love.event.quit() end)
		else
			delay:new(3,function()
				self.falldown = false
				self.hp = self.hpMax
				self.staminaTimer = self.staminaCD
				self.state:switch(self.state.current, self.state.stack["idle"])
			end)
		end
	end
end




function cat:inputControl(dt)
	local down = love.keyboard.isDown
	local key 
	if down("w") then
		key = "w"
	elseif down("s") then
		key = "s"
	elseif down("d") then		
		if self.inputflipX then
			key = "a"
		else
			key = "d"
		end
	elseif down("a") then		
		if self.inputflipX then
			key = "d"
		else
			key = "a"
		end
	end
	if key and self.keyinput[#self.keyinput]~=key then
		self.keyAntiCount = self.inputCD
		table.insert(self.keyinput,key)
	end


	self.keyAntiCount = self.keyAntiCount - dt
	if #self.keyinput>5 then table.remove(self.keyinput,1) end
	if self.keyAntiCount<0 then
		self.inputflipX = self.flipX
		table.insert(self.keyinput," ")
		self.keyAntiCount = self.inputCD
	end
end



function cat:update(dt)
	self.hp = self.hp + self.selfHeal*dt
	if self.hp> self.hpMax then self.hp = self.hpMax end
	self.fireTimer = self.fireTimer - dt
	self.staminaTimer = self.staminaTimer - dt
	self:inputControl(dt)
	self:translate(dt)
	self:updateLight()
	self.state:update()
	self.currentAnim:update(dt)
end

function cat:draw()
	if self.destroyed then return end
	if self.staminaTimer>0 then	
		love.graphics.setColor(255, 255,255, 255*math.sin(love.timer.getTime()*100))
	else
		love.graphics.setColor(255, 255, 255, 255)	
	end
	
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

	love.graphics.setLineWidth(1)
	love.graphics.setColor(50, 255, 50, 255)
	love.graphics.rectangle("fill", 
		self.x-15, 
		self.y - 70,
		30*(self.hp/self.hpMax), 5)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle("line", 
		self.x-15, 
		self.y - 70,
		30, 5)

	if self.stage.debug then
		love.graphics.circle("fill", self.x, self.y, 5)
		love.graphics.setLineWidth(1)
		love.graphics.rectangle("line", self:getBumpData())
		love.graphics.print(self.state.current.name, self.x-15,self.y-self.h-self.offy-50)
	end
	
end

return cat