local moveSys = tiny.processingSystem()
moveSys.filter = tiny.requireAll('vel', 'pos')
moveSys.isUpdateSys = true

local running

function moveSys:onAddToWorld()
	gs.Game.signal:register('toggleRun', function()
		running = not running
		if running == true then
			gs.Game.hspeed = gs.Game.hspeed + 20
		else
			if gs.Game.player:checkOnGround() then
				gs.Game.hspeed = gs.Game.defSpeed
			else
				Timer.tween(0.7, gs.Game, {hspeed = gs.Game.defSpeed}, 'linear')
			end
		end
	end)
	if running == true then gs.Game.signal:emit('toggleRun') end
end

local gx, gy, scrollSpeed
function moveSys:process(e, dt)
	scrollSpeed = 0

	--migrate to gravitySys?
	if e.gravity == true then
		e.vel.y = math.min(e.vel.y + (e.gravSpeed or 10), 230)
	end

	if e.scroll == true then
		scrollSpeed = -gs.Game.hspeed
	end

	--attempt to move to goal position
	gx, gy = e.warpX or e.pos.x + (e.vel.x + scrollSpeed) * dt, e.warpY or e.pos.y + e.vel.y * dt
	if e.warpX then e.warpX = nil end
	if e.warpY then e.warpY = nil end

	e.pos.x, e.pos.y, e.cols = bwo:move(e, gx, gy, e.filter)
end

return moveSys
