local attack = require 'src/attacks'
local spell = require 'src/spells'

--

local Player = class 'Player'
Player:with(fsm)

function Player:init(x, y, playClass)
	self.pos = vec.new(x, y)
	self.w = 16
	self.h = 28

	self.vel = vec.new()
	self.gravity = true
	self.persistOffscreen = true

	--inventory
	self.inv = {}
	self.equip = {
		weapon = nil,
		amulet = nil,
	}

	--stats
	self.playClass = playClass
	self.expLevel = 1
	self.exp = 0

	self.maxHp = 5;								self.hp = self.maxHp
	self.maxMp = 5;								self.mp = self.maxMp

	self.maxStr = playClass.stats.str;	self.str = self.maxStr
	self.maxDex = playClass.stats.dex;	self.dex = self.maxDex
	self.maxInt = playClass.stats.int;	self.int = self.maxInt
	self.maxHov = playClass.stats.hov;	self.hov = self.maxHov

	self.pow = 1
	self.mag = 1

	self.maxHovTime = 0.5;	self.hovTime = self.maxHovTime
	self.mpRegenSpeed = 8

	self.skillPoints = {
		self.playClass.trees[1].color,
		self.playClass.trees[2].color,
		self.playClass.trees[3].color
	}

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
	self.mpRegenTimer = self.timer:every(self.mpRegenSpeed, function()
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
				elseif Input:pressed('attack')
					and self.canAttack == true
					and self.curAttack then

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
					if self.hovTime > 0 and not self:checkHeadBump() then
						self:switchState('Hover')
					end
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
				local atkRechargeTime = math.max(self.curAttack.rechargeTime - self.dex * 0.03, 0)
				self.timer:after(atkRechargeTime, function()
					self.canAttack = true
				end)

				self.blinking = {atkRechargeTime, '#52fffa'}
			end
		}
	}

	self:switchState('Walk')

	--
	Signal.register('enemyDefeated', function(enemy) self.exp = self.exp + enemy.expDrop end)

	--bump filter
	self.filter = function(item, other)
		if other.isEnemy 			then return 'cross'
		elseif other.isBlock		then return 'slide'
		elseif other.ghost == true	then return 'cross' end
	end

	--graphics stuff
	self.draw = Player.draw
	self.ox = 9
	self.oy = 92
	self.depth = 10
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

	--calculate pow and mag
	self.pow = self.str + self.curAttack.baseDamage
	self.mag = self.int + self.curSpell.baseDamage

	--level up
	local maxExp = self.expLevel * 8
	if self.exp >= maxExp then
		self.exp = math.abs(maxExp - self.exp)
		self.expLevel = self.expLevel + 1
	end

	--spellcasting
	if Input:pressed('cast')
		and self.mp - self.curSpell.cost >= 0
		and self.canAttack == true
		and self.curSpell then

		local wt = self.curSpell.windupTime
		self.spellLag = math.max(wt - (self.int * 0.08 + self.dex * 0.025), 0)
		self.canAttack = false
		self.casting = true

--		self:changeSprite(spr.bair.castCharge)
	end

	if self.casting == true then
		if self.spellLag then
			if self.spellLag > 0 then
				self.spellLag = self.spellLag - dt
			else
				self.mp = self.mp - self.curSpell.cost
				self.curSpell.enter(self)
				self.spellLag = nil

--				self:changeSprite(self.curSpell.sprite or spr.bair.castGeneric)
			end
		else
			if self.curSpell.update then
				self.curSpell.update(self)
			else
				self:endSpell()
			end
		end

		if Input:released('cast') then
			if self.casting == true then self:endSpell() end
		end
	end

	--select attack
	if self.state ~= self.states.Attack and self.canAttack == true then
		local atk, spl = 5, 3

		if Input:down('right') then atk = atk + 1; spl = spl + 1 end
		if Input:down('left') then atk = atk - 1 end
		if Input:down('up') then atk = atk - 3; spl = spl - 2 end
		if Input:down('down') then atk = atk + 3; spl = spl + 2 end

		if self.attacks[atk] then self.curAttack = self.attacks[atk] end
		if self.spells[spl] then self.curSpell = self.spells[spl] end
	end
end

--
function Player:endSpell()
	if self.curSpell.exit then self.curSpell.exit(self) end

	local splRechargeTime = math.max(self.curSpell.rechargeTime - self.int * 0.075, 0)
	if not self.blinking and self.casting == true then
		self.blinking = {splRechargeTime, '#52fffa'}
	end

	if self.canAttack == false then
		self.timer:after(splRechargeTime, function()
			self.canAttack = true
		end)
	end

	if self.mp > 0 and not self.spellLag then self.timer:reset(self.mpRegenTimer) end

	self.spellLag = nil
	self.casting = false

	-- if self.curSpell.update then self:changeSprite(spr.bair.walk)
	-- else self.timer:after(0.3, function() self:changeSprite(spr.bair.walk) end) end
end

--collision callback
function Player:collide(other)
	if other.isEnemy or other.name == 'DamageBox' then
		--take damage
		self.damage = 1
		self.gravity = true
		if self.state == self.states.Hover then self:switchState('InAir') end
	end
end

--utilities
function Player:checkOnGround()
	local q = bwo:queryRect(self.pos.x, self.pos.y + self.h, self.w, 1)
	local grounded = false
	lume.each(q, function(i) if i.name == 'Block' then grounded = true end end)
	return grounded
end

function Player:checkHBlockCollision(x, y)
	local q = bwo:queryRect(x or self.pos.x, y or self.pos.y, self.w, self.h)
	local collision = false
	lume.each(q, function(i) if i.name == 'Block' then collision = true end end)
	return collision
end

function Player:checkHeadBump()
	local q = bwo:queryRect(self.pos.x, self.pos.y - 1, self.w, 1)
	local bumped = false
	lume.each(q, function(i) if i.name == 'Block' then bumped = true end end)
	return bumped
end

function Player:closeEnough()
	for i = 1, 12 do
		if not self:checkHBlockCollision(self.pos.x, self.pos.y - i) then
			return true
		end
	end
	for i = 1, 12 do
		if not self:checkHBlockCollision(self.pos.x, self.pos.y + i) then
			return true
		end
	end

	return false
end

local spellBg = {opacity = 0}
function Player:draw()
	--draw spell chargeup
	if self.spellLag then
		local xx, yy =
			self.pos.x / 3 + self.w / 6 + gs.Game.camera.x - 160,
			self.pos.y / 3 + self.h / 6 + gs.Game.camera.y - 90

		love.graphics.setCanvas(shapesCanvas)
		-- lg.setColor(0.9, 0, 0.80, 0.3)
		-- lg.circle('fill', xx, yy, self.spellLag * 20, self.spellLag * 10 + 3)
		-- lg.setColor(1, 1, 1, self.opacity)
		-- self.spr:draw(self.spritesheet, self.pos.x / 3 + gs.Game.camera.x - 160,
		-- 	self.pos.y / 3 + gs.Game.camera.y - 90, 0, 0.333, 0.333, self.ox, self.oy)
		lg.setColor(0.9, 0, 0.7, spellBg.opacity)
		if spellBg.opacity == 0 then
			self.timer:tween(math.max(self.curSpell.rechargeTime - self.int * 0.075, 0) / 2.5,
				spellBg,{opacity = 0.3}, 'quad')
		end
		lg.circle('fill', xx, yy, self.spellLag * 20, self.spellLag * 10 + 3)
		lg.setColor(0.8, 0, 0.85)
		lg.circle('line', xx, yy, self.spellLag * 20, self.spellLag * 10 + 3)
		love.graphics.setCanvas()
	else
		spellBg.opacity = 0
	end
end

function Player:changeSprite(spr)
	self.spr = spr

	if self.spr.draw then
		self.spr:gotoFrame(1)
		self.spr:resume()
	end
end

return Player
