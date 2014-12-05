local gpio = require("gpio")
local led = require("led")
local color = require("color")

local led = led( gpio.pinmap[17][1], gpio.pinmap[18][1], gpio.pinmap[18][7] ,10000)


local PERIOD = 8000
while true do
	local f = 0
	while f<PERIOD do
		local r,g,b = color.HSVtoRGB( f/PERIOD, 1, 1 )
		led:color( r,g,b )
		f = f + 1
	end
end

