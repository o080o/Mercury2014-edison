
local color = {}

function color.HSVtoRGB(h,s,v)
	h = h * math.pi * 2
	local r = v * math.max(0,math.min(1,.5 + math.cos(h) ))
	local g = v * math.max(0,math.min(1,.5 + math.cos(h-(2*math.pi/3)) ))
	local b = v * math.max(0,math.min(1,.5 + math.cos(h+(2*math.pi/3)) ))
	white = .3*r + .59*g + .11*b --alters the overall contributions of each color
	--white = r/3 + g/3 + b/3 --completely uniform contributions (no color correction for LED brightness)
	print("::", r,g,b)
	return r,g,b
	--return r+s*(white-r), g+s*(white-g), b+s*(white-b)
end

case = {}
case[0] = function(v,p,q,t) return v,t,p end
case[1] = function(v,p,q,t) return q,v,p end
case[2] = function(v,p,q,t) return p,v,t end
case[3] = function(v,p,q,t) return p,q,v end
case[4] = function(v,p,q,t) return t,p,v end
case[5] = function(v,p,q,t) return v,p,q end
function color.HSVtoRGB(h,s,v)
	h = h * 6
	local index  = math.min(5,math.floor(h))
	local f,p,q,t
	f = h - index
	p = v * (1-s)
	q = v * (1-s*f)
	t = v * (1-s*(1-f))

	return case[index](v,p,q,t)
end

local EPSILON = 1e-20 -- avoids division by zero
function color.RGBtoHSV(r,g,b)
	local k, h, s, v = 0
	if g<b then
		g,b = b,g; k=-1
	end
	if r<g then
		r,g = g,r; k=-2/6-k
	end
	local chroma = r - math.min(g,b)
	h = math.abs( k + (g-b) / (6 * chroma + EPSILON))
	s = chroma / (r + EPSILON)
	v = r
	return h,s,v
end
return color
