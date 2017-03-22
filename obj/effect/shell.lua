local base = require "obj/weapon/weapon_base"

local gun = class("shell",base)
gun.fireRate = 1
gun.damage = 0
gun.magazineSize = 7
gun.reloadTime = 1
gun.knockoff = 0
gun.recoil = 0

function gun:resetParameter()
	if self.rot > 0 then
		self.rot = -self.rot +Pi/4
	else
		self.rot = -self.rot - Pi/4
	end
	self.x = self.parent.x
	self.y = self.parent.y - self.parent.h - self.parent.offy
	self.ay = 0.7
	self.speed = 10
	--self.damping = 0.95
	self.antiCount = 3
	self.changeTimer = 0
	self.fragCount = 30
	self.srot = love.math.random()*10
	self.life = 2
	self.enableLight = false
end

function gun:collision(cols)
	for i,col in ipairs(cols) do
		local other = col.other
		if other.isWall then
			if col.normal.y~=0 then
				self.dy = math.percentOffset(-self.dy*0.5,0.5)
				self.dx = math.percentOffset(self.dx*0.5,0.5)
			else
				self.dy = math.percentOffset(self.dy*0.5,0.5)
				self.dx = math.percentOffset(-self.dx*0.5,0.5)
			end
		end
	end
end

function gun.collisionfilter(me,other)
	if other.isWall then return bump.Response_Slide end
	return bump.Response_Cross
end

local rect = {-1,0.3,1,0.3,1,-0.3,-1,-0.3}

function gun:draw()
	love.graphics.setLineWidth(1)
	love.graphics.setColor(255,255,0,255)
	self.srot = self.srot + love.timer.getDelta()*self.life
	love.graphics.polygon("fill", math.polygonTrans(self.x,self.y,self.srot,5,rect))
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.polygon("line", math.polygonTrans(self.x,self.y,self.srot,5,rect))
end

return gun