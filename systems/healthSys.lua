local healthSys = tiny.processingSystem()
healthSys.filter = tiny.requireAll('hp')
healthSys.isUpdateSys = true

function healthSys:process(e, dt)
	if e.damage and not e.invincible then
		e.hp = e.hp - e.damage

		e.invincible = true
		Timer.after(1.1, function() e.invincible = false end)
	end

	if e.hp <= 0 then
		if e.name ~= 'Player' then
			ewo:remove(e)
		else
			ewo:clearEntities()
			ewo:clearSystems()
			Gamestate.switch(gs.GameOver)
		end
	end

	e.damage = nil
end

return healthSys
