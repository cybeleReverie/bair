local enemyAI = class 'enemyAI' --mixin class for enemy AI functionality

--AI primitives
function enemyAI:moveTowardsGoal()
	--calculate velocity towards point
	self.vel = self.goal - self.pos
	self.vel:normalizeInplace()
	self.vel = self.vel * self.speed

	--snap to goal if close enough
	if self.pos:dist(self.goal) <= 5 then
		self.warpX = self.goal.x
		self.warpY = self.goal.y
	end
end

function enemyAI:setGoalPos(x, y)
	self.goal.x, self.goal.y = x, y
end

function enemyAI:setSpeed(spd)
	self.speed = spd
end

function enemyAI:atGoalPos()
	return self.pos == self.goal
end

function enemyAI:stopMoving()
	self.vel.x, self.vel.y = 0, 0
end

return enemyAI
