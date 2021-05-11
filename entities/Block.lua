local Block = class 'Block'

function Block:init(x, y, velx, vely)
	self.x = x
	self.y = y
	self.w = 24
	self.h = 24

	self.vel = vec.new(velx or 0, vely or 0)

	self.draw = true
	self.spr = img.block

	self.isBlock = true

	self.filter = function(item, other)
		if other.name == 'Player' then return 'cross' end
	end

	ewo:add(self)
end

function Block:update(dt)
end

return Block
