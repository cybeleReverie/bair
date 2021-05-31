local mapgenSys = tiny.processingSystem()
mapgenSys.filter = tiny.requireAll('isMapgen')
mapgenSys.isUpdateSys = true

--
local defChunkKey = {
	['#'] = Block
}

local function matrixFromChunk(chunk)
	local cx, cy = 1, 1
	local matrix = util.newMatrix(chunk.w, chunk.h, 0)

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

local function buildChunk(this, x, y, chunk)
	local xx, yy, cur
	local yOff = 5.5 * 24 - (chunk.h * 24)

	for i in ipairs(chunk.terrain) do
		for j in ipairs(chunk.terrain[i]) do
			xx, yy = x + i * 24 - 24, yOff + j * 24 - 24 + y * 24

			cur = chunk.key[chunk.terrain[i][j]] or defChunkKey[chunk.terrain[i][j]]
			if cur then cur:new(xx, yy).scroll = true end
		end
	end
end

local function spawnEnemy(this)
	this.enemyList[#this.enemyList]:new(320, 81)
end

function mapgenSys:onAdd(e)
	--min/max encounter timer bounds (in seconds)
	e.encTimer = {12, 15}

	--load chunks
	--move to more optimal place so it's only called once for each chunk in the entire game
	lume.each(e.chunks, function(i) i.terrain = matrixFromChunk(i) end)

	--signal registry
	e.signalRegistry = {
		Signal.register('buildNewFloor', function()
			e:buildFloor(24 * 14, 0)
		end),

		Signal.register('spawnEncounter', function()
			local encType = random.weightedChoice({obstacle = 50, enemy = 50})

			if encType == 'obstacle' then
				--build random obstacle
				e:buildChunk(320, 0, e.chunks[random.num(#e.chunks)])

				--set timer for next obstacle
				 --make dynamic timing
				Timer.after(random.num(e.encTimer[1], e.encTimer[2]), function()
					Signal.emit('spawnEncounter')
				end)
			elseif encType == 'enemy' then
				e:spawnEnemy()
			end
		end),

		Signal.register('enemyDefeated', function()
			Timer.after(random.num(3, 5), function() Signal.emit('spawnEncounter') end)
		end),
	}

	--common mapgen methods
	e.buildChunk = buildChunk
	e.spawnEnemy = spawnEnemy

	--spawn first encounter
	Signal.emit('spawnEncounter')

	--build floor
	e:buildFloor(1, 0)
end

function mapgenSys:process(e, dt)
end

return mapgenSys
