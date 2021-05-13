local Turtledove = class 'Turtledove'
Turtledove:with(enemyAI)

function Turtledove:init(x, y)
	self.x = x
	self.y = y
	self.w = 42
	self.h = 16
	self.vel = vec.new()
	self.home = {x = 260, y = 102}
	self.speed = 100

	self.hp = 10

	self.draw = true
	self.ox = 10
	self.oy = 6

	self.spritesheet = img.turtledove
	self.spr = spr.turtledove.idle

	self.states = {
		Idle = {
			callback = function(self)
				--stay still
				self.vel.x = 0
				self.vel.y = 0
				self.speed = 8

				self.timer:after(math.random(2, 4),
					function()
						self:switchState('Attack')
					end)

				self.spr = spr.turtledove.idle
			end,
			update = function(self)
				self:moveTowardsPoint(self.gx, self.gy)
			end
		},
		Attack = {
			--ground rush
			{callback = function(self)
				self.timer:after(0.2, function()
					self.gx = 24
					self.gy = self.home.y
					self.speed = math.random(280, 400)

					self.spr = spr.turtledove.rush
				end)

				self.spr = spr.turtledove.preRush
			end,
			update = function(self)
				--move towards attack spot
				self:moveTowardsPoint(self.gx, self.gy)

				if self:atGoalPos() and self.gx ~= self.home.x then
					self.vel.x, self.vel.y = 0, 0
					self:switchState('Retreat')
				end
			end},

			--air rush
			{callback = function(self)
				self.timer:after(0.2, function()
					self.gx = 24
					self.gy = self.home.y

					--switch from ground to air
					self.timer:tween(0.25, self, {gy = 48}, 'cubic')
					self.speed = math.random(280, 400)

					self.spr = spr.turtledove.rush
				end)

				--maybe shoot bile ball
				if math.random(4) == 1 then
					self:spitBileBall()
				end

				self.spr = spr.turtledove.preRush
			end,
			update = function(self)
				--move towards attack spot
				self:moveTowardsPoint(self.gx, self.gy)

				if self:atGoalPos() and self.gx ~= self.home.x then
					self:stop()
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

	self.attackWeights = {{33, 1}, {33, 2}, {33, 3}}

	self.isEnemy = true

	ewo:add(self)
end

function Turtledove:spitBileBall()
	local d = DamageBox:new(self.x - 8, self.y + 4, 8, 5, 1, 0, -300, 0)
	d.spr = img.bileBall
	d.draw = true
end

return Turtledove
