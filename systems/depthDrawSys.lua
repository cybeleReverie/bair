local depthDrawSys = tiny.sortedProcessingSystem()
depthDrawSys.filter = tiny.requireAll('draw', 'depth')
depthDrawSys.isDrawSys = true

function depthDrawSys:onAdd(e)
	depthDrawSys:onModify() --sort draw order by depth key
end

function depthDrawSys:compare(e1, e2)
	--sort depth by y position
	local depth1, depth2 = e1.depth or 0, e2.depth or 0
	return e1.y - depth1 > e2.y - depth2
end

function depthDrawSys:process(e, dt)
	love.graphics.setColor(1, 1, 1)

	if e.spr then
		--invincibility transparency
		if e.invincible then love.graphics.setColor(1, 1, 1, 0.7) end

		if e.spr.draw then --animation
			e.spr:draw(e.spritesheet, e.x, e.y, 0, 1, 1, e.ox or 0, e.oy or 0)
			e.spr:update(love.timer.getDelta())
		elseif e.spr.sheet then -- tile
			love.graphics.draw(e.spr.sheet, e.spr.tile, e.x, e.y, 0, 1, 1, e.ox or 0, e.oy or 0)
		else --static sprite
			love.graphics.draw(e.spr, e.x, e.y, 0, 1, 1, e.ox or 0, e.oy or 0)
		end
	else
		--placeholder rectangle
		love.graphics.setColor(0, 0.85, 0)
		love.graphics.rectangle('fill', e.x, e.y, e.w, e.h)
	end

	--draw red hitboxes
	if debugMode == true then
		love.graphics.setColor(1, 0, 0)
		love.graphics.rectangle('line', e.x, e.y, e.w, e.h)
	end
end

return depthDrawSys
