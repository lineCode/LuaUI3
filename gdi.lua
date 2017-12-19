local ffi = require("ffi")

ffi.cdef[[
HDC GetDC(HWND hWnd);
int ReleaseDC(HWND hWnd, HDC hDC);
typedef struct tagPAINTSTRUCT {
	HDC   hdc;
	BOOL  fErase;
	RECT  rcPaint;
	BOOL  fRestore;
	BOOL  fIncUpdate;
	BYTE  rgbReserved[32];
} PAINTSTRUCT, *PPAINTSTRUCT, *NPPAINTSTRUCT, *LPPAINTSTRUCT;
HDC      BeginPaint(HWND hwnd, LPPAINTSTRUCT lpPaint);
BOOL     EndPaint(HWND hWnd, const PAINTSTRUCT *lpPaint);
BOOL     InvalidateRect(HWND hWnd, const RECT *lpRect, BOOL bErase);
BOOL     RedrawWindow(HWND hWnd, const RECT *lprcUpdate, HRGN hrgnUpdate, UINT flags);
HGDIOBJ  SelectObject(HDC hdc, HGDIOBJ h);
BOOL     DeleteObject(HGDIOBJ ho);
COLORREF SetDCBrushColor(HDC hdc, COLORREF color);
COLORREF SetDCPenColor(HDC hdc, COLORREF color);
int      SetBkMode(HDC hdc, int mode);
HDC      CreateCompatibleDC(HDC hdc);
BOOL     DeleteDC(HDC hdc);
BOOL     SwapBuffers(HDC);
int      GetObjectW(HGDIOBJ hgdiobj, int cbBuffer, LPVOID lpvObject);
HGDIOBJ  GetStockObject(int i);

BOOL LineTo(HDC hdc, int nXEnd, int nYEnd);
BOOL MoveToEx(HDC hdc, int X, int Y, LPPOINT lpPoint);

BOOL Chord(HDC hdc, int x1, int y1, int x2, int y2, int x3, int y3, int x4, int y4);
BOOL Ellipse(HDC hdc, int left, int top, int right, int bottom);
int FillRect(HDC hDC, const RECT *lprc, HBRUSH hbr);
int FrameRect(HDC hDC, const RECT *lprc, HBRUSH hbr);
BOOL InvertRect(HDC hDC, const RECT *lprc);
BOOL Pie(HDC hdc, int left, int top, int right, int bottom, int xr1, int yr1, int xr2, int yr2);
BOOL PolyPolygon(HDC hdc, const POINT *apt, const INT *asz, int csz);
BOOL Polygon(HDC hdc, const POINT *apt, int cpt);
BOOL Rectangle(HDC hdc, int left, int top, int right, int bottom);
BOOL RoundRect(HDC hdc, int left, int top, int right, int bottom, int width, int height);
]]

function RGB(r, g, b)
	return b * 65536 + g * 256 + r
end

WHITE_BRUSH          = 0
LTGRAY_BRUSH         = 1
GRAY_BRUSH           = 2
DKGRAY_BRUSH         = 3
BLACK_BRUSH          = 4
NULL_BRUSH           = 5
HOLLOW_BRUSH         = NULL_BRUSH

WHITE_PEN            = 6
BLACK_PEN            = 7
NULL_PEN             = 8

OEM_FIXED_FONT       = 10
ANSI_FIXED_FONT      = 11
ANSI_VAR_FONT        = 12
SYSTEM_FONT          = 13
DEVICE_DEFAULT_FONT  = 14
DEFAULT_PALETTE      = 15
SYSTEM_FIXED_FONT    = 16
DEFAULT_GUI_FONT     = 17

DC_BRUSH             = 18
DC_PEN               = 19


ffi.cdef[[
typedef struct tagLOGFONTW
{
    LONG      height;
    LONG      width;
    LONG      escapement;
    LONG      orientation;
    LONG      lfWeight;
    bool      italic;
    bool      underline;
    bool      strikeout;
    BYTE      lfCharSet;
    BYTE      lfOutPrecision;
    BYTE      lfClipPrecision;
    BYTE      lfQuality;
    BYTE      lfPitchAndFamily;
    WCHAR     lfFaceName[32];
} LOGFONTW, *PLOGFONTW,  *NPLOGFONTW,  *LPLOGFONTW;

HFONT   CreateFontIndirectW(const LOGFONTW *);

BOOL TextOutW(
	HDC     hdc,
	int     nXStart,
	int     nYStart,
	LPCWSTR lpString,
	int     cchString
);

COLORREF SetTextColor(
	HDC      hdc,
	COLORREF crColor
);

]]