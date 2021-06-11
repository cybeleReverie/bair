lg.setDefaultFilter('nearest', 'nearest')

--static image
local img = {
	hud = lg.newImage('gfx/tiles/hud.png'),

	bair = lg.newImage('gfx/player/bair.png'),
	bair2 = lg.newImage('gfx/player/bair2.png'),
	hoverEffect = lg.newImage('gfx/player/hoverEffect.png'),
	clawEffect = lg.newImage('gfx/player/clawEffect.png'),
	farclawEffect = lg.newImage('gfx/player/farclawEffect.png'),
	farclawSwipe = lg.newImage('gfx/player/farclawSwipe.png'),
	reticle = lg.newImage('gfx/player/reticle.png'),

	turtledove = lg.newImage('gfx/enemies/turtledove.png'),
	bileBall = lg.newImage('gfx/enemies/bileBall.png'),

	groundTiles = lg.newImage('gfx/tiles/groundTiles.png'),
	treasureChest = lg.newImage('gfx/treasureChest.png'),
	spike = lg.newImage('gfx/tiles/spike.png'),

	spell16 = lg.newImage('gfx/spells16.png'),
	items = lg.newImage('gfx/items.png'),
}

--animation frames
local grid = {
	bair = anim.newGrid(160, 120, img.bair:getDimensions()),
	bair2 = anim.newGrid(160, 120, img.bair2:getDimensions()),
	hoverEffect = anim.newGrid(160, 120, img.hoverEffect:getDimensions()),
	clawEffect = anim.newGrid(160, 120, img.clawEffect:getDimensions()),
	farclawEffect = anim.newGrid(65, 39, img.farclawEffect:getDimensions()),
	farclawSwipe = anim.newGrid(160, 120, img.farclawSwipe:getDimensions()),

	turtledove = anim.newGrid(53, 30, img.turtledove:getDimensions()),

	spell16 = anim.newGrid(16, 16, img.spell16:getDimensions()),
}

--animations
local spr = {
	bair = {
		walk = anim.newAnimation(grid.bair('2-7', 1), 0.09),
		run = anim.newAnimation(grid.bair('8-13', 1), 0.09),
		jump = anim.newAnimation(grid.bair(35, 1), 1),
		fall = anim.newAnimation(grid.bair(36, 1), 1),
		hover = anim.newAnimation(grid.bair('32-34', 1), 0.065),
		rollEnterExit = anim.newAnimation(grid.bair2(1, 1,  6, 1), 0.07),
		rollMid = anim.newAnimation(grid.bair2('2-5', 1), 0.08),

		attackBasic = anim.newAnimation(grid.bair('14-31', 1),
			{['1-8'] = 0.058, ['9-18'] = 0.05}, 'pauseAtEnd'),

		attackFarclaw = anim.newAnimation(grid.bair('37-47', 1),
				{['1-5'] = 0.07, [6] = 5, ['6-11'] = 0.06}, 'pauseAtEnd'),

		effect = {
			hover = anim.newAnimation(grid.hoverEffect('1-3', 1), 0.065),
			claw = anim.newAnimation(grid.clawEffect('1-8', 1), 0.058, 'pauseAtStart'),
			farclaw = anim.newAnimation(grid.farclawEffect('1-4', 1),
				0.045, 'pauseAtStart'),
			farclawSwipe = anim.newAnimation(grid.farclawSwipe('1-5', 1),
			{[1] = 5, ['2-5'] = 0.06}, 'pauseAtStart')
		}
	},

	turtledove = {
		idle = anim.newAnimation(grid.turtledove('1-2', 1), 0.25),
		preRush = anim.newAnimation(grid.turtledove(3, 1), 1),
		rush = anim.newAnimation(grid.turtledove('4-5', 1), 0.15),
	},

	spell = {
		fireball = anim.newAnimation(grid.spell16('1-2', 1), 0.15)
	},
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
	spike = tile.newSet(img.spike, 24, 24, {
		up = {1, 1},
		right = {2, 1},
		down = {3, 1},
		left = {4, 1},
		blockHor = {5, 1},
		blockVer = {6, 1},
		blockBi = {7, 1}
	}),
	hud = tile.newSet(img.hud, 1, 1, {
		heart = {26, 1, 11, 11},
		heartEmpty = {37, 1, 11, 11},
		str = {35, 12, 22, 10},
		dex = {35, 22, 22, 10},
		int = {35, 32, 22, 10},
		pow = {1, 67, 23, 7},
		mag = {1, 74, 23, 7},
		powU = {1, 61, 19, 3},
		magU = {1, 64, 19, 3},
		emptyBarL = {8, 10, 3, 8},
		emptyBarM = {11, 10, 1, 8},
		emptyBarR = {12, 10, 3, 8},
		mpBarL = {15, 10, 3, 8},
		mpBarM = {18, 10, 1, 8},
		mpBarR = {19, 10, 3, 8},
		xpBarL = {1, 10, 3, 8},
		xpBarM = {4, 10, 1, 8},
		xpBarR = {5, 10, 3, 8},
		lv = {1, 1, 12, 9},
		the = {13, 3, 13, 7},
		attackSlotSelect = {1, 18, 17, 17},
		attackSlotFill = {1, 36, 13, 13},
		attackSlotEmpty = {1, 48, 13, 13},
		spellSlotSelect = {18, 18, 17, 17},
		spellSlotFill = {14, 35, 13, 13},
		spellSlotEmpty = {14, 48, 13, 13},
	}),
	item = tile.newSet(img.items, 16, 16, {
		apple = {1, 1},
	})
}

--fonts
local font = {
	pxfont = lg.newImageFont('gfx/fonts/pixfont.png',
		'ABCDEFGHIJKLMNOPQRSTUVWXYZ/0123456789` ', -1),
	small = lg.newFont('gfx/fonts/small.ttf', 15),
	smaller = lg.newFont('gfx/fonts/smaller.ttf', 6),
	alagard = lg.newFont('gfx/fonts/alagard.ttf', 16)
}

return {img, spr, tile, font}
