local util, random = {}, {}

function util.newMatrix(w, h, def)
  local t = {}

  for i = 1, w do
    t[i] = {}
    for j = 1, h do
      t[i][j] = def or 0
    end
  end

  return t
end

function util.deepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[util.deepCopy(orig_key)] = util.deepCopy(orig_value)
        end
        setmetatable(copy, util.deepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local tableCache = {}
function util.cacheTable(t)
	assert(type(t) == 'string', 'Table to cache must be a string. Type: ' .. type(t))
	if not tableCache[t] then
		tableCache[t] = lu.deserialize(t)
	end
	return tableCache[t]
end
cat = util.cacheTable

--

function random.chance(prob)
	return math.random(prob) == 1
end

random.num = math.random
random.weightedChoice = lu.weightedchoice
random.choice = lu.randomchoice

--
local col = {
	red = {1, 0, 0},
	green = {0, 1, 0},
	blue = {0, 0, 1},
	white = {1, 1, 1},
	black = {0, 0, 0}
}

local oldSetCol = love.graphics.setColor
function love.graphics.setColor(...)
	local a = ...
	if type(a) == 'string' then
		oldSetCol(lu.color(...))
	elseif type(a) == 'table' then
		oldSetCol(unpack(a))
	else
		oldSetCol(...)
	end
end

local oldSetBgCol = love.graphics.setBackgroundColor
function love.graphics.setBackgroundColor(...)
	local a, b, c = ...
	if not c then
		oldSetBgCol(lu.color(...))
	else
		oldSetBgCol(...)
	end
end

return {util, random, col}
