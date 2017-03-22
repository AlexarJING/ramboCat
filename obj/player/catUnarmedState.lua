local s = {}

s.idle = {
	relative={"jumpStart","walk","attack"},
	onEnter = function(role) 
		role:playAnim("idle",true)
 	end,
	condition = function(role) return true end,
}



s.walk = {
	relative={"jumpStart","jumpAir","attack"},
	onEnter = function(role) 
		role:playAnim("walk",true)
 	end,
	condition = function(role)
		return role:keyMove()
	end,
}



s.jumpStart = {
	relative={"jumpAir"},
	onEnter = function(role) 
		role:playAnim("jumpStart",true)
 	end,
	condition = function(role)
		return role:keyJump()
	end,
}

s.jumpAir = {
	relative={"jumpEnd"},
	onEnter = function(role) 
		role:playAnim("jumpAir",true)
 	end,
	condition = function(role)
		role:keyMove()
		return not role.onGround
	end,
}

s.jumpEnd = {
	relative={},
	onEnter = function(role) 
		role:playAnim("jumpEnd")
		role:backToIdle()
 	end,
	condition = function(role)
		role:keyMove()
		return role.onGround
	end,
}

s.die = {
	relative={},
	onEnter = function(role) 
		role:playAnim("dead")
		role.falldown = true
 	end,
	condition = function(role)
		return role.falldown
	end,
}

s.getup = {
	relative={"getup"},
	onEnter = function(role) 
		role:playAnim("getup")
		role.gettingUp = true
		role:backToIdle(function()
			role.gettingUp = false
		end)
 	end,
	condition = function(role)
		return role.gettingUp
	end,
}

s.attack = {
	relative={"attack"},
	onEnter = function(role) 
		role:playAnim(role.attackType)
		role.attacking = true
		role:backToIdle(function()
			role.attacking = false
			role.attackZone:destroy()
		end)
 	end,
	condition = function(role)
		if role.attacking or role:keyAttack() then
			role:keyMove()
			return true
		end
	end,
}
return s