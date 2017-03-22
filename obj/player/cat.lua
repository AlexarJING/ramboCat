local base = require "obj/base"
local cat = class("cat",base)
local MachineGun = require "obj/weapon/machinegun"
local SnipeRifle = require "obj/weapon/sniperifle"
local ShotGun = require "obj/weapon/shotgun"
local Grenade = require "obj/weapon/grenade"
local Pistol = require "obj/weapon/pistol"
local Shell = require "obj/effect/shell"

cat.weapons = {
	{gun = Pistol, count = 1/0 },
	{gun = MachineGun, count = 100},
	{gun = SnipeRifle, count = 10},
	{gun = ShotGun, count = 20},
	{gun = Grenade,count = 5}
}

cat.Pistol = Pistol
cat.Grenade =Grenade
cat.Machinegun = MachineGun
cat.SnipeRifle =SnipeRifle
cat.ShotGun =ShotGun
cat.ShotGunFrag = require "obj/weapon/frag"
cat.GrenadeFrag = require "obj/weapon/grenadeFrag"

local path = "res/anim/cat_gun.png"
cat.stateData = require "obj/player/catState"
cat.animAtlas = love.graphics.newImage(path)

cat.animData = {
	{"gunoff",1,1,4},
	{"idle",1,2,8},
	{"standfire",1,3,8,},
	{"walk",1,4,8},
	{"walkfire",1,5,8},
	{"jumpStart",1,6,4},
	{"jumpAir",5,6,2},
	{"jumpEnd",7,6,3},
	{"jumpFire",5,7,2},
	{"roll",1,8,4},
	{"down" ,1,9,7},
	{"getup",8,9,2},
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
	self:changeWeapon(0)
	self.money = 0
	self.score = 0
	self.selfHeal = 0
	
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
		return bump.Response_Cross
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

function cat:keyRoll()
	local down = love.keyboard.isDown
	local dx
	if down("e") then 
		dx = self.speed * 20
	elseif down("q") then
		dx = -self.speed * 20
	end
	if dx then 
		self.dx = dx 
		local sound = love.audio.newSource("res/sound/catjump.wav")
		sound:play()
	end
	return dx
end


function cat:keyFire()
	if love.mouse.isDown(1) or love.keyboard.isDown("j") then
		return self:fire()
	end

	if love.mouse.isDown(2) or love.keyboard.isDown("i") then
		return self:grenade()
	end
end


function cat:grenade()

	if self.fireTimer > 0 then return end
	local g = self.weapons[5]
	if g.count == 0 then return end
	g.count=g.count-1

	self.fireTimer = 0.5

	if self.flipX then
		self.dx = self.dx+g.gun.recoil
	else
		self.dx = self.dx-g.gun.recoil
	end
	
	g.gun(self)
	return true
end


function cat:fire(t)
	if self.stage.enableMenu then return end
	if self.fireTimer > 0 then return end
	if not self.infAmmo then
		if self.currentWeapon.count == 0 then return end
		self.currentWeapon.count=self.currentWeapon.count-1
	end
	Shell(self)
	self.fireTimer = self.fireCD

	if self.flipX then
		self.dx = self.dx+self.currentWeapon.gun.recoil
	else
		self.dx = self.dx-self.currentWeapon.gun.recoil
	end
	
	self.currentWeapon.gun(self)

	return true
end

function cat:changeWeapon(dx)
	--if self.reloading then return end

	self.weaponIndex = self.weaponIndex+dx
	

	if self.weaponIndex>= 5 then self.weaponIndex = 1 end
	if self.weaponIndex<1 then self.weaponIndex = 4 end
	self.currentWeapon = self.weapons[self.weaponIndex]
	self.fireCD = 1/self.currentWeapon.gun.fireRate
	self.fireTimer = self.fireCD
end

function cat:setWeapon(dx)
	self.weaponIndex = dx
	if not self.weapons[self.weaponIndex] then self.weaponIndex = 1 end
	self.currentWeapon = self.weapons[self.weaponIndex]
	self.fireCD = 1/self.currentWeapon.gun.fireRate
	self.fireTimer = self.fireCD
end

function cat:getHit(who,damage)
	if self.falldown then return end
	if self.rolling then return end
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

function cat:update(dt)
	self.hp = self.hp + self.selfHeal*dt
	if self.hp> self.hpMax then self.hp = self.hpMax end
	self.fireTimer = self.fireTimer - dt
	self.staminaTimer = self.staminaTimer - dt
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