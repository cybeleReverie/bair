local spell = require 'src/spells'

local item = {}

item.apple = {
	use = function(user) user.hp = math.min(user.hp + 1, user.maxHp) end,
	weight = 1,
	spr = tile.item.apple,
}

local spellList = {fireball = 1}
item.scroll = {
	use = function(user) table.insert(user.spells, spell[random.weightedChoice(spellList)]) end,
	weight = 1,
--	spr = tile.item.scroll,
}

return item
