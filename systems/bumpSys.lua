local bumpSys = tiny.processingSystem()
bumpSys.filter = tiny.requireAll('x', 'y', 'w', 'h')
bumpSys.isUpdateSys = true

function bumpSys:onAdd(e)
	bwo:add(e, e.x, e.y, e.w, e.h)

	if e.ghost == true then
		e.filter = function(item, other) return 'cross' end
	end
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
	if e.x <= -48 or e.y <= -48 or e.x >= SCREEN_W + 350 or e.y >= SCREEN_H + 48 then
		if e.name ~= 'Player' then
			ewo:remove(e)
		end
	end
end

function bumpSys:onRemove(e)
	bwo:remove(e)
end

return bumpSys