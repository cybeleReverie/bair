local Mapgen = class 'Mapgen'

function Mapgen:init()
	self.encTimer = {15, 18} --encounter timer bounds (in seconds)

	--build floor
	self:buildFloor(0, 0)
	Signal.register('buildNewFloor', function()
		self:buildFloor(24 * 14, 0)
	end)

	--spawn encounter signal
	Signal.register('spawnEncounter', function(encType)
		if encType == 'obstacle' then
			--build random obstacle
			self:buildChunk(320, 12, self.chunks[math.random(#self.chunks)])

			--set timer for next obstacle
			Timer.after(math.random(self.encTimer[1], self.encTimer[2]), function()
				Signal.emit('spawnEncounter', util.rnd({{50, 'obstacle'}, {50, 'enemy'}}))
			end)
		elseif encType == 'enemy' then
			self:spawnEnemy()
		end
	end)

	--spawn first encounter
	Timer.after(1, function()
		Signal.emit('spawnEncounter', util.rnd({{50, 'obstacle'}, {50, 'enemy'}}))
	end)

	ewo:addEntity(self)
end

function Mapgen:buildFloor(x, y)
	--make optimized 48x48 blocks
	for i = 1, 15 do
		local b = Block:new(x + i * 24 - 48, y + 6.5 * 24 - 24, -gs.Game.hspeed)

		if i == 1 then
			b.update = function(this)
				if math.floor(this.x) <= -24 then
					Signal.emit("buildNewFloor")
					ewo:remove(this)
				end
			end
		end
	end

	for i = 1, 15 do
		Block:new(x + i * 24 - 48, y + 6.5 * 24, -gs.Game.hspeed)
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
