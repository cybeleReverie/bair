local spell = {}

--fireball
spell.fireball = {
	baseDamage = 1,
	windupTime = 1.1,
	rechargeTime = 1.25,
	cost = 1,

	enter = function(caster)
		DamageBox:new{
			x = caster.pos.x + caster.w + 2,
			y = caster.pos.y + 6,
			w = 14, h = 12,
			velx = 270,
			dmg = caster.pow,
			dealer = caster,
			spr = spr.spell.fireball, spritesheet = img.spell16,
			ox = 2, oy = 3,
		}
	end
}

return spell
