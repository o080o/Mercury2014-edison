local gpio = {} -- module table

pinmap = {} -- values taken from intel's edison mini breaout hardware guide
pinmap[17] = {182, nil, nil, nil, 135, nil, 27, 20, 28, 111, 109, 115, nil, 128}
pinmap[18] = {13, 165, nil,nil, nil, 19, 12, 183, nil, 110, 114, 129, 130, nil}
pinmap[19] = {nil, nil, nil, 44,46,48,nil, 131, 14, 40, 43, 77, 82, 83}
pinmap[20] = {nil, nil, 134, 45, 47, 49, 15, 84, 42, 41, 78, 79, 80, 81}
gpio.pinmap = pinmap



-- basic OOP class constructor using metatables
function class()
	local classObj = {}
	classObj.__index = classObj
	local classMt = {}
	function classMt:__call(...)
		local self = {}
		setmetatable(self, classObj)
		self:__init(...) -- constructor
		return self
	end
	return setmetatable(classObj, classMt)
end

function write(fname, value)
	local file, err = io.open(fname, "w")
	assert(file, err)
	file:write(value)
	file:close()
	--local cmdline = "echo "..value.." > "..fname
	--print(cmdline)
	--os.execute(cmdline)
end

function enable(pin)
	write("/sys/class/gpio/export", tostring(pin))
end
-- truthy values are output, falsy values set ot input
function setDir(pin, dir)
	local str = "in"
	if dir then str = "low" end
	write("/sys/class/gpio/gpio"..tostring(pin).."/direction", str)
end
function setMode(pin, mode)
	write("/sys/kernel/debug/gpio_debug/gpio"..tostring(pin).."/current_pinmux","mode"..tostring(mode))
end

local GPIO = class()
-- constructor Pin(Int pin, Bool mode)
-- return Pin reference to the specified pin number (SoC #, not board #) and
-- the given mode (controlls pin muxing etc)
function GPIO:__init(pin, dir )
	assert(type(pin)=="number", "No pin specified")
	self.pin = pin
	self.dir = dir or false
	self.state = false --output state
	enable(pin)
	setMode(pin, 0)
	setDir(pin,dir)
	-- maintain an open file handle over the lifetime of this object
	local err
	if dir then
		self.file, err = io.open("/sys/class/gpio/gpio"..tostring(pin).."/value", "w")
		assert(self.file, err)
	else
		self.file, err = io.open("/sys/class/gpio/gpio"..tostring(pin).."/value", "r")
		assert(self.file, err)
	end
end
function GPIO.__tostring(self)
	local dirstr, statestr = "input", "low"
	if self.dir then dirstr = "output" end
	if self:getState() then statestr = "high" end
	return "Pin "..self.pin..": "..statestr.."("..dirstr..")"
end
function GPIO:__gc()
	if self.file then self.file:close() end
end
function GPIO:setState(state)
	self.state = state
	if self.dir then
		local str = "0"
		if state then str = "1" end
		self.file:seek("set",0)
		self.file:write(str)
		--write(self.fname, str)
	end
end
function GPIO:getState()
	if self.dir then
		return self.state
	else
		self.file:seek("set",(0))
		return 1==tonumber(self.file:read(1))
	end
end

pwmmux = {}
pwmmux[12] = 1
pwmmux[13] = 1
pwmmux[182] = 1
pwmmux[183] = 1


local PWM = class()
function PWM:__init(pin)
end
function PWM:write(val)
end
function PWM:period(period)
end

local SPI = class()
function SPI:init()
end
function SPI:push(val)
	return 0
end


gpio.GPIO = GPIO

return gpio
