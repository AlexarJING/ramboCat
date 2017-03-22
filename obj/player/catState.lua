local s = {}

s.idle = {
	relative={"jumpStart","standFire","walk","jumpAir","roll"},
	onEnter = function(role) 
		role:playAnim("idle",true)
 	end,
	condition = function(role) return true end,
}

s.standFire = {
	relative={},
	onEnter = function(role)
		role.firing = true
		role:playAnim("standfire",true)
 	end,
	condition = function(role)
		return role:keyFire()
	end,
}

s.walk = {
	relative={"jumpStart","standFire","jumpAir"},
	onEnter = function(role) 
		role:playAnim("walk",true)
 	end,
	condition = function(role)
		return role:keyMove()
	end,
}

s.walkFire = {
	relative={"walkFire","jumpStart","jumpAir"},
	onEnter = function(role) 
		role:playAnim("walkfire",true)
 	end,
	condition = function(role)
		return role:keyFire() and role:keyMove()
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
	relative={"jumpEnd","jumpFire"},
	onEnter = function(role) 
		role:playAnim("jumpAir",true)
 	end,
	condition = function(role)
		role:keyMove()
		return not role.onGround
	end,
}

s.jumpFire = {
	relative={"jumpFire","jumpEnd","jumpAir"},
	onEnter = function(role) 
		role:playAnim("jumpFire",true)
 	end,
	condition = function(role)
		role:keyMove()
		return (not role.onGround) and role:keyFire()
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

s.roll = {
	relative={"roll"},
	onEnter = function(role) 
		if not role.rolling then
			role:playAnim("roll")
			role:backToIdle(function()
				role.rolling = false
			end)
			role.rolling = true
		end
 	end,
	condition = function(role)
		return role.rolling or role:keyRoll()
	end,
}

s.die = {
	relative={},
	onEnter = function(role) 
		role:playAnim("down")
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
return s