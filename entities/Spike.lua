local Spike = DamageBox:extend('Spike')

function Spike:init(x, y, subtype)
	local sprite = tile.spike[subtype]

	if subtype == 'left' or subtype == 'right' or subtype == 'up' or subtype == 'down' then
		Spike.super.init(self, {
			x = x, y = y,
			w = 20, h = 24,
			dmg = 2,
			scroll = true,
			ox = 2, oy = 0,
			spr = sprite
		})
		if subtype == 'left' or subtype == 'right' then self.ox = 0 end
	else
		--block part
		ewo:add{
			pos = vec.new(x + 8, y + 8),
			w = 8, h = 8,
			scroll = true,
			isBlock = true,
			filter = function(item, other)
				if other.name == 'Player'	then return 'cross'
				elseif other.ghost == true	then return 'cross'
				end
			end
		}

		--appearance
		Cosmetic:new{
			x = x, y = y,
			spr = sprite,
			scroll = true
		}

		--spikes
		if subtype == 'blockHor' or subtype == 'blockBi' then
			DamageBox:new{
				x = x + 1, y = y + 9,
				w = 6, h = 6,
				dmg = 2,
				scroll = true,
			}
			DamageBox:new{
				x = x + 16, y = y + 9,
				w = 6, h = 6,
				dmg = 2,
				scroll = true
			}
		end
		if subtype == 'blockVer' or subtype == 'blockBi' then
			DamageBox:new{
				x = x + 9, y = y,
				w = 6, h = 8,
				dmg = 2,
				scroll = true
			}
			DamageBox:new{
				x = x + 9, y = y + 16,
				w = 6, h = 8,
				dmg = 2,
				scroll = true
			}
		end
	end
end

return Spike
