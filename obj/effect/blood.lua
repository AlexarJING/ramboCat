local blood = class("blood")
local bloodSize =  10
local power = 10
local speed = 20

function blood:init(bullet,col)
	local pos = col.touch
	local norm = col.normal
	self.x,self.y = bullet.x,bullet.y
	self.rot = bullet.rot
	self.drops = {}
	self.damping = 0.85
	self.ay = 0.5
	self.ax = 0
	self.colorFading = 0
	self.speed = speed
	self.life = 0.2
	self.stage = bullet.stage
	self.world = bullet.stage.world
	for i = 1, power do
		self:newDrop()
	end

	self.stage = bullet.stage
	self.stage:addObject(self)
end

function blood:newDrop()
	local drop = {
		x = self.x,
		y = self.y,
		rot = self.rot,
		speed = self.speed,
		life = self.life,
		color = {love.math.random(50,255),0,0, love.math.random(150,200)}
	}
	drop.speed = drop.speed+ drop.speed*2*(0.5-love.math.random())/2 --(+- 1/2)
	drop.rot = drop.rot + (0.5-love.math.random())*2
	drop.dx = speed*math.sin(drop.rot)
	drop.dy = -speed*math.cos(drop.rot)
	drop.life = drop.life + drop.life*2*(0.5-love.math.random())/2
	--drop.body = self.world:add(drop,drop.x,drop.y,bloodSize,bloodSize)
	table.insert(self.drops,drop)
end

function blood.filter(me,other)
	if other.isWall then return bump.Response_Touch end
	return bump.Response_Cross
end

function blood:collision(drop,cols)
	for i,col in ipairs(cols) do
		local other = col.other
		if other.isWall then
			if col.normal.y == -1 then
				self.dx = 0
				self.dy = 0
			else
				self.ay = 0.1
				self.dx = 0
			end
		end
	end
end

function blood:update(dt)
	local allDead = true
	local ax = self.ax
	local ay = self.ay
	local damping = self.damping
	local colorFading = self.colorFading

	for i,drop in ipairs(self.drops) do
		if drop.dead then
			--pass
		else
			drop.dx = drop.dx + ax
			drop.dy = drop.dy +ay
			drop.dx = drop.dx*damping
			drop.dy = drop.dy*damping
			drop.x = drop.x + drop.dx
			drop.y = drop.y + drop.dy
			--local cols
			--drop.x , drop.y , cols= self.world:move(drop,drop.x,drop.y,self.filter)
			--self:collision(drop,cols)

			drop.color[4] = drop.color[4] - colorFading
			drop.life = drop.life -dt
			if drop.life<0 then
				drop.dead = true
				--self.world:remove(drop)
			else
				allDead = false
			end
		end
	end

	blooder:addBlood(function()
		self:draw()
	end)
	if allDead then self.destroyed = true end
end

function blood:draw()
	
	for i,drop in ipairs(self.drops) do
		if drop.dead then
			--pass
		else
			love.graphics.setColor(drop.color)
			love.graphics.rectangle("fill", drop.x, drop.y, bloodSize, bloodSize)
		end
	end

end


return blood