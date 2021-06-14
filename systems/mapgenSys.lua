local mapgenSys = tiny.processingSystem()
mapgenSys.filter = tiny.requireAll('isMapgen')
mapgenSys.isUpdateSys = true

--
local defChunkKey = {
	['#'] = Block
}

--
local genChallengeRoom = require 'src/genChallengeRoom'

--
--utilities
local function matrixFromChunk(chunk)
	local cx, cy = 1, 1
	local matrix = u.newMatrix(chunk.w, chunk.h, 0)

	chunk.terrain:gsub('.', function(cur)
		if cy <= chunk.h then
			if cur ~= '\n' and cur ~= '	' and cur ~= ' ' then
				matrix[cx][cy] = cur
				cx = cx + 1
			end

			if cx > chunk.w then
				cy = cy + 1
				cx = 1
			end
		end
	end)

	return matrix
end

local function idItem(item)
	local args
	local c = item
	if not class.isClass(c) then
		if lu.all(c, lm 'x -> type(x) == "table"') then
			return idItem(random.choice(c))
		end

		args = lu.slice(c, 2, #c)
		c = c[1]
	end
	return c, args or cat '{}'
end

--mapgen methods
local function buildChunk(this, x, y, chunk)
	local xx, yy, cur
	local yOff = 5.5 * 24 - (chunk.h * 24)

	if chunk.script then chunk:script() end
	for i in ipairs(chunk.terrain) do
		for j in ipairs(chunk.terrain[i]) do
			xx, yy = x + i * 24 - 24, yOff + j * 24 - 24 + y * 24

			cur = chunk.key[chunk.terrain[i][j]] or defChunkKey[chunk.terrain[i][j]]
			if cur then
				cur, args = idItem(cur)

				cur:new(xx, yy, unpack(args)).scroll = true
			end
		end
	end
end

local function spawnObstacle(this)
	local obst

	-- build either ranadom chunk or procedural challenge room
	if random.chance(1) then
		obst = genChallengeRoom(random.num(6, 10), random.num(4, 9))
		obst = mapgenSys.testRoom
	else
		obst = random.choice(this.chunks)
	end
	this:buildChunk(320, 0, obst)

	--set timer for next obstacle
	mapgenSys.timer:after(obst.w + 1, function()
		gs.Game.signal:emit 'spawnEncounter'
	end)
end

local function spawnEnemy(this)
	random.choice(this.enemyList):new(320, 81)
end

function mapgenSys:onAddToWorld()
	self.timer = Timer.new()
end

function mapgenSys:onAdd(e)
	--load chunks
	--move to more optimal place so it's only called once for each chunk in the entire game
	lu.each(e.chunks, function(i) i.terrain = matrixFromChunk(i) end)
	self.testRoom = genChallengeRoom(random.num(6, 10), random.num(4, 9))

	--signal registry
	gs.Game.signal:register('buildNewFloor', function()
		e:buildFloor(24 * 14, 0)
	end)

	gs.Game.signal:register('spawnEncounter', function()
		local encType = random.weightedChoice({obstacle = 500000000, enemy = 50})

		if encType == 'obstacle' then
			e:spawnObstacle()
		elseif encType == 'enemy' then
			e:spawnEnemy()
		end
	end)

	gs.Game.signal:register('enemyDefeated', function()
		self.timer:after(random.num(3, 4), function() gs.Game.signal:emit 'spawnEncounter' end)
	end)

	--common mapgen methods
	e.buildChunk = buildChunk
	e.spawnObstacle = spawnObstacle
	e.spawnEnemy = spawnEnemy

	--spawn first encounter
	gs.Game.signal:emit 'spawnEncounter'

	--build floor
	e:buildFloor(1, 0)
end

function mapgenSys:update(dt)
	self.timer:update(dt)
	if Input:pressed('attack') then
		self.testRoom = genChallengeRoom(random.num(6, 10), random.num(4, 9))
	end
end

function mapgenSys:process(e, dt)

end

function mapgenSys:onRemoveFromWorld()
	self.timer:clear()
end

return mapgenSys
