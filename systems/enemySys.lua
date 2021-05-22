local enemySys = tiny.processingSystem()
enemySys.filter = tiny.requireAll('isEnemy')
enemySys.isUpdateSys = true

function enemySys:onAdd(e)
	e.goal = {x = e.home.x, y = e.home.y}

	--collision callback
	e.collide = function(this, other)
		if other.name == 'DamageBox' then
			--take damage
			this.damage = other.dmg
		end
	end

	--private timer instance
	e.timer = Timer.new()

	--common states
	e.states._switchCallback = function(this, state) --called by FSM upon switching state
		--clear all timers & tweens
		this.timer:clear()
	end

	e.states.Attack.callback = function(this)
		local s = this.states['Attack'][random.weightedChoice(this.attackWeights)]

		this.states._switchCallback(this)

		this.state = s
		if s.callback then s.callback(this) end
	end

	e.states.Enter = { --consolidate w/ retreat?
		callback = function(this)
			--reset goal coords to home
			this:setGoalPos(this.home.x, this.home.y)

			--switch to idle sprite
			this.spr = spr[string.lower(this.name)].idle
		end,
		update = function(this)
			--move towards home
			this:moveTowardsPoint(this.home.x, this.home.y)

			if this:atGoalPos() then
				this:switchState('Idle')
			end
		end
	}

	e.states.Retreat = {
		callback = function(this)
			this:setGoalPos(this.home.x, this.home.y)
			this:setSpeed(200)

			this.spr = spr[string.lower(this.name)].idle
		end,
		update = function(this)
			this:moveTowardsPoint(this.goal.x, this.goal.y, this.speed)

			if this:atGoalPos() then
				this:switchState('Idle')
			end
		end
	}

	--bump filter
	e.filter = function(item, other)
		if other.name == 'Player' 	then return 'cross'
		elseif other.ghost == true	then return 'cross' end
	end

	--switch to enter state
	e:switchState('Enter')
end

function enemySys:process(e, dt)
	--update state
	e:updateState()

	--retreat if hurt
	if e.invincible then e:switchState('Retreat') end

	--update private timer
	e.timer:update(dt)
end

function enemySys:onRemove(e)
	Timer.after(random.num(4, 6), function()
		Signal.emit('spawnEncounter', random.weightedChoice({obstacle = 75, enemy = 25}))
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
