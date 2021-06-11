local drawSys = tiny.processingSystem()
drawSys.filter = tiny.filter('draw&!depth')
drawSys.isDrawSys = true

function drawSys:onAdd(e)
	if not e.color then e.color = '#ffffff' end
end

local drawFrame = {}
function drawSys:process(e, dt)
	drawFrame.x = gs.Game.camera.x - 192
	drawFrame.y = gs.Game.camera.y - 122
	drawFrame.w = gs.Game.camera.x + 160
	drawFrame.h = gs.Game.camera.x + 90

	if e.pos.x >= drawFrame.x - e.w and e.pos.x <= drawFrame.w
		and e.pos.y >= drawFrame.y - e.h and e.pos.y <= drawFrame.h then

		lg.setColor(lume.color(e.color, e.opacity or 1))

		if e.spr then
			if e.spr.draw then			--animation
				e.spr:draw(e.spritesheet, e.pos.x, e.pos.y, 0, 1, 1, e.ox or 0, e.oy or 0)
				if not pause then e.spr:update(love.timer.getDelta()) end
			elseif e.spr.sheet then		-- tile
				lg.draw(e.spr.sheet, e.spr.tile, e.pos.x, e.pos.y, 0, 1, 1, e.ox or 0, e.oy or 0)
			else						--static sprite
				lg.draw(e.spr, e.pos.x, e.pos.y, 0, 1, 1, e.ox or 0, e.oy or 0)
			end
		end

		if type(e.draw) == 'function' then e:draw() end

		--blinking
		if e.blinking then
			local ogCol = e.color
			local blinking = e.blinking
			local blink = Timer.every(0.06, function()
				-- if e.opacity == 1 then e.opacity = e.opacity - 0.4
				-- else e.opacity = 1 end
				if e.color == ogCol then e.color = blinking[2]
				else e.color = ogCol end
			end)
			Timer.after(e.blinking[1], function()
				--e.opacity = 1
				e.color = ogCol
				Timer.cancel(blink)
			end)
			e.blinking = nil
		end
	end
end

return drawSys
