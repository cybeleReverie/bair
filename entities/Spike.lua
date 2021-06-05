local Spike = DamageBox:extend('Spike')

function Spike:init(x, y, subtype)
	local sprite = tile.spike[subtype]
	local xx, yy = x, y
	local w, h
	local ox, oy = 0, 0

	if subtype == 'left' or subtype == 'right' or subtype == 'up' or subtype == 'down' then
		if subtype == 'left' then
			xx = x + 8
			yy = yy + 2
			w, h = 16, 20
			ox, oy = 8, 2
		elseif subtype == 'right' then
			yy = yy + 2
			w, h = 16, 20
			oy = 2
		elseif subtype == 'up' then
			yy = y + 8
			w, h = 24, 16
			oy = 8
		elseif subtype == 'down' then
			w, h = 24, 16
		end

		Spike.super.init(self, {
			x = xx, y = yy,
			w = w, h = h,
			dmg = 2,
			scroll = true,
			ox = ox, oy = oy,
			spr = sprite
		})
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
