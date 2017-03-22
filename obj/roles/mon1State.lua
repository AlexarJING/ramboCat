local s = {}

s.idle = {
	relative={"walk","attack"},
	onEnter = function(role) 
		role:playAnim("idle",true)
 	end,
	condition = function(role) return true end,
}


s.walk = {
	relative={"attack"},
	onEnter = function(role) 
		role:playAnim("walk",true)
 	end,
	condition = function(role)
		return role:move()
	end,
}

s.hurt = {
	relative={},
	onEnter = function(role)
		role:playAnim("hurt")
		role:backToIdle()
	end,
	condition = function(role) return true end
}

s.die = {
	relative={},
	onEnter = function(role)
		role:playAnim("die",false)
		role.stage.cam:shake(0.2,10)
		local sound  = love.audio.newSource("res/sound/die3.wav")
		sound:play()
		role.currentAnim.onEnd = function()
			role:destroy()
			if role.block then role.stage.light:remove(role.block) end
		end
	end,
	condition = function(role) return true end
}

s.attack = {
	relative={"attack"},
	onEnter = function(role)
		role:playAnim("attack",false)
		role.ax = 0
		role.attacking =true
		role:backToIdle(function()
			delay:new(0.5,function() role.attacking = false end)
		end)
	end,
	condition = function(role) 
		return role.attacking
	end
}
return s