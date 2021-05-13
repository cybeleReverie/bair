love.graphics.setDefaultFilter('nearest', 'nearest')

local img = {
	block = love.graphics.newImage('gfx/block.png'),
	bair = love.graphics.newImage('gfx/bair.png'),
	turtledove = love.graphics.newImage('gfx/turtledove.png'),
	bileBall = love.graphics.newImage('gfx/bileBall.png')
	--groundTiles = love.graphics.newImage('gfx/groundTiles.png')
}

local grid = {
	bair = anim.newGrid(94, 40, img.bair:getWidth(), img.bair:getHeight()),
	turtledove = anim.newGrid(53, 30, img.turtledove:getWidth(), img.turtledove:getHeight())
}

local sprite = {
	bair = {
		walk = anim.newAnimation(grid.bair('2-5', 1), 0.18),
		jump = anim.newAnimation(grid.bair(27, 1), 1),
		fall = anim.newAnimation(grid.bair(28, 1), 1),
		hover = anim.newAnimation(grid.bair('24-26', 1), 0.065),
		attack = anim.newAnimation(grid.bair('6-23', 1),
			{['1-8'] = 0.058, ['9-18'] = 0.05},
			function() Signal.emit('attackComplete') end) --evil mixing game logic w/ graphics
	},
	turtledove = {
		idle = anim.newAnimation(grid.turtledove('1-2', 1), 0.25),
		preRush = anim.newAnimation(grid.turtledove(3, 1), 1),
		rush = anim.newAnimation(grid.turtledove('4-5', 1), 0.15),
	}
}

local tile = {
	-- ground = tile.newSet(img.groundTiles, 24, 24, {
	-- 	rocks = {1, 1},
	-- })
}

local font = {
	romulus = love.graphics.newFont('gfx/Romulus.ttf', 16),
	alagard = love.graphics.newFont('gfx/alagard.ttf', 16)
}

return {img, sprite, tile, font}
