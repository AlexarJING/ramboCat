local base = require "obj/weapon/weapon_base"
local gFrag = require "obj/weapon/grenadeFrag"
local gun = class("grenade",base)
gun.fireRate = 1
gun.damage = 0
gun.magazineSize = 7
gun.reloadTime = 1
gun.knockoff = 0
gun.recoil = 0
gun.antiCount =2.5


function gun:resetParameter()
	if self.rot > 0 then
		self.rot = self.rot - Pi/4
	else
		self.rot = self.rot + Pi/4
	end
	self.x = self.parent.x
	self.y = self.parent.y - self.parent.h - self.parent.offy
	self.ay = 0.7
	self.speed = 10
	self.changeTimer = 0
	self.fragCount = 30
	self.name = "grenade"

end

function gun:collision(cols)
	for i,col in ipairs(cols) do
		local other = col.other
		if other.isWall then
			if col.normal.y~=0 then
				self.dy = -self.dy/2
				self.dx = self.dx/2
			else
				self.dx = -self.dx/2
				self.dy = self.dy/2
			end
		end
	end
end

function gun.collisionfilter(me,other)
	if other.isWall then return bump.Response_Slide end
	return bump.Response_Cross
end

function gun:explosion()
	for i = 1,self.fragCount do
		local f = gFrag(self.parent,self)
		f.x = self.x
		f.y = self.y
	end
	local l = self.stage.light:newLight(self.x,self.y,unpack(self.flashColor))
	delay:new(0.3,function() self.stage.light:remove(l) end)
	playSound("grenade")
	self.stage.cam:shake(0.3,20)
	self:destroy()
end

local colorRed = {255,0,0,255}
local colorWhite = {255,255,255,255}

function gun:draw()
	if math.abs(self.dy) < 0.01 then
		self.ay = 0
		self.dy = 0
		self.dx = 0
	end
	self.antiCount = self.antiCount - love.timer.getDelta()
	if self.antiCount<0 and not self.destroyed then
		self:explosion()
	end

	self.changeTimer = self.changeTimer - love.timer.getDelta()
	if self.changeTimer<0 then
		self.color = self.color == colorRed and colorWhite or colorRed
		self.changeTimer = self.antiCount/20
	end
	love.graphics.setColor(self.color)
	love.graphics.circle("fill", self.x, self.y, 5)
end

return gun