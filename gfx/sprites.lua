lg.setDefaultFilter('nearest', 'nearest')

--static image
local img = {
	hud = lg.newImage('gfx/hud.png'),
	bair = lg.newImage('gfx/bair.png'),
	turtledove = lg.newImage('gfx/turtledove.png'),
	bileBall = lg.newImage('gfx/bileBall.png'),
	groundTiles = lg.newImage('gfx/groundTiles.png'),
	reticle = lg.newImage('gfx/reticle.png'),
	clawEffect = lg.newImage('gfx/clawEffect.png'),
	spell16 = lg.newImage('gfx/spell16.png'),
}

--animation frames
local grid = {
	bair = anim.newGrid(160, 40, img.bair:getDimensions()),
	turtledove = anim.newGrid(53, 30, img.turtledove:getDimensions()),
	clawEffect = anim.newGrid(65, 39, img.clawEffect:getDimensions()),
	spell16 = anim.newGrid(16, 16, img.spell16:getDimensions()),
}

--animations
local spr = {
	bair = {
		walk = anim.newAnimation(grid.bair('2-5', 1), 0.18),
		jump = anim.newAnimation(grid.bair(27, 1), 1),
		fall = anim.newAnimation(grid.bair(28, 1), 1),
		hover = anim.newAnimation(grid.bair('24-26', 1), 0.065),

		attackBasic = anim.newAnimation(grid.bair('6-23', 1),
			{['1-8'] = 0.058, ['9-18'] = 0.05}, 'pauseAtEnd'),

		attackFarclaw = anim.newAnimation(grid.bair('29-39', 1),
				{['1-5'] = 0.07, [6] = 5, ['7-11'] = 0.06}, 'pauseAtEnd'),

		clawEffect = anim.newAnimation(grid.clawEffect('1-4', 1),
				0.045, 'pauseAtEnd')
	},

	turtledove = {
		idle = anim.newAnimation(grid.turtledove('1-2', 1), 0.25),
		preRush = anim.newAnimation(grid.turtledove(3, 1), 1),
		rush = anim.newAnimation(grid.turtledove('4-5', 1), 0.15),
	},

	spell = {
		fireball = anim.newAnimation(grid.spell16('1-2', 1), 0.15)
	}
}

--tilesets
local tile = {
	ground = tile.newSet(img.groundTiles, 24, 24, {
		dirt = {4, 1},
		dirtGrassy = {5, 1},
		grassyStoneL = {1, 1},
		grassyStoneR = {3, 1},
		stone = {2, 1},
		stoneDecayUgL = {1, 2}, --Ug = underground
		stoneDecayUgD = {2, 2},
		stoneDecayUgR = {3, 2},
		rootL = {6, 1, 48, 48},
		rootD = {8, 1, 24, 48},
		rootR = {9, 1, 48, 48}
	}),
	hud = tile.newSet(img.hud, 8, 8, {
		heart = {1, 1},
		heartEmpty = {2, 1},
	})
}

--fonts
local font = {
	romulus = lg.newFont('gfx/Romulus.ttf', 16),
	alagard = lg.newFont('gfx/alagard.ttf', 16)
}

return {img, spr, tile, font}
