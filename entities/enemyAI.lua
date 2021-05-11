local enemyAI = class 'enemyAI' --mixin class for enemy AI functionality

--AI primitives
function enemyAI:moveTowardsPoint(x, y)
	--calculate velocity towards point
	self.vel.x = x - self.x
	self.vel.y = y - self.y
	self.vel:normalizeInplace()
	self.vel = self.vel * self.speed

	--snap to goal if close enough
	if self:distToPoint(x, y) <= 5 then
		self.warpX = x
		self.warpY = y
	end
end

function enemyAI:atGoalPos()
	return self.x == self.gx and self.y == self.gy
end

--state machine functions
function enemyAI:switchState(state)
	local s = self.states[state]

	--clear all timers
	self.timer:clear()

	--choose random attack
	if state == 'Attack' then
		s = self.states[state][util.rnd(self.attackWeights)]
	end

	self.state = s

	--call new state callback
	if s.callback then s.callback(self) end
end

--AI utilities
function enemyAI:distToPoint(x, y)
	return math.abs(self.x - x) + math.abs(self.y - y)
end

return enemyAI
