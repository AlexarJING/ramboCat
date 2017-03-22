local menu = {}
local cat
local items 
function menu:init(stage)
	self.stage = stage
	self.offset = 10*self.stage.globalScale
	self.style = {
		fgColor = "#FFFFFF",
		bgColor = "#25AAE1F0",
        mode3d = true,
        glass = true,
        round = .18,
        font = font,
	}
	gooi.setStyle(self.style)
	--gooi.desktopMode()
	cat = self.stage.cat
	items = 
{
	{"Rambo FirstAid Kit",
	function(stage,cat) return cat.hpMax end,
	function(stage,cat) cat.hp = cat.hpMax end},
	{"Rambo Stanima Upgrade",
	function(stage,cat) return 100 + (cat.hpMax-100)/20,cat.hpMax + 20 end,
	function(stage,cat) cat.hpMax = cat.hpMax + 20 end},
	{"Rambo SelfHeal Upgrade",
	function(stage,cat) return 100 +10*cat.selfHeal/0.3, cat.selfHeal + 0.3 end,
	function(stage,cat) cat.selfHeal = cat.selfHeal + 0.3 end},
	{"Pistol Damage Upgrade",
	function(stage,cat) return 100+10*(cat.Pistol.damage-12)/0.5,cat.Pistol.damage + 0.5 end,
	function(stage,cat) cat.Pistol.damage = cat.Pistol.damage + 0.5 end},
	{"Pistol FireRate Upgrade",
	function(stage,cat) return 100+10*(cat.Pistol.fireRate - 3)/0.2, cat.Pistol.fireRate + 0.2 end,
	function(stage,cat) cat.Pistol.fireRate = cat.Pistol.fireRate + 0.2 end},
	{"Pistol Accuracy Upgrade",
	function(stage,cat) return 100+10*(cat.Pistol.accuracy-15),cat.Pistol.accuracy+1 end,
	function(stage,cat) cat.Pistol.accuracy = cat.Pistol.accuracy + 1 end},
	{"MachineGun Magazine x100",
	function(stage,cat) return 100 end,
	function(stage,cat) cat.weapons[2].count = cat.weapons[2].count + 100 end},
	{"MachineGun Damage Upgrade",
	function(stage,cat) return 100+10*(cat.Machinegun.damage-10)/0.2,cat.Machinegun.damage + 0.2 end,
	function(stage,cat) cat.Machinegun.damage = cat.Machinegun.damage + 0.2 end},
	{"MachineGun Accuracy Upgrade",
	function(stage,cat) return 100+10*(cat.Machinegun.accuracy-8),cat.Machinegun.accuracy+1 end,
	function(stage,cat) cat.Machinegun.accuracy = cat.Machinegun.accuracy+1 end},
	{"ShotGun Magazine x20",
	function(stage,cat) return 100 end,
	function(stage,cat) cat.weapons[4].count = cat.weapons[4].count + 20 end},
	{"ShotGun Damage Upgrade",
	function(stage,cat) return 100+10*(cat.ShotGunFrag.damage-10),cat.ShotGunFrag.damage+1 end,
	function(stage,cat) cat.ShotGunFrag.damage = cat.ShotGunFrag.damage + 1 end},
	{"ShotGun Power Upgrade",
	function(stage,cat) return 100+10*(cat.ShotGunFrag.speed-13)/0.5,cat.ShotGunFrag.speed+0.5 end,
	function(stage,cat) cat.ShotGunFrag.speed = cat.ShotGunFrag.speed + 0.5 end},
	{"SnipeRifle Magazine x10",
	function(stage,cat) return 100 end,
	function(stage,cat) cat.weapons[3].count = cat.weapons[3].count + 10 end},
	{"SnipeRifle fireRate Upgrade",
	function(stage,cat) return 100+10*(cat.SnipeRifle.fireRate-1)/0.2,cat.SnipeRifle.fireRate+0.2 end,
	function(stage,cat) cat.SnipeRifle.fireRate = cat.SnipeRifle.fireRate + 0.2 end},
	{"SnipeRifle Recoil Upgrade",
	function(stage,cat) return 100+10*(cat.SnipeRifle.recoil-25),cat.SnipeRifle.recoil-1 end,
	function(stage,cat) cat.SnipeRifle.recoil = cat.SnipeRifle.recoil-1  end},
	{"Grenade Package x5",
	function(stage,cat) return 100 end,
	function(stage,cat) cat.weapons[5].count = cat.weapons[5].count + 5 end},
	{"Grenade AntiCount Upgrade",
	function(stage,cat) return 100 + 10 *(cat.Grenade.antiCount-2.5)/0.1, cat.Grenade.antiCount-0.1 end,
	function(stage,cat) cat.Grenade.antiCount = cat.Grenade.antiCount - 0.1 end},
	{"Grenade Power Upgrade",
	function(stage,cat) return 100 + 10 *(cat.GrenadeFrag.speed-15)/0.5, cat.GrenadeFrag.speed+0.5  end,
	function(stage,cat) cat.GrenadeFrag.speed = cat.GrenadeFrag.speed + 0.5 end},
}
	return self
end





function menu:addLine(tab)
	local name = tab[1]
	local price,level = tab[2](self.stage,cat)
	level = level or "1"
	local title = gooi.newLabel({text = name.." ["..level.."]", orientation = "center",opaque = true}):bg("#111111")
	local unitPrice = gooi.newLabel({text = tostring(price), orientation = "center",opaque = true}):bg("#111111")
	local buy = gooi.newButton({text = "buy", orientation = "center"}):bg("#ff8800")
	buy:onPress(function(obj)
		local cat = self.stage.cat
		if cat.money >= price then
			cat.money = cat.money - price
			tab[3](self.stage,cat)
			self.stage:newMessage(tab[1])
			obj.text = "sold out"
			obj:onPress(function() end)
			obj:bg("#111111")
			playSound("getitem")
		end
	end)
	self.grid:add(title,unitPrice,buy)	
end

function menu:newGrid()
	if self.grid then gooi.removeComponent(self.grid) end
	self.grid = gooi.newPanel(15*self.offset, 5*self.offset, w()/2, h()/2, "grid 8x4")	
	self.grid:setColspan(1, 1, 4):setColspan(2, 1, 2)
	:add(
		gooi.newLabel({text = "Rambo's depot", orientation = "center"}),
		gooi.newLabel({text = "object", orientation = "center",opaque = true}),
		gooi.newLabel({text = "price", orientation = "center",opaque = true}),
		gooi.newLabel({text = "settle", orientation = "center",opaque = true})
	)
	for i = 1,5 do
		self.grid:setColspan(i+2, 1, 2)
		self:addLine(table.random(items))
	end
end


function menu:removeGrid()
	if self.grid then gooi.removeComponent(self.grid) end
	self.grid = nil
end


function menu:update(dt)
	gooi.update(dt)
end

function menu:draw()
	gooi.draw()
end

return menu