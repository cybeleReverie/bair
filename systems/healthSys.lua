local healthSys = tiny.processingSystem()
healthSys.filter = tiny.requireAll('hp')
healthSys.isUpdateSys = true

function healthSys:process(e, dt)
	if e.damage and not e.invincible then
		e.hp = e.hp - e.damage

		e.invincible = true
		Timer.after(1.1, function() e.invincible = false; e.opacity = 1 end)
	end
	e.damage = nil

	if e.invincible then e.opacity = 0.6 end

	if e.hp <= 0 then
		if e.name ~= 'Player' then
			ewo:remove(e)
		else
			Gamestate.switch(gs.GameOver)
		end
	end
end

return healthSys
