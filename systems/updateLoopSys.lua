local updateLoopSys = tiny.processingSystem()
updateLoopSys.filter = tiny.requireAll('update')
updateLoopSys.isUpdateSys = true

function updateLoopSys:process(e, dt)
	e:update(dt)
end

return updateLoopSys
