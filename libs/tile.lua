local tile = {}

function tile.newSet(img, w, h, tiles)
	local ts = {} --tileset
	local ct

	for k, v in pairs(tiles) do
		ct = v --current tile
		local tx, ty, tw, th = --current tile pos and dimensions
			ct[1] * w - w,
			ct[2] * h - h,
			ct[3] or w,
			ct[4] or h

		--add new tile to sheet
		ts[k] = {
			tile = love.graphics.newQuad(tx, ty, tw, th, img),
		 	sheet = img
		}
	end

	return ts
end

return tile
