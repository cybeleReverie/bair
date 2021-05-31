local Mapgen = class 'Mapgen'

function Mapgen:init()
	self.isMapgen = true
	self.enemyList = {
		Turtledove
	}

	ewo:add(self)
end

local groundTiles = {
	tile.ground.dirt,
	tile.ground.stone,
	tile.ground.stoneDecayUgL,
	tile.ground.stoneDecayUgR,
	tile.ground.stoneDecayUgD,
	0,
	0,
	tile.ground.dirtGrassy,
	tile.ground.rootL,
	tile.ground.rootD,
	tile.ground.rootR,
	tile.ground.grassyStoneL,
	tile.ground.grassyStoneR
}

local nbL, nbR, nbU, ajt --declared outside of function for less garbage
function Mapgen:generateFloorTiles()
	local floor = util.newMatrix(14, 2, 1)
	local xx, yy, r

	--seed stone tiles
	for i = 1, random.num(5) do
		xx, yy = random.num(2, #floor - 1), random.num(2)
		floor[xx][yy] = 2
	end

	--adjust tiles
	for i in ipairs(floor) do
		for j in ipairs(floor[i]) do
			--adjust transition tiles
			ajt = floor[i][j]

			--if current tile is dirt
			if floor[i][j] == 1 then
				--look for neighboring stones
				nbL, nbR, nbU =
					i < #floor and floor[i + 1][j] == 2,
					i > 1 and floor[i - 1][j] == 2,
					j == 2 and floor[i][j - 1] == 2

				--make top dirt tiles grassy
				if j == 1 then ajt = 8 end

				--change to decayed stone if stone neighbor
				if j == 1 then --above ground
					if nbL then ajt = 12 end
					if nbR then ajt = 13 end
				else --below ground
					if nbL then ajt = 3 end
					if nbR then ajt = 4 end
					if nbU and random.chance(2) then ajt = 5 end
				end

				--if stone neighbors on both sides, adjust to solid stone or dirt
				if nbU and nbR then ajt = random.num(2) end
			end

			floor[i][j] = ajt
		end
	end

	return floor
end

function Mapgen:buildFloor(x, y)
	local floor = self:generateFloorTiles()
	local b, bx, by, rt

	for i in ipairs(floor) do
		for j in ipairs(floor[i]) do
			bx, by =
				x + i * 24 - 24,
				y + j * 24 + 4.5 * 24

			b = Block:new(bx, by, -gs.Game.hspeed)
			b.spr = groundTiles[floor[i][j]]

			if floor[i][j] == 1 or floor[i][j] == 8 then
				--add roots
				if random.num(8) == 1 and i % 2 == 0 then
					r = random.num(3)
					if r == 1 then
						if i < #floor and (floor[i + 1][j] == 1 or floor[i + 1][j] == 8) then
							rt = 9
						end
					elseif r == 2 then
						rt = 10
					else
						rt = 11
					end
					Cosmetic:new{
						x = bx,
						y = by,
						velx = -gs.Game.hspeed,
						spr = groundTiles[rt]
					}
				end
			end

			--designate one block as signal caller to build new floor
			if i == 1 and j == 1 then
				b.update = function(this)
					if math.floor(this.pos.x) <= 0 then
						Signal.emit("buildNewFloor")
						this.update = nil
					end
				end
			end
		end
	end
end

--chunks
Mapgen.chunks = {
	{terrain = [[....#
				 ##..#
				 ##..#]],
	w = 5, h = 3,
	key = {}},

	{terrain = [[#..#
				 ...#
				 ....
				 #...
				 #..#]],
	w = 4, h = 5,
	key = {}},

	require 'chunks/common/1'
}

return Mapgen
