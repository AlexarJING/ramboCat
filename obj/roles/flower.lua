local base = require "obj/base"
local flower = class("flower",base)

local path = "res/anim/mon4.png"
flower.stateData = require "obj/roles/mon1State"
flower.animAtlas = love.graphics.newImage(path)

flower.animData = {
	{"idle",1,1,4},
	{"jumpStart",1,2,4},
	{"jumpAir",5,2,2},
	{"jumpEnd",7,3,3},
	{"attack",1,3,5},
	{"rangeAttackStart",1,4,6},
	{"rangeAttackCharge",7,4,2},
	{"rangeAttackShot",9,4,6},
	{"hurt",1,5,3},
	{"die",4,5,5},
}
