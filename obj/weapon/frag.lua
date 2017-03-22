local base = require "obj/weapon/weapon_base"
local frag = class("frag",base)


frag.fireRate = 1
frag.damage = 10
frag.magazineSize = 1
frag.reloadTime = 1
frag.knockoff = 20
frag.speed = 13

function frag:resetParameter()
	self.life = 0.5
	self.damping = 0.9
	self.rot = self.rot + (0.5-love.math.random())
	self.speed = self.speed + self.speed * (0.5-love.math.random())*0.5
	self.enableLight = false
	self.color = {love.math.random(200,255),love.math.random(200,255),love.math.random(0,200)}
end

function frag:draw()
	local r,g,b = unpack(self.color)
	love.graphics.setColor(r,g,b,200)
	love.graphics.rectangle("fill", self.x-2, self.y-2, 4, 4)
	love.graphics.setColor(r,g,b,100)
	love.graphics.rectangle("fill", self.ox-1, self.oy-1, 2, 2)
end

function frag.collisionfilter(me,other)
	if other.isWall then return bump.Response_Bounce end
	return bump.Response_Cross
end

function frag:collision(cols)
	for i,col in ipairs(cols) do
		local other = col.other
		if other.isWall then
			if col.normal.y~=0 then
				self.dy = -self.dy
			else
				self.dx = -self.dx
			end
		elseif other.isMonster then
			self.Blood(self,col)
			other.dx = -col.normal.x*self.knockoff
			other:getHit(self.parent,self.damage)
			self:destroy()
			return
		end
	end
	
end

return frag