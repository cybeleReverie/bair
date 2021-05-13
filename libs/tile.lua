local tile = {}

function tile.newSet(img, w, h, tiles)
	local ts = {src = img}
	local ct

	for i in ipairs(tiles) do
		ct = tiles[i]
		ts[ct] = love.graphics.newQuad(ct[1] * w - w, ct[2] * h - h, ct[3] or w, ct[4] or h, img)
	end

	return ts
end

return tile
