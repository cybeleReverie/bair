local moveSys = tiny.processingSystem()
moveSys.filter = tiny.requireAll('vel', 'pos')
moveSys.isUpdateSys = true

local gx, gy
function moveSys:process(e, dt)
	--migrate to gravitySys?
	if e.gravity == true then
		e.vel.y = math.min(e.vel.y + (e.gravSpeed or 10), 230)
	end

	--attempt to move to goal position
	gx, gy = e.warpX or e.pos.x + e.vel.x * dt, e.warpY or e.pos.y + e.vel.y * dt
	if e.warpX then e.warpX = nil end
	if e.warpY then e.warpY = nil end

	e.pos.x, e.pos.y, e.cols = bwo:move(e, gx, gy, e.filter)
end

return moveSys
