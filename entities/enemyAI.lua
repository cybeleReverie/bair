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

function enemyAI:setGoalPos(x, y)
	self.goal.x, self.goal.y = x, y
end

function enemyAI:setSpeed(spd)
	self.speed = spd
end

function enemyAI:atGoalPos()
	return self.x == self.goal.x and self.y == self.goal.y
end

function enemyAI:stopMoving()
	self.vel.x, self.vel.y = 0, 0
end

--AI utility functions
function enemyAI:distToPoint(x, y)
	return lume.distance(self.x, self.y, x, y)
end

return enemyAI
