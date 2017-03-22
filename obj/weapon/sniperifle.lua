local base = require "obj/weapon/weapon_base"
local gun = class("sniperifle",base)
gun.fireRate = 1
gun.damage = 50
gun.magazineSize = 7
gun.reloadTime = 1
gun.knockoff = 10
gun.recoil = 25


function gun:resetParameter()
	self.rot = self.rot
	self.speed = 40
	self.stage.cam:shake(0.2,10)
	self.w = 50
	self.h = 50
    self.ix,self.iy = self.x,self.y
    self.name = "sniper rifle"
    playSound("rifle")
end

function gun:collision(cols)
	for i,col in ipairs(cols) do
		local other = col.other
		if other.isWall then
			self.Spark(self,col)
			self:destroy()
			break
		elseif other.isMonster then
			--Spark(self,col)
			self.Blood(self,col)
			other.dx = -col.normal.x*self.knockoff
			other:getHit(self.parent,self.damage)
		end
	end
end



function gun:draw()
	if self.x > self.ix then
		for x = self.x , self.ix, -1 do
			if (self.x -x) >255 then break end
			love.graphics.setColor(255, 255, 0, 255-(self.x-x))
			love.graphics.rectangle("fill", x, self.y, 1, 5)
		end
	else
		for x = self.x , self.ix, 1 do
			if (x - self.x) >255 then break end
			love.graphics.setColor(255, 255, 0, 255-(x - self.x))
			love.graphics.rectangle("fill", x, self.y, 1, 5)
		end
	end

	love.graphics.setLineWidth(2)
	love.graphics.setColor(255, 255, 0, 155)
	love.graphics.ellipse( "line", self.x, self.y+2.5, 3, 6 )
	love.graphics.setColor(255, 255, 0, 100)
	love.graphics.ellipse( "line", self.ox, self.oy+2.5, 3, 6 )

end

return gun