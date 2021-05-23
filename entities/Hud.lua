local Hud = class 'Hud'

function Hud:init()
	self.x, self.y = 0, 0
	self.depth = 1000
	ewo:add(self)
end

function Hud:draw()
	--draw health
	for i = 1, gs.Game.player.maxHp do
		love.graphics.setColor(0.1, 0.1, 0.1)
		love.graphics.circle('fill', 64 + i * 9, 154, 4, 6)
	end
	for i = 1, gs.Game.player.hp do
		love.graphics.setColor(0.8, 0, 0)
		love.graphics.circle('fill', 64 + i * 9, 154, 3, 6)
	end

	--draw mp
	for i = 1, gs.Game.player.maxMp do
		love.graphics.setColor(0.1, 0.1, 0.1)
		love.graphics.circle('fill', 64 + i * 9, 166, 4, 6)
	end
	for i = 1, gs.Game.player.mp do
		love.graphics.setColor(0.15, 0.15, 0.9)
		love.graphics.circle('fill', 64 + i * 9, 166, 3, 6)
	end
end

return Hud
