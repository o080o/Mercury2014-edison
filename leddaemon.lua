local gpio = require("gpio")
local led = require("led")
local color = require("color")

local PwrBtn = require("pwrbtn")

local ffi = require("ffi")
ffi.cdef[[
int sleep(int);
int usleep(int);
]]

local function wifiMode()
	local apd, err1 = io.popen( "systemctl | grep hostapd" )
	local ifconfig, err2 = io.popen( "ifconfig | grep wlan0 -A 3")
	if apd and ifconfig then
		local isAPMode = string.len( apd:read( "*all" ) ) > 0 
		local wificonfig = ifconfig:read("*all"):match("UP BROADCAST RUNNING MULTICAST")
		apd:close(); ifconfig:close()
		if not wificonfig then return "offline" end
		if isAPMode then return "ap"
		else return "wifi" end
	else
		if apd then apd:close() end
		if ifconfig then ifconfig:close() end
		print(err1)
		print(err2)
		return "err"
	end

end



local PERIOD = 100
local f = 0
local state = "idle"

local led = led( gpio.pinmap[18][7], gpio.pinmap[18][1], gpio.pinmap[17][1] ,10000)
local btn = PwrBtn()

function btn.down()
	state = "btn"
end
function btn.up()
	state = "idle"
	led:color( 1, 0, 0 )
	local mode = wifiMode()
	-- topple between wifi connection and Acess Point mode
	if mode=="ap" then os.execute( "configure_edison --disableOneTimeSetup" )
	else os.execute( "configure_edison --enableOneTimeSetup" ) end
end

local states = {}
function states.idle(f)
	states[ wifiMode() ](f)
end
function states.btn(f)
	led:color( 0, (1-1*.1), 1-1*.1 )
end

function states.ap(f)
	local r,g,b = color.HSVtoRGB( (f%(PERIOD/5))/(PERIOD/5), 1, 1)
	led:color( (1-r),(1-g*.1),(1-b*.2) ) 
end
function states.wifi(f)
	local r,g,b = color.HSVtoRGB( (f%PERIOD)/PERIOD, 1, 1)
	led:color( (1-r),(1-g*.1),(1-b*.2) ) 
end
function states.err(f)
	if f%2 == 0 then
	led:color( 1,0,0)
	else
	led:color( 1,1,1)
	end
end

local FLASHPERIOD = 2
function states.offline(f)
	--local r = math.floor(( 2*(f % FLASHPERIOD))/FLASHPERIOD)
	local r = math.floor( f % 2 )
	led:color( (1-r),1,1)
end


local BIGNUM = 2^16
while true do
	if states[state] then states[state](f)
	else states["idle"](f) end
	btn:poll()
	f = (f + 1) % BIGNUM
	ffi.C.usleep(40000)
end

