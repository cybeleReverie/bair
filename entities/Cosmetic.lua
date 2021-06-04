local Cosmetic = class 'Cosmetic'

function Cosmetic:init(params)
	self.pos = vec.new(params.x, params.y)
	self.w = params.w
	self.h = params.h

	if params.velx or params.vely or params.scroll then
		if not self.w then self.w = 1 end
		if not self.h then self.h = 1 end
		self.vel = vec.new(params.velx or 0, params.vely or 0)
--		if params.scroll == true then self.vel.x = -gs.Game.hspeed end
	end
	self.scroll = params.scroll

	self.gravity = params.gravity
	self.update = params.update
	self.collide = params.collide

	if params.filter then self.filter = params.filter else self.ghost = true end

	self.spr = params.spr
	self.spritesheet = params.spritesheet
	self.ox, self.oy = params.ox, params.oy
	self.draw = true
	self.depth = params.depth or 10

	ewo:add(self)
end

return Cosmetic
