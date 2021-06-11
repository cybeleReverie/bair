local TestZone = {}

function TestZone:enter()
	stringo = 'dogs!cats'
end

function TestZone:draw()
	lg.setColor(1, 1, 1)
	lg.print(fun)
end

return TestZone
