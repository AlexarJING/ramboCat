local base = require "obj/weapon/weapon_base"
local gun = class("machinegun",base)

gun.magazineSize = 100
gun.reloadTime = 2
gun.fireRate = 10
gun.damage = 10
gun.knockoff = 2
gun.recoil = 1
gun.accuracy = 8

function gun:resetParameter()
	self.rot = self.rot + self.rot*2*(0.5-love.math.random())/self.accuracy
	self.speed = 15
	self.name = "machine gun"
	playSound("machinegun")
end


return gun