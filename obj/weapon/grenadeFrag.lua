local shotFrag = require "obj/weapon/frag"
local gFrag = class("grenadeFrag",shotFrag)
gFrag.speed = 15

function gFrag:resetParameter()
	self.life = 0.5
	self.speed = 20
	self.damping = 0.9
	self.rot = love.math.random()*Pi*2
	self.speed = self.speed + (0.5-love.math.random())*10
	self.damage = 50
	self.enableLight = false
	self.color = {love.math.random(200,255),love.math.random(200,255),love.math.random(0,200)}
end

function gFrag:collision(cols)
	for i,col in ipairs(cols) do
		local other = col.other
		if other.isWall then
			--self.Spark(self,col)
			if col.normal.y~=0 then
				self.dy = -self.dy
			else
				self.dx = -self.dx
			end

		elseif other.isMonster then
			self.Blood(self,col)
			other.dx = -col.normal.x*self.knockoff
			other:getHit(self.parent,self.damage)
			--self:destroy()
			return
		end
	end
	
end

return gFrag