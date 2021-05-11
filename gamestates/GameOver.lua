local GameOver = {}

function GameOver:update(dt)
	if Input:pressed('attack') then
		love.event.quit('restart')
	end
end

function GameOver:draw()
	love.graphics.setFont(font.alagard)
	love.graphics.setBackgroundColor(0, 0, 0)
	love.graphics.setColor(1, 1, 1)
	love.graphics.print('You died.\n\nPress Attack to restart.', 4, 4)
end

return GameOver
