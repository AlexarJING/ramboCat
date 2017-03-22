local base = require "obj/weapon/weapon_base"
local gun = class("pistol",base)

gun.magazineSize = 100
gun.reloadTime = 2
gun.fireRate = 3
gun.damage = 12
gun.knockoff = 1
gun.recoil = 1
gun.accuracy = 15
function gun:resetParameter()
	self.rot = self.rot + self.rot*2*(0.5-love.math.random())/self.accuracy
	self.speed = 15
	self.name = "pistol"
	playSound("pistol")
end

function gun:draw()
	love.graphics.setColor(255, 255, 0, 255)
	love.graphics.setLineWidth(5)
	love.graphics.line(self.x, self.y,self.ox, self.oy)
	love.graphics.circle("fill", self.x,self.y,3)
end

return gun