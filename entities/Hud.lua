local Hud = class 'Hud'

local player, mpBarW, expBarW, dt
local expMaxW = 48

function Hud:init()
	player = gs.Game.player
	mpBarW = gs.Game.player.mp
	self.depth = 1000
end

local function drawShinyBar(x, y, w, h)

end

function Hud:draw()
	dt = love.timer.getDelta()

	--draw exp bar
	lg.setColor(1, 1, 1)
	love.graphics.print('Lv. ' .. player.expLevel, 2, -1)
--	love.graphics.print(player.exp .. '/' .. player.expLevel * 8, 3, 16)

	local maxExp = player.expLevel * 8
	expBarW = math.floor((maxExp - (maxExp - player.exp)) / maxExp * 48)

	lg.setColor(lume.color('#261624')); lg.rectangle('fill', 34, 3, 48, 7)
	lg.setColor(lume.color('#00c6b0')); lg.rectangle('fill', 34, 3, expBarW, 7)
	lg.setColor(1, 1, 1, 0.25);			lg.line(34, 4, 34 + expBarW, 4)
	lg.setColor(1, 1, 1, 0.5);			lg.line(34, 5, 34 + expBarW, 5)
	lg.setColor(0, 0, 0, 0.25);			lg.line(34, 9, 34 + expBarW, 9)
	lg.setColor(0, 0, 0);				lg.rectangle('line', 34, 3, 48, 7)

	--draw hp
	lg.setColor(1, 1, 1)
	for i = 1, player.maxHp do
		lg.draw(img.hud, tile.hud.heartEmpty.tile, 84 + i * 9, 140)
	end
	for i = 1, player.hp do
		lg.draw(img.hud, tile.hud.heart.tile, 84 + i * 9, 140)
	end

	--draw mp bar
	if player.mp < mpBarW then mpBarW = math.max(mpBarW - 4 * dt, player.mp)
	elseif player.mp > mpBarW then mpBarW = math.min(mpBarW + 2 * dt, player.mp) end

	lg.setColor(lume.color('#261624')); lg.rectangle('fill', 94, 152, player.maxMp * 8, 7)
	lg.setColor(lume.color('#7e0a70')); lg.rectangle('fill', 94, 152, mpBarW * 8, 7)
	lg.setColor(1, 1, 1, 0.05);			lg.line(94, 153, 94 + mpBarW * 8, 153)
	lg.setColor(1, 1, 1, 0.2);			lg.line(94, 154, 94 + mpBarW * 8, 154)
	lg.setColor(0, 0, 0, 0.35);			lg.line(94, 157, 94 + mpBarW * 8, 157)
	lg.setColor(0, 0, 0); 				lg.rectangle('line', 94, 152, player.maxMp * 8, 7)

	--draw melee moveset
	local xx, yy
	local atk = lume.find(player.attacks, player.curAttack)

	for i = 0, 8 do
		xx, yy = 4 + (i % 3) * 15, 136 + ((i * 15 - i % 3 * 15) / 3)

		lg.setColor(1, 1, 1, 0.25)
		lg.rectangle('fill', xx, yy, 12, 12)

		lg.setColor(0, 0, 0)
		lg.rectangle('line', xx, yy, 12, 12)

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
