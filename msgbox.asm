bits 64
default rel
global WinMain

extern MessageBoxA
extern ExitProcess

segment .text

WinMain:
    push rbp
    mov rbp, rsp
    sub rsp, 32

	; show the message box
    xor ecx, ecx
    lea rdx, message
    lea r8,  title
    mov r9d, MB_OK
    call MessageBoxA

    mov rsp, rbp
    pop rbp
    xor ecx, ecx
	call ExitProcess

segment .data
    MB_OK   equ 0
	title	db "A message for you", 0
	message db "This is your first message", 0

