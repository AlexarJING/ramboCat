local base = require "obj/weapon/weapon_base"
local shotFrag = require "obj/weapon/frag"

local gun = class("shotgun",base)
gun.fireRate = 3
gun.damage = 0
gun.magazineSize = 7
gun.reloadTime = 1
gun.knockoff = 10
gun.fragCount = 30
gun.recoil = 15

local Spark = require "obj/effect/spark"
function gun:resetParameter()
	self.rot = self.rot
	self.speed = 0
	self.life = 0.3
	self.stage.cam:shake(0.2,15)
	Spark(self,self.x,self.y,self.rot)
	for i = 1 , self.fragCount do
		shotFrag(self.parent)	
	end
	self.name = "shot gun"
	playSound("shot")
end

return gun