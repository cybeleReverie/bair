local GameOver = {
	camera = Camera(320 / 2, 180 / 2, 3)
}

function GameOver:enter()
end

function GameOver:update(dt)
	if Input:pressed('attack') then
		Gamestate.switch(gs.Game)
	end
end

function GameOver:draw()
	GameOver.camera:attach()
	love.graphics.setFont(font.alagard)
	love.graphics.setBackgroundColor(0, 0, 0)
	love.graphics.setColor(1, 1, 1)
	love.graphics.print('You died.\n\nPress Attack to restart.', 4, 4)
	GameOver.camera:detach()
end

return GameOver
