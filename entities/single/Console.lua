local Console = class 'Console'

function Console:init()
	self.buffer = {}
	self.x = 218
	self.y = 2

	gs.Game.signal:register('enemySpawned', function(enemy)
		self:print(enemy.name .. ' appears!')
	end)
	gs.Game.signal:register('enemyDefeated', function(enemy)
		self:print(enemy.name .. ' defeated!')
	end)
end

function Console:print(txt)
	table.insert(self.buffer, txt)
	if #self.buffer > 4 then table.remove(self.buffer, 1) end
end

local txt
local txtVal
function Console:draw()
	lg.setFont(font.smaller)
	txtVal = 1

	for i = #self.buffer, 1, -1 do
		if i < #self.buffer then txtVal = txtVal - 0.09 end
		txt = self.buffer[i]
		lg.setColor(0, 0, 0, txtVal / 1.2)
		lg.printf(txt, self.x + 1, self.y + 1 + (i - 1) * 8, 100, 'right')
		lg.setColor(txtVal, txtVal, txtVal)
		love.graphics.printf(txt, self.x, self.y + (i - 1) * 8, 100, 'right')
	end
end

return Console
