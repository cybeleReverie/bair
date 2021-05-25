local spell = {}

--fireball
spell.fireball = {
	rechargeTime = 1,
	cost = 1,
--	sprite = spr.bair.castGeneric,

	enter = function(self)
		local Fireball = DamageBox:new{
			x = self.x + self.w + 2,
			y = self.y + 6,
			w = 15, h = 14,
			velx = 270,
			dmg = 1,
			dealer = self,
			spr = spr.spell.fireball, spritesheet = img.spell16,
			ox = 4, oy = 3
		}
	end
}

return spell
