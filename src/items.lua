local item = {}

item.apple = {
	use = function(user) user.hp = math.min(user.hp + 1, user.maxHp) end,
	weight = 1,
	spr = tile.item.apple,
}

return item
