local incDir = ";/home/usr/local/share/lua/5.2/"
local libDir = ";/home/usr/local/lib/lua/5.2/"
package.path = package.path .. incDir .. "?.lua" .. incDir .. "?/init.lua"
package.path = package.path .. libDir .. "?.lua" .. libDir .. "?/init.lua"
package.cpath = package.cpath .. incDir .. "?.so" .. incDir .. "?/loadall.so"
package.cpath = package.cpath .. libDir .. "?.so" .. libDir .. "?/loadall.so"

local socket = require("socket")
local class = require("object")

local function parse(str)
	-- split by words
	local id, name, parameterStr = str:match("(.)(%S*)(.*)")
	id = string.byte(id)
	local parameters = {}
	for word in parameterStr:gmatch(" (%S*)") do
		table.insert(parameters, word)
	end
	return id, name, parameters
end

local Comm = class()
local function newClient(table, key)
	local client = socket.udp()
end
function Comm:__init(port)
	self.idCounter = 0
	self.pending = {}
	self.clients = setmetatable({}, {__index=function(clients, addr)
		print("new connection from: ", addr)
		local newClient = socket.udp()
		newClient:setpeername(addr, port)
		clients[addr] = newClient
		return newClient
	end})

	self.recv = socket.udp()
	recv:setsockname("*", port) -- receive from any address
end
function Comm:nextID()
	self.idCount = self.idCount+1
	if self.idCount >= 256 then self.idCount = 0 end
	return self.idCount
end
function Comm:sendMessage(addr, name, ...)
	local params = {...}
	local str = {}
	local id = string.char(self:nextID())
	table.insert(str, id)
	table.insert(str, name)
	for _,param in ipairs(params) do
		table.insert(str, " ")
		table.insert(str, tostring(param))
	end
	local message = table.concat(str)
	print("sending: ", message)
	pending[id] = message
	self:sendTo(message)
end
function Comm:sendTo(addr, message)
	local client=clients[addr]
	return client:send(message)
end
function Comm:ack(client, id)
	if id~=0 then
		local message = "\0ACK " .. tostring(id)
		self:sendTo(addr, message)
	else -- this is actually an ack from a client
		seld.pending[id] = nil
	end
end
function Comm:recv()
	local string, addr, port  = assert(self.recv:receiveFrom())
	local id, name, parameters = parse(string)
	print("recvd:", id, name, unpack(parameters))
	self:ack(addr, id)
	return name, parameters
end
function Comm:close()
	recv:close()
	for sock in pairs(self.clients) do
		sock:close()
	end
	setmetatable(self, {}) -- we can no longer act as a Comm object...
end

local commands = {}
function commands.echo(...)
	print(...)
end


local comm = Comm(1234)

while true do
	local name, parameters = Comm:recv()
	if commands[name] then
		commands[name](unpack(parameters))
	end
end
