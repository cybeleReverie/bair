local Player = class 'Player'

function Player:init(x, y)
	self.x = x
	self.y = y
	self.w = 16
	self.h = 28

	self.vel = vec.new()
	self.gravity = true

	--stats
	self.maxHp = 10		self.hp = self.maxHp
	self.maxMp = 5		self.mp = self.maxMp

	self.maxStr = 3		self.str = self.maxStr
	self.maxDex = 3		self.dex = self.maxDex
	self.maxInt = 3		self.int = self.maxInt

	self.maxPow = 3		self.pow = self.maxPow
	self.maxHov = 0.5 	self.hov = self.maxHov
	self.maxMag = 3		self.mag = self.maxMag

	self.jumpHeight = 290
	self.attackRecharge = 1.1
	self.canAttack = true
	self.isAttacking = false

	--moveset
	self.moves = {
		{}, {}, {},
		{}, {}, {},
		{}, {}, {}
	}

	--private timer instance
	self.timer = Timer.new()

	--bump filter
	self.filter = function(item, other)
		if other.isEnemy 					then return 'cross'
		elseif other.isBlock				then return 'slide'
		elseif other.name == 'DamageBox'	then return 'cross' end
	end

	--graphics stuff
	self.draw = true
	self.ox = 9
	self.oy = 12

	self.spritesheet = img.bair
	self.spr = spr.bair.walk

	ewo:add(self)
end

function Player:update(dt)
	--[[try to keep update loop as stateless as possible.
	separate graphics from game logic as much as possible;
	put all graphics stuff at the bottom of each function/code block
	]]

	local onGround = self:checkOnGround()
	local isHovering = self.gravity == false and self.vel.y == 0

	self.timer:update(dt)

	if onGround then
		self.vel.y = 0
		self.hov = self.maxHov

		if not self.isAttacking then self.spr = spr.bair.walk end
	end

	--limit hovering
	if isHovering then
		self.hov = math.max(0, self.hov - dt)

		self.spr = spr.bair.hover
	end

	if self.hov <= 0 then
		self.gravity = true
	end

	--block collision
	if self:checkHBlockCollision() then
		self.gravity = true

		if self:closeEnough() == false then self.damage = 1 end
	end

	if self:checkHeadBump() then
		self.vel.y = 0
	end

	--player controls
	if Input:pressed('jump') and self.isAttacking == false then
		if onGround then
			self.vel.y = -self.jumpHeight
			self.hov = self.maxHov
		else
			--hover if jumping midair
			self:hover()
		end
	end

	if self.vel.y == 0 and not onGround then
		--hover at max jump height
		self:hover()
	end

	if Input:released('jump') then
		--enable gravity if hovering
		self.gravity = true

		--shorten jump height if jumping
		if self.vel.y < 0 then self.vel.y = self.vel.y / 1.8 end
	end

	if Input:pressed('attack') and self.canAttack and onGround then
		self.timer:after(0.29, function()
			DamageBox:new(self.x + self.w + 32, self.y + 4, 16, 24, self.pow, 0.2, 140)
		end)

		self.canAttack = false
		self.isAttacking = true

		self.timer:after(self.attackRecharge, function() self.canAttack = true end)

		self.spr = spr.bair.attack
	end

	Signal.register('attackComplete', function()
		self.isAttacking = false
		spr.bair.attack:gotoFrame(1)
	end)

	--graphics stuff
	if self.vel.y < 0 then
		self.spr = spr.bair.jump
	elseif self.vel.y > 0 then
		if self.isAttacking then
			Signal.emit('attackComplete')
		end

		self.spr = spr.bair.fall
	end
end

--collision callback
function Player:collide(other)
	if other.isEnemy or other.name == 'DamageBox' then
		--take damage
		self.damage = 1
		self.gravity = true
		self.hov = 0
	end
end

--utilities
function Player:checkOnGround()
	local q = bwo:queryRect(self.x, self.y + self.h, self.w, 1)
	for i in ipairs(q) do
		if q[i].name == 'Block' then
			return true
		end
	end
end

function Player:checkHBlockCollision(x, y)
	local q = bwo:queryRect(x or self.x, y or self.y, self.w, self.h)
	for i in ipairs(q) do
		if q[i].name == 'Block' then
			return true
		end
	end
end

function Player:checkHeadBump()
	local q = bwo:queryRect(self.x, self.y - 1, self.w, 1)
	for i in ipairs(q) do
		if q[i].name == 'Block' then
			return true
		end
	end
end

function Player:hover()
	if self.hov > 0 then
		self.gravity = false
		self.vel.y = 0
	end
end

function Player:closeEnough()
	for i = 1, 6 do
		if not self:checkHBlockCollision(self.x, self.y - i) then
			return true
		end
	end
	for i = 1, 6 do
		if not self:checkHBlockCollision(self.x, self.y + i) then
			return true
		end
	end

	return false
end

return Player
