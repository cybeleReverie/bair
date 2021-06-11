local PauseMenu = class 'PauseMenu'

local player

function PauseMenu:init()
	player = gs.Game.player
	self.states = {'Inventory', 'Stats', 'Tree'}
	self.state = self.states[1]
	self.cursor = 0
end

function PauseMenu:update(dt)
	if Input:pressed('left') then
		self.cursor = self.cursor - 1
		if self.cursor < 0 then self.cursor = 5 end
	end
	if Input:pressed('right') then
		self.cursor = self.cursor + 1
		if self.cursor > 5 then self.cursor = 0 end
	end
	if Input:pressed('attack') then
		if player.inv[self.cursor + 1] then
			player.inv[self.cursor + 1].use(player)
			player.inv[self.cursor + 1] = nil
		end
	end
end

function PauseMenu:draw()
	lg.setFont(font.small)

	lg.setColor(0.6, 0.6, 0.6)
	lg.rectangle('fill', 32, 32, 320 - 56, 180 - 48)
	lg.setColor(0, 0, 0)
	lg.rectangle('line', 32, 32, 320 - 56, 180 - 48)

	if self.state == 'Inventory' then
		lg.setColor(0, 0, 0)
		lg.print('Inventory:', 35, 32)

		lg.setColor(1, 1, 1)
		for i = 0, #player.inv - 1 do
			if player.inv[i + 1] then
				love.graphics.draw(player.inv[i + 1].spr.sheet, player.inv[i + 1].spr.tile, 36 + i * 20, 48)
			end
		end

		love.graphics.rectangle('line', 35 + self.cursor * 20, 48, 18, 18)
	elseif self.state == 'Tree' then

	elseif self.state == 'Stats' then

	end
end

return PauseMenu
