function CreateDwordArray(size)
	local m_array = ffi.new("unsigned long[?]", size)
	local obj = {}
	obj.GetAt = function(idx)
		assert(idx >= 0 and idx < size, "out_of_range")
		return m_array[idx];
	end
	obj.SetAt = function(idx, n)
		assert(type(n) == 'number', 'type_error')
		assert(idx >= 0 and idx < size, "out_of_range")
		m_array[idx] = n;
	end
	return obj;
end
	
--[[
local array = CreateDwordArray(1024 * 1024);
for i = 0, 1024 * 1024 - 1 do
	array.SetAt(i, i);
end
]]
--[[
print(array.GetAt(1024 * 1024 - 1));

function CreatePtrArray(type_, size)
	local array_t = ffi.cdef("$ **", type_);
	
end
]]