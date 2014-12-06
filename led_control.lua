local gpio = require("gpio")
local led = require("led")
local color = require("color")

local ffi = require("ffi")
ffi.cdef[[
int sleep(int);
int usleep(int);
]]



local led = led( gpio.pinmap[18][7], gpio.pinmap[18][1], gpio.pinmap[17][1] ,10000)


local PERIOD = 100
while true do
	local f = 0
	while f<PERIOD do
		local r,g,b = color.HSVtoRGB( f/PERIOD, 1, 1 )
		led:color( (1-r),(1-g*.1),(1-b*.2) )
		f = f + 1
		ffi.C.usleep(40000)
	end
end

