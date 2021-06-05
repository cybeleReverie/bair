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
			if cur then
				if class.isClass(cur) then
					cur:new(xx, yy).scroll = true
				else
					cur[1]:new(xx, yy, unpack(lume.slice(cur, 2, #cur)))
				end
			end
		end
	end
end

local function spawnEnemy(this)
	this.enemyList[#this.enemyList]:new(320, 81)
end

local function genChallengeRoom(w, h)
	local obstacles = {spike = 70, block = 30}
	local path = {}
	local chunk = {
		terrain = util.newMatrix(w, h, 0),
		w = w, h = h,
		key = {
			block = Block,
			spikeU = {Spike, 'up'},
			spikeR = {Spike, 'right'},
			spikeL = {Spike, 'left'},
			spikeBH = {Spike, 'blockHor'},
			spikeBV = {Spike, 'blockVer'},
			spikeBB = {Spike, 'blockBi'}}
	}

	local prev
	local cur = {}
	cur.y = h
	cur.item = random.weightedChoice({spike = 70, block = 30})

	for i = 1, w do
		if i > 1 then
			prev =  cur
			cur = {}
			cur.y = random.num(h)
			cur.item = random.weightedChoice(obstacles)

			if i == 2 then cur.y = random.num(h - 2, h - 1) end

			if cur.item == 'block' then
				if cur.y == h or prev.item == 'block' then cur.item = 'spike'
				elseif prev.item == 'spikeBH' and cur.y >= h - 2 and cur.y == prev.y then
					prev.item = 'spikeL'
				end
			end

			if cur.item == 'spike' then
				if prev.item == 'spikeBV' or prev.item == 'spikeBB' then
					cur.item = 'spikeBH'
				elseif prev.item == 'spikeU' then
					cur.item = 'spikeBH'
					cur.y = prev.y - random.num(2)
				elseif prev.item == 'block' and cur.y == prev.y then
					cur.item = 'spikeR'
				end
			end
		end

		if cur.y ~= h then
			if cur.item == 'spike' then cur.item = random.choice({'spikeBH', 'spikeBV', 'spikeBB'}) end
		else
			if cur.item == 'spike' then cur.item = 'spikeU' end
		end

		if prev then
			if prev.item == 'spikeBH' and cur.item == 'spikeBH' then
				if prev.y == cur.y then
					if random.chance(2) then
						cur.item = random.choice({'spikeBV', 'spikeBB'})
					else
						while cur.y == prev.y do
							cur.y = random.num(h)
						end
					end
				end
				if prev.y == cur.y + 2 and (prev.item == 'block' or prev.item == 'spikeBH') then
					cur.item = random.choice({'block', 'spikeBH'})
				end
			end
			if prev.y == cur.y - 2 and (prev.item == 'spikeBB' or prev.item == 'spikeBV') then
				if cur.y < h then cur.y = cur.y + 1
				else prev.item = 'spikeBH' end
			end
		end

		table.insert(path, cur)
	end

	for i in ipairs(path) do
		chunk.terrain[i][path[i].y] = path[i].item
	end

	return chunk
end

function mapgenSys:onAddToWorld()
	self.timer = Timer.new()
end

function mapgenSys:onAdd(e)
	--load chunks
	--move to more optimal place so it's only called once for each chunk in the entire game
	lume.each(e.chunks, function(i) i.terrain = matrixFromChunk(i) end)
	local testRoom = genChallengeRoom(random.num(5, 7), random.num(3, 4))

	--signal registry
	gs.Game.signal:register('buildNewFloor', function()
		e:buildFloor(24 * 14, 0)
	end)

	gs.Game.signal:register('spawnEncounter', function()
		local encType = random.weightedChoice({obstacle = 500000000, enemy = 50})

		if encType == 'obstacle' then
			local obst

			--build either ranadom chunk or procedural challenge room
			if random.chance(1) then
				obst = genChallengeRoom(5, 4)
				obst = testRoom
			else
				obst = e.chunks[random.num(#e.chunks)]
			end
			e:buildChunk(320, 0, obst)

			--set timer for next obstacle
			self.timer:after(random.num(obst.w, obst.w + 2), function()
				gs.Game.signal:emit('spawnEncounter')
			end)
		elseif encType == 'enemy' then
			e:spawnEnemy()
		end
	end)

	gs.Game.signal:register('enemyDefeated', function()
		self.timer:after(random.num(3, 5), function() gs.Game.signal:emit('spawnEncounter') end)
	end)

	--common mapgen methods
	e.buildChunk = buildChunk
	e.spawnEnemy = spawnEnemy

	--spawn first encounter
	gs.Game.signal:emit('spawnEncounter')

	--build floor
	e:buildFloor(1, 0)
end

function mapgenSys:update(dt)
	self.timer:update(dt)
end

function mapgenSys:process(e, dt)
end

function mapgenSys:onRemoveFromWorld()
	self.timer:clear()
end

return mapgenSys
