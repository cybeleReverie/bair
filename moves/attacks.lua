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
	rechargeTime = 1.5,
	sprite = spr.bair.attackFarclaw,

	enter = function(self)
		self.timer:after(0.4, function()
			Reticle = {
				x = self.x + self.w,
				y = self.y + self.h / 2 - 10,
				w = 1,
				h = 1,
				vel = vec.new(135, 0),
				ghost = true,
				update = function(this)
					if this.x > 320 then
						ewo:remove(this)
						self.curAttack.exit(self)
					end
				end,
				spr = img.reticle,
				draw = true,
				depth = 10,
			}
			Reticle.this = Reticle

			ewo:add(Reticle)
		end)
	end,

	exit = function(self)
		self.timer:clear()

		if Reticle and Reticle.x < 320 then
			local d = DamageBox:new{
				x = Reticle.x, y = Reticle.y - 16,
				w = 24, h = 26,
				dmg = self.pow,
				decay = 0.16,
				persistOnCollide = true,
				spr = spr.bair.clawEffect, spritesheet = img.clawEffect
			}
			d.ox, d.oy = 36, 2

			ewo:remove(Reticle)

			self.spr:gotoFrame(7)
		end
		Reticle = nil

		self.timer:after(0.35, function() self:switchState('Walk') end)
	end
}

return attack
