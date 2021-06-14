local initStates = require('entities/single/player/playerStates')
local attack = require 'src/attacks'
local spell = require 'src/spells'

--

local Player = class 'Player'
Player:with(fsm)

function Player:init(x, y, playClass, name)
	self.givenName = name
	self.title = 'INSERT TITLE'
	self.pos = vec.new(x, y)
	self.xFix = x
	self.w = 16
	self.h = 30

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

	self.maxHp = 5;						self.hp = self.maxHp
	self.maxMp = 5;						self.mp = self.maxMp

	self.maxStr = playClass.stats.str;	self.str = self.maxStr
	self.maxDex = playClass.stats.dex;	self.dex = self.maxDex
	self.maxInt = playClass.stats.int;	self.int = self.maxInt
	self.maxHov = playClass.stats.hov;	self.hov = self.maxHov

	self.pow = 1
	self.mag = 1

	self.maxHovTime = 0.65;	self.hovTime = self.maxHovTime
	self.minRollTime = 0.6
	self.maxRollTime = 1.5
	self.mpRegenSpeed = 8

	self.skillPoints = {
		self.playClass.trees[1].color,
		self.playClass.trees[2].color,
		self.playClass.trees[3].color
	}

	self.jumpHeight = 295
	self.canAttack = true
	self.canRun = true
	self.canRoll = true
	self.running = false

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
	self.states = initStates(self)

	self:switchState 'Walk'

	--
	gs.Game.signal:register('enemyDefeated', function(enemy) self.exp = self.exp + enemy.expDrop end)

	--bump filter
	self.filter = function(item, other)
		if other.isEnemy 			then return 'cross'
		elseif other.isBlock		then return 'slide'
		elseif other.ghost == true	then return 'cross' end
	end

	--graphics stuff
	self.draw = Player.draw
	self.ox = 9
	self.oy = 90
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
	self.maxExp = self.expLevel * 8
	if self.exp >= self.maxExp then
		self.exp = math.abs(self.maxExp - self.exp)
		self.expLevel = self.expLevel + 1
	end

	--spellcasting
	if Input:pressed 'cast'
		and self.mp - self.curSpell.cost >= 0
		and self.canAttack == true
		and self.curSpell then

		local wt = self.curSpell.windupTime
		self.spellLag = math.max(wt - (self.int * 0.08 + self.dex * 0.025), 0)
		self.canAttack = false
		self.casting = true

		self:changeSprite(spr.bair.castCharge)
	end

	if self.casting == true then
		self.canRun = false
		self:stopRunning()
		if self.spellLag then
			if self.spellLag > 0 then
				self.spellLag = self.spellLag - dt
			else
				self.mp = self.mp - self.curSpell.cost
				self.curSpell.enter(self)
				self.spellLag = nil

				self:changeSprite(self.curSpell.sprite or spr.bair.castSpell)
			end
		else
			if self.curSpell.update then
				self.curSpell.update(self)
			else
				self:endSpell()
			end
		end

		if Input:released 'cast' then
			if self.casting == true then self:endSpell() end
		end
	end

	--select attack
	if not self:inState 'Attack' and self.canAttack == true then
		local atk, spl = 5, 3

		if Input:down 'right' then atk = atk + 1; spl = spl + 1 end
		if Input:down 'left' then atk = atk - 1 end
		if Input:down 'up' then atk = atk - 3; spl = spl - 2 end
		if Input:down 'down' then atk = atk + 3; spl = spl + 2 end

		if self.attacks[atk] then self.curAttack = self.attacks[atk] end
		if self.spells[spl] then self.curSpell = self.spells[spl] end
	end

	--maintain x pos on thick wall collisions
	if self.pos.x ~= self.xFix then
		local i = -6
		while self:checkHBlockCollision(self.xFix, self.pos.y + i) do
			i = i - 6
		end

		self.warpX = self.xFix
		self.warpY = self.pos.y - i
	end
end

--
function Player:stopRunning()
	if self.running == true then
		gs.Game.signal:emit('toggleRun')
		self.running = false
	end
end

function Player:endSpell()
	if self.curSpell.exit then self.curSpell.exit(self) end

	local splRechargeTime
	if not self.spellLag then
		splRechargeTime = math.max(self.curSpell.rechargeTime - self.int * 0.075, 0)
	else
		splRechargeTime = math.max(self.curSpell.rechargeTime - self.int * 0.075, 0) / 2.5
	end
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
	self.canRun = true

	if self.curSpell.update then
		self:changeSprite(spr.bair.walk)
	else
		self.timer:after(0.25, function() self.spr:gotoFrame(2) end)
		self.timer:after(0.32, function()
			if self.running == true then self:changeSprite(spr.bair.run)
			else self:changeSprite(spr.bair.walk) end
		end)
	end
end

--collision callback
function Player:collide(other)
	if other.isEnemy or class.inheritsFrom(other, DamageBox) then
		self.damage = 1
		if self:inState 'Hover' then self:switchState 'InAir' end
	end
end

--graphics
function Player:draw()
	local dt = love.timer.getDelta()
	lg.setColor(col.white)

	if self.sprEffect then
		self.sprEffect.anim:draw(self.sprEffect.img, self.pos.x, self.pos.y, 0, 1, 1,
			self.ox + (self.sprEffect.ox or 0), self.oy + (self.sprEffect.oy or 0))
		self.sprEffect.anim:update(dt)
	end
end

function Player:changeSprite(sprite, frame)
	self.spr = sprite
	self.sprEffect = nil

	--select spritesheet
	if sprite == spr.bair.walk or sprite == spr.bair.run or sprite == spr.bair.jump or sprite == spr.bair.fall
		or sprite == spr.bair.hover or sprite == spr.bair.attackBasic or sprite == spr.bair.attackFarclaw then

		self.spritesheet = img.bair
	elseif sprite == spr.bair.rollEnterExit or sprite == spr.bair.rollMid or sprite == spr.bair.castCharge
		or sprite == spr.bair.castSpell then
		self.spritesheet = img.bair2
	end

	--sprite effects
	if sprite == spr.bair.hover then
		self.sprEffect = cat '{anim = spr.bair.effect.hover, img = img.hoverEffect}'
	elseif sprite == spr.bair.attackBasic then
		self.sprEffect = cat '{anim = spr.bair.effect.claw, img = img.clawEffect}'
	elseif sprite == spr.bair.attackFarclaw then
		self.sprEffect = cat '{anim = spr.bair.effect.farclawSwipe, img = img.farclawSwipe}'
	elseif sprite == spr.bair.castCharge then
		self.sprEffect = cat '{anim = spr.bair.effect.castCharge, img = img.castChargeEffect, ox = 10, oy = -87}'
	end

	if self.sprEffect then self.sprEffect.anim:resume() end

	if self.spr.draw then
		self.spr:gotoFrame(frame or 1)
		self.spr:resume()
	end
end

--utilities
function Player:checkOnGround()
	return lu.any(bwo:queryRect(self.pos.x, self.pos.y + self.h, self.w, 1), lm 'i -> i.isBlock')
end

function Player:checkHBlockCollision(x, y)
	return lu.any(bwo:queryRect(x or self.pos.x, y or self.pos.y, self.w, self.h), lm 'i -> i.isBlock')
end

function Player:checkHeadBump()
	return lu.any(bwo:queryRect(self.pos.x, self.pos.y - 1, self.w, 1), lm 'i -> i.isBlock')
end

function Player:closeEnough()
	for i = 1, 12 do
		if not self:checkHBlockCollision(self.pos.x, self.pos.y - i) then
			return true
		end
	end
	for i = 1, 12 do
		if not self:checkHBlockCollision(self.pos.x, self.pos.y + i) then
			self.warpY = self.pos.y + i
			return true
		end
	end

	return false
end

function Player:spaceToAttack()
	local q = {}
	for i = 0, 1 do
		q[#q + 1] = bwo:queryRect(self.pos.x + self.w + i * 18, self.pos.y + self.h, 18, 1)
	end
	return lu.all(q, lm 'x -> lu.any(x, lm "i -> i.isBlock")')
end

return Player

--old spell windup animation, maybe salvage?

--local spellBg = {opacity = 0}
-- function Player:draw()
-- 	--draw spell chargeup
-- 	if self.spellLag then
-- 		local xx, yy =
-- 			self.pos.x / 3 + self.w / 6 + gs.Game.camera.x - 160,
-- 			self.pos.y / 3 + self.h / 6 + gs.Game.camera.y - 90
--
-- 		love.graphics.setCanvas(shapesCanvas)
-- 		lg.setColor(0.9, 0, 0.7, spellBg.opacity)
-- 		if spellBg.opacity == 0 then
-- 			self.timer:tween(math.max(self.curSpell.rechargeTime - self.int * 0.075, 0) / 2.5,
-- 				spellBg,{opacity = 0.3}, 'quad')
-- 		end
-- 		lg.circle('fill', xx, yy, self.spellLag * 20, self.spellLag * 10 + 3)
-- 		lg.setColor(0.8, 0, 0.85)
-- 		lg.circle('line', xx, yy, self.spellLag * 20, self.spellLag * 10 + 3)
-- 		love.graphics.setCanvas()
-- 	else
-- 		spellBg.opacity = 0
-- 	end
-- end
