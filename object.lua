-- basic OOP class constructor using metatables
local function class()
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

return class
