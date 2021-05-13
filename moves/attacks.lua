local attack = {}

attack.basic = function(self)
	self.timer:after(0.29, function()
		DamageBox:new(self.x + self.w + 32, self.y + 4, 16, 24, self.pow, 0.2, 140)
	end)

	self.canAttack = false
	self.isAttacking = true

	self.timer:after(self.attackRecharge, function() self.canAttack = true end)

	self.spr = spr.bair.attack
end

attack.farclaw = function(self)

end

return attack
