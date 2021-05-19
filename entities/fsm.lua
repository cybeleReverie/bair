local fsm = class 'fsm' --mixin class for state machine functionality

-- function fsm:update()
-- 	self.state:update()
-- end

function fsm:switchState(state)
	--call current state's exit function
	if self.state and self.state.exit then self.state.exit(self) end

	local s = self.states[state]

	--optional switch callback
	if self.states._switchCallback then self.states._switchCallback(self) end

	self.state = s

	--call new state callback
	if s.callback then s.callback(self) end
end

function fsm:updateState(dt)
	if self.state.update then self.state.update(self, dt) end
end

return fsm
