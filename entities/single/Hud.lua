local Hud = class 'Hud'

local player, mpBarW, expBarW, dt, textConsole
local nameW
local expMaxW = 48
local topLeftAlpha = 1

function Hud:init()
	player = gs.Game.player
	mpBarW = gs.Game.player.mp
	nameW = font.pxfont:getWidth(player.givenName)

	textConsole = Console:new()
end

function Hud:draw()
	dt = love.timer.getDelta()
	lg.setFont(font.pxfont)

	if gs.Game.camera.y - player.pos.y > 60 then
		topLeftAlpha = lu.lerp(topLeftAlpha, 0.3, 0.2)
	elseif topLeftAlpha < 1 then
		topLeftAlpha = lu.lerp(topLeftAlpha, 1, 0.2)
	end

	self:drawName()
	self:drawExp()
	self:drawHp()
	self:drawMp()
	self:drawMoves()
	self:drawStats()

	--draw console
	textConsole:draw()
end

function Hud:drawName()
	lg.setColor(col.white, topLeftAlpha)
	lg.print(player.givenName, 1, 1)
	lg.draw(img.hud, tile.hud.the.tile, 4 + nameW, 1)
	lg.print(player.title, 19 + nameW, 1)
end

function Hud:drawExp(alpha)
	lg.setColor(col.white, topLeftAlpha)
	expBarW = expMaxW * math.floor(player.exp) / player.maxExp

	lg.draw(img.hud, tile.hud.emptyBarL.tile, 1, 9)
	lg.draw(img.hud, tile.hud.emptyBarM.tile, 3, 9, 0, 48, 1)
	lg.draw(img.hud, tile.hud.emptyBarR.tile, 51, 9)
	if player.exp > 0 then lg.draw(img.hud, tile.hud.xpBarL.tile, 1, 9) end
	lg.draw(img.hud, tile.hud.xpBarM.tile, 3, 9, 0, expBarW, 1)

	lg.draw(img.hud, tile.hud.lv.tile, 1, 11)
	lg.print(player.expLevel, 13, 12)
end

function Hud:drawHp()
	lg.setColor(col.white)
	for i = player.maxHp, 1, -1 do
		lg.draw(img.hud, tile.hud.heartEmpty.tile, 80 + i * 8, 136)
	end
	for i = 1, player.hp do
		lg.draw(img.hud, tile.hud.heart.tile, 80 + i * 8, 136)
	end
end

function Hud:drawMp()
	if player.mp < mpBarW then mpBarW = math.max(mpBarW - 4 * dt, player.mp)
	elseif player.mp > mpBarW then mpBarW = math.min(mpBarW + 2 * dt, player.mp) end

	lg.setColor(col.white)
	lg.draw(img.hud, tile.hud.emptyBarL.tile, 88, 148)
	lg.draw(img.hud, tile.hud.emptyBarM.tile, 91, 148, 0, player.maxMp * 7, 1)
	lg.draw(img.hud, tile.hud.emptyBarR.tile, 91 + player.maxMp * 7, 148)
	if mpBarW > 0 then lg.draw(img.hud, tile.hud.mpBarL.tile, 88, 148) end
	lg.draw(img.hud, tile.hud.mpBarM.tile, 91, 148, 0, mpBarW * 7, 1)
	if mpBarW == player.maxMp then lg.draw(img.hud, tile.hud.mpBarR.tile, 91 + mpBarW * 7, 148) end

	lg.print(player.mp .. '/' .. player.maxMp, 88, 152)
end

function Hud:drawMoves()
	--draw melee moves
	local xx, yy
	local atk = lu.find(player.attacks, player.curAttack)

	lg.setColor(col.white)
	for i = 0, 8 do
		xx, yy = 4 + (i % 3) * 15, 136 + ((i * 15 - i % 3 * 15) / 3)

		lg.draw(img.hud, tile.hud.attackSlotEmpty.tile, xx, yy)

		if atk == i + 1 then
			lg.draw(img.hud, tile.hud.attackSlotFill.tile, xx, yy)
			lg.draw(img.hud, tile.hud.attackSlotSelect.tile, xx - 2, yy - 2)
		end
	end

	--draw spells
	local spell = lu.find(player.spells, player.curSpell)

	for i = 0, 5 do
		xx, yy = 57 + (i % 2) * 15, 136 + ((i * 15 - i % 2 * 15) / 2)

		lg.draw(img.hud, tile.hud.spellSlotEmpty.tile, xx, yy)

		if spell == i + 1 then
			lg.draw(img.hud, tile.hud.spellSlotFill.tile, xx, yy)
			lg.draw(img.hud, tile.hud.spellSlotSelect.tile, xx - 2, yy - 2)
		end
	end
end

function Hud:drawStats()
	--str/dex/int
	lg.setColor(col.white)
	lg.draw(img.hud, tile.hud.str.tile, 283, 147)
	lg.draw(img.hud, tile.hud.dex.tile, 283, 158)
	lg.draw(img.hud, tile.hud.int.tile, 283, 169)
	if player.str < 10 then lg.print('`', 306, 149) end
	if player.dex < 10 then lg.print('`', 306, 160) end
	if player.int < 10 then lg.print('`', 306, 171) end
	lg.print(player.str, 312, 149)
	lg.print(player.dex, 312, 160)
	lg.print(player.int, 312, 171)

	--pow
	local powStr = ''; if player.pow < 100 then powStr = powStr .. '`' end --leading 0
	if player.pow < 10 then powStr = powStr .. '`' end; powStr = powStr .. player.pow
	lg.draw(img.hud, tile.hud.pow.tile, 86, 161)
	lg.printf(powStr, 88, 169, 18, 'right')
	lg.draw(img.hud, tile.hud.powU.tile, 88, 176)

	--mag
	local magStr = ''; if player.mag < 100 then magStr = magStr .. '`' end --leading 0
	if player.mag < 10 then magStr = magStr .. '`' end; magStr = magStr .. player.mag
	lg.draw(img.hud, tile.hud.mag.tile, 112, 161)
	lg.printf(magStr, 114, 169, 18, 'right')
	lg.draw(img.hud, tile.hud.magU.tile, 114, 176)
end

return Hud
