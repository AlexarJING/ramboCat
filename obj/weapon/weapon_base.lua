local bullet = class("weapon_base")
bullet.Spark = require "obj/effect/spark"
bullet.Blood = require "obj/effect/blood"

local color = {255,255,255}
function bullet:init(obj,pBullet)
	if obj.flipX then
		self.x = obj.x - 30
		self.rot = -Pi/2
	else
		self.x = obj.x + 30
		self.rot = Pi/2
	end
	self.dx = 0
	self.dy = 0
	self.ax = 0
	self.ay = 0
	self.y = obj.y - obj.offy - obj.h/2
	self.w = 5
	self.h = 5
	self.damping = 1
	self.parent = obj
	self.stage = obj.stage
	self.stage:addObject(self)
	self.world = self.stage.world
	self.isBullet = true
	self.enableLight = true
	--self.rot = self.rot + self.rot*2*(0.5-love.math.random())/16
	self.life = 30
	self.flashColor = {255,255,255}
	self:setup(pBullet)
end


function bullet:setup(p)
	if p then
		self.x = p.x
		self.y = p.y
		self.rot = p.rot
	end
	self:resetParameter()
	self:initLight()
	self:initBump()
	self.ox = self.x
	self.oy = self.y
	self.dx = self.dx + self.speed*math.sin(self.rot)
	self.dy = self.dy -self.speed*math.cos(self.rot)
end

function bullet:initLight()
	if self.stage.enableLight and self.enableLight then
		local l = self.stage.light:newLight(self.x,self.y,unpack(self.flashColor))
		delay:new(0.03,function() self.stage.light:remove(l) end)
		self.light = self.stage.light:newLight(self.x,self.y,unpack(self.flashColor))
		self.light.range = 500
	end
end

function bullet:resetParameter()
	
end

function bullet:initBump()
	self.world:add(self,self.x-self.w/2,self.y-self.h/2,self.w,self.h)
end

function bullet.collisionfilter(me,other)
	return bump.Response_Cross
end

function bullet:destroy()
	self.destroyed = true
	if self.light then
		self.stage.light:remove(self.light)
	end
	if self.enableLight then
		local str = 3
		self.stage.light.post_shader:addEffect("sine_warp",
			function()
				local light = self.stage.light 
				local l = light.l
				local t = light.t
				local s = light.s
				local x = (self.x + l/s) * s
				local y = (self.y + t/s) * s
				str = str - 0.1
				return {
				offset = {x/self.stage.w,y/self.stage.h},
				strength = str,
				time = love.timer.getTime()
			}
			end
		)
		delay:new(0.2,function()
			self.stage.light.post_shader:removeEffect("sine_warp")
			end )
	end
	--[[
	if self.stage.enableLight and self.enableLight then
		local l = self.stage.light:newLight(self.x,self.y,unpack(self.flashColor))
		delay:new(0.3,function() self.stage.light:remove(l) end)
	end]]
	self.world:remove(self)
end

function bullet:collision(cols)
	for i,col in ipairs(cols) do
		local other = col.other
		if other.isWall then
			self.Spark(self,col)
			self:destroy()
			return
		elseif other.isMonster then
			self.Blood(self,col)
			other.dx = -col.normal.x*self.knockoff
			other:getHit(self.parent,self.damage)
			self:destroy()
			return
		end
	end
	
end


function bullet:update(dt)
	if self.destroyed then return end
	self.life = self.life - dt
	if self.life < 0 then return self:destroy() end
	self.dx = self.dx + self.ax
	self.dy = self.dy + self.ay
	self.ox = self.x
	self.oy = self.y
	self.dx = self.dx * self.damping
	self.dy = self.dy * self.damping

	self.x = self.x + self.dx*60*dt
	self.y = self.y + self.dy*60*dt
	if self.light then
		self.light.x = self.x
		self.light.y = self.y
	end
	self.x,self.y,cols = self.world:move(self,self.x-self.h/2,self.y-self.w/2,self.collisionfilter)
	self.x = self.x + self.w/2
	self.y = self.y + self.h/2
	self:collision(cols)
end

function bullet:draw()
	love.graphics.setColor(255, 255, 0, 255)
	love.graphics.setLineWidth(10)
	love.graphics.line(self.x, self.y,self.ox, self.oy)
end

return bullet