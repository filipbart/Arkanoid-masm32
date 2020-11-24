.386
.model flat,stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc
include \masm32\include\comdlg32.inc
include \masm32\include\shell32.inc
include \masm32\include\msimg32.inc

;Biblioteki
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\comdlg32.lib
includelib \masm32\lib\shell32.lib
includelib \masm32\lib\msimg32.lib

WinMain PROTO :DWORD, :DWORD, :DWORD, :DWORD

RGB macro red,green,blue
	xor		eax,eax
	mov		ah,blue
	shl		eax,8
	mov		ah,green
	mov		al,red
endm

.CONST
IDB_BACKGROUND equ 1000
IDB_PAD equ 2137
IDB_BALL equ 1337

;Inicjalizacja danych
.DATA                     
ClassName db "Arkanoid",0        ; nazwa naszej klasy window
AppName db "Arkanoid Game",0        ; nazwa naszego okienka
LibName db "splash.dll",0
FunctionName db "SplashScreen",0
UpdatePad BYTE 0
xPad DWORD 362
BallSpeed BYTE 4

Ball struct

    bwidth BYTE 8
    bheight BYTE 8
    x byte 50
    y byte 50

    movex BYTE 1
    movey BYTE 1

Ball ends

.DATA?                ; niezainicjowane dane
hInstance HINSTANCE ?        ; Instancyjny uchwyt naszego programu
hImage dd ?
CommandLine LPSTR ?
hLib dd ?
hPad dd ?
char WPARAM ?

.CODE                ; Tu zaczyna siê nasz kod
start:

INVOKE LoadLibrary, ADDR LibName
     .IF eax!=NULL
        mov hLib, eax
        INVOKE GetProcAddress, hLib, ADDR FunctionName 
    .ENDIF
INVOKE FreeLibrary, eax
    
INVOKE GetModuleHandle, NULL
    mov    hInstance, eax
    INVOKE GetCommandLine
    mov    CommandLine, eax
    INVOKE WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
    INVOKE ExitProcess, eax

WinMain PROC hInst:     HINSTANCE,\
             hPrevInst: HINSTANCE,\
             CmdLine:   LPSTR,\
             CmdShow:   DWORD



LOCAL wc:WNDCLASSEX                                            ; tworzenie localych zmiennych na stosie
LOCAL msg:MSG
LOCAL hwnd:HWND

invoke	GetModuleHandle,NULL
mov		hInstance,eax

    mov   wc.cbSize,SIZEOF WNDCLASSEX                   ; wype³nienie wartoœci struktury wc
    mov   wc.style, CS_HREDRAW or CS_VREDRAW
    mov   wc.lpfnWndProc, OFFSET WndProc
    mov   wc.cbClsExtra,NULL
    mov   wc.cbWndExtra,NULL
    push  hInstance
    pop   wc.hInstance
    RGB   32,32,32
    invoke	CreateSolidBrush,eax
    mov   wc.hbrBackground,eax
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
                WS_SYSMENU or WS_MINIMIZEBOX or WS_SIZEBOX,\
                ebx,\
                eax,\
                824,\
                664,\
                NULL,\
                NULL,\
                hInst,\
                NULL
    mov   hwnd,eax
    invoke ShowWindow, hwnd,SW_SHOWNORMAL               ; wyœwietlenie naszego okienka na ekranie
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

DrawLevel1 proc hWnd:HWND, xpad:DWORD, upad:BYTE
LOCAL ps: PAINTSTRUCT
LOCAL hdc: HDC
LOCAL hMemDC: HDC
LOCAL rect: RECT


        INVOKE BeginPaint, hWnd, ADDR ps
        mov    hdc, eax
        INVOKE CreateCompatibleDC, hdc
        mov    hMemDC, eax
         mov      al, upad
         cmp      al, 1
         jne     DrawStart
         jle      PadDraw


DrawStart:

;==========BACKGROUND=============

         invoke   SelectObject,hMemDC,hImage
         invoke   GetClientRect,hWnd,addr rect
         invoke   BitBlt,hdc,0,0,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY

;==========FIFTH ROW============

         invoke	CreatePen,PS_SOLID,1,00800080h	
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,00800080h
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,710,140,800,160	

         invoke	CreatePen,PS_SOLID,1,00800080h
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,00800080h	
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,610,140,700,160	

         invoke	CreatePen,PS_SOLID,1,00800080h
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,00800080h
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,510,140,600,160	

         invoke	CreatePen,PS_SOLID,1,00800080h
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,00800080h
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,410,140,500,160	

         invoke	CreatePen,PS_SOLID,1,00800080h
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,00800080h
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,310,140,400,160	

         invoke	CreatePen,PS_SOLID,1,00800080h
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,00800080h
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,210,140,300,160	      

         invoke	CreatePen,PS_SOLID,1,00800080h	;Shape2
	   invoke	SelectObject,hdc,eax			;Shape2
	   invoke	CreateSolidBrush,00800080h       	;Shape2
	   invoke	SelectObject,hdc,eax			;Shape2
	   invoke	Rectangle,hdc,110,140,200,160	      ;Shape2


	   invoke	CreatePen,PS_SOLID,1,00800080h	;Shape1
	   invoke	SelectObject,hdc,eax			;Shape1
	   invoke	CreateSolidBrush,00800080h	      ;Shape1
	   invoke	SelectObject,hdc,eax			;Shape1
	   invoke	Rectangle,hdc,10,140,100,160	      ;Shape1

;==========FOURTH ROW============

         invoke	CreatePen,PS_SOLID,1,00FFFF00h	
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,00FFFF00h	
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,710,110,800,130	

         invoke	CreatePen,PS_SOLID,1,00FFFF00h
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,00FFFF00h		
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,610,110,700,130	
     
         invoke	CreatePen,PS_SOLID,1,00FFFF00h
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,00FFFF00h	
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,510,110,600,130	

         invoke	CreatePen,PS_SOLID,1,00FFFF00h
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,00FFFF00h
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,410,110,500,130	

         invoke	CreatePen,PS_SOLID,1,00FFFF00h
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,00FFFF00h	
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,310,110,400,130	

         invoke   CreatePen,PS_SOLID,1,00FFFF00h
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,00FFFF00h
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,210,110,300,130	      

         invoke	CreatePen,PS_SOLID,1,00FFFF00h	;Shape2
	   invoke	SelectObject,hdc,eax			;Shape2
	   invoke	CreateSolidBrush,00FFFF00h       	;Shape2
	   invoke	SelectObject,hdc,eax			;Shape2
	   invoke	Rectangle,hdc,110,110,200,130	      ;Shape2

	   invoke	CreatePen,PS_SOLID,1,00FFFF00h	;Shape1
	   invoke	SelectObject,hdc,eax			;Shape1
	   invoke	CreateSolidBrush,00FFFF00h	      ;Shape1
	   invoke	SelectObject,hdc,eax			;Shape1
	   invoke	Rectangle,hdc,10,110,100,130	      ;Shape1

;==========THIRD ROW============

         invoke	CreatePen,PS_SOLID,1,0000FFFFh	
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,0000FFFFh	
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,710,80,800,100	

         invoke	CreatePen,PS_SOLID,1,0000FFFFh	
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,0000FFFFh		
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,610,80,700,100	

         invoke	CreatePen,PS_SOLID,1,0000FFFFh	
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,0000FFFFh		
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,510,80,600,100	

         invoke	CreatePen,PS_SOLID,1,0000FFFFh
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,0000FFFFh	
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,410,80,500,100	

         invoke	CreatePen,PS_SOLID,1,0000FFFFh
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,0000FFFFh	
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,310,80,400,100	

         invoke	CreatePen,PS_SOLID,1,0000FFFFh
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,0000FFFFh	
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,210,80,300,100	      

         invoke	CreatePen,PS_SOLID,1,0000FFFFh	;Shape2
	   invoke	SelectObject,hdc,eax			;Shape2
	   invoke	CreateSolidBrush,0000FFFFh		;Shape2
	   invoke	SelectObject,hdc,eax			;Shape2
	   invoke	Rectangle,hdc,110,80,200,100	      ;Shape2

	   invoke	CreatePen,PS_SOLID,1,0000FFFFh	;Shape1
	   invoke	SelectObject,hdc,eax			;Shape1
	   invoke	CreateSolidBrush,0000FFFFh	      ;Shape1
	   invoke	SelectObject,hdc,eax			;Shape1
	   invoke	Rectangle,hdc,10,80,100,100	      ;Shape1

;==========SECOND ROW============

         invoke	CreatePen,PS_SOLID,1,00008000h	
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,00008000h		
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,710,50,800,70	

         invoke	CreatePen,PS_SOLID,1,00008000h	
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,00008000h		
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,610,50,700,70	

         invoke	CreatePen,PS_SOLID,1,00008000h	
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,00008000h		
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,510,50,600,70	

         invoke	CreatePen,PS_SOLID,1,00008000h	
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,00008000h		
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,410,50,500,70	

         invoke	CreatePen,PS_SOLID,1,00008000h	
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,00008000h		
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,310,50,400,70	

         invoke	CreatePen,PS_SOLID,1,00008000h	
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,00008000h		
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,210,50,300,70	      

         invoke	CreatePen,PS_SOLID,1,00008000h	;Shape2
	   invoke	SelectObject,hdc,eax			;Shape2
	   invoke	CreateSolidBrush,00008000h		;Shape2
	   invoke	SelectObject,hdc,eax			;Shape2
	   invoke	Rectangle,hdc,110,50,200,70	      ;Shape2

	   invoke	CreatePen,PS_SOLID,1,00008000h	;Shape1
	   invoke	SelectObject,hdc,eax			;Shape1
	   invoke	CreateSolidBrush,00008000h		;Shape1
	   invoke	SelectObject,hdc,eax			;Shape1
	   invoke	Rectangle,hdc,10,50,100,70	      ;Shape1

;==========FIRST ROW============
         invoke	CreatePen,PS_SOLID,1,000000FFh	
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,000000FFh		
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,710,20,800,40	

         invoke	CreatePen,PS_SOLID,1,000000FFh	
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,000000FFh		
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,610,20,700,40	

         invoke	CreatePen,PS_SOLID,1,000000FFh	
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,000000FFh		
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,510,20,600,40	

         invoke	CreatePen,PS_SOLID,1,000000FFh	
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,000000FFh		
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,410,20,500,40	

         invoke	CreatePen,PS_SOLID,1,000000FFh	
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,000000FFh		
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,310,20,400,40	

         invoke	CreatePen,PS_SOLID,1,000000FFh	
	   invoke	SelectObject,hdc,eax			
	   invoke	CreateSolidBrush,000000FFh		
	   invoke	SelectObject,hdc,eax			
	   invoke	Rectangle,hdc,210,20,300,40	      

         invoke	CreatePen,PS_SOLID,1,000000FFh	;Shape2
	   invoke	SelectObject,hdc,eax			;Shape2
	   invoke	CreateSolidBrush,000000FFh		;Shape2
	   invoke	SelectObject,hdc,eax			;Shape2
	   invoke	Rectangle,hdc,110,20,200,40	      ;Shape2

	   invoke	CreatePen,PS_SOLID,1,000000FFh	;Shape1
	   invoke	SelectObject,hdc,eax			;Shape1
	   invoke	CreateSolidBrush,000000FFh		;Shape1
	   invoke	SelectObject,hdc,eax			;Shape1
	   invoke	Rectangle,hdc,10,20,100,40	      ;Shape1
                        ;poczatekL, poczatekT, koniecL, koniecT,
         mov      ebx, xPad
        invoke   SelectObject,hMemDC,hPad
        invoke   TransparentBlt, hdc, ebx, 583, 85, 17, hMemDC, 0, 0, 85, 17, 16777215
        invoke UpdateWindow, hWnd

         jmp PadDraw
         jmp EndDraw

PadDraw:  

;============PLATFORM===============
        mov      ebx, xPad
        invoke   SelectObject,hMemDC,hPad
        invoke   TransparentBlt, hdc, ebx, 583, 85, 17, hMemDC, 0, 0, 85, 17, 16777215
        ;jmp EndDraw

EndDraw:

        invoke   DeleteDC,hMemDC      
        invoke EndPaint, hWnd, ADDR ps


ret

DrawLevel1 endp


;============Pad==============
DrawPad proc hWnd:HWND

LOCAL ps: PAINTSTRUCT
LOCAL hdc: HDC
LOCAL hMemDC: HDC
LOCAL rect: RECT

         
         ;RGB      255,255,255
         ;invoke   TransparentBlt, hdc, 0, 0, 500, 500, hMemDC, 0, 0, 500, 500, ebx
         invoke   DeleteDC,hMemDC      
         invoke   EndPaint, hWnd, ADDR ps

ret
   
DrawPad endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

    .IF uMsg==WM_DESTROY                           ; gdy u¿ytkownik zamyka nasze okno
        invoke DeleteObject, hImage
        invoke PostQuitMessage,NULL             ; zakoñczenie naszej aplikacji
    .ELSEIF uMsg == WM_CREATE
        invoke LoadBitmap,hInstance,IDB_BACKGROUND
        mov hImage,eax
        invoke LoadBitmap,hInstance,IDB_PAD
        mov hPad, eax
    .ELSEIF uMsg == WM_PAINT
        invoke DrawLevel1, hWnd, xPad,UpdatePad
    .ELSEIF uMsg == WM_CHAR
         push wParam
         pop char
        .IF char == 'a' 
            .IF xPad > 2
            ;invoke DeleteObject, hPad
            sub xPad, 4
            mov UpdatePad, 1
            invoke InvalidateRect, hWnd, NULL, FALSE
            .ENDIF
        .ELSEIF char == 'd'
            .IF xPad < 722
            add xPad, 4
            mov UpdatePad, 1
            invoke InvalidateRect, hWnd, NULL, FALSE
            .ENDIF
        .ENDIF            
    .ELSE
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam     ; domyœlne przetwarzanie wiadomoœci
        ret
    .ENDIF
    xor eax,eax
    ret
WndProc endp


end start