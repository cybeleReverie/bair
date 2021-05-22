local attack = require 'moves/attacks'
local spell = require 'moves/spells'

--

local Player = class 'Player'
Player:with(fsm)

function Player:init(x, y)
	self.x = x
	self.y = y
	self.w = 16
	self.h = 28

	self.vel = vec.new()
	self.gravity = true
	self.persistOffscreen = true

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
	self.canAttack = true
	self.isAttacking = false

	--moveset
	self.attacks = {
		[5] = attack.basic,
		[6] = attack.farclaw
	}
	self.curAttack = 5

	self.spells = {}
	self.curSpell = 1

	--private timer instance
	self.timer = Timer.new()

	--fsm states
	self.states = {
		Walk = {
			callback = function(self)
				self.vel.y = 0
				self.hov = self.maxHov
				self.gravity = true

				self:changeSprite(spr.bair.walk)
			end,
			update = function(self)
				self.vel.y = 0

				if self:checkOnGround() == false then
					self:switchState('InAir')
				end

				if Input:pressed('jump') then
					self.vel.y = -self.jumpHeight
					self:switchState('InAir')
				end

				if Input:pressed('attack') and self.canAttack == true and not (self.y < 104) then
					self:switchState('Attack')
				end
			end
		},
		InAir = {
			callback = function(self)
				self.gravity = true
			end,
			update = function(self)
				if self:checkHeadBump() then
					self.vel.y = 0
				end

				if self:checkOnGround() then
					self:switchState('Walk')
				end

				if Input:pressed('jump') or (Input:down('jump') and self.vel.y == 0) then
					if self.hov > 0 and not self:checkHeadBump() then self:switchState('Hover') end
				end

				if Input:released('jump') then
					--shorten jump height if jumping
					if self.vel.y < 0 then self.vel.y = self.vel.y / 1.8 end
				end

				if self.vel.y < 0 then
					self:changeSprite(spr.bair.jump)
				elseif self.vel.y > 0 then
					self:changeSprite(spr.bair.fall)
				end
			end
		},
		Hover = {
			callback = function(self)
				self.gravity = false
				self.vel.y = 0

				self:changeSprite(spr.bair.hover)
			end,
			update = function(self, dt)
				if self.hov <= 0 or Input:released('jump') then
					self:switchState('InAir')
				end

				if self:checkOnGround() then
					self:switchState('Walk')
				end

				self.hov = math.max(0, self.hov - dt)
			end
		},
		Attack = {
			callback = function(self)
				self.curAttack.enter(self)
				self.atkExit = self.curAttack.exit
				self.canAttack = false

				self:changeSprite(self.curAttack.sprite)
			end,
			update = function(self)
				if self.curAttack.update then
					self.curAttack.update(self)
				end

				if Input:released('attack') then
					if self.atkExit then
						self.curAttack.exit(self)
						self.atkExit = nil
					end
				end
			end,
			exit = function(self)
				self.timer:after(self.curAttack.rechargeTime, function() self.canAttack = true end)
			end
		},
		-- _switchCallback = function(self, state) --called by FSM upon switching state
		-- 	clear all timers & tweens
		-- 	self.timer:clear()
		-- end
	}

	self:switchState('Walk')

	--bump filter
	self.filter = function(item, other)
		if other.isEnemy 			then return 'cross'
		elseif other.isBlock		then return 'slide'
		elseif other.ghost == true	then return 'cross' end
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
	self.timer:update(dt)
	self:updateState(dt)

	--block collision
	if self:checkHBlockCollision() then
		if self:closeEnough() == false then self.damage = 1 end
	end

	--select attack
	if self.state ~= self.states.Attack then
		local atk = 5

		if Input:down('right') then atk = atk + 1 end
		if Input:down('left') then atk = atk - 1 end
		if Input:down('up') then atk = atk - 3 end
		if Input:down('down') then atk = atk + 3 end

		self.curAttack = self.attacks[atk]
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
	local grounded = false
	lume.each(q, function(i) if i.name == 'Block' then grounded = true end end)
	return grounded
end

function Player:checkHBlockCollision(x, y)
	local q = bwo:queryRect(x or self.x, y or self.y, self.w, self.h)
	local collision = false
	lume.each(q, function(i) if i.name == 'Block' then collision = true end end)
	return collision
end

function Player:checkHeadBump()
	local q = bwo:queryRect(self.x, self.y - 1, self.w, 1)
	local bumped = false
	lume.each(q, function(i) if i.name == 'Block' then bumped = true end end)
	return bumped
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

function Player:changeSprite(spr)
	self.spr = spr

	if self.spr.draw then
		self.spr:gotoFrame(1)
		self.spr:resume()
	end
end

return Player
