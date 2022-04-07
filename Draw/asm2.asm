.686
.model flat, stdcall
option casemap:none
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD
count proto :DWORD,:DWORD
Paint_Proc proto :DWORD, :DWORD
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

_rectangles struc
   lx dd ?
   ly dd ?
   rx dd ?
   ry dd ?
_rectangles ends

_circle struc
   clx dd ?
   cly dd ?
   crx dd ?
   cry dd ?
_circle ends
 
_square struc
   slx dd ?
   sly dd ?
   srx dd ?
   sry dd ?
_square ends

_point struc
   x dd ?
   y dd ?
_point ends

_triangle struc
   tx1 dd ?
   ty1 dd ?
   tx2 dd ?
   ty2 dd ?
   tx3 dd ?
   ty3 dd ?
_triangle ends

.data
ClassName db "SimpleWinClass", 0
AppName db "МЕГА КОНСТРУКТОР LEGA v.000001 Pre-alpha", 0
hInstance HINSTANCE ?

;прямоугольник
rectangles _rectangles 50 dup(<50,50,100,80>)
irect dd ?
colors_rect dd 50 dup(?)
icolor_rect dd ?
Hcolor_rect HWND ?
Hbtn_rect dd ?
Hbtn_rect_color dd ?
color_rect dd ?
x1 dd ?
y1 dd ?
x2 dd ?
y2 dd ?

;круг
circles _circle 50 dup(<50,50,100,100>)
icircle dd ?
colors_circle dd 50 dup(?)
icolor_circle dd ?
Hbtn_circle dd ?
Hbtn_circle_color dd ?
Hcolor_circle HWND ?
color_circle dd ?
cx1 dd ?
cy1 dd ?
cx2 dd ?
cy2 dd ?

;квадрат
squares _square 50 dup(<50,50,100,100>)
isquare dd ?
colors_square dd 50 dup(?)
icolor_square dd ?
Hbtn_square dd ?
Hbtn_square_color dd ?
Hcolor_square HWND ?
color_square dd ?
sx1 dd ?
sy1 dd ?
sx2 dd ?
sy2 dd ?

;треугольник
triangle _point 10 dup(<>)
triangles _triangle 50 dup(<30,100,15,130,45,130>)
colors_triangle dd 50 dup(?)
itriangle dd ?
icolor_triangle dd ?
Hbtn_triangle dd ?
Hbtn_triangle_color dd ?
Hcolor_triangle HWND ?
color_triangle dd ?

;options
Hbtn_speed dd ?
Hspeed dd ?
speed dd 1

HBtn dd ?
HBrush dd ?
ButtonClassName db "button",0
ButtonText db "Create",0
ButtonText2 db "Change",0
ButtonText3 db "Clear",0

fswitcher dd 4

circle_counter dd 0
square_counter dd 0
rectangle_counter dd 0
triangle_counter dd 0
counter dd ?


text_header db "LEGA",0
text_deffigure db "Your figure:",0
text_rectangle db "Rectangle",0
text_circle db "Circle",0
text_color db "Color:",0
text_logo db "©2019,OOO <<Best Software>>.All right reserved.",0
text_speed db "Figure speed",0
text_options db "Options",0
text_square db "Square",0
text_triangle db "Triangle",0
Hfont_header dd ?


buffer db 25 dup(?)
holdpen dd ?

STATIC db "STATIC",0
EditClassName db "edit",0
ame1 db "Минимум x:",0

numbuffer dd ?
Hbtn_clear dd ?

.const
ButtonID equ 1
EditID equ 2
.code
start:
	invoke GetModuleHandle, NULL
	mov    hInstance, eax
	invoke WinMain, hInstance, NULL, NULL, NULL
	invoke ExitProcess, eax

WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD
		LOCAL wc:WNDCLASSEX
		LOCAL msg:MSG
		LOCAL hwnd:HWND
    mov   wc.cbSize, SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW
	mov   wc.lpfnWndProc, OFFSET WndProc
	mov   wc.cbClsExtra, NULL
	mov   wc.cbWndExtra, NULL
	push  hInst
	pop   wc.hInstance
	mov   wc.hbrBackground, 0
	mov   wc.lpszMenuName, 0
	mov   wc.lpszClassName, OFFSET ClassName
	invoke LoadIcon, NULL, IDI_APPLICATION
	mov   wc.hIcon, eax
	invoke LoadCursor, NULL, IDC_ARROW
	mov   wc.hCursor, eax
	invoke RegisterClassEx, addr wc
	INVOKE CreateWindowEx, WS_EX_CLIENTEDGE, ADDR ClassName, ADDR AppName,\
           WS_OVERLAPPEDWINDOW, CW_USEDEFAULT,\
           CW_USEDEFAULT, 1024, 768, NULL, NULL,\
           hInst, NULL
	mov hwnd, eax
	INVOKE ShowWindow, hwnd, SW_SHOWNORMAL
	INVOKE UpdateWindow, hwnd
      .WHILE TRUE
                INVOKE GetMessage, ADDR msg, NULL, 0, 0
                .BREAK .IF (!eax)
                INVOKE TranslateMessage, ADDR msg
                INVOKE DispatchMessage, ADDR msg
	  .ENDW
	mov eax, msg.wParam
	ret
WinMain endp




WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
        LOCAL hOld:HDC
        LOCAL hMemDC: HDC
        LOCAL hBmp: HDC
        LOCAL ps:PAINTSTRUCT
		LOCAL ps2:PAINTSTRUCT 
        LOCAL rc:RECT
        LOCAL hdc:HDC

    .IF uMsg==WM_DESTROY
        invoke PostQuitMessage, NULL
	  ret
    .ELSEIF uMsg==WM_CREATE
	  invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonText,WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,75,650,100,25,hWnd,ButtonID,hInstance,NULL;кнопка создания прямоугольника
	  mov Hbtn_rect,eax
	   invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonText2,WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,75,680,100,25,hWnd,ButtonID,hInstance,NULL;кнопка создания прямоугольника
	  mov Hbtn_rect_color,eax
	  invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonText,WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,300,650,100,25,hWnd,ButtonID,hInstance,NULL;кнопка создания круга
	  mov Hbtn_circle,eax
	  invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonText2,WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,300,680,100,25,hWnd,ButtonID,hInstance,NULL;кнопка создания круга
	  mov Hbtn_circle_color,eax
	  invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonText,WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,485,650,100,25,hWnd,ButtonID,hInstance,NULL;кнопка создания квадрат
	  mov Hbtn_square,eax
	  invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonText2,WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,485,680,100,25,hWnd,ButtonID,hInstance,NULL;кнопка создания квадрат
	  mov Hbtn_square_color,eax
	  invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonText,WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,675,650,100,25,hWnd,ButtonID,hInstance,NULL;кнопка создания квадрат
	  mov Hbtn_triangle,eax
	  invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonText2,WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,675,680,100,25,hWnd,ButtonID,hInstance,NULL;кнопка создания квадрат
	  mov Hbtn_triangle_color,eax
	  invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonText2,WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,850,630,100,25,hWnd,ButtonID,hInstance,NULL;кнопка скорости
	  mov Hbtn_speed,eax
	  invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonText3,WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,850,680,100,25,hWnd,ButtonID,hInstance,NULL;кнопка скорости
	  mov Hbtn_clear,eax
	  invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or ES_AUTOHSCROLL,75,600,100,25,hWnd,EditID,hInstance,NULL;цвет прямоугольника
	  mov Hcolor_rect,eax
	  invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or ES_AUTOHSCROLL,300,600,100,25,hWnd,EditID,hInstance,NULL;цвет круга
	  mov Hcolor_circle,eax
	  invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or ES_AUTOHSCROLL,485,600,100,25,hWnd,EditID,hInstance,NULL;цвет квадрата
	  mov Hcolor_square,eax
	  invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or ES_AUTOHSCROLL,675,600,100,25,hWnd,EditID,hInstance,NULL;цвет треугольника
	  mov Hcolor_triangle,eax
	  invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or ES_AUTOHSCROLL,850,600,100,25,hWnd,EditID,hInstance,NULL;текстбокс скорости
	  mov Hspeed,eax

  	.ELSEIF uMsg==WM_COMMAND
			mov eax,wParam
			.IF ax==ButtonID
				shr eax,16
				.IF ax==BN_CLICKED
				  mov eax,lParam
				 .IF eax==Hbtn_rect
					invoke GetWindowText,Hcolor_rect,ADDR buffer,25;достаем цвет
					invoke StrToIntEx, ADDR buffer,1,ADDR numbuffer;из textboxа
					mov eax,numbuffer
					invoke CreateSolidBrush, eax
					mov ebx,icolor_rect
					mov colors_rect[ebx],eax
					inc rectangle_counter
					mov fswitcher,1
					invoke InvalidateRect, hWnd, 0, FALSE
				 .ENDIF
				 .IF eax==Hbtn_rect_color
					 invoke GetWindowText,Hcolor_rect,ADDR buffer,25;достаем цвет
			         invoke StrToIntEx, ADDR buffer,1,ADDR numbuffer;из textboxа
			         mov eax,numbuffer
			         invoke CreateSolidBrush, eax
			         mov ebx,icolor_rect
			         sub ebx,4
			         mov colors_rect[ebx],eax
			         invoke InvalidateRect, hWnd, 0, FALSE
				 .ENDIF
				 .IF eax==Hbtn_circle
				    invoke GetWindowText,Hcolor_circle,ADDR buffer,25;достаем цвет
					invoke StrToIntEx, ADDR buffer,1,ADDR numbuffer;из textboxа
				    mov eax,numbuffer
					invoke CreateSolidBrush, eax
					mov ebx,icolor_circle
					mov colors_circle[ebx],eax
				    inc circle_counter
					mov fswitcher,3
					invoke InvalidateRect, hWnd, 0, FALSE
				 .ENDIF
				 .IF eax==Hbtn_circle_color
					 invoke GetWindowText,Hcolor_circle,ADDR buffer,25;достаем цвет
			         invoke StrToIntEx, ADDR buffer,1,ADDR numbuffer;из textboxа
			         mov eax,numbuffer
			         invoke CreateSolidBrush, eax
			         mov ebx,icolor_circle
			         sub ebx,4
			         mov colors_circle[ebx],eax
			         invoke InvalidateRect, hWnd, 0, FALSE
				 .ENDIF
				 .IF eax==Hbtn_square
				    invoke GetWindowText,Hcolor_square,ADDR buffer,25;достаем цвет
					invoke StrToIntEx, ADDR buffer,1,ADDR numbuffer;из textboxа
				    mov eax,numbuffer
					invoke CreateSolidBrush, eax
					mov ebx,icolor_square
					mov colors_square[ebx],eax
				    inc square_counter
					mov fswitcher,2
					invoke InvalidateRect, hWnd, 0, FALSE
				 .ENDIF
				  .IF eax==Hbtn_square_color
				     invoke GetWindowText,Hcolor_square,ADDR buffer,25;достаем цвет
			         invoke StrToIntEx, ADDR buffer,1,ADDR numbuffer;из textboxа
			         mov eax,numbuffer
			         invoke CreateSolidBrush, eax
			         mov ebx,icolor_square
			         sub ebx,4
			         mov colors_square[ebx],eax
			         invoke InvalidateRect, hWnd, 0, FALSE
				 .ENDIF
				 .IF eax==Hbtn_triangle
				    invoke GetWindowText,Hcolor_triangle,ADDR buffer,25;достаем цвет
					invoke StrToIntEx, ADDR buffer,1,ADDR numbuffer;из textboxа
					mov eax,numbuffer
					invoke CreateSolidBrush, eax
					mov ebx,icolor_triangle
					mov colors_triangle[ebx],eax
				    inc triangle_counter
				    mov fswitcher,4
					invoke InvalidateRect, hWnd, 0, FALSE
				 .ENDIF
				  .IF eax==Hbtn_triangle_color
				     invoke GetWindowText,Hcolor_triangle,ADDR buffer,25;достаем цвет
			         invoke StrToIntEx, ADDR buffer,1,ADDR numbuffer;из textboxа
			         mov eax,numbuffer
			         invoke CreateSolidBrush, eax
			         mov ebx,icolor_triangle
			         sub ebx,4
			         mov colors_triangle[ebx],eax
			         invoke InvalidateRect, hWnd, 0, FALSE
				 .ENDIF
				 .IF eax==Hbtn_speed
				    invoke GetWindowText,Hspeed,ADDR buffer,25;достаем скорость
					invoke StrToInt, ADDR buffer ;из textboxа
					mov speed,eax
				    invoke SetFocus,hWnd
				 .ENDIF
				  .IF eax==Hbtn_clear
				   mov circle_counter,0
                   mov square_counter,0
                   mov rectangle_counter,0
                   mov triangle_counter,0
				    invoke InvalidateRect,hWnd,0,FALSE
				 .ENDIF
				.ENDIF
			.ENDIF
    .ELSEIF uMsg==WM_KEYDOWN
	  .IF fswitcher==1 ;rectangle
	       .IF wParam==37;left
		       mov esi,irect
			   mov eax,speed
		       sub rectangles[esi].lx,eax
			   sub rectangles[esi].rx,eax
			   invoke InvalidateRect, hWnd, 0, FALSE
		   .ENDIF
		    .IF wParam==38;up
			   mov esi,irect
			   mov eax,speed
		       sub rectangles[esi].ly,eax
			   sub rectangles[esi].ry,eax
			   invoke InvalidateRect, hWnd, 0, FALSE
		   .ENDIF
		    .IF wParam==39;right
			   mov esi,irect
			   mov eax,speed
		       add rectangles[esi].lx,eax
			   add rectangles[esi].rx,eax
			   invoke InvalidateRect, hWnd, 0, FALSE
		   .ENDIF
		    .IF wParam==40;down
			   mov esi,irect
			   mov eax,speed
		       add rectangles[esi].ly,eax
			   add rectangles[esi].ry,eax
			   invoke InvalidateRect, hWnd, 0, FALSE
		   .ENDIF
	 .ENDIF
	 .IF fswitcher==2 ;square
	     .IF wParam==37;left
		       mov esi,isquare
			   mov eax,speed
		       sub squares[esi].slx,eax
			   sub squares[esi].srx,eax
			   invoke InvalidateRect, hWnd, 0, FALSE
		   .ENDIF
		    .IF wParam==38;up
			   mov esi,isquare
			   mov eax,speed
		       sub squares[esi].sly,eax
			   sub squares[esi].sry,eax
			   invoke InvalidateRect, hWnd, 0, FALSE
		   .ENDIF
		    .IF wParam==39;right
			   mov esi,isquare
			   mov eax,speed
		       add squares[esi].slx,eax
			   add squares[esi].srx,eax
			   invoke InvalidateRect, hWnd, 0, FALSE
		   .ENDIF
		    .IF wParam==40;down
			   mov esi,isquare
			   mov eax,speed
		       add squares[esi].sly,eax
			   add squares[esi].sry,eax
			   invoke InvalidateRect, hWnd, 0, FALSE
		   .ENDIF
	 .ENDIF
	 .IF fswitcher==3 ;circle
	       .IF wParam==37;left
		       mov esi,icircle
			   mov eax,speed
		       sub circles[esi].clx,eax
			   sub circles[esi].crx,eax
			   invoke InvalidateRect, hWnd, 0, FALSE
		   .ENDIF
		    .IF wParam==38;up
			   mov esi,icircle
			   mov eax,speed
		       sub circles[esi].cly,eax
			   sub circles[esi].cry,eax
			   invoke InvalidateRect, hWnd, 0, FALSE
		   .ENDIF
		    .IF wParam==39;right
			   mov esi,icircle
			   mov eax,speed
		       add circles[esi].clx,eax
			   add circles[esi].crx,eax
			   invoke InvalidateRect, hWnd, 0, FALSE
		   .ENDIF
		    .IF wParam==40;down
			   mov esi,icircle
			   mov eax,speed
		       add circles[esi].cly,eax
			   add circles[esi].cry,eax
			   invoke InvalidateRect, hWnd, 0, FALSE
		   .ENDIF
	 .ENDIF
	 .IF fswitcher==4
	        .IF wParam==37;left
		       mov esi,itriangle
			   mov eax,speed
		       sub triangles[esi].tx1,eax
			   sub triangles[esi].tx2,eax
			   sub triangles[esi].tx3,eax
			   invoke InvalidateRect, hWnd, 0, FALSE
		   .ENDIF
		    .IF wParam==38;up
			   mov esi,itriangle
			   mov eax,speed
		       sub triangles[esi].ty1,eax
			   sub triangles[esi].ty2,eax
			   sub triangles[esi].ty3,eax
			   invoke InvalidateRect, hWnd, 0, FALSE
		   .ENDIF
		    .IF wParam==39;right
			   mov esi,itriangle
			   mov eax,speed
		       add triangles[esi].tx1,eax
			   add triangles[esi].tx2,eax
			   add triangles[esi].tx3,eax
			   invoke InvalidateRect, hWnd, 0, FALSE
		   .ENDIF
		    .IF wParam==40;down
			   mov esi,itriangle
			   mov eax,speed
		       add triangles[esi].ty1,eax
			   add triangles[esi].ty2,eax
			   add triangles[esi].ty3,eax
			   invoke InvalidateRect, hWnd, 0, FALSE
		   .ENDIF
	 .ENDIF
	 .ELSEIF uMsg==WM_MOUSEMOVE
	          mov eax,wParam
			  .IF wParam==MK_MBUTTON
			  invoke InvalidateRect, hWnd, 0, TRUE
			  .ENDIF
			.IF fswitcher==1
			 .IF wParam==MK_LBUTTON
			  mov esi,irect
			  dec rectangles[esi].lx
			  dec rectangles[esi].ly
			  invoke InvalidateRect, hWnd, 0, FALSE
			 .ENDIF
			 .IF wParam==MK_RBUTTON
			  mov esi,irect
			  inc rectangles[esi].lx
			  inc rectangles[esi].ly
			  invoke InvalidateRect, hWnd, 0, FALSE
			 .ENDIF
			.ENDIF
			.IF fswitcher==2
			 .IF wParam==MK_LBUTTON
			  mov esi,isquare
			  dec squares[esi].slx
			  dec squares[esi].sly
			  invoke InvalidateRect, hWnd, 0, FALSE
			 .ENDIF
			 .IF wParam==MK_RBUTTON
              mov esi,isquare
			  inc squares[esi].slx
			  inc squares[esi].sly
			  invoke InvalidateRect, hWnd, 0, FALSE
			 .ENDIF
			.ENDIF
			.IF fswitcher==3
			 .IF wParam==MK_LBUTTON
			  mov esi,icircle
			  dec circles[esi].clx
			  dec circles[esi].cly
			  invoke InvalidateRect, hWnd, 0, FALSE
			 .ENDIF
			 .IF wParam==MK_RBUTTON
              mov esi,icircle
			  inc circles[esi].clx
			  inc circles[esi].cly
			  invoke InvalidateRect, hWnd, 0, FALSE
			 .ENDIF
	      .ENDIF
		  .IF fswitcher==4
			  .IF wParam==MK_LBUTTON
			  mov esi,itriangle
			  dec triangles[esi].ty1
			  dec triangles[esi].tx2
			  inc triangles[esi].ty2
			  inc triangles[esi].tx3
			  inc triangles[esi].ty3
			  invoke InvalidateRect, hWnd, 0, FALSE
			 .ENDIF
			 .IF wParam==MK_RBUTTON
              mov esi,itriangle
			  inc triangles[esi].ty1
			  inc triangles[esi].tx2
			  dec triangles[esi].ty2
			  dec triangles[esi].tx3
			  dec triangles[esi].ty3
			  invoke InvalidateRect, hWnd, 0, FALSE
			 .ENDIF
		.ENDIF
    .ELSEIF uMsg==WM_PAINT
	    invoke GetClientRect, hWnd, ADDR rc
        invoke BeginPaint, hWnd, ADDR ps
		mov hdc, eax
        invoke CreateCompatibleDC, hdc
		mov hMemDC, eax
		invoke CreateCompatibleBitmap, hdc, rc.right, rc.bottom
		mov hBmp, eax
		invoke SelectObject, hMemDC, hBmp
	    mov hOld, eax
		invoke FillRect, hMemDC, ADDR rc, 0

		;интерфейс
	    invoke  CreateFont,50,25,0,0,400,0,0,0,0,0,0,4,0,0   
		invoke SelectObject, hMemDC,eax
	    invoke TextOutA,hMemDC,400,10,ADDR text_header,4;заголовок
		invoke CreateFont,15,8,0,0,400,0,0,0,0,0,0,4,0,0;логотип 
		invoke SelectObject, hMemDC,eax
		invoke TextOutA,hMemDC,600,10,ADDR text_logo,47;
	    invoke TextOutA,hMemDC,30,30,ADDR text_deffigure,12;
		invoke CreateFont,17,9,0,0,400,0,0,0,0,0,0,4,0,0 ;color  
		invoke SelectObject, hMemDC,eax
	    invoke TextOutA,hMemDC,100,560,ADDR text_color,5;
		invoke TextOutA,hMemDC,325,560,ADDR text_color,5;
		invoke TextOutA,hMemDC,507,560,ADDR text_color,5;
		invoke TextOutA,hMemDC,695,560,ADDR text_color,5;
	    invoke TextOutA,hMemDC,850,560,ADDR text_speed,12;
		invoke CreateFont,20,10,0,0,500,0,0,0,0,0,0,4,0,0;figures
		invoke TextOutA,hMemDC,75,510,ADDR text_rectangle,9;
		invoke TextOutA,hMemDC,325,510,ADDR text_circle,6;
		invoke TextOutA,hMemDC,500,510,ADDR text_square,6;
		invoke TextOutA,hMemDC,685,510,ADDR text_triangle,8;
		invoke TextOutA,hMemDC,875,510,ADDR text_options,7;

		;рисуем область создаваемых фигур
		invoke CreatePen,PS_SOLID, 3, 000000ffh
		invoke SelectObject,hMemDC,eax
		mov holdpen,eax
        invoke MoveToEx,hMemDC,25,50,ADDR ps
		invoke LineTo,hMemDC,150,50
		invoke LineTo,hMemDC,150,150
		invoke LineTo,hMemDC,25,150
		invoke LineTo,hMemDC,25,50
		invoke SelectObject,hMemDC,holdpen
		;рисуем нижний интерфейс
	    invoke CreatePen,PS_SOLID, 4, 00000000h
		invoke SelectObject,hMemDC,eax
		mov holdpen,eax
		invoke MoveToEx,hMemDC,0,540,ADDR ps
		invoke LineTo,hMemDC,1024,540
		invoke MoveToEx,hMemDC,0,500,ADDR ps
		invoke LineTo,hMemDC,1024,500
		invoke MoveToEx,hMemDC,250,500,ADDR ps
		invoke LineTo,hMemDC,250,768
		invoke MoveToEx,hMemDC,425,500,ADDR ps
		invoke LineTo,hMemDC,425,768
		invoke MoveToEx,hMemDC,825,500,ADDR ps
		invoke LineTo,hMemDC,825,768
		invoke MoveToEx,hMemDC,615,500,ADDR ps
		invoke LineTo,hMemDC,615,768
		invoke SelectObject,hMemDC,holdpen

        ;фигуры
		
		;круги
	    mov eax,circle_counter
		mov counter,eax
		xor esi,esi
		xor ebx,ebx
		.WHILE counter!=0
		invoke SelectObject, hMemDC, colors_circle[ebx]
		mov eax,circles[esi].clx
		mov cx1,eax
		mov eax,circles[esi].cly
		mov cy1,eax
		mov eax,circles[esi].crx
		mov cx2,eax
		mov eax,circles[esi].cry
		mov cy2,eax
		mov icircle,esi
		add esi,sizeof _circle
		add ebx,4
		mov icolor_circle,ebx
		invoke Ellipse, hMemDC, cx1, cy1, cx2, cy2
		dec counter
		.ENDW
		;прямоугольники
		mov eax,rectangle_counter
		mov counter,eax
		xor esi,esi
		xor ebx,ebx
		.WHILE counter!=0
		invoke SelectObject, hMemDC, colors_rect[ebx]
		mov eax,rectangles[esi].lx
		mov x1,eax
		mov eax,rectangles[esi].ly
		mov y1,eax
		mov eax,rectangles[esi].rx
		mov x2,eax
		mov eax,rectangles[esi].ry
		mov y2,eax
		mov irect,esi
		add esi,sizeof _rectangles
		add ebx,4
		mov icolor_rect,ebx
		invoke Rectangle, hMemDC, x1, y1, x2, y2
		dec counter
		.ENDW
        ;квадраты	
	    mov eax,square_counter
		mov counter,eax
		xor esi,esi
		xor ebx,ebx
		.WHILE counter!=0
		invoke SelectObject, hMemDC, colors_square[ebx]
		mov eax,squares[esi].slx
		mov sx1,eax
		mov eax,squares[esi].sly
		mov sy1,eax
		mov eax,squares[esi].srx
		mov sx2,eax
		mov eax,squares[esi].sry
		mov sy2,eax
		mov isquare,esi
		add esi,sizeof _square
		add ebx,4
		mov icolor_square,ebx
		invoke Rectangle, hMemDC, sx1, sy1, sx2, sy2
		dec counter
		.ENDW
		;треугольники
		mov eax,triangle_counter
		mov counter,eax
		xor esi,esi
		xor ebx,ebx
        .WHILE counter!=0
		invoke SelectObject,hMemDC,colors_triangle[ebx]
		xor edi,edi
		lea edi,triangle
		mov eax,triangles[esi].tx1 ;x1
		mov [edi],eax
		mov eax,triangles[esi].ty1;y1
		mov [edi+4],eax 
		mov eax,triangles[esi].tx2;x2
		mov [edi+8],eax
		mov eax,triangles[esi].ty2;y2
		mov [edi+12],eax
		mov eax,triangles[esi].tx3;x3
		mov [edi+16],eax
		mov eax,triangles[esi].ty3;y3
		mov [edi+20],eax
		mov itriangle,esi
		add esi,sizeof _triangle
		add ebx,4
		mov icolor_triangle,ebx
		invoke Polygon,hMemDC,edi,3
		dec counter
		.ENDW

		invoke BitBlt, hdc, 0, 0, rc.right, rc.bottom, hMemDC, 0, 0, SRCCOPY
        invoke SelectObject, hMemDC, hOld
        invoke DeleteObject, hBmp
        invoke DeleteDC, hMemDC
        invoke EndPaint, hdc, ADDR ps
		invoke SetFocus,hWnd
	.ELSE
		invoke DefWindowProc, hWnd, uMsg, wParam, lParam
		ret
	.ENDIF
	xor    eax, eax
	ret
WndProc endp
end start
