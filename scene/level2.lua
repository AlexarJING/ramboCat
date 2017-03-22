local scene = gamestate.new()
local Cat = require "obj/player/cat"
local Cat2 = require "obj/player/cat_unarmed"
local Mon1 = require "obj/roles/jumper"
local Mon2 = require "obj/roles/zombie"
local Mon3 = require "obj/roles/flyer"
local waveManager = require ("scr/waveManager")
local menu = require "scr/menu"
local monsters = {Mon1,Mon2,Mon3}

function scene:enter(from,screenshot,how,cx,cy)
	self.name = "level2"
	self.enableLight = true
	self.debug = false
	self.scale = 2

	self.addMonTimer = 0
	self.addMonCD = 5

	self:initMap()
	self:initLight()

	self:initMonsterEntries()
	self.waveManager = waveManager
	self.waveManager:init(self)

	--self.cat = Cat(self,500,400)
	self.cat = Cat(self,500,400)
	self.monsters = {}
	self.objects = {}
	self.messageTimer = -1
	self.credits = 3

	self:setGlobalScale(2,640,360)
	self.enableMenu = false
	self.menu =  menu:init(self)
	self.pause = false
	playSound("bg2")
	if screenshot then
		self:fade(screenshot,how,cx,cy)
	end
end 

function scene:initMap()
	
	self.map = sti("res/tile/map3.lua", { "bump","light" })
	self.world = bump.newWorld(32)
	self.map:bump_init(self.world)

	for i,v in ipairs(self.map.bump_collidables) do
		v.isWall = true
	end

	self.cam = camera.new(0,0,self.map.width*32,self.map.height*32)	
	self.cam:setScale(self.scale)	
end

function scene:initLight()
	if not self.enableLight then return end
	self.light = LightWorld({
   		ambient = {30,30,30},
    	shadowBlur = 0.0
 	})
	self.light:setCamera(self.cam)
	self.map:light_init(self.light)
	self.lights = self.map.lights
end

function scene:initMonsterEntries()
	local map = self.map
	self.monsterEntries = {}
	for _, tileset in ipairs(map.tilesets) do
		for _, tile in ipairs(tileset.tiles) do
			local gid = tileset.firstgid + tile.id
			if tile.properties and tile.properties.monsterEntry == true and map.tileInstances[gid] then
				for _, instance in ipairs(map.tileInstances[gid]) do
					local t = {properties = tile.properties, x = instance.x + map.offsetx + 32, y = instance.y + map.offsety + 1, width = map.tilewidth, height = map.tileheight, layer = instance.layer }
					table.insert(self.monsterEntries,t)
				end
			end
		end
	end
end

function scene:addRandomMonster()
	local entry = table.random(self.monsterEntries)	
	self:addMonster(entry.x,entry.y)
end

function scene:addMonster(x,y,t)
	if t then return table.insert(self.monsters,monsters[t](self,x,y)) end
	table.insert(self.monsters,table.random(monsters)(self,x,y))
end

function scene:addObject(obj)
	table.insert(self.objects,obj)
end



function scene:updateLight()
	for i,v in ipairs(self.lights) do
		v.range = math.percentOffset(100,0.2)
	end
end

function scene:update(dt)
	if self.pause then return end
	
	self.menu:update(dt)
	self.waveManager:update(dt)
	self:updateLight()
	self.map:update(dt)
	self.cat:update(dt)
	for i = #self.monsters , 1 , -1 do
		local obj = self.monsters[i]
		obj:update(dt)
		if obj.destroyed then table.remove(self.monsters,i) end
	end
	for i = #self.objects , 1 , -1 do
		local obj = self.objects[i]
		obj:update(dt)
		if obj.destroyed then table.remove(self.objects,i) end
	end
	--self.cam:followTarget(self.cat, 100, 5)
	local x,y = self.cam:toWorld(0, 0)
	self.cam:setPosition(self.cat.x,self.cat.y)
	if self.enableLight then
		self.light:update(dt)
	end

	blooder:update()
end 


function scene:drawWithLight()	
	self.light:draw(function()		
		self.map:draw()
		blooder:draw()
		self.map:drawLayer(self.map.layers.stage)
		if self.debug then self.map:bump_draw(self.world) end
		for i,v in ipairs(self.monsters) do
			v:draw()
		end
		for i,v in ipairs(self.objects) do
			v:draw() 
		end
		self.cat:draw()

	end)
end

function scene:drawWithoutLight()
	self.cam:draw(function()
		self.map:draw()
		blooder:draw()
		if self.debug then self.map:bump_draw(self.world) end
		for i,v in ipairs(self.monsters) do
			v:draw()
		end
		for i,v in ipairs(self.objects) do
			v:draw()
		end
		self.cat:draw()
	end)
end


function scene:newMessage(message)
	self.messageTimer = 2
	self.message = message
end

local showMoney = 0
local showScore = 0
local helpText = [[
	Key Instruction
	a,d 		Move left and move right
	q,e 		Roll left and roll right (immune any attack)
	space,k     Jump
	lMouse,j	Fire (depends on current weapon)
	rMouse,i	Throw a grenade if you have.
	mMouse,tab	Switch Weapon	
	1 		Weapon pistol. Infinity ammo.
	2 		Weapon machine gun. High fire rate but low accuracy.
	3 		Weapon shot gun. Bloody hell in combat distance.
	4 		Weapon snipe rifle. Penetrate enemies and high damage.
	f		Toggle Flash Light. Can not see clearly?
	F1		Toggle Full Screen. So...big...
	F2		Toggle Light System. Low FPS ? Try this!
	F3 		Toggle Mouse Dirction Mode. Cat always faces to the mouse.
	F4		Send Next Wave Immidietly. Let the party start!
	F12		Exit. See you later！
	ESC		Pause or exit depot
]]



function scene:drawLabels()
	if math.floor(self.cat.score)> showScore then 
		showScore = showScore + 1 
	end
	if math.floor(self.cat.money)> showMoney then 
		showMoney = showMoney + 1 
	elseif math.floor(self.cat.money)< showMoney then
		showMoney = showMoney - 1
	end
	love.graphics.setColor(255, 255, 0, 255)
	love.window.setTitle(love.timer.getFPS())
	love.graphics.print("credits",self.offset,self.offset,0,self.fontSize,self.fontSize)
	love.graphics.print("x "..tostring(self.credits),20*self.offset,self.offset,0,self.fontSize,self.fontSize)
	if self.cat.currentWeapon then
		love.graphics.print(self.cat.currentWeapon.gun.name,self.offset,h()-5*self.offset,0,self.fontSize,self.fontSize)
		if self.cat.infAmmo then
			love.graphics.print("x "..tostring(1/0),20*self.offset,h()-5*self.offset,0,self.fontSize,self.fontSize)
		else
			love.graphics.print("x "..tostring(self.cat.currentWeapon.count),20*self.offset,h()-5*self.offset,0,self.fontSize,self.fontSize)
		end
	end
	love.graphics.print(string.format("Gold: %d",showMoney), w()/2-10*self.offset, self.offset, 0, self.fontSize, self.fontSize)
	love.graphics.print("Wave "..tostring(self.waveManager.waveCount+1)
		.." In: "..tostring(math.floor(self.waveManager.waveTimer).." sec"),w()-32*self.offset,self.offset,0,self.fontSize,self.fontSize)
	love.graphics.print(string.format("Score: %08d",showScore), w()-30*self.offset,h()-5*self.offset,0,self.fontSize,self.fontSize)
	love.graphics.print("press esc for help",w()/2-17*self.offset,h()-5*self.offset,0,self.fontSize,self.fontSize)
	self.messageTimer = self.messageTimer - love.timer.getDelta()
	if self.messageTimer > 0 then
		love.graphics.printf(self.message, 0, h()/2,w()/2,"center",0,self.fontSize,self.fontSize)
	end

	if self.pause then
		love.graphics.setColor(100, 100, 100, 150)
		love.graphics.rectangle("fill", 0, 0, w(), h())
		love.graphics.setColor(255, 255, 0, 255)
		love.graphics.print("Game Paused",w()/2-20*self.offset,5*self.offset,0,self.fontSize*2,self.fontSize*2)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.print(helpText, self.offset,10*self.offset,0,self.fontSize,self.fontSize)
	end
end


function scene:wheelmoved( x, y )
	if y>0 then
		self.cat:changeWeapon(1)
	elseif y<0 then
		self.cat:changeWeapon(-1)
	end
end


function scene:draw()
	if self.enableLight then
		self:drawWithLight()
	else
		self:drawWithoutLight()
	end
	self:drawLabels()
	self.menu:draw()
end

function scene:keypressed(key)
	if key == "f" then
		self.cat:toggleFlashLight()
	elseif key == "f1" then
		love.window.setFullscreen(not love.window.getFullscreen(),"exclusive")
		self.pause = true
	elseif key =="f2" then
		self.enableLight = not self.enableLight
	elseif key == "f3" then
		self.mouseDirection = not self.mouseDirection
	elseif key == "f4" then
		self.waveManager:nextWave()
		local bonus = math.ceil(self.waveManager.waveTimer)
		self.cat.money = self.cat.money + bonus
		self:newMessage("you got bonus +"..bonus.." !")
	elseif key == "f12" then
		love.window.setFullscreen()
		love.event.quit()
	elseif key == "escape" then
		if self.enableMenu then
			self.enableMenu = false
			self.menu:removeGrid()
			self.waveManager.waveTimer = 0
		else
			self.pause = not self.pause
			self.menu:removeGrid()
		end
	elseif key == "tab" then
		self.cat:changeWeapon(1)
	elseif key == "1" then
		self.cat:setWeapon(1)
	elseif key == "2" then
		self.cat:setWeapon(2)
	elseif key == "3" then
		self.cat:setWeapon(3)
	elseif key == "4" then
		self.cat:setWeapon(4)
	elseif key == "`" then
		--self.cat.infAmmo = not self.cat.infAmmo
		--self.debug = not self.debug
	elseif key == "5" then
		self.menu:newGrid()
	elseif key == "end" then
		self:switch()
	end

end


function scene:setGlobalScale(s,w,h)
	
	w = w or 640
	h = h or 360
	--if self.w == w and self.h == h then return end
	self.w = w
	self.h = h
	self.globalScale = s
	self.cam.scale = 1
	self.fontSize = s
 	self.offset = s*5
 	local sw,sh = love.graphics.getDimensions()
 	if sw ~= s*w or sh ~= s*h then
 		love.window.setMode(w*s, h*s)
 	end
 	self.cam:setWindow(0,0,w, h)
 	self.light:refreshScreenSize(w, h)
	blooder:resetCanvas(w*s, h*s)
	self.map:resize(w, h)

	self.canvas = love.graphics.newCanvas(w,h)
	self.canvas:setFilter( "nearest", "nearest" )
	self.draw = function()
		love.graphics.setCanvas(self.canvas)
		love.graphics.circle("fill", 10,100,200)
		love.graphics.clear()
		if self.enableLight then
			self:drawWithLight()
		else
			self:drawWithoutLight()
		end
		love.graphics.setCanvas()
		love.graphics.setColor(255,255,255,255)
		love.graphics.draw(self.canvas,0,0,0,s,s)
		self:drawLabels()
		self.menu:draw()
	end
end

function scene:fade(screenshot,how,cx,cy)
	local o_draw = self.draw

	delay:new(1,function() self.draw = o_draw end)
	local cam = camera.new(-w(),-h(),2*w(),2*h())
	if how == "flip" then
		local sRot = 0
		self.draw = function(self)
			love.graphics.setCanvas(self.canvas)
			love.graphics.circle("fill", 10,100,200)
			love.graphics.clear()
			if self.enableLight then
				self:drawWithLight()
			else
				self:drawWithoutLight()
			end
			love.graphics.setCanvas()
			love.graphics.setColor(255,255,255,255)
			
			sRot = sRot + Pi* love.timer.getDelta()
			if math.cos(sRot)>0 then
				love.graphics.push()
				love.graphics.origin()
				love.graphics.translate(cx, cy)
				love.graphics.draw(screenshot,w()/2,0,0,math.cos(sRot),1,w()/2)
				love.graphics.pop()
			else
				love.graphics.draw(self.canvas,w()/2,0,0,-self.globalScale*math.cos(sRot),self.globalScale,self.w/2)
			end
			self:drawLabels()
			self.menu:draw()
		end
	elseif how == "zoom" then
		local zoom = 1
		self.draw = function(self)
			love.graphics.setCanvas(self.canvas)
			love.graphics.circle("fill", 10,100,200)
			love.graphics.clear()
			if self.enableLight then
				self:drawWithLight()
			else
				self:drawWithoutLight()
			end
			love.graphics.setCanvas()
			love.graphics.setColor(255,255,255,255)
			zoom = zoom + love.timer.getDelta()*10
			if zoom<6 then				
				cam:setPosition(cx+150,cy-250)
				cam:setScale(zoom)
				cam:draw(function()
				love.graphics.draw(screenshot)
				end)
			else	
				local cx2,cy2 = self.cam:toScreen(self.cat.x,self.cat.y)
				cam:setPosition(cx2-130,cy2-100)
				cam:setScale(14-zoom)
				cam:draw(function()
				love.graphics.draw(self.canvas)
				end)
			end
			self:drawLabels()
			self.menu:draw()
		end

	end
end

function scene:leave()
	self.light = nil
	self.map = nil
	playSound("bg2","stop")
end

function scene:switch()
	local cx,cy = self.cam:toScreen(self.cat.x,self.cat.y)
	cx = cx * self.globalScale
	cy = cy * self.globalScale
	gamestate.switch(gameState.level1, love.graphics.newImage(love.graphics.newScreenshot()),"flip",cx,cy)
end

function scene:quit()
    local key = love.window.showMessageBox(
    	"Exit Game", "Really quit the Game!", 
    	{"Bye~","Return"})
    if key == 2 then 
    	self.pause = true
    	return true 
    end
end
return scene