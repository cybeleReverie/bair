local bumpSys = tiny.processingSystem()
bumpSys.filter = tiny.requireAll('x', 'y', 'w', 'h')
bumpSys.isUpdateSys = true

function bumpSys:onAdd(e)
	bwo:add(e, e.x, e.y, e.w, e.h)
end

function bumpSys:process(e, dt)
	--handle collisions
	if e.cols then
		for i in ipairs(e.cols) do
			if e.collide then e:collide(e.cols[i].other) end
			e.cols[i] = nil
		end
	end

	--remove if offscreen
	if e.x <= -32 or e.y <= -32 or e.x >= SCREEN_W + 350 or e.y >= SCREEN_H + 32 then
		if e.name ~= 'Player' then
			ewo:remove(e)
		end
	end
end

function bumpSys:onRemove(e)
	bwo:remove(e)
end

return bumpSys
