local ffi=require("ffi")
ffi.cdef[[
	int open(const char*, int);
	int close(int);
	int read(int, void*, size_t);
]]

cio = {}

cio.open = ffi.C.open
cio.close = ffi.C.close
cio.O_NONBLOCK = 2048
cio.BUFFERSIZE = 100

function cio.open(fname)
	local fd = ffi.C.open(fname, cio.O_NONBLOCK)
	if fd < 0 then return nil end
	local file = {}
	file.fd = fd
	file.buffer = ffi.new('uint8_t[?]', cio.BUFFERSIZE)
	file.tmpbuffer = ""
	function file:read(n)
		local bytes = ffi.C.read(self.fd, self.buffer, math.max(n,ffi.sizeof(self.buffer)))
		if bytes <= 0 then return nil end
		self.tmpbuffer = self.tmpbuffer .. ffi.string(self.buffer)
		if #self.tmpbuffer < n then 
			return nil
		else
			local rval = self.tmpbuffer
			self.tmpbuffer = ""
			return rval
		end
	end
	function file:close()
		cio.close(self.fd)
		self.fd = nil
	end
	return file
end

return cio
