includelib comdlg32.lib
	extrn	__imp__GetOpenFileNameA@4:dword
	extrn	__imp__GetSaveFileNameA@4:dword
	extrn __imp__ChooseColorA@4:dword
	extrn	__imp__ChooseFontA@4:dword
	extrn __imp__CommDlgExtendedError@0:dword
GetOpenFileName	equ	__imp__GetOpenFileNameA@4
GetSaveFileName	equ	__imp__GetSaveFileNameA@4
ChooseColor		equ	__imp__ChooseColorA@4
ChooseFont		equ	__imp__ChooseFontA@4
CommDlgExtendedError	equ	__imp__CommDlgExtendedError@0
