local attack = {}

--Basic
attack.basic = {
	rechargeTime = 0.5,
	sprite = spr.bair.attackBasic,

	enter = function(self)
		self.timer:after(0.29, function()
			DamageBox:new{
				x = self.x + self.w + 32, y = self.y + 4,
				w = 16, h = 24,
				dmg = self.pow,
				decay = 0.2,
				velx = 140
			}
		end)

		Timer.after(0.964, function() self:switchState('Walk') end)

		self.spr = spr.bair.attackBasic
	end
}

--Farclaw
local Reticle
attack.farclaw = {
	rechargeTime = 0.75,
	sprite = spr.bair.attackFarclaw,

	enter = function(self)
		Reticle = {
			x = self.x + self.w,
			y = self.y + self.h / 2 - 10,
			w = 1,
			h = 1,
			vel = vec.new(110, 0),
			ghost = true,
			spr = img.reticle,
			draw = true,
			depth = 10,
		}

		ewo:add(Reticle)
	end,

	exit = function(self)
		local d = DamageBox:new{
			x = Reticle.x - 40, y = Reticle.y - 15,
			w = 10, h = 10,
			dmg = self.pow,
			decay = 0.16,
			spr = spr.bair.clawEffect, spritesheet = img.clawEffect
		}

		ewo:remove(Reticle)

		Timer.after(0.3, function() self:switchState('Walk') end)
	end
}

return attack
