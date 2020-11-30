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
IDB_BLOCK1 equ 420
IDB_BLOCK2 equ 421
IDB_BLOCK3 equ 422
IDB_BLOCK4 equ 423
IDB_BLOCK5 equ 424


;Inicjalizacja danych
.DATA                     
ClassName db "Arkanoid",0        ; nazwa naszej klasy window
AppName db "Arkanoid Game",0        ; nazwa naszego okienka
LibName db "splash.dll",0
FunctionName db "SplashScreen",0
TestText db "Testowy",0
ID_TIMER dd 1
Level1Blocks DWORD 40 dup (1)
Lifes BYTE 3

Block struct

    x dd 10
    y dd 20
    bwidth dd 90
    bheight dd 20

Block ends

block Block <>

Ball struct

    bwidth dd 8
    bheight dd 8
    x dd 402
    y dd 570

    movex dd -2
    movey dd -4

Ball ends

ball Ball <>

Pad struct

    pwidth dd 85
    pheight dd 17
    x DWORD 362
    y DWORD 583

Pad ends

pad Pad <>

.DATA?                ; niezainicjowane dane
hInstance HINSTANCE ?        ; Instancyjny uchwyt naszego programu
CommandLine LPSTR ?
hLib dd ?
hImage HBITMAP ?
hPad HBITMAP ?
hBall HBITMAP ?
hBlock1 HBITMAP ?
hBlock2 HBITMAP ?
hBlock3 HBITMAP ?
hBlock4 HBITMAP ?
hBlock5 HBITMAP ?
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
    mov   wc.hbrBackground,NULL
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
                WS_SYSMENU or WS_MINIMIZEBOX,\
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
LOCAL OldPad:HBITMAP


        invoke BeginPaint, hWnd, addr ps
        INVOKE CreateCompatibleDC, hdc
        mov    hMemDC, eax
        mov      al, upad
        cmp      al, 1
        jne     DrawStart

DrawStart:

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
        



ret

DrawLevel1 endp


;========================COLLISION=============================
Collision proc

mov ebx, 0
mov eax, 0

;====================WINDOW COLLISION==========================   
cmp ball.y, 0
jle NegMovey
cmp ball.x, 0
jle NegMovex
cmp ball.x, 810
jge NegMovex

;========================PAD COLLISION=========================
mov ebx, ball.y             ;ebx = ball.y
add ebx, ball.bheight       ;ebx = ball.y.bottom
cmp ebx, pad.y              ;compare pad.y with ball.y.bottom
jge PadCollision            ;if ball.y.bottom >= pad.y.top -> jmp to padcollision 
jmp NotEqual                ;else

PadCollision:
    mov eax, pad.x          ;eax = pad.x.left
    mov ebx, ball.x         ;ebx = ball.x.left
    add ebx, ball.bwidth    ;ebx = ball.x.right
    cmp ebx, eax
    jge PadCollisionTrue    ;if ball.x.right >= pad.x.left - > jmp to PadCollisionTrue
    jmp NotEqual
   

PadCollisionTrue:
    add eax, 14             ;eax += 14 -> end orange part of pad left
    cmp ebx, eax            
    jle MovexChange         ;jmp to MovexChange if ball hits orange part of pad left
    mov eax, pad.x          ;eax = pad.x.left
    add eax, pad.pwidth     ;eax = pad.x.right
    cmp ball.x, eax
    jge NotEqual            ;PadCollisionNotTrue
    sub eax, 14             ;eax -= 14 -> start orange part of pad right
    cmp ball.x, eax             
    jge MovexChangeRight         ;if ball hits orange part of pad right
    add eax, 14             ;eax = pad.x.right
    sub eax, 42             ;eax = pad.x.center
    cmp ball.x, eax         
    jge MovexNormalRight    ;ball.x >= pad.x.center
    jmp MovexNormalLeft     ;else

MovexChange:
    mov ball.movex, 4
    neg ball.movex
    jmp NegMovey

MovexChangeRight:
    mov ball.movex, 4
    jmp NegMovey
    
MovexNormalRight:
    mov ball.movex, 2
    jmp NegMovey

MovexNormalLeft:
    mov ball.movex, -2
    jmp NegMovey

NegMovey: 
    neg ball.movey
    jmp NotEqual
    
NegMovex:
    neg ball.movex
    jmp NotEqual
 
NotEqual:
    mov ebx, 0
    mov eax, 0

ret

Collision endp

;=============================BALL MOVEMENT=======================
BallUpdate proc

mov eax, ball.movex
add ball.x, eax

mov eax, ball.movey
add ball.y, eax
        
ret
BallUpdate endp


;===================DRAWING OBJECTS ON SCREEN================
DrawObjects proc hdc:HDC, prc:RECT, hWnd:HWND

;=========LOCAL variables=========
LOCAL hdcBuffer:HDC
LOCAL hbmBuffer:HBITMAP
LOCAL hbmOldBuffer:HBITMAP
LOCAL hdcMem:HDC
LOCAL hbmOld:HBITMAP
LOCAL bg:HBRUSH
LOCAL number:DWORD
LOCAL index:DWORD
LOCAL row:DWORD



    invoke CreateCompatibleDC, hdc
    mov hdcBuffer, eax

    invoke SetBkMode, hdcBuffer, TRANSPARENT
    
    invoke CreateCompatibleBitmap, hdc, prc.right, prc.bottom
    mov hbmBuffer, eax
    
    invoke SelectObject, hdcBuffer, hbmBuffer
    mov hbmOldBuffer, eax

    invoke CreateCompatibleDC, hdc
    mov hdcMem, eax

    RGB   32,32,32
    invoke	CreateSolidBrush,eax
    invoke FillRect, hdcBuffer, addr prc, eax

   
        
;============BACKGROUND================
    invoke SelectObject, hdcMem, hImage
    invoke BitBlt, hdcBuffer, 0, 0, prc.right, prc.bottom, hdcMem, 0, 0, SRCCOPY

;================BLOCKS====================


mov ecx, 0
mov ebx, 0
mov number, 0
mov index, 0 

.REPEAT
    mov ebx, [Level1Blocks + ecx * 4]
    mov number, ebx
    mov index, ecx
    .IF(number == 1)
        invoke SelectObject, hdcMem, hBlock1
        invoke TransparentBlt, hdcBuffer, block.x, block.y, 90, 20, hdcMem, 0, 0, 90, 20, 16777215
    .ENDIF
    add block.x, 100  
    mov ecx, index
    inc ecx
.UNTIL ecx == 8

;==============BALL===================
    invoke SelectObject, hdcMem, hBall
    invoke   TransparentBlt, hdcBuffer, ball.x, ball.y, ball.bheight, ball.bwidth, hdcMem, 0, 0, 8, 8, 16777215

;==============PLATFORM================
    invoke   SelectObject,hdcMem,hPad
    invoke   TransparentBlt, hdcBuffer, pad.x, pad.y, 85, 17, hdcMem, 0, 0, 85, 17, 16777215


    invoke BitBlt, hdc, 0 ,0, prc.right, prc.bottom, hdcBuffer, 0, 0, SRCCOPY

    invoke SelectObject, hdcMem, hbmOld
    invoke DeleteDC, hdcMem

    invoke SelectObject, hdcBuffer, hbmOldBuffer
    invoke DeleteDC, hdcBuffer
    invoke DeleteObject, hbmBuffer
    invoke DeleteObject, hbmOldBuffer

ret

DrawObjects endp

;======================ENDGAME=========================

EndGame proc hdc:HDC, prc:RECT, hWnd:HWND

mov ebx, ball.y
mov eax, pad.y
add eax, pad.pheight

cmp eax, ebx
jl  EndEverything
jmp NotEnd

EndEverything:
   mov ball.y, 1000
   invoke DrawObjects, hdc, prc, hWnd
   invoke KillTimer, hWnd, ID_TIMER
NotEnd:
    ret
EndGame endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
LOCAL rcClient:RECT
LOCAL hdc:HDC

    .IF uMsg==WM_DESTROY                           ; gdy u¿ytkownik zamyka nasze okno
        invoke DeleteObject, hImage
        invoke KillTimer, hWnd, ID_TIMER
        invoke PostQuitMessage,NULL             ; zakoñczenie naszej aplikacji
    .ELSEIF uMsg == WM_CREATE
        ;call CreateBlocksArray
        invoke LoadBitmap,hInstance,IDB_BACKGROUND
        mov hImage,eax
        invoke LoadBitmap,hInstance,IDB_PAD
        mov hPad, eax
        invoke LoadBitmap, hInstance, IDB_BALL
        mov hBall, eax
        invoke LoadBitmap, hInstance, IDB_BLOCK1
        mov hBlock1, eax
        invoke LoadBitmap, hInstance, IDB_BLOCK2
        mov hBlock2, eax
        invoke LoadBitmap, hInstance, IDB_BLOCK3
        mov hBlock3, eax
        invoke LoadBitmap, hInstance, IDB_BLOCK4
        mov hBlock4, eax
        invoke LoadBitmap, hInstance, IDB_BLOCK5
        mov hBlock5, eax

        invoke SetTimer, hWnd, ID_TIMER, 16, NULL

    .ELSEIF uMsg == WM_TIMER   
         mov block.x, 10
         mov block.y, 20
         invoke GetDC, hWnd
         mov hdc, eax
         invoke GetClientRect, hWnd, ADDR rcClient
         invoke BallUpdate
         invoke DrawObjects, hdc, rcClient, hWnd
         invoke Collision
         invoke EndGame, hdc, rcClient, hWnd
         invoke ReleaseDC, hWnd, hdc             
    .ELSEIF uMsg == WM_CHAR
         push wParam
         pop char
        .IF char == 'a' 
            .IF pad.x > 2
            sub pad.x, 6
            .ENDIF
        .ELSEIF char == 'd'
            .IF pad.x < 729
            add pad.x, 6
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