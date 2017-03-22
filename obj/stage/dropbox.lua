local base = require "obj/weapon/weapon_base"

local gun = class("dropbox",base)
gun.fireRate = 1
gun.damage = 0
gun.magazineSize = 7
gun.reloadTime = 1
gun.knockoff = 0
gun.recoil = 0

function gun:resetParameter()
	self.rot = 0
	self.x = self.parent.x
	self.y = self.parent.y - 35
	self.w = 30
	self.h = 30
	self.ay = 0.8
	self.speed = 5
	self.dy = -2-2*love.math.random()
	self.dx = (0.5- love.math.random())*5
	self.life = 1/0
	self.enableLight = false
	self:setType()
end
--[[
cat.weapons = {
	{gun = Pistol, count = 1/0 },
	{gun = MachineGun, count = 100},
	{gun = SnipeRifle, count = 0},
	{gun = ShotGun, count = 0},
	{gun = Grenade,count = 0}
}
]]

local boxes = {
	M = {"Machinegun +100" ,function(stage,cat) cat.weapons[2].count = cat.weapons[2].count + 100 end },
	S = {"Shotgun + 20",function(stage,cat) cat.weapons[4].count = cat.weapons[4].count + 20 end },
	R = {"Sniperifle + 10",function(stage,cat) cat.weapons[3].count = cat.weapons[3].count + 10 end},
	G = {"Grenade + 5",function(stage,cat) cat.weapons[5].count = cat.weapons[5].count + 5 end},
	H = {"HP full recovered",function(stage,cat) cat.hp = cat.hpMax end},
	I = {"Infinity Bullets +20",function(stage,cat) cat.infAmmo=true;delay:new(20,function()cat.infAmmo = false end)end}
}

local choose = {"M","S","G","H","R"}

function gun:setType()
	self.boxType = table.random(choose)
	self.pickMessage = boxes[self.boxType][1]
	self.pickFunc = boxes[self.boxType][2]
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
		elseif other.isPlayer then
			self.stage:newMessage(self.pickMessage)
			self.pickFunc(self.stage,self.stage.cat)
			self.stage.cam:shake(0.2,10)
			playSound("getitem")
			self:destroy()
		end
	end
end

function gun.collisionfilter(me,other)
	if other.isWall then return bump.Response_Slide end
	return bump.Response_Cross
end

local rect = {-1,0.3,1,0.3,1,-0.3,-1,-0.3}

function gun:draw()
	love.graphics.setLineWidth(3)
	love.graphics.setColor(100,100,255,255)
	love.graphics.rectangle("fill", self.x-self.w/2,self.y-self.h/2,self.w,self.h)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle("line", self.x-self.w/2,self.y-self.h/2,self.w,self.h)
	love.graphics.print(self.boxType, self.x-9,self.y-15,0,2,2)
end

return gun


