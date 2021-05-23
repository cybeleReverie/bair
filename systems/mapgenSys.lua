local mapgenSys = tiny.processingSystem()
mapgenSys.filter = tiny.requireAll('isMapgen')
mapgenSys.isUpdateSys = true

function mapgenSys:onAdd(e)
	--min/max encounter timer bounds (in seconds)
	e.encTimer = {14, 18}

	--signal registry
	e.signalRegistry = {
		Signal.register('buildNewFloor', function()
			e:buildFloor(24 * 14, 0)
		end),

		Signal.register('spawnEncounter', function(encType)
			if encType == 'obstacle' then
				--build random obstacle
				e:buildChunk(320, 12, e.chunks[random.num(#e.chunks)])

				--set timer for next obstacle
				Timer.after(random.num(e.encTimer[1], e.encTimer[2]), function()
					Signal.emit('spawnEncounter', random.weightedChoice({obstacle = 50, enemy = 50}))
				end)
			elseif encType == 'enemy' then
				e:spawnEnemy()
			end
		end)
	}

	--common mapgen methods
	e.buildChunk = function(this, x, y, chunk)
		for i in ipairs(chunk) do
			for j in ipairs(chunk[i]) do
				if chunk[i][j] == 1 then
					Block:new(x + j * 24 - 24, y + i * 24 - 24, -gs.Game.hspeed)
				end
			end
		end
	end

	e.spawnEnemy = function(this)
		this.enemyList[#this.enemyList]:new(320, 81)
	end

	--spawn first encounter
	Timer.after(1, function()
		Signal.emit('spawnEncounter', random.weightedChoice({obstacle = 50, enemy = 50}))
	end)

	--build floor
	e:buildFloor(0, 0)
end

function mapgenSys:process(e, dt)
end

return mapgenSys
