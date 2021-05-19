local DamageBox = class 'DamageBox'

function DamageBox:init(params)
	self.x = params.x
	self.y = params.y
	self.w = params.w
	self.h = params.h
	self.dmg = params.dmg
	self.vel = vec.new(params.velx or 0, params.vely or 0)

	self.ghost = true

	if params.decay then
		Timer.after(params.decay, function() ewo:remove(self) end)
	end

	if params.spr then
		self.spr = params.spr
		if params.spritesheet then
			self.spritesheet = params.spritesheet
			self.spr:gotoFrame(1)
			self.spr:resume()
		end
		self.draw = true
	end

	ewo:add(self)
end

function DamageBox:collide(other)
	if other.name ~= 'DamageBox' then ewo:remove(self) end
end

return DamageBox
