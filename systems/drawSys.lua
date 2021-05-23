local drawSys = tiny.processingSystem()
drawSys.filter = tiny.filter('draw&!depth')
drawSys.isDrawSys = true

function drawSys:process(e, dt)
	love.graphics.setColor(1, 1, 1, e.opacity or 1)

	if type(e.draw) == 'function' then e:draw()
	else
		if e.spr then
			if e.spr.draw then --animation
				if e.draw == true then
					e.spr:draw(e.spritesheet, e.x, e.y, 0, 1, 1, e.ox or 0, e.oy or 0)
				end
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
	end

	--blinking
	if e.blinking then
		local blink = Timer.every(0.06, function() --migrate to drawsys
			if e.opacity == 1 then e.opacity = e.opacity - 0.4
			else e.opacity = 1 end
		end)
		Timer.after(e.blinking, function()
			e.opacity = 1
			Timer.cancel(blink)
		end)
		e.blinking = nil
	end

	--draw red hitboxes
	if debugMode == true then
		if e.w and e.h then
			love.graphics.setColor(1, 0, 0)
			love.graphics.rectangle('line', e.x, e.y, e.w, e.h)
		end
	end
end

return drawSys
