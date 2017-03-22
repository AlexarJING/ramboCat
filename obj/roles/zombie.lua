local base = require "obj/base"
local zombie = class("zombie",base)

local path = "res/anim/mon2.png"
zombie.stateData = require "obj/roles/mon1State"
zombie.animAtlas = love.graphics.newImage(path)

zombie.animData = {
	{"idle",1,1,4},
	{"walk",1,2,4},
	{"attack",1,3,4},
	{"hurt",1,4,3},
	{"die",4,4,5},
	{"transform",1,6,6},
	{"fly",6,6,2},
}

zombie.weapon = require "obj/weapon/unarm"	

function zombie:resetParameter()
	self.w = 16	
	self.h = 40
	self.offy = 4
	self.tw = 64
	self.th = 64
	self.ax = 0
	self.ay = 0.8
	self.speed = 1
	self.direction = 1
	self.scale = 1.5
	self.flipX = false
	self.isMonster = true
	self.hp = 50
	self.damage = 15
	self.price = 2
end

function zombie:move()
	self.ax = 0
	if self.state.current.name ~= "attack" then
		self.ax = 1
		return true
	else
		self.ax = 0
	end
end


function zombie.collidefilter(me,other)
	if other.isPlayer then
		return bump.Response_Cross
	elseif other.isMonster then
		return bump.Response_Cross
	elseif other.isWall then
		return bump.Response_Slide
	end
end


function zombie:collision(cols)
	for i,col in ipairs(cols) do
		local other = col.other
		if other.isWall then
			if col.normal.y == -1 then
				self.onGround = true
				self.dy = 0
			else
				self.direction = - self.direction
				self.flipX = not self.flipX
			end
		elseif other.isPlayer then
			self.attacking = true
			delay:new(0.2,function()self:attack()end)
		end
	end
end

function zombie:attack()
	if self.attackTimer > 0 then return end

	self.attackTimer = self.attackCD

	if self.flipX then
		self.dx = self.dx+self.weapon.recoil
	else
		self.dx = self.dx-self.weapon.recoil
	end
	self.weapon(self)

	return true

end

return zombie
