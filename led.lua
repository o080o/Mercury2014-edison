local gpio = require("gpio")
local class = require("object")

local led = class()
function led:__init(p1,p2,p3, period)
	period = period or 1000
	self.r = gpio.PWM(p1, period)
	self.g = gpio.PWM(p2, period)
	self.b = gpio.PWM(p3, period)
end
function led:color(r,g,b)
	self.r:setValue(r)
	self.g:setValue(g)
	self.b:setValue(b)
end

return led
