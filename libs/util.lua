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

--

function random.chance(prob)
	return math.random(prob) == 1
end

random.num = math.random
random.weightedChoice = lume.weightedchoice
random.choice = lume.randomchoice

return {util, random}
