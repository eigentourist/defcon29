; Set 64-bit mode and relative addressing
bits 64
default rel

; Set the global entry point
global main
global MsgBuffer

; Declare references to Windows API functions
extern ExitProcess
extern GetLastError
extern FormatMessageA
extern LoadLibraryA
extern _CRT_INIT
extern printf

segment .text

main:
    push rbp
    mov rbp, rsp
    sub rsp, 80

    call    _CRT_INIT

    mov     rcx, FakeLibName
    call    LoadLibraryA

    call GetLastError
    mov  [lastErrorCode], eax

    lea  rcx, [ErrorMsg]
    mov  rdx, [lastErrorCode]
    call printf

    mov     rsp, rbp
    pop     rbp
    xor     rax, rax
	call    ExitProcess

segment .data
    STD_INPUT_HANDLE    equ -10
    STD_OUTPUT_HANDLE   equ -11
    STD_ERROR_HANDLE    equ -12
    FakeLibName         db "abcd.dll",0
    ErrorMsg            db "Error code: %x",0xd, 0xa, 0

segment .bss
    lastErrorCode   resd   1
    hconmode resd   1
    hstdin   resq   1
    hstdout  resq   1
    hstderr  resq   1
