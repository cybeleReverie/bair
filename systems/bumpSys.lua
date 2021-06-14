local bumpSys = tiny.processingSystem()
bumpSys.filter = tiny.requireAll('pos', 'w', 'h')
bumpSys.isUpdateSys = true

function bumpSys:onAdd(e)
	if e.ghost == true then
		e.filter = function(item, other) return 'cross' end
	end

	if e.scroll then
		if not e.vel then e.vel = vec.new(0, 0) end
	end

	bwo:add(e, e.pos.x, e.pos.y, e.w, e.h)
end

function bumpSys:process(e, dt)
	--handle collisions
	if e.collide and e.cols then
		lu.each(e.cols, lm 'x,e -> e:collide(x.other)', e)
		e.cols = nil
	end

	--remove if offscreen
	if e.pos.x <= -48 or e.pos.y <= -48 or e.pos.x >= SCREEN_W + 350 or e.pos.y >= SCREEN_H + 48 then
		if not e.persistOffscreen then
			ewo:remove(e)
		end
	end
end

function bumpSys:onRemove(e)
	bwo:remove(e)
end

return bumpSys
