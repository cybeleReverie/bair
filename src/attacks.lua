local attack = {}

--Basic
attack.basic = {
	baseDamage = 1,
	rechargeTime = 0.85,
	sprite = spr.bair.attackBasic,

	enter = function(self)
		self.timer:after(0.29, function()
			DamageBox:new{
				x = self.pos.x + self.w + 32, y = self.pos.y + 4,
				w = 16, h = 24,
				dmg = self.pow,
				decay = 0.2,
				velx = 100,
				dealer = self
			}
		end)

		Timer.after(spr.bair.attackBasic:getAnimDur(), function() self:switchState('Walk') end)
	end
}

--Farclaw
local Reticle
attack.farclaw = {
	baseDamage = 1,
	rechargeTime = 1.5,
	sprite = spr.bair.attackFarclaw,

	enter = function(self)
		self.timer:after(spr.bair.attackFarclaw:getAnimDur(1, 4), function()
			Reticle = Cosmetic:new{
				x = self.pos.x + self.w,
				y = self.pos.y + self.h / 2 - 10,
				velx = 250,
				update = function(this)
					if this.pos.x > 320 then
						ewo:remove(this)
						self.curAttack.exit(self, true)
					end
				end,
				collide = function(this, other)
					if other.name == 'Block' then
						ewo:remove(this)
						self.curAttack.exit(self, true)
					end
				end,
				spr = img.reticle,
				depth = 10
			}
		end)
	end,

	exit = function(self, cancel)
		self.timer:clear()

		if not cancel and Reticle then
			DamageBox:new{
				x = Reticle.pos.x, y = Reticle.pos.y - 13,
				w = 24, h = 26,
				dmg = self.pow,
				decay = 0.16,
				dealer = self,
				spr = spr.bair.effect.farclaw, spritesheet = img.farclawEffect,
				ox = 36, oy = 2
			}
			ewo:remove(Reticle)

			self.spr:gotoFrame(7)
			self.sprEffect.anim:gotoFrame(2)
		end
		Reticle = nil

		self.timer:after(spr.bair.attackBasic:getAnimDur(7, #spr.bair.attackFarclaw.durations) + 0.1,
			function() self:switchState('Walk'); end)
	end
}

return attack
