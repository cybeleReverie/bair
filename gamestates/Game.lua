local Game = {hspeed = 40}

function Game:enter()
	Game.player = Player:new(16, 104)
	Game.mapgen = Mapgen:new()

	love.graphics.setBackgroundColor(0.6, 0.6, 1)
end

function Game:update(dt)
	ewo:update(dt, ecsUpdateSys)
end

function Game:draw()
	ewo:update(nil, ecsDrawSys)

 	--move to HUD later
	love.graphics.setColor(1, 0, 0)
	love.graphics.print('HP: ' .. Game.player.hp .. '\nMP: ' .. Game.player.mp ..
		'\nHOV: ' .. lume.round(Game.player.hov, .1), 0, 136)
end

return Game
