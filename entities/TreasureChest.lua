local TreasureChest = class 'TreasureChest'

function TreasureChest:init(x, y)
	self.pos = vec.new(x, y)
	self.w, self.h = 32, 24
	self.scroll = true

	self.loot = item.apple --random.weightedChoice({})

	self.ghost = true
	self.isSoftBlock = true

	self.spr = img.treasureChest
	self.draw = true

	ewo:add(self)
end

function TreasureChest:collide(other)
	if other.name == 'DamageBox' and other.dealer == gs.Game.player then
		local l = Cosmetic:new{
			x = self.pos.x + self.w / 2 - 8,
			y = self.pos.y,
			w = 16, h = 16,
			scroll = true,
			vely = -120,
			gravity = true,
			filter = function(this, other)
				if other.isBlock then return 'slide' else return 'cross' end end,
			spr = self.loot.spr,
		}
		l.collide = function(this, other)
			if other.name == 'Player' then
				table.insert(other.inv, self.loot)
				ewo:remove(l)
			end
		end
		ewo:remove(self)
	end
end

return TreasureChest
