function love.load()
	--debug stuff
	drawHitboxes = false

	--load libs
	lume = require 'libs/lume'
	util, random = unpack(require 'libs/util')
	class = require 'libs/class'
	input = require 'libs/boipushy'
	tiny = require 'libs/tiny'
	bump = require 'libs/bump'
	anim = require 'libs/anim8'
	tile = require 'libs/tile'
	suit = require 'libs/suit'
	Timer = require 'libs/timer'
	Camera = require 'libs/camera'
	Signal = require 'libs/signal'
	vec = require 'libs/vec'
	Gamestate = require 'libs/gamestate'
	consoleToggle = require 'libs/console/console'
	lg = love.graphics

	--graphics
	img, spr, tile, font = unpack(require 'gfx/sprites')

	--gamestates
	gs = {
		Game = require 'gamestates/Game',
		GameOver = require 'gamestates/GameOver'
	}

	--
	require 'entities/entities'
	playerClass = require 'src/playerClasses'
	item = require 'src/items'

	--initialize ECS and Bump world
	ewo = tiny.world(
		require 'systems/drawSys',
		require 'systems/depthDrawSys',
		require 'systems/mapgenSys',
		require 'systems/bumpSys',
		require 'systems/moveSys',
		require 'systems/updateLoopSys',
		require 'systems/healthSys',
		require 'systems/enemySys'
	)
	bwo = bump.newWorld()

	--ECS draw system filter
	ecsUpdateSys = tiny.requireAll('isUpdateSys')
	ecsDrawSys = tiny.requireAll('isDrawSys')

	--
	math.randomseed(os.time())
	lg.setLineStyle("rough")
	Gamestate.registerEvents()

	--bind inputs
	Input = input()
	Input:bind('z', 'jump')
	Input:bind('x', 'attack')
	Input:bind('c', 'cast')
	Input:bind('escape', 'exit')
	Input:bind('left', 'left')
	Input:bind('right', 'right')
	Input:bind('up', 'up')
	Input:bind('down', 'down')
	Input:bind('`', 'debug')
	Input:bind('space', function() pause = not pause end)

	--
	pause = false
	shapesCanvas = love.graphics.newCanvas(320, 180)

	Gamestate.switch(gs.Game)
end

function love.textinput(text)
	consoleToggle(text)
end

function love.update(dt)
	Timer.update(dt)

	if Input:pressed('exit') then
		love.event.quit()
	end
	if Input:pressed('debug') then
		pause = true --debugMode = not debugMode
	end
end

function love.draw()
end
