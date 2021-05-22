local Mapgen = class 'Mapgen'

function Mapgen:init()
	self.encTimer = {14, 18} --encounter timer bounds (in seconds)

	--build floor
	self:buildFloor(0, 0)
	Signal.register('buildNewFloor', function()
		self:buildFloor(24 * 14, 0)
	end)

	--spawn encounter signal
	Signal.register('spawnEncounter', function(encType)
		if encType == 'obstacle' then
			--build random obstacle
			self:buildChunk(320, 12, self.chunks[random.num(#self.chunks)])

			--set timer for next obstacle
			Timer.after(random.num(self.encTimer[1], self.encTimer[2]), function()
				Signal.emit('spawnEncounter', random.weightedChoice({obstacle = 50, enemy = 50}))
			end)
		elseif encType == 'enemy' then
			self:spawnEnemy()
		end
	end)

	--spawn first encounter
	Timer.after(1, function()
		Signal.emit('spawnEncounter', random.weightedChoice({obstacle = 50, enemy = 50}))
	end)

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
					if nbU then ajt = 5 end
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
					Cosmetic:new(bx, by, -gs.Game.hspeed, 0, groundTiles[rt])

					Signal:emit('depthSort')
				end
			end

			--designate one block as signal caller to build new floor
			if i == 1 and j == 1 then
				b.update = function(this)
					if math.floor(this.x) <= 0 then
						Signal.emit("buildNewFloor")
						this.update = nil
					end
				end
			end
		end
	end
end

function Mapgen:buildChunk(x, y, chunk)
	for i in ipairs(chunk) do
		for j in ipairs(chunk[i]) do
			if chunk[i][j] == 1 then
				Block:new(x + j * 24 - 24, y + i * 24 - 24, -gs.Game.hspeed)
			end
		end
	end
end

function Mapgen:spawnEnemy()
	Turtledove:new(320, 81)
end

--chunks
Mapgen.chunks = {
	{{0, 0, 0, 0, 0},
	 {0, 0, 0, 0, 0},
	 {0, 0, 0, 0, 1},
	 {1, 1, 0, 0, 1},
	 {1, 1, 0, 0, 1}},

	{{1, 0, 0, 1},
	 {0, 0, 0, 1},
 	 {0, 0, 0, 0},
 	 {1, 0, 0, 0},
 	 {1, 0, 0, 1}}
}

return Mapgen
