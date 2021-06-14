local drawSys = tiny.processingSystem()
drawSys.filter = tiny.filter('draw&!depth')
drawSys.isDrawSys = true

function drawSys:onAdd(e)
	--set default color to white
	if not e.color then e.color = '#ffffff' end
end

local function drawEntity(e)
	--animation
	if e.spr.draw then
		e.spr:draw(e.spritesheet, e.pos.x, e.pos.y, 0, e.scaleX or 1, e.scaleY or 1, e.ox or 0, e.oy or 0)
		if not pause then e.spr:update(love.timer.getDelta()) end
	-- tile
	elseif e.spr.sheet then
		lg.draw(e.spr.sheet, e.spr.tile, e.pos.x, e.pos.y, 0, e.scaleX or 1, e.scaleY or 1, e.ox or 0, e.oy or 0)
	elseif e.spr.type and e.spr:type() == 'Image' then
	--static sprite
		lg.draw(e.spr, e.pos.x, e.pos.y, 0, e.scaleX or 1, e.scaleY or 1, e.ox or 0, e.oy or 0)
	else
		error('Entity "' .. e.name .. '" has unsupported sprite type: ' .. type(e.spr))
	end
end

local drawFrame = {}
function drawSys:process(e, dt)
	drawFrame.x = gs.Game.camera.x - 192
	drawFrame.y = gs.Game.camera.y - 122
	drawFrame.w = gs.Game.camera.x + 160
	drawFrame.h = gs.Game.camera.x + 90

	if e.pos.x >= drawFrame.x - e.w and e.pos.x <= drawFrame.w
		and e.pos.y >= drawFrame.y - e.h and e.pos.y <= drawFrame.h then

		lg.setColor(e.color, e.opacity)
		if e.spr then drawEntity(e) end

		if type(e.draw) == 'function' then e:draw() end

		--blinking
		if e.blinking then
			local ogCol = e.color
			local blinking = e.blinking
			local reps = math.ceil(e.blinking[1] * 17); reps = reps + (reps % 2) --always even repetitions

			Timer.every(0.06, function()
				if e.color == ogCol then e.color = blinking[2]
				else e.color = ogCol end
			end, reps)

			e.blinking = nil
		end
	end
end

return drawSys
