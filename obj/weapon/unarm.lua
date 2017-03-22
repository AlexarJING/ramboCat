local base = require "obj/weapon/weapon_base"
local gun = class("unarmed",base)

gun.reloadTime = 2
gun.fireRate = 99
gun.damage = 20
gun.knockoff = 30
gun.recoil = 1
gun.accuracy = 15
function gun:resetParameter()
	self.speed = 0
	self.name = "unarmed"
	self.life = 0.08
	self.w = 30
	self.h = 30
	self.enableLight =false
	--self.flashColor = {255,100,0}
end

function gun:collision(cols)
	for i,col in ipairs(cols) do
		local other = col.other	
		if other.isMonster and self.parent.isPlayer then
			self.Blood(self,col)
			other.dx = -col.normal.x*self.knockoff
			other:getHit(self.parent,self.damage)
		elseif other.isPlayer and self.parent.isMonster then 
			self.Blood(self,col)
			other.dx = col.normal.x*self.knockoff
			other:getHit(self.parent,self.damage)
		end
	end
end

function gun:draw()
	--[[
	love.graphics.setColor(255, 255, 0, 255)
	love.graphics.setLineWidth(1)
	love.graphics.rectangle("line", self.x-self.w/2,self.y-self.h/2,self.w,self.h)]]
end

return gun