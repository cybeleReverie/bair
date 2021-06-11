local enemySys = tiny.processingSystem()
enemySys.filter = tiny.requireAll('isEnemy')
enemySys.isUpdateSys = true

function enemySys:onAdd(e)
	gs.Game.signal:emit('enemySpawned', e)

	e.goal = vec.new(e.home.x, e.home.y)

	--collision callback
	e.collide = function(this, other)
		if class.inheritsFrom(other, DamageBox) then
			this.damage = other.dmg
			this:switchState('Retreat')
			--only retreat from melee attacks:
			--if other.dealer.state == other.dealer.states.Attack then this:switchState('Retreat') end
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
			this:moveTowardsGoal()

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
			this:moveTowardsGoal()

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

	--update private timer
	e.timer:update(dt)
end

function enemySys:onRemove(e)
	gs.Game.signal:emit('enemyDefeated', e)
end

return enemySys
