--load libs
util = require 'libs/util'
class = require 'libs/class'
input = require 'libs/boipushy'
tiny = require 'libs/tiny'
bump = require 'libs/bump'
anim = require 'libs/anim8'
tile = require 'libs/tile'
Timer = require 'libs/timer'
Camera = require 'libs/camera'
Signal = require 'libs/signal'
vec = require 'libs/vec'
Gamestate = require 'libs/gamestate'

--graphics
img, spr, tile, font = unpack(require 'gfx/sprites')

--gamestates
gs = {
	Game = require 'gamestates/Game',
	GameOver = require 'gamestates/GameOver'
}

--entities
require 'entities/entities'

--initialize ECS and Bump world
ewo = tiny.world(
	require 'systems/drawSys',
	require 'systems/collisionSys',
	require 'systems/moveSys',
	require 'systems/updateLoopSys',
	require 'systems/healthSys',
	require 'systems/enemySys'
)
bwo = bump.newWorld(50)

--ECS draw system filter
ecsUpdateSys = tiny.requireAll('isUpdateSys')
ecsDrawSys = tiny.requireAll('isDrawSys')

--game logic
function love.load()
	math.randomseed(os.time())
	Gamestate.registerEvents()

	--bind inputs
	Input = input()
	Input:bind('z', 'jump')
	Input:bind('x', 'attack')
	Input:bind('escape', 'exit')
	Input:bind('`', 'debug')

	Gamestate.switch(gs.Game)
end

function love.update(dt)
	Timer.update(dt)

	if Input:pressed('exit') then
		love.event.quit()
	end
	if Input:pressed('debug') then
		debugMode = not debugMode
	end
end

function love.draw()
	love.graphics.print(bwo:countItems())
	love.graphics.scale(3, 3)
end
