local filename = [[E:\NewCodeReader\statistic\fft10.LOG]]

function ReadTableData(filename)
	local all_lines = {}
	for line in io.lines(filename) do 
	--	print(line);
		local i = 1;
		local list = {}
		local begin = 1;
		local end_ = 1;
		local in_space = false;
		local in_quote = false;
		local insert_quote = false;
		
		while i <= #line do
			local code = string.byte(line, i);
			
			if code == 9 or code == 32 then
				if not in_quote then
					if not insert_quote then
						in_space = true;
						end_ = i - 1;
						local item = string.sub(line, begin, end_);
						begin = end_ + 1;
						end_ = begin + 1;
						table.insert(list, item);
					else
						insert_quote = false;
					end
				end
			elseif code == 34 then
				in_quote = not in_quote;
				if in_quote then
					begin = i + 1;
				else
					end_ = i - 1;
					local item = string.sub(line, begin, end_);
					table.insert(list, item);
					insert_quote = true;
				end
			else
				if not in_quote and in_space then
					begin = i;
					in_space = false;
				end
			end
			i = i + 1;		
		end
		table.insert(all_lines, list);
	end
	return all_lines;
end

local all_lines = ReadTableData(filename)
table.sort(all_lines, function(a, b)
		return tonumber(a[6]) < tonumber(b[6]);
	end);
local i = 1;
for _, line in ipairs(all_lines) do
	for idx, v in ipairs(line) do
		if idx == 6 then
			print (v);
		end
	end
end