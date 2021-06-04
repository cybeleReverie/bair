local Thing = class 'Thing'

function Thing:init(params)
	for k, v in pairs(params) do
		self[k] = v
	end

	ewo:add(self)
end

return Thing
