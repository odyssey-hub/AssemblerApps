.686
.model flat,stdcall
option casemap:none
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD
count proto 
include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
include masm32.inc
include shlwapi.inc
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib masm32.lib
includelib shlwapi.lib


.data
ps PAINTSTRUCT <>
rc RECT <>
brushBack dd ?
hdc dd ?
ClassName db "SimpleWinClass",0
ClassName1 db "OtherWinClass",0
AppName db "Контрольная работа, Холкин Дмитрий, Вариант №36",0
AppNam1e db "График",0
LineName db "Линия",0
PointName db "Точки",0
ButtonClassName db "button",0
ButtonText db "Построить",0
EditClassName db "edit",0
STATIC db "STATIC",0
ame1 db "Минимум x:",0
ame2 db "Максимум x:",0
ame3 db "Шаг",0
flg db 0
repp dd ?
step dq ?
ScaleX dd ?
ScaleY dd ?
intX dd ?
intY dd ?
minX dd ?
maxX dd ?
minY dd -250000
maxY dd 250000
OffsetX dd ?
hwnd1 dd ?
OffsetY dd ?
hInstance HINSTANCE ?
CommandLine LPSTR ?
hwndButton HWND ?
hwndEditMinX HWND ?
hwndEditMaxX HWND ?
hwndEditStep HWND ?
tmp dd ?
buffer db 25 dup(?)
a dq ?
x dq ?

.const
ButtonID equ 1
LINE_RB equ 131
POINT_RB equ 132
EditID equ 2
IDM_EXIT equ 4

.code
start:
	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke WinMain, hInstance,NULL,NULL,NULL
	invoke ExitProcess,eax
    WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
	LOCAL hwnd:HWND
	LOCAL wc1:WNDCLASSEX
	;Регистрируем класс доп. окна
	mov   wc1.cbSize,SIZEOF WNDCLASSEX
	mov   wc1.style, CS_HREDRAW or CS_VREDRAW
	mov   wc1.lpfnWndProc, OFFSET WndProc1
	mov   wc1.cbClsExtra,NULL
	mov   wc1.cbWndExtra,NULL
	push  hInstance
	pop   wc1.hInstance
	mov   wc1.hbrBackground, 6
	mov   wc1.lpszMenuName,0
	mov   wc1.lpszClassName,OFFSET ClassName1
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov   wc1.hIcon,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov   wc1.hCursor,eax
	invoke RegisterClassEx, addr wc1
	;Регистрируем класс основного окна
	mov   wc.cbSize,SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW
	mov   wc.lpfnWndProc, OFFSET WndProc
	mov   wc.cbClsExtra,NULL
	mov   wc.cbWndExtra,NULL
	push  hInst
	pop   wc.hInstance
	mov   wc.hbrBackground, 5
	mov   wc.lpszMenuName,0
	mov   wc.lpszClassName,OFFSET ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov   wc.hIcon,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax
	invoke RegisterClassEx, addr wc

	invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
           CW_USEDEFAULT,400,300,NULL,NULL,\
           hInst,NULL
	mov   hwnd,eax
	invoke ShowWindow, hwnd,SW_SHOWNORMAL
	invoke UpdateWindow, hwnd

	.WHILE TRUE
                invoke GetMessage, ADDR msg,NULL,0,0
                .BREAK .IF (!eax)
                invoke TranslateMessage, ADDR msg
                invoke DispatchMessage, ADDR msg
	.ENDW
	mov     eax,msg.wParam
	ret
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	.IF uMsg==WM_DESTROY
		invoke PostQuitMessage,NULL
		ret
	.ELSEIF uMsg==WM_CREATE
		invoke CreateWindowEx,WS_EX_LEFT, ADDR STATIC,ADDR ame1,\
                        WS_CHILD or WS_VISIBLE,\
						5,5,100,25,hWnd,NULL,hInstance,NULL
		invoke CreateWindowEx,WS_EX_LEFT, ADDR STATIC,ADDR ame2,\
                        WS_CHILD or WS_VISIBLE,\
						5,35,100,25,hWnd,NULL,hInstance,NULL
		invoke CreateWindowEx,WS_EX_LEFT, ADDR STATIC,ADDR ame3,\
                        WS_CHILD or WS_VISIBLE,\
						5,65,100,25,hWnd,NULL,hInstance,NULL
		invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,\
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\
                        ES_AUTOHSCROLL,\
                        95,5,100,25,hWnd,EditID,hInstance,NULL
		mov  hwndEditMinX,eax
			invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,\
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\
                        ES_AUTOHSCROLL,\
						95,35,100,25,hWnd,EditID,hInstance,NULL
		mov  hwndEditMaxX,eax
			invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,\
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\
                        ES_AUTOHSCROLL,\
                        95,65,100,25,hWnd,EditID,hInstance,NULL
		mov  hwndEditStep,eax
		invoke SetFocus, hwndEditMinX
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonText,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        95,95,100,25,hWnd,ButtonID,hInstance,NULL
		mov  hwndButton,eax
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR LineName,\
                        WS_CHILD or WS_VISIBLE or BS_AUTORADIOBUTTON,\
                        95,125,100,25,hWnd,LINE_RB,hInstance,NULL
		invoke SendMessage,eax,BM_SETCHECK,BST_CHECKED,0
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR PointName,\
                        WS_CHILD or WS_VISIBLE or BS_AUTORADIOBUTTON,\
                        95,155,100,25,hWnd,POINT_RB,hInstance,NULL
	.ELSEIF uMsg==WM_COMMAND
				mov eax,wParam
		.IF ax==LINE_RB
				 mov flg,0
		.ELSEIF ax==POINT_RB
				 mov flg,1
		.ELSE
			.IF ax==ButtonID
				shr eax,16
				.IF ax==BN_CLICKED
					invoke GetWindowText,hwndEditMinX,ADDR buffer,25
					invoke StrToInt, ADDR buffer
					mov  minX,eax
					invoke GetWindowText,hwndEditMaxX, ADDR buffer,25
					invoke StrToInt, ADDR buffer
					mov  maxX,eax
					invoke GetWindowText,hwndEditStep,ADDR buffer,25
					invoke StrToFloat, ADDR buffer, ADDR step
					;Создаем доп. окно
					invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName1,ADDR AppNam1e,\
					WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
					CW_USEDEFAULT,800,600,0,NULL,\
					hInstance,NULL
					mov   hwnd1,eax

					invoke ShowWindow, hwnd1, SW_SHOWNORMAL
					invoke UpdateWindow, hwnd1
				.ENDIF
			.ENDIF
		.ENDIF
	.ELSE
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		ret
	.ENDIF
	xor    eax,eax
	ret
WndProc endp

WndProc1  proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	.IF uMsg==WM_DESTROY
		invoke DestroyWindow,hWnd
		ret
	.ELSEIF uMsg==WM_PAINT
		invoke GetClientRect, hWnd, offset rc
		invoke BeginPaint, hWnd, ADDR ps
		mov hdc,eax
		invoke CreatePen,PS_SOLID, 2, 00000000h
		mov brushBack, eax
		invoke SelectObject,hdc,brushBack
		;Считаем масштаб, сдвиг
		fild rc.bottom
		mov [tmp], 2
		fidiv tmp
		fistp OffsetY
		fild maxX
		fisub minX
		fidivr rc.right
		fstp ScaleX
		fild rc.bottom
		fild maxY 
		fisub minY
		fdiv
		fstp ScaleY
		fild maxX
		fmul ScaleX
		fisubr rc.right
		fistp OffsetX
		;Рисуем координатные оси
		invoke MoveToEx,hdc,OffsetX,0,0
		invoke LineTo,hdc,OffsetX,rc.bottom
		invoke MoveToEx,hdc,0,OffsetY,0
		invoke LineTo,hdc,rc.right,OffsetY
		invoke CreatePen,PS_SOLID, 3, 002020FFh
		mov brushBack, eax
		invoke SelectObject,hdc,brushBack
		;Кол-во повторений, точек
		fild maxX
		fisub minX
		fdiv step
		fabs
		fistp repp

		mov ecx, repp
		fild minX
		fstp x

		invoke count
		push ecx
		invoke MoveToEx, hdc, intX, intY, 0
		pop ecx

		cnt:
		invoke count
		push ecx 
		.IF flg==1
			invoke MoveToEx, hdc, intX, intY, 0
		.ENDIF
		invoke LineTo, hdc, intX, intY
		pop ecx
		fld x
		fadd step
		fstp x
		loop cnt

		invoke EndPaint, hWnd, ADDR ps
	.ELSE
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		ret
	.ENDIF
	xor    eax,eax
	ret
WndProc1 endp

jmp @enddd

count proc
		;(первая скобка)	(1)
		mov [tmp], 5
		fld x
		fmul x
		fmul x
		fmul x
		fimul tmp
		mov [tmp], 7
		fld x
		fmul x
		fmul x
		fimul tmp
		fsubp
		;e^-x
		fld x
		fchs
		fldl2e
		fmul
		fld st
		frndint
		fsub st(1), st
		fxch st(1)
		f2xm1
		fld1
		fadd
		fscale
		fstp st(1)
		;log(e^-x)			(2)
		fldlg2
		fxch
		fyl2x
		;(1)*(2)			(3)
		fmulp
		;12+cos(x^2-17)		(4)
		fld x
		fmul x
		mov [tmp], 17
		fisub tmp
		fcos
		mov [tmp], 12
		fiadd tmp
		;(3) * (4)
		faddp
		;Считаем X и Y, как координату пикселя
		fmul ScaleY
		fild OffsetY
		fsubr
		fistp intY
		fld x
		fmul ScaleX
		fiadd OffsetX
		fistp intX
	ret
count endp

@enddd:
end start
