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
AppName db "Function Researcher v0.1 Beta",0
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
hwndEditPunct HWND ?
hwndEditA HWND ?
hwndEditB HWND ?
tmp dd ?
buffer db 25 dup(?)
x dd ?

error_integral db "Условие непрерывности не выполняется",0
error db "Ошибка",0
error_ODZ db  "Значения не соответсвуют ОДЗ",0

htext_exmin db "Кол-во минимумов",0
htext_exmax db "Кол-во максимумов",0
htext_ex db "Кол-во экстремумов",0
htext_calculate db "Ответ",0
htext_gr db "Угол",0
htext_ymin db "Ymin",0
htext_xmin db  "Xmin",0
htext_ymax db "Ymax",0
htext_xmax db  "Xmax",0


text_int db "ОПРЕДЕЛЕННЫЙ ИНТЕГРАЛ",0
text_min db "Наименьшее значение",0
text_max db "Наибольшее значение",0
text_x1 db "x1",0
text_x2 db "x2",0
text_a db "a",0
text_b db "b",0
text_degree db "Рассчет теперь ведется в градусах",0
text_radian db "Рассчет теперь ведется в радианах",0
text_degrad db "Изменить рассчет угла",0
text_calculate db "Вычислить",0
text_calculate2 db "Введите x0",0
text_search db "ИССЛЕДОВАНИЕ ФУНКЦИИ",0
text_punct db "Кол-во знаков после запятой",0
text_btnpunct db "Изменить",0
text_extremum db "Точки экстремума",0
text_function db "y(x)=sin(pi-x)ln(x^2+8x)+cos(Vx^2-12)e^-x",0

dn10    dd 10
v10     dd 10.0
v8 dd 8.0
v12 dd 12.0
v180 dd 180.0
v100 dd 100.0
v1000 dd 1000.0
v100000 dd 100000.0
v01 dd 0.0001
v_01 dd 0.001
NumBuf  db 64 dup(0)
NumA    dd ?
NumB    dd ?
Num_Buf dd ?
ftmp dd ?
button_text_calc db "Calculate",0

 Hbtn_calculate dd ?
 hwndEditX0 dd ?
 hwndEditX1 dd ?
 hwndEditX2 dd ?
 Hbtn_min dd ?
 Hbtn_max dd ?
 Hbtn_extremum dd ?
 Hbtn_degree dd ?
 Hbtn_punct dd ?
 Hbtn_integral dd ?

 comm_counter dd 6
 x1 dd ?
 x2 dd ?
 ymin dd 1000000.0
 xmin dd ?
 ymax dd -1000000.0
 xmax dd ?
 yprev dd ?
 pflag dd 0
 nflag dd 0
 pcounter dd 0
 ncounter dd 0
 tflag dd 1
 a dd ?
 b dd ?

.const
ButtonID equ 1
RADIAN_RB equ 129
DEGREE_RB equ 130
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
           CW_USEDEFAULT,475,700,NULL,NULL,\
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
						5,55,100,25,hWnd,NULL,hInstance,NULL
		invoke CreateWindowEx,WS_EX_LEFT, ADDR STATIC,ADDR ame2,\
                        WS_CHILD or WS_VISIBLE,\
						5,85,100,25,hWnd,NULL,hInstance,NULL
		invoke CreateWindowEx,WS_EX_LEFT, ADDR STATIC,ADDR ame3,\
                        WS_CHILD or WS_VISIBLE,\
						5,115,100,25,hWnd,NULL,hInstance,NULL
        invoke CreateWindowEx,WS_EX_LEFT, ADDR STATIC,ADDR text_function,\
                        WS_CHILD or WS_VISIBLE,\
						95,25,275,25,hWnd,NULL,hInstance,NULL
        invoke CreateWindowEx,WS_EX_LEFT, ADDR STATIC,ADDR text_calculate2,\
                        WS_CHILD or WS_VISIBLE,\
						250,85,100,25,hWnd,NULL,hInstance,NULL
        invoke CreateWindowEx,WS_EX_LEFT, ADDR STATIC,ADDR text_punct,\
                        WS_CHILD or WS_VISIBLE,\
						250,150,125,50,hWnd,NULL,hInstance,NULL
        invoke CreateWindowEx,WS_EX_LEFT, ADDR STATIC,ADDR text_search,\
                        WS_CHILD or WS_VISIBLE,\
						140,250,200,50,hWnd,NULL,hInstance,NULL
        invoke CreateWindowEx,WS_EX_LEFT, ADDR STATIC,ADDR text_int,\
                        WS_CHILD or WS_VISIBLE,\
						140,500,200,50,hWnd,NULL,hInstance,NULL
        invoke CreateWindowEx,WS_EX_LEFT, ADDR STATIC,ADDR text_x1,\
                       WS_CHILD or WS_VISIBLE,\
						170,270,200,50,hWnd,NULL,hInstance,NULL
		invoke CreateWindowEx,WS_EX_LEFT, ADDR STATIC,ADDR text_x2,\
                       WS_CHILD or WS_VISIBLE,\
					250,270,200,50,hWnd,NULL,hInstance,NULL
        invoke CreateWindowEx,WS_EX_LEFT, ADDR STATIC,ADDR text_a,\
                       WS_CHILD or WS_VISIBLE,\
						170,525,200,50,hWnd,NULL,hInstance,NULL
         invoke CreateWindowEx,WS_EX_LEFT, ADDR STATIC,ADDR text_b,\
                       WS_CHILD or WS_VISIBLE,\
						250,525,200,50,hWnd,NULL,hInstance,NULL
		invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,\
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\
                        ES_AUTOHSCROLL,\
                        95,55,100,25,hWnd,EditID,hInstance,NULL
		mov  hwndEditMinX,eax
			invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,\
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\
                        ES_AUTOHSCROLL,\
						95,85,100,25,hWnd,EditID,hInstance,NULL
		mov  hwndEditMaxX,eax
			invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,\
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\
                        ES_AUTOHSCROLL,\
                        95,115,100,25,hWnd,EditID,hInstance,NULL
		mov  hwndEditStep,eax
		invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,\
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\
                        ES_AUTOHSCROLL,\
                        250,195,50,25,hWnd,EditID,hInstance,NULL
		mov  hwndEditPunct,eax
		invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,\
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\
                        ES_AUTOHSCROLL,\
                        250,100,100,25,hWnd,EditID,hInstance,NULL
		mov  hwndEditX0,eax
		invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,\
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\
                        ES_AUTOHSCROLL,\
                        150,300,70,25,hWnd,EditID,hInstance,NULL
		mov  hwndEditX1,eax
		invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,\
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\
                        ES_AUTOHSCROLL,\
                        230,300,70,25,hWnd,EditID,hInstance,NULL
		mov  hwndEditX2,eax
		invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,\
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\
                        ES_AUTOHSCROLL,\
                        150,545,70,25,hWnd,EditID,hInstance,NULL
		mov  hwndEditA,eax
		invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,\
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\
                        ES_AUTOHSCROLL,\
                        230,545,70,25,hWnd,EditID,hInstance,NULL
		mov  hwndEditB,eax
		;invoke SetFocus, hwndEditMinX
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonText,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        95,145,100,25,hWnd,ButtonID,hInstance,NULL
		mov  hwndButton,eax
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR text_calculate,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        250,125,100,25,hWnd,ButtonID,hInstance,NULL
		mov  Hbtn_calculate,eax
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR text_min,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        50,350,175,50,hWnd,ButtonID,hInstance,NULL
		mov  Hbtn_min,eax
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR text_max,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        250,350,175,50,hWnd,ButtonID,hInstance,NULL
		mov  Hbtn_max,eax
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR text_extremum,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        150,410,150,50,hWnd,ButtonID,hInstance,NULL
		mov  Hbtn_extremum,eax
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR text_degrad,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        250,55,175,25,hWnd,ButtonID,hInstance,NULL
		mov  Hbtn_degree,eax
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR text_btnpunct,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        300,195,100,25,hWnd,ButtonID,hInstance,NULL
		mov  Hbtn_punct,eax
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR text_calculate,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        175,580,100,25,hWnd,ButtonID,hInstance,NULL
		mov  Hbtn_integral,eax
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR LineName,\
                        WS_CHILD or WS_VISIBLE or BS_AUTORADIOBUTTON,\
                        95,175,100,25,hWnd,LINE_RB,hInstance,NULL
		invoke SendMessage,eax,BM_SETCHECK,BST_CHECKED,0
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR PointName,\
                        WS_CHILD or WS_VISIBLE or BS_AUTORADIOBUTTON,\
                        95,205,100,25,hWnd,POINT_RB,hInstance,NULL
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
				    mov eax,lParam
					.IF eax==hwndButton
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
					.IF eax==Hbtn_degree
					 .IF  tflag==1
						mov tflag,0
						push MB_OK
						push offset htext_gr
						push offset text_degree
						push hWnd
						call MessageBox
					  .ELSEIF  tflag==0
						mov tflag,1
						push MB_OK
						push offset htext_gr
						push offset text_radian
						push hWnd
						call MessageBox
					 .ENDIF
					.ENDIF
					.IF eax==Hbtn_calculate
					push offset NumBuf
	                push 32
	                push WM_GETTEXT
	                push hwndEditX0 
	                call SendMessage
					lea ebx, NumBuf
                    ;Переводим строку в вещественное число
                    ;В ebx мы передаём указатель на буфер
                    ;В вершине стэка вещественных чисел будет возвращенно вещественное число
	                call str2flt
	                FSTP ftmp
					mov eax,ftmp
					call flt_calc
	                lea ebx,NumBuf
	                add ebx,63
					mov ftmp,eax
	                FLD ftmp
	                call flt2str
	                push MB_OK
	                push offset htext_calculate
	                push ebx
	                push hWnd
	                call MessageBox
					.ENDIF
					.IF eax==Hbtn_min
					invoke GetWindowText,hwndEditX1,ADDR buffer,25
					invoke StrToInt, ADDR buffer
					mov ebx,eax
					invoke GetWindowText,hwndEditX2,ADDR buffer,25
					invoke StrToInt, ADDR buffer
					sub eax,ebx
					mov ecx,10000
					mul ecx
					mov ecx,eax
					push ecx
					push offset NumBuf
	                push 32
	                push WM_GETTEXT
	                push hwndEditX1 
	                call SendMessage
					lea ebx, NumBuf
	                call str2flt
	                fstp x1
					mov ebx,x1
					pop ecx

					minimum:
					mov eax,ebx
					mov ftmp,eax
					fld ftmp
					call flt_calc
					fstp tmp
					mov ftmp,eax
					fld ftmp
					fld ymin
					fxch
					fcomi st,st(1) 
					jae notmin
					mov eax,ftmp
					mov ymin,eax
					mov xmin,ebx
					notmin:
					fstp tmp
					fstp tmp
					mov ftmp,ebx
			        fld ftmp
					fld v01
					fadd
					fstp ftmp
					mov ebx,ftmp
					loop minimum

					lea ebx,NumBuf
	                add ebx,63
					mov eax,ymin
					mov ftmp,eax
	                FLD ftmp
	                call flt2str
	                push MB_OK
	                push offset htext_ymin
	                push ebx
	                push hWnd
	                call MessageBox
					lea ebx,NumBuf
	                add ebx,63
					mov eax,xmin
					mov ftmp,eax
	                FLD ftmp
	                call flt2str
	                push MB_OK
	                push offset htext_xmin
	                push ebx
	                push hWnd
	                call MessageBox
					error2:
					invoke MessageBox,hWnd,offset error_ODZ,offset error,MB_OK
					.ENDIF

					.IF eax==Hbtn_max
					invoke GetWindowText,hwndEditX1,ADDR buffer,25
					invoke StrToInt, ADDR buffer
					mov ebx,eax
					invoke GetWindowText,hwndEditX2,ADDR buffer,25
					invoke StrToInt, ADDR buffer
					sub eax,ebx
					mov ecx,10000
					mul ecx
					mov ecx,eax
					push ecx
					push offset NumBuf
	                push 32
	                push WM_GETTEXT
	                push hwndEditX1 
	                call SendMessage
					lea ebx, NumBuf
	                call str2flt
	                fstp x1
					mov ebx,x1
					pop ecx

					maximum:
					mov eax,ebx
					mov ftmp,eax
					fld ftmp
					call flt_calc
					fstp tmp
					mov ftmp,eax
					fld ftmp
					fld ymax
					fxch
					fcomi st,st(1) 
					jbe notmax
					mov eax,ftmp
					mov ymax,eax
					mov xmax,ebx
					notmax:
					fstp tmp
					fstp tmp
					mov ftmp,ebx
			        fld ftmp
					fld v01
					fadd
					fstp ftmp
					mov ebx,ftmp
					loop maximum

					lea ebx,NumBuf
	                add ebx,63
					mov eax,ymax
					mov ftmp,eax
	                FLD ftmp
	                call flt2str
	                push MB_OK
	                push offset htext_ymax
	                push ebx
	                push hWnd
	                call MessageBox
				    lea ebx,NumBuf
	                add ebx,63
					mov eax,xmax
					mov ftmp,eax
	                FLD ftmp
	                call flt2str
	                push MB_OK
	                push offset htext_xmax
	                push ebx
	                push hWnd
	                call MessageBox
					.ENDIF

					.IF eax==Hbtn_punct
					invoke GetWindowText,hwndEditPunct,ADDR buffer,25
					invoke StrToInt, ADDR buffer
					mov  comm_counter,eax
					.ENDIF

					.IF eax==Hbtn_extremum
					invoke GetWindowText,hwndEditX1,ADDR buffer,25
					invoke StrToInt, ADDR buffer
					mov ebx,eax
					invoke GetWindowText,hwndEditX2,ADDR buffer,25
					invoke StrToInt, ADDR buffer
					sub eax,ebx
					mov ecx,1000
					mul ecx
					mov ecx,eax
					push ecx
					push offset NumBuf
	                push 32
	                push WM_GETTEXT
	                push hwndEditX1 
	                call SendMessage
					lea ebx, NumBuf
	                call str2flt
	                fstp x1
					mov eax,x1
					mov ftmp,eax
					fld ftmp
					call flt_calc
					mov yprev,eax
			        fld ftmp
					fld v_01
					fadd
					fstp ftmp
					mov ebx,ftmp
					pop ecx
					extremum:
					mov eax,ebx
					mov ftmp,eax
					fld ftmp
					call flt_calc
					mov ftmp,eax
					fstp tmp
					fld ftmp
					fld yprev
					fxch
					fcomi st,st(1) 
					jae smaller
					jmp more
					smaller:
					.IF pflag==0
					inc pcounter
					mov nflag,0
					mov pflag,1
					.ENDIF
					jmp next
					more:
					.IF nflag==0
					inc ncounter
					mov pflag,0
					mov nflag,1
					.ENDIF
					next:
					mov eax,ftmp
					mov yprev,eax
					fstp tmp
					fstp tmp
					mov ftmp,ebx
			        fld ftmp
					fld v_01
					fadd
					fstp ftmp
					mov ebx,ftmp
					dec ecx
					test ecx,ecx
					jnz extremum
					
					
					lea ebx,NumBuf
					add ebx,63
					mov eax,pcounter
					dec eax
					add eax,ncounter
	                call int2str
	                push MB_OK
	                push offset htext_ex
	                push ebx
	                push hWnd
	                call MessageBox
					lea ebx,NumBuf
					add ebx,63
					mov eax,pcounter
					dec eax
	                call int2str
	                push MB_OK
	                push offset htext_exmin
	                push ebx
	                push hWnd
	                call MessageBox
					lea ebx,NumBuf
	                add ebx,63
					mov eax,ncounter
	                call int2str
	                push MB_OK
	                push offset htext_exmax
	                push ebx
	                push hWnd
	                call MessageBox
					mov pcounter,0
					mov ncounter,0
					.ENDIF

					.IF eax==Hbtn_integral
					push offset NumBuf
	                push 32
	                push WM_GETTEXT
	                push hwndEditA 
	                call SendMessage
					lea ebx, NumBuf
	                call str2flt
					fstp a
					push offset NumBuf
	                push 32
	                push WM_GETTEXT
	                push hwndEditB 
	                call SendMessage
					lea ebx, NumBuf
	                call str2flt
					fstp b
					fld b 
					fld a
					fcomip st,st(1)
					fstp tmp
					jb not_error
					push MB_OK
	                push offset error
	                push offset error_integral
	                push hWnd
	                call MessageBox
					jmp iserror
					not_error:
					mov eax,b
					call flt_calc
					mov b,eax
					fld a
					mov eax,a
					call flt_calc
					fstp tmp 
					mov a,eax
					fld a
					fld b
					fsub
				    lea ebx,NumBuf
	                add ebx,63
	                call flt2str
	                push MB_OK
	                push offset htext_calculate
	                push ebx
	                push hWnd
	                call MessageBox
					iserror:		
					.ENDIF
					.ENDIF
			.ENDIF;clicked
		.ENDIF;buttonid
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
    fld x
	fld x;x
	fmul;x^2
    fld x
    mov [tmp],8
    fimul tmp;8x
    fadd;x^2+8x
	fld1;1
	fxch st(1);st(0)=x^2+8x,st(1)=1
	fyl2x;log2 x^2+8x
	fldl2e;log2e
	fdiv;log2 x^2+8x/log2e=ln x^2+8x

	fldpi;pi
	fld x
	fsub;pi-x
	.IF tflag==0
	fldpi
	fmul
	fld v180
	fdiv
	.ENDIF
	fsin;sin(pi-x)

	fmul;sin(pi-x)*ln x^2+8x
	
	fld x
	fld x;x
	fmul;x^2
	mov [tmp],12
	fisub tmp;x^2-12
	fsqrt;srqt(x^2-12)
	.IF tflag==0
	fldpi
	fmul
	fld v180
	fdiv
	.ENDIF
	fcos;cos(sqrt(x^2-12))

	fld x
    fchs;-x
	fldl2e
    fmul;log2e*-x
    fld st;st(0)=st(1)=log2e*-x
    frndint;в st(0) целая часть
    fsub st(1),st;в st(1) остаток
    fxch st(1);st(0)-остаток,st(1)-целая часть
    f2xm1;st(0)=(2^остаток)-1
    fld1;st(0)=1,st(1)=(2^остаток)-1
    fadd;st(0)=2^остаток,st(1)=2^целая часть
    fscale;st(0)=2^остаток*2^целая часть=2^(log2e*-x)
    fstp st(1);
    
	fmul;cos(sqrt(x^2-12))*e^(-x)

	fadd;sin(pi-x)*ln x^2+8x+cos(sqrt(x^2-12))*e^(-x)

	fmul ScaleY
    fmul v1000
	fild OffsetY
	fsubr
	fistp intY
	fld x
	fmul ScaleX
	fiadd OffsetX
	fistp intX
count endp
flt_calc proc
    sub esp,04h

    mov [esp],eax
	FLD dword ptr [esp];x
	fld st;x
	fmul;x^2
    mov [esp],eax
    FLD dword ptr [esp];x
    fld v8;8
    fmul;8x
    fadd;x^2+8x
	fld1;1
	fxch st(1);st(0)=x^2+8x,st(1)=1
	fyl2x;log2 x^2+8x
	fldl2e;log2e
	fdiv;log2 x^2+8x/log2e=ln x^2+8x

	fldpi;pi
	mov [esp],eax
	FLD dword ptr [esp];x
	fsub;pi-x
	.IF tflag==0
	fldpi
	fmul
	fld v180
	fdiv
	.ENDIF
	fsin;sin(pi-x)

	fmul;sin(pi-x)*ln x^2+8x
	
	mov [esp],eax
	FLD dword ptr [esp];x
	fld st;x
	fmul;x^2
	fld v12;12
	fsub;x^2-12
	fsqrt;srqt(x^2-12)
	.IF tflag==0
	fldpi
	fmul
	fld v180
	fdiv
	.ENDIF
	fcos;cos(sqrt(x^2-12))

	mov [esp],eax
	FLD dword ptr [esp];x
    fchs;-x
	fldl2e
    fmul;log2e*-x
    fld st;st(0)=st(1)=log2e*-x
    frndint;в st(0) целая часть
    fsub st(1),st;в st(1) остаток
    fxch st(1);st(0)-остаток,st(1)-целая часть
    f2xm1;st(0)=(2^остаток)-1
    fld1;st(0)=1,st(1)=(2^остаток)-1
    fadd;st(0)=2^остаток,st(1)=2^целая часть
    fscale;st(0)=2^остаток*2^целая часть=2^(log2e*-x)
    fstp st(1);
    
	fmul;cos(sqrt(x^2-12))*e^(-x)

	fadd;sin(pi-x)*ln x^2+8x+cos(sqrt(x^2-12))*e^(-x)

    FSTP dword ptr [esp]
	mov eax,[esp]
	add esp,04h
	ret
flt_calc endp
str2flt:
flt_part equ dword ptr [esp]
int_part equ dword ptr [esp+04h]
neg_flag equ dword ptr [esp+08h]
cpy_addr equ dword ptr [esp+0Ch]
;Резервируем место для 4ёх 32битных аргументов
	sub esp,010h
	xor edx,edx
;Проверим, стоит ли знак минус перед числом
;Если стоит, то поставим в стек соотвутствующий флаг
	mov al,[ebx]
	cmp al,'-'
	jnz flt_positive
	mov neg_flag,1
	jmp pt_prelp
flt_positive:
	mov neg_flag,0
pt_prelp:
;Заменяем точку на нулевой символ и переводим те строки в два целых числа
	mov int_part,ebx
	dec ebx
;Найдём позицию точки в строке
	pt_lp:
		inc ebx
		mov al,[ebx]
		cmp al,'.'
		jz pt_found
		test al,al
	jnz pt_lp
;Точка не найдена, дробная часть вещественного числа равна 0
	mov cpy_addr,1
	mov flt_part,edx
	jmp pt_int_part
pt_found:
	mov [ebx],dl
	inc ebx
	mov cpy_addr,ebx
	call str2uint
	mov flt_part,eax
	sub ebx,cpy_addr
	mov cpy_addr,ebx
pt_int_part:
	mov ebx, int_part
	call str2int
	mov int_part,eax
	mov ecx,cpy_addr
	FILD flt_part
pt_flt:
	FDIV v10
	loop pt_flt
pt_int:
	FILD int_part
	cmp neg_flag,1
	jne rez_pol
	fxch
	fchs
rez_pol:
	FADD
pt_ret:
	add esp,010h
	ret
;str2flt end


flt2str:
	sub esp,04h
	FLDZ
	FADD ST,ST(1)
	FLDZ
	FADD ST,ST(1)
;Округлим число и вычтем его от числа с дробной частью
	FRNDINT
	FSUB
;В результате осталась только дробная часть
fstr_flt_part:
;Умножим дробную часть на 100000
;Мы округляем число до 6ти знаков
;При необходимости можно взять больше знаков
    mov ecx,comm_counter
	_comm:
	FMUL v10
	loop _comm
	FISTP dword ptr [esp]
	mov eax,[esp]
	test eax,eax
;Результирующее число всегда меньше на единицу. Нормализуем ,увеличив его на 1, в случае если дробная часть не равна нулю.
	jz dont_inc
	inc eax
	mov dword ptr [esp],eax
dont_inc:
;Результирующее число имеет отрицательный знак. Это обычно означает, что дробная часть у числа длинная.
;Нормализуем это число путём его бинарного отрицания
	test eax,080000000h
	jz not_neg
	neg eax
	inc eax
not_neg:
	mov byte ptr [ebx],0h
	dec ebx
;Запишем дробную часть
	call uint2str
;Теперь нормализуем строковую дробную часть, добавив нули в случае, если дробная часть имеет меньше 5 знаков
	dec ebx
	mov ecx,[esp]
	mov eax,10000
add_z_lp:
	cmp eax,ecx
	jbe done_z_lp
	mov byte ptr [ebx],'0'
	dec ebx
	xor edx,edx
	div dn10
	test eax,eax
	jnz add_z_lp
;Завершаем дробную часть точкой и переводим целую часть в строку
done_z_lp:
	mov byte ptr [ebx],'.'
	dec ebx
	FISTP dword ptr [esp]
	mov eax,[esp]
	call int2str
	add esp,04h
	ret
;flt2str end

str2int:
	sub esp,04h
	;Обнулим eax и edi для дальнейших вычислений
	xor edi,edi
	xor eax,eax
	mov dl,[ebx]
	cmp dl,'-'
	jnz i_positive
	inc ebx
	mov [esp],edx
	jmp i_lp
i_positive:
	mov [esp],eax
	i_lp:
		mov dl,[ebx]
		test dl,dl
		jz i_end
		cmp dl,'0'
		jb fail_input
		cmp dl,'9'
		ja fail_input
		sub dl,'0'
		;Копируем dl в di, т.к. при умножении edx будет перезаписан
		xor dh,dh
		mov di,dx
		mul dn10
		add eax,edi
		inc ebx
	jmp i_lp
i_end:
	mov edx,[esp]
	test edx,edx
	jz i_ret
	not eax
	inc eax
i_ret:
	add esp,04h
	ret
fail_input:
	xor eax,eax
	add esp,04h
	ret
;str2int end

str2uint:
	;Обнулим eax и edi для дальнейших вычислений
	xor edi,edi
	xor eax,eax
	ui_lp:
		mov dl,[ebx]
		test dl,dl
		jz ui_end
		cmp dl,'0'
		jb ufail_input
		cmp dl,'9'
		ja fail_input
		sub dl,'0'
		;Копируем dl в di, т.к. при умножении edx будет перезаписан
		xor dh,dh
		mov di,dx
		mul dn10
		add eax,edi
		inc ebx
	jmp ui_lp
ui_end:
	ret
ufail_input:
	xor eax,eax
	ret
;str2int end

uint2str:
	uo_lp:
		xor edx,edx
		div dn10
		add dl,'0'
		mov [ebx],dl
		dec ebx
		test eax,eax
	jnz uo_lp
	inc ebx
	ret
;int2str end


int2str:
	sub esp,04h
	xor edx,edx
	test eax,080000000h
	jz o_positive
	mov [esp],eax
	;Знак числа будет хранится в стеке
	not eax
	inc eax
	jmp o_prelp
o_positive:
	mov [esp],edx
o_prelp:
	o_lp:
		div dn10
		add dl,'0'
		mov [ebx],dl
		dec ebx
		xor edx,edx
		test eax,eax
	jnz o_lp
	mov eax,[esp]
	test eax,eax
	jz o_char_positive
	mov al,'-'
	mov [ebx],al
	add esp,04h
	ret
o_char_positive:
	inc ebx
	add esp,04h
	ret
;int2str end
    


 @enddd:
 end start