.386
.model flat,stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc
include \masm32\include\comdlg32.inc
include \masm32\include\shell32.inc

;Biblioteki
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\comdlg32.lib
includelib \masm32\lib\shell32.lib

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

.CONST
IDB_BACKGROUND equ 1000

;Inicjalizacja danych
.DATA                     
ClassName db "Arkanoid",0        ; nazwa naszej klasy window
AppName db "Arkanoid Game",0        ; nazwa naszego okienka

.DATA?                ; niezainicjowane dane
hInstance HINSTANCE ?        ; Instancyjny uchwyt naszego programu
hImage dd ?

.CODE                ; Tu zaczyna siê nasz kod
start:
invoke GetModuleHandle, NULL            
mov hInstance,eax
invoke WinMain, hInstance,NULL,NULL, SW_SHOWDEFAULT        ; wywo³anie g³ównej funkcji
invoke ExitProcess, eax                           ; zakoñczenie programu. Kod powrotu jest zwracany w eax z WinMain.



WinMain proc hInst:HINSTANCE,\
        hPrevInst:HINSTANCE,\
        CmdLine:LPSTR,\
        CmdShow:DWORD

LOCAL wc:WNDCLASSEX                                            ; tworzenie localych zmiennych na stosie
LOCAL msg:MSG
LOCAL hwnd:HWND

    mov   wc.cbSize,SIZEOF WNDCLASSEX                   ; wype³nienie wartoœci struktury wc
    mov   wc.style, CS_HREDRAW or CS_VREDRAW
    mov   wc.lpfnWndProc, OFFSET WndProc
    mov   wc.cbClsExtra,NULL
    mov   wc.cbWndExtra,NULL
    push  hInstance
    pop   wc.hInstance
    mov   wc.hbrBackground,COLOR_WINDOW+1
    mov   wc.lpszMenuName,NULL
    mov   wc.lpszClassName,OFFSET ClassName
    invoke LoadIcon,hInstance,8190
    mov   wc.hIcon,eax
    mov   wc.hIconSm,eax
    invoke LoadCursor,NULL,IDC_ARROW
    mov   wc.hCursor,eax
    invoke RegisterClassEx, addr wc                       ; rejestrowanie naszej klasy window


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
                WS_OVERLAPPEDWINDOW,\
                ebx,\
                eax,\
                800,\
                600,\
                NULL,\
                NULL,\
                hInst,\
                NULL
    mov   hwnd,eax
    invoke ShowWindow, hwnd,CmdShow               ; wyœwietlenie naszego okienka na ekranie
    invoke UpdateWindow, hwnd                                 ; odœwie¿enie obszaru roboczego

    .WHILE TRUE                                                         ; wprowadzenie pêtli sprawdzania wiadomoœci
                invoke GetMessage, ADDR msg,NULL,0,0
                .BREAK .IF (!eax)
                invoke TranslateMessage, ADDR msg
                invoke DispatchMessage, ADDR msg
   .ENDW
    mov     eax,msg.wParam                                            ; zwraca kod wyjœcia w eax
    ret
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
LOCAL ps: PAINTSTRUCT
LOCAL hdc: HDC
LOCAL hMemDC: HDC
LOCAL rect: RECT
    .IF uMsg==WM_DESTROY                           ; gdy u¿ytkownik zamyka nasze okno
        invoke DeleteObject, hImage
        invoke PostQuitMessage,NULL             ; zakoñczenie naszej aplikacji
    .ELSEIF uMsg == WM_CREATE
        invoke LoadBitmap,hInstance,IDB_BACKGROUND
        mov hImage,eax
    .ELSEIF uMsg == WM_PAINT
	   invoke	BeginPaint,hWnd,ADDR ps
	   mov	hdc,eax
         invoke   CreateCompatibleDC,hdc
         mov      hMemDC, eax
         invoke   SelectObject,hMemDC,hImage
         invoke   GetClientRect,hWnd,addr rect
         invoke   BitBlt,hdc,0,0,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
         invoke   DeleteDC,hMemDC
	   invoke	CreatePen,PS_SOLID,1,00000000h	;Shape2
	   invoke	SelectObject,hdc,eax			;Shape2
	   invoke	CreateSolidBrush,00FFFFFFh		;Shape2
	   invoke	SelectObject,hdc,eax			;Shape2
	   invoke	Rectangle,hdc,0,0,30,65			;Shape2
	   invoke	CreatePen,PS_SOLID,1,000000FFh	;Shape1
	   invoke	SelectObject,hdc,eax			;Shape1
	   invoke	CreateSolidBrush,000000FFh		;Shape1
	   invoke	SelectObject,hdc,eax			;Shape1
	   invoke	Rectangle,hdc,56,56,129,73	;Shape1
         invoke	EndPaint,hWnd,ADDR ps
    .ELSE
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam     ; domyœlne przetwarzanie wiadomoœci
        ret
    .ENDIF
    xor eax,eax
    ret
WndProc endp

end start