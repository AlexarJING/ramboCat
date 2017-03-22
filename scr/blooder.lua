local bloody = {}

function bloody:init()
	self.canvas = love.graphics.newCanvas()
	self.accum = love.graphics.newCanvas()
end

function bloody:resetCanvas(w,h)
	self.canvas = love.graphics.newCanvas(w,h)
	self.accum = love.graphics.newCanvas(w,h)
end


function bloody:addBlood(func)	
	love.graphics.setCanvas(self.accum)
	func()
	love.graphics.setCanvas()
end

local code = [[
void effects(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 tcolor = Texel(texture,texture_coords);
    tcolor.a -= 0.005;
    tcolor.a = max(0,tcolor.a);
    love_Canvases[0] = tcolor;
}
]]
local shader = love.graphics.newShader(code)

function bloody:update()
	love.graphics.setCanvas(self.canvas)
	love.graphics.setBlendMode("replace","premultiplied")
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(self.accum)
	love.graphics.setBlendMode("alpha")
	love.graphics.setCanvas()

	love.graphics.setCanvas(self.accum)
	love.graphics.setBlendMode("alpha")
	love.graphics.clear(50,0,0,0)
	love.graphics.setShader(shader)
	love.graphics.draw(self.canvas,0,0.1)
	love.graphics.setBlendMode("alpha")
	love.graphics.setShader()
	
	love.graphics.setCanvas()

end

function bloody:draw()
	love.graphics.setBlendMode("alpha")
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(self.accum)
	love.graphics.setBlendMode("alpha")
end


return bloody