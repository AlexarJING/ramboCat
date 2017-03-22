local base = require "obj/weapon/weapon_base"

local gun = class("coin",base)
gun.fireRate = 1
gun.damage = 0
gun.magazineSize = 7
gun.reloadTime = 1
gun.knockoff = 0
gun.recoil = 0
local img  = love.graphics.newImage("res/anim/coins.png")
--function animation:init(img,fx,fy,w,h,offx,offy,lx,ly,delay,count) 

function gun:resetParameter()
	self.rot = 0
	self.x = self.parent.x
	self.y = self.parent.y - 10
	self.w = 16
	self.h = 16
	self.ay = 0.8
	self.speed = 5
	self.dy = -2 -2*love.math.random()
	self.dx = (0.5- love.math.random())*5
	self.life = 10
	self.anim = animation(img,0,0,32,32,0,0,287,31,1/10)
	self.enableLight= false
	self.alpha = 255
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
	G = {"Sniperifle + 5",function(stage,cat) cat.weapons[5].count = cat.weapons[5].count + 5 end},
	H = {"HP full recovered",function(stage,cat) cat.hp = cat.hpMax end},
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
			self.stage.cat.money = self.stage.cat.money + love.math.random(1,5)
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
	self.alpha = self.alpha - 1/self.life
	love.graphics.setColor(255, 255, 255, self.alpha)
	self.anim:update(love.timer.getDelta())
	self.anim:draw(self.x - self.w,self.y- self.h)
end	

return gun