local base = require "obj/base"
local flyer = class("flyer",base)

local path = "res/anim/mon3.png"
flyer.stateData = require "obj/roles/mon1State"
flyer.animAtlas = love.graphics.newImage(path)

flyer.animData = {
	{"idle",1,1,5},
	{"walk",1,1,5},
	{"attack",1,2,5},
	{"hurt",1,3,2},
	{"die",4,3,5},
}

	

function flyer:resetParameter()
	self.w = 20
	self.h = 25
	self.offy = 15
	self.tw = 64
	self.th = 64
	self.ax = 1
	self.ay = 0
	self.speed = 1
	self.direction = 1
	self.scale = 1.5
	self.flipX = false
	self.isMonster = true
	self.hp = 30
	self.damage = 10
	self.price = 3
end

function flyer.collidefilter(me,other)
	if other.isPlayer then
		return bump.Response_Cross
	elseif other.isMonster then
		return bump.Response_Cross
	elseif other.isWall then
		return bump.Response_Slide
	end
end


function flyer:collision(cols)
	for i,col in ipairs(cols) do
		local other = col.other
		if other.isWall then
			if col.normal.y == -1 then
				--self.onGround = true
				--self.dy = 0
			elseif col.normal.x~=0 then
				self.direction = - self.direction
				self.flipX = not self.flipX
			end
		else
			
		end
	end
end

function flyer:toPlayer()
	local cat = self.stage.cat
	self.ay = 0
	if self.y > cat.y then
		if self.y - (cat.y-cat.offy-cat.h) > 50 then
			self.dy = -0.2
		end
	else
		if (cat.y-cat.offy-cat.h) - self.y > 50 then
			self.dy = 0.2
		end
	end

end


local timer = 0
function flyer:update(dt)
	timer = timer + dt*10
	if not self.dead then
		self:toPlayer()
		self.ay = math.sin(timer)*0.5
		self.state:update()
		self:translate(dt)
	end
	self.currentAnim:update(dt)
end

return flyer
