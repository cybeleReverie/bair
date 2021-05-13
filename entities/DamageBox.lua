local DamageBox = class 'DamageBox'

function DamageBox:init(x, y, w, h, dmg, decay, velx, vely)
	self.x = x
	self.y = y
	self.w = w
	self.h = h
	self.dmg = dmg
	self.vel = vec.new(velx or 0, vely or 0)

	if decay > 0 then
		Timer.after(decay, function() ewo:remove(self) end)
	end

	self.filter = function(item, other) return 'cross' end

	ewo:add(self)
end

function DamageBox:collide(other)
	if other.name ~= 'DamageBox' then ewo:remove(self) end
end

return DamageBox
