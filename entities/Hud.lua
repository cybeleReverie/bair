local Hud = class 'Hud'

local player

function Hud:init()
	self.x, self.y = 0, 0
	player = gs.Game.player
	self.depth = 1000

	ewo:add(self)
end

function Hud:draw()
	--draw hp
	for i = 1, player.maxHp do
		love.graphics.draw(img.hud, tile.hud.heartEmpty.tile, 64 + i * 9, 140)
	end
	for i = 1, player.hp do
		love.graphics.draw(img.hud, tile.hud.heart.tile, 64 + i * 9, 140)
	end

	--draw mp
	love.graphics.setColor(lume.color('#261624'))
	love.graphics.rectangle('fill', 72, 152, player.maxMp * 8, 7)
	love.graphics.setColor(lume.color('#7e0a70'))
	love.graphics.rectangle('fill', 72, 152, player.mp * 8, 7)
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle('line', 72, 152, player.maxMp * 8, 7)
	love.graphics.rectangle('line', 72, 152, player.maxMp * 8, 7)

	--draw melee attacks
	local xx, yy
	-- for i = 0, 8 do
	-- 	xx, yy = 4 + (i % 3) * 14, 136 + ((i * 14 - i % 3 * 14) / 3)
	-- 	if player.attacks[i + 1] then
	-- 		love.graphics.setColor(0, 0, 0)
	-- 		love.graphics.rectangle('line', xx, yy, 12, 12)
	--
	-- 		love.graphics.print(i + 1, xx, yy)
	--
	-- 	end
	-- 	-- if player.curAttack == i + 1 then
	-- 	-- 	love.graphics.setColor(1, 1, 1)
	-- 	-- 	love.graphics.rectangle('line', xx, yy, 12, 12)
	-- 	-- end
	-- end
end

return Hud
