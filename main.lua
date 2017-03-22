__TESTING = true
require "lib/autobatch"
require "lib/util"
bump=require "lib/bump"
class=require "lib/middleclass"
gamestate= require "lib/hump/gamestate"
tween= require "lib/tween"
delay= require "lib/delay"
input= require "lib/input"
camera= require "lib/gamera"
sti = require "lib/sti"
animation = require "lib/animation"
LightWorld = require "lib/light"
require "lib/gooi"
playSound = require "scr/sound"
blooder = require "scr/blooder"
blooder:init()
font = love.graphics.newImageFont("res/imagefont.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"")
love.graphics.setFont(font)

function love.load()
	love.graphics.setDefaultFilter( "nearest","nearest" )
    gameState={}
    for _,name in ipairs(love.filesystem.getDirectoryItems("scene")) do
        gameState[name:sub(1,-5)]=require("scene."..name:sub(1,-5))
    end
    gamestate.registerEvents()
    gamestate.switch(gameState.level1)
end

function love.update(dt) delay:update(dt) end
function love.mousereleased(x, y, button) gooi.released() end
function love.mousepressed(x, y, button)  gooi.pressed() end
function love.textinput(text) gooi.textinput(text) end
function love.keypressed(key) gooi.keypressed(key) end


