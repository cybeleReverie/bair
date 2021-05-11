local moveSys = tiny.processingSystem()
moveSys.filter = tiny.requireAll('vel')
moveSys.isUpdateSys = true

function moveSys:process(e, dt)
	--migrate to gravitySys?
	if e.gravity then
		e.vel.y = math.min(e.vel.y + (e.gravSpeed or 10), 230)
	end

	--attempt to move to goal position
	local gx, gy = e.warpX or e.x + e.vel.x * dt, e.warpY or e.y + e.vel.y * dt
	if e.warpX then e.warpX = nil end
	if e.warpY then e.warpY = nil end

	e.x, e.y, e.cols = bwo:move(e, gx, gy, e.filter)
end

return moveSys
