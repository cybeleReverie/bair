local enemySys = tiny.processingSystem()
enemySys.filter = tiny.requireAll('isEnemy')
enemySys.isUpdateSys = true

function enemySys:onAdd(e)
	--collision callback
	e.collide = function(this, other)
		if other.name == 'DamageBox' then --generalize later
			--take damage
			this.damage = other.dmg
		end
	end

	--common states
	e.states.Enter = { --consolidate w/ retreat?
		callback = function(self)
			--reset goal coords to home
			e.gx = e.home.x
			e.gy = e.home.y

			--switch to idle sprite
			e.spr = spr[string.lower(e.name)].idle
		end,
		update = function(self)
			--move towards home
			self:moveTowardsPoint(self.home.x, self.home.y)

			if self:atGoalPos() then
				self:switchState('Idle')
			end
		end
	}

	e.states.Retreat = {
		callback = function(self)
			self.gx = self.home.x
			self.gy = self.home.y
			self.speed = 200

			e.spr = spr[string.lower(e.name)].idle
		end,
		update = function(self)
			self:moveTowardsPoint(self.gx, self.gy, self.speed)

			if self:atGoalPos() then
				self:switchState('Idle')
			end
		end
	}

	--private timer instance
	e.timer = Timer.new()

	--bump filter
	e.filter = function(item, other)
		if other.name == 'Player' then return 'cross'
		elseif other.name == 'DamageBox' then return 'cross' end
	end

	--switch to enter state
	e:switchState('Enter')
end

function enemySys:process(e, dt)
	--update state
	if e.state.update then e.state.update(e) end

	--retreat if hurt
	if e.invincible then e:switchState('Retreat') end

	--update private timer
	e.timer:update(dt)
end

function enemySys:onRemove(e)
	Timer.after(math.random(4, 6), function()
		Signal.emit('spawnEncounter', util.rnd({{75, 'obstacle'}, {25, 'enemy'}}))
	end)
end

--AI primitives
local function moveTowardsPoint(ent, x, y, spd)
	--calculate velocity towards point
	ent.vel.x = x - ent.x
	ent.vel.y = y - ent.y
	ent.vel:normalizeInplace()
	ent.vel = ent.vel * spd

	--snap to goal if close enough
	if ent:distToPoint(x, y) <= 5 then
		ent.warpX = x
		ent.warpY = y
	end
end

return enemySys
