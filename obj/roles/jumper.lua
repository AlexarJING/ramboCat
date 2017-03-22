local base = require "obj/base"
local jumper = class("jumper",base)

local path = "res/anim/mon1.png"
jumper.stateData = require "obj/roles/mon1State"
jumper.animAtlas = love.graphics.newImage(path)

jumper.animData = {
	{"idle",1,1,4},
	{"walk",1,2,5},
	{"attack",1,3,6},
	{"hurt",2,4,2},
	{"die",4,4,5},
	{"jumpStart",1,6,5},
	{"jumpAir",6,6,2},
	{"jumpEnd",6,7,2},
}


function jumper:resetParameter()
	self.w = 20
	self.h = 20
	self.offy = 11
	self.tw = 64
	self.th = 64
	self.ax = 1
	self.ay = 0.8
	self.speed = 1
	self.direction = 1
	self.scale = 1.5
	self.flipX = false
	self.isMonster = true
	self.hp = 30
	self.damage = 10
	self.price = 4
end

function jumper.collidefilter(me,other)
	if other.isPlayer then
		return bump.Response_Cross
	elseif other.isMonster then
		return bump.Response_Cross
	elseif other.isWall then
		return bump.Response_Bounce
	end
end


function jumper:collision(cols)
	for i,col in ipairs(cols) do
		local other = col.other
		if other.isWall then
			if col.normal.y == -1 then
				self.onGround = true
				self.dy = -15
			elseif col.normal.x ~= 0 then
				self.direction = - self.direction
				self.flipX = not self.flipX
			end
		else
			
		end
	end
end

return jumper