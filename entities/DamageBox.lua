local DamageBox = class 'DamageBox'

function DamageBox:init(params)
	self.x = params.x
	self.y = params.y
	self.w = params.w
	self.h = params.h
	self.dmg = params.dmg
	self.vel = vec.new(params.velx or 0, params.vely or 0)
	self.dealer = params.dealer

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

	self.ox, self.oy = params.ox, params.oy

	if not params.persistOnCollide then
		self.collide = function(self, other)
			if not other.ghost then ewo:remove(self) end
		end
	end

	ewo:add(self)
end

return DamageBox
