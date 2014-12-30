local class = require("object")
local cio = require("cio")


local pwrBtn=class()
function pwrBtn:__init()
	self.file, err = cio.open("/dev/input/event1")
	assert(self.file, err)
	self.state = "up"
end

function hex(str)
	local rval = {}
	for c in str:gmatch(".") do
		local byte = string.byte(c)
		local hex = string.format("%02x ", byte)
		table.insert(rval, hex)
	end
	return table.concat(rval)
end
function binary(str)
	local hexvalue = {["0"]="0000", ["1"]="0001", ["2"]="0010", ["3"]="0011", ["4"]="0100", ["5"]="0101", ["6"]="0110", ["7"]="0111", ["8"]="1000", ["9"]="1001", ["a"]="1010", ["b"]="1011",["c"]="1100", ["d"]="1101", ["e"]="1110", ["f"]="1111"}
	local bin = {}
	for c in str:gmatch(".") do
		local byte = string.byte(c)
		local hex = string.format("%02x", byte)
		for h in hex:gmatch(".") do
			table.insert(bin, hexvalue[h])
		end
		table.insert(bin, " ")
	end
	return table.concat(bin)
end

function pwrBtn:parseEvent(event)
	if self.state=="up" then self.state="down" 
	elseif self.state=="down" then self.state="up" end
	if self[self.state] then self[self.state]() end
end
function pwrBtn:poll()
	--local event = self.file:read(32)
	local event = self.file:read(1)
	if event then self:parseEvent(event) end
end

function pwrBtn:up()
end
function pwrBtn:down()
end

return pwrBtn
