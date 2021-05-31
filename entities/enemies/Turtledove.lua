local Turtledove = class 'Turtledove'
Turtledove:with(enemyAI, fsm)

function Turtledove:init(x, y)
	self.pos = vec.new(x, y)
	self.w = 42
	self.h = 16
	self.vel = vec.new()
	self.home = {x = 260, y = 102}
	self.speed = 100

	self.hp = 20
	self.expDrop = 3

	self.draw = true
	self.ox = 10
	self.oy = 6

	self.spritesheet = img.turtledove
	self.spr = spr.turtledove.idle

	self.states = {
		Idle = {
			callback = function(self)
				--stay still
				self:stopMoving()

				self.timer:after(random.num(0.9, 2.9),
					function()
						self:switchState('Attack')
					end)

				self.spr = spr.turtledove.idle
			end,
			update = function(self)
				self:moveTowardsGoal()
			end
		},
		Attack = {
			--ground rush
			{callback = function(self)
				self.timer:after(0.2, function()
					self:setGoalPos(24, self.home.y)
					self:setSpeed(random.num(280, 400))

					self.spr = spr.turtledove.rush
				end)

				self.spr = spr.turtledove.preRush
			end,
			update = function(self)
				--move towards attack spot
				self:moveTowardsGoal()

				if self:atGoalPos() and self.goal.x ~= self.home.x then
					self:stopMoving()
					self:switchState('Retreat')
				end
			end},

			--air rush
			{callback = function(self)
				self.timer:after(0.2, function()
					self:setGoalPos(24, self.home.y)

					--switch from ground to air
					self.timer:tween(0.25, self.goal, {y = 48}, 'cubic')
					self:setSpeed(random.num(280, 400))

					self.spr = spr.turtledove.rush
				end)

				--maybe shoot bile ball
				if random.chance(3) then
					self:spitBileBall()
				end

				self.spr = spr.turtledove.preRush
			end,
			update = function(self)
				--move towards attack spot
				self:moveTowardsGoal(self.goal.x, self.goal.y)

				if self:atGoalPos() and self.goal.x ~= self.home.x then
					self:stopMoving()
					self:switchState('Retreat')
				end
			end},

			--spit bile ball
			{callback = function(self)
				self:spitBileBall()

				self.timer:after(0.25, function()
					self:switchState('Idle')
				end)

				self.spr = spr.turtledove.rush
			end}
		}
	}

	self.attackWeights = {[1] = 33, [2] = 33, [3] = 33}

	self.isEnemy = true

	ewo:add(self)
end

function Turtledove:spitBileBall()
	local d = DamageBox:new{
		x = self.pos.x - 8,
		y = self.pos.y + 4,
		w = 8, h = 5,
		dmg = 1,
		velx = -350 + random.num(20),
		dealer = self,
		spr = img.bileBall
	}
end

return Turtledove
