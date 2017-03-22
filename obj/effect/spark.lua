local spark=class("spark")
local count = 15


function spark:init(bullet,col,y,rot)
	
	if type(col)=="table" then
		local norm = col.normal
		local pos = col.touch
		self.x,self.y=pos.x,pos.y
		self.rot = math.atan(norm.x/norm.y)
	else
		self.x = col
		self.y = y
		self.rot = rot
	end
	self.life=0.1
	self.damping = 0.8
	self.speed = 10

	self.sparkles = {}
	for i = 1, count do
		self:newSparkle()
	end
	self.stage = bullet.stage
	self.stage:addObject(self)
end

function spark:newSparkle()
	local sparkle = {
		x = self.x,
		y = self.y,
		color = {love.math.random(200,255),love.math.random(200,255),0, love.math.random(150,200)},
		rot = self.rot + 2*(0.5-love.math.random())
	}
	local speed = self.speed + self.speed*2*(0.5-love.math.random())/4
	sparkle.ox = sparkle.x
	sparkle.oy = sparkle.y
	sparkle.dx = speed * math.sin(sparkle.rot)
	sparkle.dy = -speed * math.cos(sparkle.rot)
	sparkle.life = self.life +self.life*2*(0.5-love.math.random())/4
	table.insert(self.sparkles,sparkle)
end


function spark:update(dt)
	if self.destroyed then return end
	
	for i = #self.sparkles ,1, -1 do
		local s = self.sparkles[i]
		s.life = s.life -dt
		if s.life<0 then
			table.remove(self.sparkles,i)
		else
			s.ox = s.x
			s.oy = s.y
			s.x = s.x + s.dx
			s.y = s.y + s.dy
		end
	end

	if not self.sparkles[1] then self.destroyed = true end
end



function spark:draw()
	love.graphics.setLineWidth(1)
	for i = #self.sparkles ,1, -1 do
		local s = self.sparkles[i]
		love.graphics.setColor(s.color)
		love.graphics.line(s.ox,s.oy,s.x,s.y)
	end
end

return spark