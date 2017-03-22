local scene = gamestate.new()

function scene:init()

end 

scene.switchMode = {
	flip = function(self,ssFrom,ssTo)

	end
}

function scene:enter(from,to,how,...)
    self.to = to
    self.switchMode[how](self,...)
end


function scene:draw()
	love.graphics.setColor(255, 255, 255, self.alpha)
    love.graphics.draw(self.screen)
end

function scene:update(dt)
    self.alpha=self.alpha-255*self.time/60
    if self.how=="tween" then       
        if self.alpha<0 then gamestate.switch(self.state_to,self.state_from,self.arg) end
    elseif self.how=="bg" then
        if self.alpha<50 then gamestate.switch(self.state_to,self,self.screen) end
    end
end 

function scene:leave()


end
return scene