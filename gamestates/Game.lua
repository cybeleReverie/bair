local Game = {
	defSpeed = 45,
	hspeed = 45,
	camera = Camera(320 / 2, 180 / 2, 3),
	signal = Signal.new()
}

function Game:init()
end

function Game:enter(previous, signalRegistry)
	--add game systems
	ewo:refresh()
	ewo:add(
		require 'systems/drawSys',
		require 'systems/depthDrawSys',
		require 'systems/mapgenSys',
		require 'systems/bumpSys',
		require 'systems/moveSys',
		require 'systems/updateLoopSys',
		require 'systems/healthSys',
		require 'systems/enemySys')

	Game.player = Player:new(16, 104, playerClass.warrior, 'INSERT NAME')
	Game.mapgen = Mapgen:new()
	Game.hud = Hud:new()
	Game.pauseMenu = PauseMenu:new()

	Game.camGoalY = Game.player.pos.y - 14

	lg.setBackgroundColor('#8b87d6')
end

local function smoother(dx, dy)
	local dt = love.timer.getDelta()
	local damp = 0.6
	if dy < 0 then dy = dt / damp * dy
	else dy = dt * 4 * dy end
	if math.abs(dy) < 0.1 then dy = 0 end
	return dx, dy
end

function Game:update(dt)
	if math.floor(Game.player.pos.y) > 64 then
		Game.camGoalY = 91
	else
		if Game.player:checkOnGround()
			or (Game.camGoalY ~= 91 and Game.camGoalY < Game.player.pos.y + 6 and Game.player.vel.y > 8) then

			Game.camGoalY = Game.player.pos.y + 6
		end
	end

	if not pause then ewo:update(dt, ecsUpdateSys)
	else Game.pauseMenu:update(dt) end
	Game.camera:lockY(Game.camGoalY, smoother)
end

local drawHitbox = function(e) lg.rectangle("line", e.pos.x, e.pos.y, e.w, e.h) end
function Game:draw()
	lg.setCanvas(shapesCanvas)
	lg.clear()
	lg.setCanvas()

	Game.camera:attach()
	ewo:update(nil, ecsDrawSys)
	lg.draw(shapesCanvas)

	--debug stuff
	if drawHitboxes == true then
		lg.setColor(col.red)
		lu.each(bwo:getItems(), drawHitbox)
	end
	Game.camera:detach()

	lg.scale(3, 3)
	Game.hud:draw()
	if pause then Game.pauseMenu:draw() end
	lg.scale(1, 1)
end

function Game:leave()
	Timer.clear()
	Game.signal:clearPattern('.*')
	ewo:clearEntities()
	ewo:clearSystems()
end

return Game
