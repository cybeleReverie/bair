local drawSys = require 'systems/drawSys'

--

local depthDrawSys = tiny.sortedProcessingSystem()
depthDrawSys.filter = tiny.requireAll('draw', 'depth')
depthDrawSys.isDrawSys = true

function depthDrawSys:onAdd(e)
	if not e.color then e.color = '#ffffff' end
end

function depthDrawSys:compare(e1, e2)
	local depth1, depth2 = e1.depth, e2.depth
	return depth1 > depth2
end

depthDrawSys.process = drawSys.process --defer to drawSys process function

return depthDrawSys
