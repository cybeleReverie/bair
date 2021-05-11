local util = {}

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

function util.rnd(params)
	local pool = params
	local poolsize = 0
	for k,v in pairs(pool) do
		poolsize = poolsize + v[1]
	end
	local selection = math.random(1,poolsize)
	for k,v in pairs(pool) do
		selection = selection - v[1]
		if (selection <= 0) then
			return v[2]
		end
	end
end

function util.round(num, precision)
   return math.floor(num * math.pow(10, precision) +  0.5) / math.pow(10, precision)
end

function util.tableCopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

return util
