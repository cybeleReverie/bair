local Cosmetic = class 'Cosmetic'

function Cosmetic:init(x, y, velx, vely, spr)
	self.x = x
	self.y = y

	if velx or vely then
		self.w = 1
		self.h = 1
		self.vel = vec.new(velx or 0, vely or 0)
	end

	self.ghost = true

	self.spr = spr
--	self.spritesheet = params.spritesheet
	self.draw = true
	self.depth = 10

	ewo:add(self)
end

return Cosmetic
