local ffi = require("ffi")
local kernel32 = ffi.load("kernel32");

require('common');
require('winuser');
require('gdi');

CP_ACP = 0;
CP_UTF8 = 65001;
INVALID_HANDLE_VALUE = ffi.cast("intptr_t", -1)

NULL = ffi.cast("void *", 0);

local C = ffi.C;

function CreateApiBind()
  local obj = {}
	function obj.A2W(mbcs, codepage)
		assert(type(mbcs)=='string');
		if type(codepage) == 'nil' then
			codepage = CP_UTF8;
		end
		assert(type(codepage)=='number');
		local size_buffer = C.MultiByteToWideChar(codepage, 0, mbcs, #mbcs, nil, 0);
		-- print('size_buffer:', size_buffer, '#mbcs:', #mbcs);
		if size_buffer <= 0 then -- ? 空字符串怎么处理
			return nil
		end
		local buffer = ffi.new("uint16_t[?]", size_buffer + 1); -- 结尾问题还是要好好看MSDN
		local size_written = C.MultiByteToWideChar(codepage, 0, mbcs, #mbcs, buffer, size_buffer);
		-- print('size_written:', size_written);
		return ffi.cast("void *", buffer), size_written; -- 这样就无法下标访问了 比较安全一点 
		-- return buffer, size_written;
	end

	function obj.W2A(unicode, codepage)
		assert(type(unicode)=='cdata');
		if type(codepage) == 'nil' then
			codepage = CP_UTF8;
		end
		assert(type(codepage)=='number');
		local size_buffer = C.WideCharToMultiByte(codepage, 0, unicode, -1, nil, 0, nil, nil);
		-- print('size_buffer:', size_buffer);
		if size_buffer <= 0 then -- ? 空字符串怎么处理
			return nil
		end
		-- TODO cache the buffer
		local buffer = ffi.new("uint8_t[?]", size_buffer + 1); -- 结尾问题还是要好好看MSDN
		local size_written = C.WideCharToMultiByte(codepage, 0, unicode, -1, buffer, size_buffer, nil, nil);
		-- print('size_written:', size_written);
		return ffi.string(buffer, size_written - 1);
	end

  --[[
	local str_utf8 = "大家好我是luajit我喜欢用ffi"
	-- print('str_utf8:', str_utf8);
	local utf16, length = obj.A2W(str_utf8, CP_UTF8);
	-- print("utf16 begin")
	-- for i = 0, 9999 do
		-- print(utf16[i]);
		-- utf16[i] = 0; -- ffi is dangrous, it can easily corrupt your memory.
	-- end
	-- print("utf16 end")
	local str_gbk = obj.W2A(utf16, 936);
	print('str_gbk:', str_gbk, '#str_gbk:', #str_gbk);
  ]]
  
	local function FindDataToTable(wfd)
		local data = {}
		data.path = obj.W2A(wfd.cFileName);
		if bit.band(wfd.dwFileAttributes, 0x10) ~= 0 then
			data.dir = true;
    else
      data.dir = false;
		end
		return data;
	end

	function obj.ListDirFiles(dir_path)
		local wfd = ffi.new("WIN32_FIND_DATAW");
		local list = {};
		local hFind = C.FindFirstFileW(obj.A2W(dir_path, CP_UTF8), wfd);
		if hFind == INVALID_HANDLE_VALUE then
			return nil;
		end
		local data = FindDataToTable(wfd);
		table.insert(list, data);
		while(C.FindNextFileW(hFind, wfd) ~= 0) do
			data = FindDataToTable(wfd);
			table.insert(list, data);
		end
		C.FindClose(hFind);
		return list;
	end
  
  function obj.RegisterClass(cls_name, wndproc)
    local wc = ffi.new("WNDCLASSEXW");
    wc.cbSize = ffi.sizeof("WNDCLASSEXW");
    wc._style = bit.bor(WINUSER.CS_HREDRAW, WINUSER.CS_VREDRAW, WINUSER.CS_DBLCLKS);
    wc.proc = wndproc;
    wc.cbClsExtra = 0;
    wc.cbWndExtra = 0;
    wc.hInstance = NULL;
    wc.icon = NULL;
    wc.cursor = C.LoadCursorW(NULL, WINUSER.IDC_ARROW);
    wc.background = C.GetStockObject(GDI.WHITE_BRUSH);
    wc.lpszMenuName = NULL;
    wc.lpszClassName = obj.A2W(cls_name);
    wc.small_icon = NULL;
    local ret = C.RegisterClassExW(wc);
    assert(ret ~= 0);
  end
  
  function obj.CreateWindow(parent, cls_name, title, style, ex_style, x, y, w, h)
    -- TODO carefully design.
	end
  
	return obj;
end

local api = CreateApiBind()
local dir = api.ListDirFiles('F:\\*');

function SetDCPenColor(hdc, color)
	C.SetDCPenColor(hdc, color);
	local old_pen = C.SelectObject(hdc, C.GetStockObject(GDI.DC_PEN));
end

function MoveTo(hdc, x, y)
	C.MoveToEx(hdc, x, y, NULL);
end

function LineTo(hdc, x, y)
	C.LineTo(hdc, x, y);
end

function SetDCBrushColor(hdc, color)
	C.SetDCBrushColor(hdc, color);
end

local rect = ffi.new("RECT");
function FillRect(hdc, x, y, w, h)
	rect.left = x;
	rect.top = y;
	rect.right = x + w;
	rect.bottom = y + h;
	C.FillRect(hdc, rect, C.GetStockObject(GDI.DC_BRUSH));
end

function TextOut(hdc, x, y, str)
	local wstr, length = api.A2W(str);
	C.TextOutW(hdc, x, y, wstr, length);
end

function SetTextColor(hdc, color)
	C.SetTextColor(hdc, color);
end

function CreatePlotWindow(x, y, w, h, draw_proc)
	local ps = ffi.new("PAINTSTRUCT");
	local rect = ffi.new("RECT");
	api.RegisterClass('my_wnd', function(hwnd, message, wparam, lparam)
			if message == WINUSER.WM_PAINT then
				local hdc = C.BeginPaint(hwnd, ps);
				-- TODO GetClientRect
				C.GetClientRect(hwnd, rect);
				draw_proc(hdc, rect.right - rect.left, rect.bottom - rect.top);
--				C.MoveToEx(hdc, 0, 100, NULL);
--				C.LineTo(hdc, 100, 100);
				C.EndPaint(hwnd, ps);
--				C.SelectObject(hdc, old_pen);
			elseif message == WINUSER.WM_DESTROY then
				C.PostQuitMessage(0);
			end
			return C.DefWindowProcW(hwnd, message, wparam, lparam);
		end);
	local hwnd = C.CreateWindowExW(0, api.A2W('my_wnd'), api.A2W('hello', CP_UTF8), WINUSER.WS_OVERLAPPEDWINDOW,
		x, y, w, h, NULL, NULL, NULL, NULL);
	assert(hwnd ~= 0);
	C.ShowWindow(hwnd, WINUSER.SW_SHOW);
	return hwnd;
end

function RunMessageLoop()
	local msg = ffi.new('MSG');
	while C.GetMessageW(msg, NULL, 0, 0) ~= 0 do
	  C.TranslateMessage(msg);
	  C.DispatchMessageW(msg);
	end
end

local plot_data = {
	{ name = '10', value = 323},
	{ name = '20', value = 423},
	{ name = '30', value = 523},
	{ name = '40', value = 223},
	{ name = '50', value = 123},
}

math.randomseed(os.time());
CreatePlotWindow(10, 10, 600, 400, function(hdc, width, height)
		local margin_top = 30;
		local margin_bottom = 24;
		local item_w = width / (#plot_data * 2 + 1);
		SetDCPenColor(hdc, RGB(0, 0, 255));
		MoveTo(hdc, 0, height - margin_bottom);
		LineTo(hdc, width, height - margin_bottom);
		SetDCBrushColor(hdc, RGB(127, 127, 127));

		
		local max = 0;
		local i = 1;
		while i <= #plot_data do
			local item = plot_data[i];
			if item.value > max then
				max = item.value;
			end
			i = i + 1;
		end
		
		SetTextColor(hdc, RGB(0, 0, 0));
		i = 1;
		local x = item_w;
		local item_h = 0;
		while i <= #plot_data do
			local item = plot_data[i];
			item_h = item.value / max * (height - margin_top - margin_bottom);
			FillRect(hdc, x, height - item_h - margin_bottom, item_w, item_h);
			TextOut(hdc, x, height - margin_bottom + 2, item.name);
			
			x = x + item_w + item_w
			i = i + 1;
		end
	end);

RunMessageLoop();

print('done');
