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
TimeMS DWORD 16
Level1Blocks DWORD 40 dup (1)
Lifes db 3
Score db 0

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
                815,\
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


;========================COLLISION=============================
Collision proc
LOCAL yBlockBottom:DWORD
LOCAL yBlockHalf:DWORD
LOCAL xBlockLeft:DWORD
LOCAL xBlockRight:DWORD
LOCAL row:DWORD
LOCAL index:DWORD


mov ebx, 0
mov eax, 0

;====================WINDOW COLLISION==========================   
cmp ball.y, 0
jle NegMovey
cmp ball.x, 0
jle NegMovex
cmp ball.x, 804
jge NegMovex

;=========================BLOCKS COLLISION========================

mov yBlockBottom, 140
mov yBlockHalf, 130
mov row, 1

mov xBlockLeft, 710
mov xBlockRight, 800

.IF(ball.y <= 140) && (ball.y >= 120)
mov ecx, 39
.WHILE(ecx >= 32)
mov ebx, xBlockLeft
mov edx, xBlockRight
.IF(ball.x >= ebx) && (ball.x <= edx)
    mov eax, [Level1Blocks + ecx * 4]
    .IF(eax == 1)
        mov [Level1Blocks + ecx * 4], 0
        neg ball.movey
    .ENDIF
.ENDIF
sub xBlockLeft, 100
sub xBlockRight, 100 
dec ecx
.ENDW 

.ELSEIF(ball.y <= 115) && (ball.y >= 95)
mov ecx, 31
.WHILE(ecx >= 24)
mov ebx, xBlockLeft
mov edx, xBlockRight
.IF(ball.x >= ebx) && (ball.x <= edx)
    mov eax, [Level1Blocks + ecx * 4]
    .IF(eax == 1)
        mov [Level1Blocks + ecx * 4], 0
        neg ball.movey
    .ENDIF
.ENDIF
sub xBlockLeft, 100
sub xBlockRight, 100 
dec ecx
.ENDW 

.ELSEIF(ball.y <= 90) && (ball.y >= 70)
mov ecx, 23
.WHILE(ecx >= 16)
mov ebx, xBlockLeft
mov edx, xBlockRight
.IF(ball.x >= ebx) && (ball.x <= edx)
    mov eax, [Level1Blocks + ecx * 4]
    .IF(eax == 1)
        mov [Level1Blocks + ecx * 4], 0
        neg ball.movey
    .ENDIF
.ENDIF
sub xBlockLeft, 100
sub xBlockRight, 100 
dec ecx
.ENDW 

.ELSEIF(ball.y <= 65) && (ball.y >= 45)
mov ecx, 15
.WHILE(ecx >= 8)
mov ebx, xBlockLeft
mov edx, xBlockRight
.IF(ball.x >= ebx) && (ball.x <= edx)
    mov eax, [Level1Blocks + ecx * 4]
    .IF(eax == 1)
        mov [Level1Blocks + ecx * 4], 0
        neg ball.movey
    .ENDIF
.ENDIF    
sub xBlockLeft, 100
sub xBlockRight, 100 
dec ecx
.ENDW 

.ELSEIF(ball.y <= 40) && (ball.y >= 20)
mov ecx, 7
.REPEAT
mov ebx, xBlockLeft
mov edx, xBlockRight
.IF(ball.x >= ebx) && (ball.x <= edx)
    mov eax, [Level1Blocks + ecx * 4]
    .IF(eax == 1)
        mov [Level1Blocks + ecx * 4], 0
        neg ball.movey
    .ENDIF
.ENDIF
sub xBlockLeft, 100
sub xBlockRight, 100 
dec ecx
.UNTIL ecx == 0
.ENDIF




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
mov block.x, 10
mov block.y, 20
.REPEAT
    mov ebx, [Level1Blocks + ecx * 4]
    mov number, ebx
    mov index, ecx
    mov eax, index
    mov ebx, 8
    div ebx
    .IF(edx == 0) && (index > 0)
        mov block.x, 10
        add block.y, 25
    .ENDIF
    .IF(number == 1)
    .IF(index < 8)
        invoke SelectObject, hdcMem, hBlock1
        invoke TransparentBlt, hdcBuffer, block.x, block.y, 90, 20, hdcMem, 0, 0, 90, 20, 16777215
    .ELSEIF (index < 16)
        invoke SelectObject, hdcMem, hBlock2
        invoke TransparentBlt, hdcBuffer, block.x, block.y, 90, 20, hdcMem, 0, 0, 90, 20, 16777215
    .ELSEIF (index < 24)
        invoke SelectObject, hdcMem, hBlock3
        invoke TransparentBlt, hdcBuffer, block.x, block.y, 90, 20, hdcMem, 0, 0, 90, 20, 16777215
    .ELSEIF (index < 32)
        invoke SelectObject, hdcMem, hBlock4
        invoke TransparentBlt, hdcBuffer, block.x, block.y, 90, 20, hdcMem, 0, 0, 90, 20, 16777215
    .ELSE
        invoke SelectObject, hdcMem, hBlock5
        invoke TransparentBlt, hdcBuffer, block.x, block.y, 90, 20, hdcMem, 0, 0, 90, 20, 16777215
    .ENDIF
    .ENDIF
    add block.x, 100  
    mov ecx, index
    inc ecx
.UNTIL ecx == 40

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


;======================WINGAME==========================

WinGame proc


WinGame endp

;======================GAMEOVER=========================

EndGame proc hdc:HDC, prc:RECT, hWnd:HWND

mov ebx, ball.y
mov eax, pad.y
add eax, pad.pheight

cmp eax, ebx
jl LoseLife
jmp NotEnd

LoseLife:
    .IF(Lifes > 0)
        dec Lifes
        mov pad.x, 362
        mov pad.y, 583
        mov ball.x, 402
        mov ball.y, 570
        jmp NotEnd
    .ELSE
        jmp EndEverything
    .ENDIF

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

        invoke SetTimer, hWnd, ID_TIMER, TimeMS, NULL

    .ELSEIF uMsg == WM_TIMER
         mov TimeMS, 16  
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
            .IF pad.x < 718
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