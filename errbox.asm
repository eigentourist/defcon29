bits 64
default rel
global WinMain

extern snprintf
extern MessageBoxA
extern GetLastError
extern LoadLibraryA
extern ExitProcess

segment .text

WinMain:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    sub rsp, 64

    ; do something erroneous
    mov     rcx, FakeLibName
    call    LoadLibraryA
    call    GetLastError
    mov     [lastErrorCode], eax

    ; create error message
    mov rcx, message
    mov rdx, msgsize
    mov r8,  errstr
    mov r9,  [lastErrorCode]
    call snprintf

	; show the message box
    xor eax, eax
    lea rdx, [message]
    lea r8,  title
    mov r9d, MB_OK
    call MessageBoxA

    mov rsp, rbp
    pop rbp
    xor ecx, ecx
	call ExitProcess

segment .data
    MB_OK   equ 0
	title	    db "Error occurred", 0
    FakeLibName db "abcd.dll",0
    errstr      db "Error code: %x", 0
    msgsize     equ 32

segment .bss
    lastErrorCode   resd    1
    message         resb    msgsize
