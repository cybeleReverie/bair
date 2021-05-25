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
	self.maxHp = 5;			self.hp = self.maxHp
	self.maxMp = 5;			self.mp = self.maxMp

	self.maxStr = 3;		self.str = self.maxStr
	self.maxDex = 3;		self.dex = self.maxDex
	self.maxInt = 3;		self.int = self.maxInt

	self.maxPow = 3;		self.pow = self.maxPow
	self.maxHov = 1;		self.hov = self.maxHov
	self.maxMag = 3;		self.mag = self.maxMag

	self.maxHovTime = 0.5;	self.hovTime = self.maxHovTime

	self.jumpHeight = 290
	self.canAttack = true

	--moveset
	self.attacks = {
		[5] = attack.basic,
		[6] = attack.farclaw
	}
	self.curAttack = self.attacks[5]

	self.spells = {
		[3] = spell.fireball
	}
	self.curSpell = self.spells[3]

	--private timer instance
	self.timer = Timer.new()

	--regenerate MP
	self.mpRegenTimer = self.timer:every(8, function()
		if self.mp < self.maxMp then self.mp = self.mp + 1 end
	end)

	--fsm states
	self.states = {
		Walk = {
			callback = function(self)
				self.vel.y = 0
				self.hovTime = self.maxHovTime
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

				if Input:pressed('attack')
					and self.canAttack == true
					and self.curAttack
					and not (self.y < 104) then
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
					if self.hovTime > 0 and not self:checkHeadBump() then self:switchState('Hover') end
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
				if self.hovTime <= 0 or Input:released('jump') then
					self:switchState('InAir')
				end

				if self:checkOnGround() then
					self:switchState('Walk')
				end

				self.hovTime = math.max(0, self.hovTime - dt)
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
				self.timer:after(self.curAttack.rechargeTime, function()
					self.canAttack = true
				end)

				self.blinking = self.curAttack.rechargeTime
			end
		}
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
	self.opacity = 1

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

	--spellcasting
	if self.curSpell then
		if Input:pressed('cast') and self.mp - self.curSpell.cost >= 0 and self.canAttack == true then
			self.curSpell.enter(self)
			self.mp = self.mp - self.curSpell.cost
			self.canAttack = false
		end

		if Input:down('cast') then
			if self.curSpell.update then self.curSpell.update(self) end
		end

		if Input:released('cast') then
			if self.curSpell.exit then self.curSpell.exit(self) end

			self.timer:after(self.curSpell.rechargeTime, function()
				self.canAttack = true
			end)

			if self.mp > 0 then self.timer:reset(self.mpRegenTimer) end

			self.blinking = self.curSpell.rechargeTime
		end
	end

	--select attack
	if self.state ~= self.states.Attack and self.canAttack == true then
		local atk, spl = 5, 3

		if Input:down('right') then atk = atk + 1; spl = spl + 1 end
		if Input:down('left') then atk = atk - 1 end
		if Input:down('up') then atk = atk - 3; spl = spl - 2 end
		if Input:down('down') then atk = atk + 3; spl = spl + 2 end

		self.curAttack, self.curSpell = self.attacks[atk], self.spells[spl]
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
	for i = 1, 10 do
		if not self:checkHBlockCollision(self.x, self.y - i) then
			return true
		end
	end
	for i = 1, 10 do
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
