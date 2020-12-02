.386					;zestaw wykorzystanych instrukcji, dyrektywa  informuj¹ca assembler aby korzystaæ z 80386
.model flat,stdcall		;model pamiêci stosowany w programie
option casemap:none		;rozró¿nanie wielkoœci liter

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

;MACRO dla funkcji RGB, aby korzystaæ z palety kolorów RGB
RGB macro red,green,blue
	xor		eax,eax
	mov		ah,blue
	shl		eax,8
	mov		ah,green
	mov		al,red
endm

;Sta³e przeznaczone dla bitmap
.CONST
IDB_BACKGROUND equ 1000
IDB_PAD equ 2137
IDB_BALL equ 1337
IDB_BLOCK1 equ 420
IDB_BLOCK2 equ 421
IDB_BLOCK3 equ 422
IDB_BLOCK4 equ 423
IDB_BLOCK5 equ 424


;Inicjalizacja danych/zmiennych
.DATA                     
ClassName db "Arkanoid",0        ; nazwa naszej klasy window
AppName db "Arkanoid Game",0        ; nazwa naszego okienka
LibName db "splash.dll",0        ;Bilbioteka ekranu startowego
FunctionName db "SplashScreen",0 
FontName db "Helvetica",0        ;Nazwy czcionek
FontName2 db "impact",0
ScoreText db "Score:",0          ;Napis do wyœwietlania punktów
LifesText db "Lifes:",0          ;¯ycia
WinText db "YOU WON!",0
LoseText db "GAME OVER",0
HelpText db "a,d - to move the pad    r - to reset game"
ID_TIMER dd 1                   ;ID timera
Level1Blocks DWORD 40 dup (1)   ;Tablica 40 elementowa wype³niona 1
Lifes DWORD 3                   ;Liczba ¿yæ
Score DWORD 0                   ;Liczba puntków
    
Block struct                    ;Struktura bloków

    x dd 10                     ;Pozycja x
    y dd 20                     ;Pozycja y
    bwidth dd 90                ;Szerokoœæ
    bheight dd 20               ;D³ugoœæ

Block ends

block Block <>

Ball struct						;Struktura pi³ki

    bwidth dd 8					
    bheight dd 8
    x dd 402
    y dd 570

    movex dd -4					;Prêdkoœæ x'owa
    movey dd -2					;Prêdkoœæ y'owa

Ball ends

ball Ball <>

Pad struct						;Struktóra pad'a/platformy

    pwidth dd 85
    pheight dd 17
    x DWORD 362
    y DWORD 583

Pad ends

pad Pad <>

.DATA?                ; niezainicjowane dane
hInstance HINSTANCE ?        ; Instancyjny uchwyt naszego programu, dziêki niemu windows rozró¿nia kopie uruchiomonego programu
CommandLine LPSTR ?
hLib dd ?				
hImage HBITMAP ?		;Niezainicjalizowana zmienna bitmapowa
hPad HBITMAP ?
hBall HBITMAP ?
hBlock1 HBITMAP ?
hBlock2 HBITMAP ?
hBlock3 HBITMAP ?
hBlock4 HBITMAP ?
hBlock5 HBITMAP ?
char WPARAM ?			;Niezainicjalizowana zmienna wparam'etrowa, przechowuje wciœniêty klawisz przez u¿ytkownika
numbBuff db 11 dup (?)	;Niezainicjalizowana tablica 11 elementowa


.CODE                ; Tu zaczyna siê kod
start:

;Funkcja czekaj¹ca, a¿ ekran startowy zostanie zamkniêty
INVOKE LoadLibrary, ADDR LibName
     .IF eax!=NULL
        mov hLib, eax
        INVOKE GetProcAddress, hLib, ADDR FunctionName 
    .ENDIF
INVOKE FreeLibrary, eax


INVOKE GetModuleHandle, NULL ;Pobieranie uchwytu instancji
    mov    hInstance, eax	 ;Przekazanie do zmiennej hInstance
    INVOKE GetCommandLine
    mov    CommandLine, eax
    INVOKE WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT ;Wywo³anie procedury WinMain z przekazanymi argumentami
    INVOKE ExitProcess, eax 


;Klasa okna
WinMain PROC hInst:     HINSTANCE,\
             hPrevInst: HINSTANCE,\
             CmdLine:   LPSTR,\
             CmdShow:   DWORD

LOCAL wc:WNDCLASSEX                                            ; tworzenie lokalnych zmiennych na stosie
LOCAL msg:MSG
LOCAL hwnd:HWND

    mov   wc.cbSize,SIZEOF WNDCLASSEX                   ; wype³nienie wartoœci struktury wc
    mov   wc.style, CS_HREDRAW or CS_VREDRAW			;Okreœlanie stylu klasy okna
    mov   wc.lpfnWndProc, OFFSET WndProc				
    mov   wc.cbClsExtra,NULL					
    mov   wc.cbWndExtra,NULL
    push  hInstance
    pop   wc.hInstance
    RGB   32,32,32
    invoke	CreateSolidBrush,eax						;Stworzenie tworzy logiczny zapis przekazanego koloru
    mov   wc.hbrBackground,eax							;Wype³nienie t³a tym kolorem
    mov   wc.lpszMenuName,NULL							;Stworzenie kontrolki menu
    mov   wc.lpszClassName,OFFSET ClassName				;Nadanie nazwy klasy okna
    invoke LoadIcon,hInstance,8190						;Za³adowanie ikony
    mov   wc.hIcon,eax									;Przekazanie ikony do klasy okna
    mov   wc.hIconSm,eax
    invoke LoadCursor,NULL,IDC_ARROW					
    mov   wc.hCursor,eax
    invoke RegisterClassEx, addr wc                       ; rejestrowanie naszej klasy window



    ;=========Centrowanie okna===========
    INVOKE GetSystemMetrics, SM_CXSCREEN	;Pobranie szerokoœci okna w pikselach
    sub eax,920
    shr eax, 1
    push eax
    INVOKE GetSystemMetrics, SM_CYSCREEN 	;Pobranie wysokoœci okna w pikselach
    sub eax,540
    shr eax, 1
    pop ebx

    ;Procedura tworz¹ce nasze okno
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


;=======================WRITE TEXT=============================
ResetGame proc hWnd:HWND

mov ecx, 0
.REPEAT
mov [Level1Blocks + ecx * 4], 1
inc ecx
.UNTIL ecx == 40

mov Score, 0
mov Lifes, 3
mov ball.x, 402
mov ball.y, 570
mov pad.x, 362
mov pad.y, 583
invoke SetTimer, hWnd, ID_TIMER, 8, NULL

ret
ResetGame endp

IntToString PROC uses ebx numb:DWORD,buffer:DWORD

    mov     ecx,buffer          ;ecx = 11 elements array
    mov     eax,numb            ;eax = numb               
    mov     ebx,10              ;ebx = 10
    add     ecx,ebx             ;ecx = buffer + max size of string
l1:
    xor     edx,edx
    div     ebx
    add     edx,48              ; convert the digit to ASCII
    mov     BYTE PTR [ecx],dl   ; store the character in the buffer
    dec     ecx                 ; decrement ecx pointing the buffer
    test    eax,eax             ; check if the quotient is 0
    jnz     l1

    inc     ecx
    mov     eax,ecx             ; eax points the string in the buffer
    ret

IntToString ENDP

;========================COLLISION=============================
Collision proc hdc:HDC, rect:RECT, hWnd:HWND
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
        add Score, 50
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
        add Score, 50
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
        add Score, 50
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
        add Score, 50
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
        add Score, 50
    .ENDIF
.ENDIF
sub xBlockLeft, 100
sub xBlockRight, 100 
dec ecx
.UNTIL ecx == -1
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
LOCAL number:DWORD
LOCAL index:DWORD
LOCAL hfont:HFONT
LOCAL Oldhfont:HFONT
LOCAL hBrushBG:HBRUSH

          
    invoke CreateCompatibleDC, hdc		;Stworzenie kompatybilnego kontekstu urz¹dzenia w pamiêci
    mov hdcBuffer, eax					;Przekazanie do zmiennej hdcBuffer
    
    invoke CreateCompatibleBitmap, hdc, prc.right, prc.bottom
    mov hbmBuffer, eax
    
    invoke SelectObject, hdcBuffer, hbmBuffer	;Wprowadzenie aktualnego buffera bitmapy do zmiennej tymczasowej
    mov hbmOldBuffer, eax

    invoke CreateCompatibleDC, hdc
    mov hdcMem, eax
        
;============BACKGROUND================

    RGB   32,32,32
    invoke	CreateSolidBrush,eax
    mov hBrushBG, eax
    invoke FillRect, hdcBuffer, addr prc, hBrushBG	;Wype³nienie obszaru roboczego kolorem
    invoke SelectObject, hdcMem, hImage			;Wprowadzenie do hdcMem bitmapy
    invoke BitBlt, hdcBuffer, 0, 0, prc.right, prc.bottom, hdcMem, 0, 0, SRCCOPY ;Wyœwietlenie bitmapy, poprzez skopiowanie z pamiêci do w³aœciwego kontekstu urz¹dzenia

;=============SCORE AND LIFES===============


invoke CreateFont, 24, 0, 0, 0, 0, 0, 0, 0,\			;Tworzenie w³asnej czcionki
                    OEM_CHARSET, OUT_DEFAULT_PRECIS,\
                    CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY,\
                    DEFAULT_PITCH or FF_SCRIPT, ADDR FontName

invoke SelectObject, hdcBuffer, eax
mov hfont, eax
RGB 129, 0, 0
invoke SetTextColor, hdcBuffer, eax
RGB   32,32,32
invoke SetBkColor, hdcBuffer, eax
invoke TextOut, hdcBuffer, 0, 605, ADDR LifesText, SIZEOF LifesText ;Wyœwietlenie tekstu
invoke IntToString, Lifes, ADDR numbBuff							;Funkcja konwertuj¹ca int na string
invoke TextOut, hdcBuffer, 60, 605, eax, 10
invoke TextOut, hdcBuffer, 200, 605, ADDR ScoreText, SIZEOF ScoreText
invoke IntToString, Score, ADDR numbBuff
invoke TextOut, hdcBuffer, 265, 605, eax, 10
invoke TextOut, hdcBuffer, 400, 605, ADDR HelpText, SIZEOF HelpText
invoke SelectObject, hdcBuffer, hfont
mov Oldhfont, eax


;================BLOCKS====================
mov ecx, 0
mov ebx, 0
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
    invoke   TransparentBlt, hdcBuffer, pad.x, pad.y, 85, 17, hdcMem, 0, 0, 85, 17, 16777215 ;Funkcja kopiuj¹ca bitmapê do kontekstu urz¹dzenia oraz tworz¹ca wyznaczony kolor jako maskê do przeŸroczystoœci (w tym przypadku ostatni argument, czyli kolor bia³y jest uznawany jako przeŸroczysty)


    invoke BitBlt, hdc, 0 ,0, prc.right, prc.bottom, hdcBuffer, 0, 0, SRCCOPY

    invoke SelectObject, hdcMem, hbmOld
    invoke DeleteDC, hdcMem

    invoke SelectObject, hdcBuffer, hbmOldBuffer
	;Usuwanie obiektów oraz kontekstów
    invoke DeleteDC, hdcBuffer
    invoke DeleteObject, hbmBuffer
    invoke DeleteObject, hbmOldBuffer
    invoke DeleteObject, hBrushBG
    invoke DeleteObject, hfont
    invoke DeleteObject, Oldhfont

ret

DrawObjects endp



;======================ENDGAME=========================

EndGame proc hdc:HDC, prc:RECT, hWnd:HWND
LOCAL hfont:HFONT

mov ebx, ball.y
mov eax, pad.y
add eax, pad.pheight

;======================WINGAME==========================
.IF(Score == 2000)
invoke DrawObjects, hdc, prc, hWnd
INVOKE CreateFont,100, 0, 0, 0, 800, 1, 0, 0,\
                          OEM_CHARSET, OUT_DEFAULT_PRECIS,\
                          CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY,\
                          DEFAULT_PITCH or FF_SCRIPT, ADDR FontName2

invoke SelectObject, hdc, eax
mov    hfont, eax
RGB    255,255,0
INVOKE SetTextColor, hdc, eax
RGB    0,0,160
invoke SetBkColor, hdc, eax
invoke TextOut, hdc, 207, 232, ADDR WinText, SIZEOF WinText
invoke SelectObject, hdc, hfont
invoke KillTimer, hWnd, ID_TIMER
jmp NotEnd
.ENDIF


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
;======================GAMEOVER=========================
    .ELSEIF (Lifes == 0)
    mov ball.y, 1000
    invoke DrawObjects, hdc, prc, hWnd
    INVOKE CreateFont,100, 0, 0, 0, 800, 1, 0, 0,\
                          OEM_CHARSET, OUT_DEFAULT_PRECIS,\
                          CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY,\
                          DEFAULT_PITCH or FF_SCRIPT, ADDR FontName2

    invoke SelectObject, hdc, eax
    mov    hfont, eax
    RGB    255,255,0
    INVOKE SetTextColor, hdc, eax
    RGB    0,0,160
    invoke SetBkColor, hdc, eax
    invoke TextOut, hdc, 207, 232, ADDR LoseText, SIZEOF LoseText
    invoke SelectObject, hdc, hfont
    invoke KillTimer, hWnd, ID_TIMER
    jmp NotEnd
    .ENDIF


   
NotEnd:
    invoke DeleteObject, hfont
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
        invoke LoadBitmap,hInstance,IDB_BACKGROUND			;Za³adowanie grafiki rastrowej do zmiennej hImage
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
        invoke SetTimer, hWnd, ID_TIMER, 8, NULL 			;Ustawienie timera czyli pêtli odœwiê¿aj¹cej siê co 8ms
    .ELSEIF uMsg == WM_TIMER 								;Warunek dla sygna³u WM_TIMER
         invoke GetDC, hWnd
         mov hdc, eax
         invoke GetClientRect, hWnd, ADDR rcClient			;Stworzenie obszaru roboczego
         invoke BallUpdate
         invoke DrawObjects, hdc, rcClient, hWnd
         invoke Collision, hdc, rcClient, hWnd
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
        .ELSEIF char == 'r'
            invoke ResetGame, hWnd
        .ENDIF            
    .ELSE
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam     ; domyœlne przetwarzanie wiadomoœci
        ret
    .ENDIF
    xor eax,eax
    ret
WndProc endp


end start