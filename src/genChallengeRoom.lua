--initialize chunk key for procgen challenge rooms
local chunkKey = {
	block = Block,
	spikeU = {Spike, 'up'},
	spikeR = {Spike, 'right'},
	spikeL = {Spike, 'left'},
	spikeBH = {Spike, 'blockHor'},
	spikeBV = {Spike, 'blockVer'},
	spikeBB = {Spike, 'blockBi'}
}

--table of allowable next obstacles for each item
local next = {
	['.'] = {'block', 'spikeBH'}, --empty space
	block = {'.', 'block', 'spikeBV', 'spikeBB', 'spikeR', 'spikeL'},
	spikeR = {'.', 'block', 'spikeBH'},
	spikeL = {'block'},
	spikeU = {'.', 'spikeU', 'block', 'spikeBV', 'spikeBB'},
	spikeBH = {'.', 'block', 'spikeBV', 'spikeBB'},
	spikeBV = {'.', 'block', 'spikeBH'},
	spikeBB = {'.', 'block', 'spikeBH', 'spikeBV', 'spikeBB'}
}

local blockOrHSpike = {block = 1, spikeBH = 2}
local blockHSpikeOrNil = {'block', 'spikeBH', '.'}

-- local function setItem(space, item, h)
-- 	space.item = item
-- 	--turn block into pillar if close enough to ground
-- 	if item == 'block' and space.y >= h - 2 then space.blocked = true end
-- end

local function isHazard(x)
	return x.item == 'spikeBV' or x.item == 'spikeBB' or x.item == 'spikeBH'
		or x.item == 'spikeU' or x.item == 'spikeL' or x.item == 'spikeR'
end
local function isEmpty(x) return x.item == '.' end
local function isSafe(x) return x.item == 'block' or x.item == 'spikeBH' or x.item == '.' end

local function checkDoubleHazard(p, i)
	local o1, o2 = p[i - 1].item, p[i - 2].item
	return (o1 == 'spikeBV' or o1 == 'spikeU' or o1 == 'spikeBB' or o1 == 'spikeR' or o1 == '.')
		and (o2 == 'spikeBV' or o2 == 'spikeU' or o2 == 'spikeBB' or o2 == 'spikeR' or o2 == '.')
end

local function setItem(p, i, pos, item, w, h)
	pos.item = item
	if pos.item == 'spikeU' then pos.y = h end

	--no dangling L spikes at the end
	if pos.item == 'spikeL' and i == w then return setItem(p, i, pos, random.weightedChoice(blockOrHSpike), w, h) end

	--set new y position
	cur.y = lume.clamp(prev.y + pathDir * random.weightedChoice(cachet '{[1] = 2, [2] = 2, [-1] = 1}'), 0, h)
end

local function genChallengeRoom(w, h)
	local chunk = {
		terrain = u.newMatrix(w, h, 0),
		w = w, h = h,
		key = chunkKey
	}
	local minHazardCount = math.max(1, math.floor(h / 3))

	--
	local path = {}
	local pathDir = random.choice(cachet '{-1, 1}')
	local prev
	local cur = {}
	cur.y = random.num(h - 1, h)
	setItem(cur, random.choice(cachet '{"spikeU", "spikeBH", "block"}'), w, h)

end

local function genChallengeRoom(w, h)
	local chunk = {
		terrain = u.newMatrix(w, h, 0),
		w = w, h = h,
		key = chunkKey
	}
	local minHazardCount = math.max(1, math.floor(h / 3))

	--
	::generate::
	local path = {}
	local pathDir = random.choice(cachet '{-1, 1}')
	local prev
	local cur = {}
	cur.y = random.num(h - 1, h)
	cur.item = random.choice(cachet '{"spikeU", "spikeBH", "block"}')
	if cur.item == 'spikeU' then cur.y = h end

	--turn block into pillar if close enough to ground
	if cur.item == 'block' then cur.blocked = true end

	--generate path of obstacles
	for i = 1, w do
		if i > 1 then
			prev =  cur
			cur = {item = prev.item, y}

			--select obstacle from table of possibilities, avoiding repeating obstacles
			while cur.item == prev.item do cur.item = random.choice(next[prev.item]) end

			--no dangling L spikes at the end
			if cur.item == 'spikeL' and i == w then cur.item = random.weightedChoice(blockOrHSpike) end

			--set new y position
			cur.y = lume.clamp(prev.y + pathDir * random.weightedChoice(cachet '{[1] = 2, [2] = 2, [-1] = 1}'), 0, h)

			--probably don't repeat previous y pos
			if cur.y == prev.y then
				if cur.y == h then cur.y = cur.y - random.num(2)
				elseif cur.y == 0 then cur.y = cur.y + random.num(2)
				else cur.y = lume.clamp(cur.y + random.num(2), 0, h) end
			end

			::adjust::
			--don't allow gaps to lead to impossible vertical jumps
			if isEmpty(prev) then
				cur.blocked = nil
				cur.y = math.min(prev.y + 1, h)
				cur.item = random.weightedChoice(blockOrHSpike)
			end

			--make L and R spikes always level with the block they're attached to
			if cur.item == 'spikeR' or prev.item == 'spikeL' then cur.y = prev.y
			elseif prev.y - cur.y > 1 or i == 2 then
				cur.item = random.weightedChoice(blockOrHSpike)
			end

			--turn block into pillar if close enough to ground
			if cur.item == 'block' and cur.y >= h - 2 then cur.blocked = true end

			--maybe give empty h positions ground spikes
			if (cur.item == '.' and cur.y < h - 1)
				or (pathDir == -1 and random.chance(2) and cur.y < h - 2) then

				cur.spiked = true
			end

			--context sensitive spikes
			if (cur.item == 'spikeBB' or cur.item == 'spikeBV')	and prev.blocked == true and cur.y >= prev.y then
				cur.item = 'spikeR'
			end

			--no redundant L/R spikes
			if cur.item == 'spikeL' and prev.item == 'block' and cur.y >= prev.y then
				cur.item = random.choice(blockHSpikeOrNil)
				goto adjust
			end
			if prev.item == 'spikeR' and
				(cur.blocked == true or (cur.item == 'block' and cur.y == prev.y - 1)) then

				prev.item = '.'
			end

			--no triple hblock spikes
			if i >= 3 and cur.item == 'spikeBH'
				and prev.item == 'spikeBH'
				and path[i - 2].item == 'spikeBH' then

				cur.item = 'block'
				goto adjust
			end

			--no useless blocks
			if i >= 3 and prev.y == h and prev.item == 'block' and pathDir == -1 and cur.item ~= 'spikeR' then
				prev.item = '.'
			end

			--no weirdly placed block spikes
			if ((prev.item == 'spikeBH' or prev.item == 'spikeBV' or prev.item == 'spikeBB')
				and prev.y >= h - 2 and cur.blocked == true) then

				prev.item = 'spikeU'
				prev.y = h
			end

			--no double empty spaces
			if isEmpty(cur) and isEmpty(prev) then
				cur.item = random.weightedChoice(blockOrHSpike)
			end

			if cur.y == h then
				if cur.item == 'spikeBV' or cur.item == 'spikeBB' then
					cur.item = 'spikeU'
				elseif cur.item == 'spikeBH' then
					cur.item = 'block'
					goto adjust
				end
			end

			if cur.item == 'block' and prev.y - cur.y > 1 then
				if i >= 3 and path[i - 2].item == 'spikeBH' then
					cur.y = cur.y + 1
				else
					cur.item = 'spikeBH'
				end
			end

			--lean towards up spikes for spike variants on the ground
			if cur.y == h then
				if cur.item == 'spikeBV' or cur.item == 'spikeBB' or cur.item == 'spikeBH' then
					cur.item = 'spikeU'
				-- elseif cur.item == 'spikeBH' then
				-- 	cur.item = random.choice(blockHSpikeOrNil)
				end
			end

			--no impossible triple obstacles
			if i > 2 and checkDoubleHazard(path, i) then
				cur.item = random.choice(blockHSpikeOrNil)
			end

			--no super tricky landings
			if i >= 3 and (path[i - 2].item == 'spikeBV' or path[i - 2].item == 'spikeBB')
				and (cur.item == 'spikeBV' or cur.item == 'spikeBB')
				and path[i - 2].y < prev.y and cur.y < prev.y then

				prev.y = cur.y
			end

			--switch pathDir direction
			if random.chance(3) or cur.y == h or cur.y == 0 or (i == 1 and pathDir == 1 and cur.y < h) then
				pathDir = -pathDir
			end

			if isSafe(cur) and prev.item ~= 'spikeBH' and not prev.verSpiked
				and prev.y - cur.y <= 2 and pathDir == 1 then

				cur.verSpiked = 4
			end

			if prev.verSpiked and prev.y - cur.y > 1 then prev.verSpiked = nil end

			if cur.item ~= 'block' then cur.blocked = nil end
		end

		path[i] = cur
	end

	--retry generation if too few hazards
	if lume.count(path, isHazard) < minHazardCount or lume.count(path, isEmpty) > 4 then
		goto generate
	end

	--map path to chunk terrain matrix
	for i, v in ipairs(path) do
		chunk.terrain[i][v.y] = v.item
		if v.blocked then for j = v.y + 1, h do chunk.terrain[i][j] = 'block' end end
		if v.spiked == true and v.y < h - 1 then chunk.terrain[i][h] = 'spikeU' end
		if v.verSpiked then
			chunk.terrain[i][v.y - v.verSpiked] = random.choice(cachet '{"spikeBV", "spikeBB"}')
		end

		if i == w and path[i].y <= 3 then
			--reward
		end
	end

	return chunk
end

return genChallengeRoom
