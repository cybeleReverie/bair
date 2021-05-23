local Game = {hspeed = 40}

function Game:enter()
	Game.player = Player:new(16, 104)
	Game.mapgen = Mapgen:new()
	Game.hud = Hud:new()

	love.graphics.setBackgroundColor(0.6, 0.6, 1)
end

function Game:update(dt)
	ewo:update(dt, ecsUpdateSys)
end

function Game:draw()
	ewo:update(nil, ecsDrawSys)
end

return Game
