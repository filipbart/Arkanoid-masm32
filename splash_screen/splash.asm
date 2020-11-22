.386
.model flat,stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc
include \masm32\include\comdlg32.inc
include \masm32\include\shell32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\comdlg32.lib
includelib \masm32\lib\shell32.lib

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

RGB macro red,green,blue
	xor		eax,eax
	mov		ah,blue
	shl		eax,8
	mov		ah,green
	mov		al,red
endm


.data?
hInstance		HINSTANCE ?
CommandLine		LPSTR ?

.data
;_______________
ClassName		db "Splash",0
AppName           db "Splash Screen",0
TitleGame         db "ARKANOID GAME",0
TextInfo          db "Press 's' to Start Game",13,10
                  db "Press 'e' to Exit Game",0
FontName          db "impact",0
;_______________

.code

start:
	invoke	GetModuleHandle,NULL
	mov		hInstance,eax
	invoke	GetCommandLine
	invoke	WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
	invoke	ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
LOCAL wc	:WNDCLASSEX
LOCAL msg 	:MSG
LOCAL hwnd	:HWND
	mov		wc.cbSize,SIZEOF WNDCLASSEX
	mov		wc.style,CS_BYTEALIGNCLIENT
	mov		wc.lpfnWndProc,offset WndProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,NULL
	push	hInst
	pop		wc.hInstance
      RGB         0,0,160
      invoke      CreateSolidBrush, eax
	mov		wc.hbrBackground,eax
	mov		wc.lpszClassName,OFFSET ClassName
	invoke	LoadIcon,NULL,IDI_APPLICATION
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke	LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke	RegisterClassEx,addr wc

 ;=========Centrowanie okna===========
    INVOKE GetSystemMetrics, SM_CXSCREEN
    sub eax,640
    shr eax, 1
    push eax
    INVOKE GetSystemMetrics, SM_CYSCREEN
    sub eax,440
    shr eax, 1
    pop ebx


invoke CreateWindowEx,NULL,\
            ADDR ClassName,\
            ADDR AppName,\
            WS_POPUP,\
            ebx,\
            eax,\
            400,\
            300,\
            NULL,\
            NULL,\
            hInst,\
            NULL
	mov		hwnd,eax
	INVOKE	ShowWindow,hwnd,SW_SHOWNORMAL
	INVOKE	UpdateWindow,hwnd
	.WHILE TRUE
		invoke	GetMessage,ADDR msg,0,0,0
		.BREAK .IF (!eax)
		invoke	TranslateMessage,ADDR msg
		invoke	DispatchMessage,ADDR msg
	.ENDW
 	mov	eax,msg.wParam
	ret
WinMain endp
WndProc proc hWnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

LOCAL hdc: HDC
LOCAL ps: PAINTSTRUCT
LOCAL rect: RECT
LOCAL hfont: HFONT

	.IF uMsg == WM_DESTROY
		invoke	PostQuitMessage,NULL
      .ELSEIF uMsg == WM_PAINT
        INVOKE BeginPaint, hWnd, ADDR ps
        mov    hdc, eax
        INVOKE CreateFont,40, 0, 0, 0, 800, 1, 0, 0,\
                          OEM_CHARSET, OUT_DEFAULT_PRECIS,\
                          CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY,\
                          DEFAULT_PITCH or FF_SCRIPT, ADDR FontName

        INVOKE SelectObject, hdc, eax
        mov    hfont, eax
        RGB    255,255,0
        INVOKE SetTextColor, hdc, eax
        RGB    0,0,160
        INVOKE SetBkColor, hdc, eax
        INVOKE TextOut, hdc, 90, 100, ADDR TitleGame, SIZEOF TitleGame
        INVOKE SelectObject, hdc, hfont
        INVOKE GetClientRect, hWnd, ADDR rect
        INVOKE DrawText, hdc, ADDR TextInfo, 0, ADDR rect, DT_CALCRECT
        mov edx, 280
        sub edx, eax
        sar edx, 1
        add rect.top, edx
        INVOKE DrawText, hdc, ADDR TextInfo, -1, ADDR rect,\
               DT_CENTER or DT_NOPREFIX

        INVOKE EndPaint, hWnd, ADDR ps
	.ELSE
		invoke	DefWindowProc,hWnd,uMsg,wParam,lParam
		ret
	.ENDIF
	xor		eax,eax
	ret
WndProc endp
end start