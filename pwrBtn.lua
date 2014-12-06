local class = require("object")
local pwrBtn=class()
function pwrBtn:__init()
	self.file, err = io.open("/dev/input/event1")
	assert(self.file, err)
end

local t = 0
function pwrBtn:parseEvent(event)
	print(event)
	t = t + 1
	print(t)
end
function pwrBtn:poll()
	local event = self.file:read(16)
	if event then self:parseEvent(event) end
end

function pwrBtn:up()
end
function pwrBtn:down()
end

return pwrBtn
