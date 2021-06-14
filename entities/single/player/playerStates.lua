return function(self)
	return {
		Walk = {
			callback = function(self)
				self.vel.y = 0
				self.hovTime = self.maxHovTime
				self.gravity = true

				self:stopRunning()

				self:changeSprite(spr.bair.walk)
			end,
			update = function(self)
				self.vel.y = 0

				if self:checkOnGround() == false then
					self:switchState 'InAir'
				end

				if Input:pressed 'jump' then
					self.vel.y = -self.jumpHeight
					self:switchState 'InAir'
				elseif Input:pressed 'attack'
					and self.canAttack == true
					and self.curAttack
					and self:spaceToAttack() then

					self:switchState 'Attack'
				end

				if Input:down 'run' and self.canRun == true then
					if Input:down 'down' and self.canRoll == true then
						self:switchState 'Roll'
						return
					end
					if self.running == false then
						gs.Game.signal:emit('toggleRun')
						self.running = true
						self:changeSprite(spr.bair.run)
					end
				end
				if Input:released 'run' then
					self:stopRunning()

					self:changeSprite(spr.bair.walk)
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
					self:switchState 'Walk'
				end

				if Input:pressed 'jump' or (Input:down 'jump' and math.abs(self.vel.y) < 6) then
					if self.hovTime > 0 and not self:checkHeadBump() then
						self:switchState 'Hover'
					end
				end

				if Input:released 'jump' then
					--shorten jump height if jumping
					if self.vel.y < 0 then self.vel.y = self.vel.y / 2.2 end
				end

				if Input:released 'run' then
					self:stopRunning()
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
				if self.hovTime <= 0 or Input:released 'jump' then
					self:switchState 'InAir'
				end

				if self:checkOnGround() then
					self:switchState'Walk'
				end

				self.hovTime = math.max(0, self.hovTime - dt)
			end
		},
		Attack = {
			callback = function(self)
				self.curAttack.enter(self)
				self.atkExit = self.curAttack.exit
				self.canAttack = false
				self:stopRunning()
				self.canRun = false

				self:changeSprite(self.curAttack.sprite)
			end,
			update = function(self)
				if self.curAttack.update then
					self.curAttack.update(self)
				end

				if Input:released 'attack' then
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
				self.canRun = true

				self.blinking = {atkRechargeTime, '#52fffa'}
			end
		},
		Roll = {
			callback = function(self)
				self.rollTime = 0
				self.stopRolling = false

				self:stopRunning()
				gs.Game.signal:emit('toggleRun', 16)
				self.running = true

				self.newH = 20
				self.warpY = self.pos.y + 8

				self.oy = 100
				self:changeSprite(spr.bair.rollEnterExit)
				self.timer:after(spr.bair.rollEnterExit:getAnimDur(1, 1),function()
					self:changeSprite(spr.bair.rollMid)
				end)
			end,
			update = function(self, dt)
				if self.rollTime then self.rollTime = self.rollTime + dt end

				if self.stopRolling == false and ((Input:released 'down' or Input:released 'run')
					or self.rollTime >= self.maxRollTime
					or self:checkHBlockCollision()) then

					self.stopRolling = true
				end

				if self.stopRolling == true and self.rollTime and self.rollTime >= self.minRollTime then
					self.rollTime = nil

					self:changeSprite(spr.bair.rollEnterExit, 2)
					self.timer:after(spr.bair.rollEnterExit:getAnimDur(2, 2), function()
						self:switchState 'Walk'
					end)
				end
			end,
			exit = function()
				self.canRoll = false
				Timer.after(1, function() self.canRoll = true end)
				self.blinking = cat '{1, "#ffd800"}'

				self:stopRunning()
				self.stopRolling = nil

				self.newH = 30
				self.oy = 90
			end
		}
	}
end
