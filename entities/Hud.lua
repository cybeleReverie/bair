local Hud = class 'Hud'

local player, mpDisplay, dt

function Hud:init()
	self.x, self.y = 0, 0
	player = gs.Game.player
	mpDisplay = gs.Game.player.mp
	self.depth = 1000

	ewo:add(self)
end

function Hud:draw()
	dt = love.timer.getDelta()

	--draw hp
	for i = 1, player.maxHp do
		lg.draw(img.hud, tile.hud.heartEmpty.tile, 84 + i * 9, 140)
	end
	for i = 1, player.hp do
		lg.draw(img.hud, tile.hud.heart.tile, 84 + i * 9, 140)
	end

	--draw mp
	if player.mp < mpDisplay then mpDisplay = math.max(mpDisplay - 4 * dt, player.mp)
	elseif player.mp > mpDisplay then mpDisplay = math.min(mpDisplay + 2 * dt, player.mp) end

	lg.setColor(lume.color('#261624')); lg.rectangle('fill', 94, 152, player.maxMp * 8, 7)
	lg.setColor(lume.color('#7e0a70')); lg.rectangle('fill', 94, 152, mpDisplay * 8, 7)
	lg.setColor(1, 1, 1, 0.05);			lg.line(94, 153, 94 + mpDisplay * 8, 153)
	lg.setColor(1, 1, 1, 0.2);			lg.line(94, 154, 94 + mpDisplay * 8, 154)
	lg.setColor(0, 0, 0, 0.35);			lg.line(94, 157, 94 + mpDisplay * 8, 157)
	lg.setColor(0, 0, 0); 				lg.rectangle('line', 94, 152, player.maxMp * 8, 7)

	--draw melee moveset
	local xx, yy
	local atk = lume.find(player.attacks, player.curAttack)

	for i = 0, 8 do
		xx, yy = 4 + (i % 3) * 15, 136 + ((i * 15 - i % 3 * 15) / 3)

		lg.setColor(1, 1, 1, 0.25)
		lg.rectangle('fill', xx, yy, 12, 12)

--		if player.attacks[i + 1] then
			lg.setColor(0, 0, 0)
			lg.rectangle('line', xx, yy, 12, 12)
			lg.print(i + 1, xx, yy)
--		end
		if atk == i + 1 then
			lg.setColor(1, 1, 1)
			lg.rectangle('line', xx, yy, 12, 12)
			lg.rectangle('line', xx - 1, yy - 1, 14, 14)
		end
	end

	--draw spells
	local spell = lume.find(player.spells, player.curSpell)

	for i = 0, 5 do
		xx, yy = 57 + (i % 2) * 15, 136 + ((i * 15 - i % 2 * 15) / 2)

		lg.setColor(1, 1, 1, 0.25)
		lg.rectangle('fill', xx, yy, 12, 12)

		--if player.spells[i + 1] then
			lg.setColor(0, 0, 0)
			lg.rectangle('line', xx, yy, 12, 12)
			lg.print(i + 1, xx, yy)
		--end
		if spell == i + 1 then
			lg.setColor(1, 1, 1)
			lg.rectangle('line', xx, yy, 12, 12)
			lg.rectangle('line', xx - 1, yy - 1, 14, 14)
		end
	end

	--draw stats
	lg.setFont(font.romulus)
	lg.setColor(1, 1, 1)
	lg.print('STR: ' .. player.str ..
			'\nDEX: ' .. player.dex ..
			'\nINT: ' .. player.int, 213, 134)
	lg.print('POW: ' .. player.pow ..
			'\nHOV: ' .. player.hov ..
			'\nMAG: ' .. player.mag, 268, 134)
end

return Hud
