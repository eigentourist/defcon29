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

; *****
; DWORD FormatMessageW(DWORD dwFlags, LPCVOID lpSource, 
; DWORD dwMessageId, DWORD dwLanguageId, 
; -- parameters below are being pushed onto the stack --
; LPWSTR lpBuffer, DWORD nSize, va_list *Arguments)
; *****
; printerror:
;     push    rbp
;     mov     rbp, rsp
;     sub     rsp, 8  ; 8 bytes for caller return address
;     sub     rsp, 32 ; shadow space for incoming parameters in registers
;     sub     rsp, 32 ; 20 bytes being used for local variables, but need 16-byte alignment

;     call GetLastError
;     mov  [lastErrorCode], eax

;     xor  rcx, rcx
;     or   rcx, FORMAT_MESSAGE_ALLOCATE_BUFFER
;     or   rcx, FORMAT_MESSAGE_FROM_SYSTEM
;     or   rcx, FORMAT_MESSAGE_IGNORE_INSERTS
;     mov  rdx, 0
;     mov  r8,  [lastErrorCode]
;     mov  r9,  0

;     mov  qword [rsp], 0       ; 8 bytes
;     mov  dword [rsp+8], 0     ; 4 bytes
; ;    mov  qword [rsp+12], MsgBuffer     ; -- don't do this, it creates linker fixup errors
;     mov  rax, MsgBuffer
;     mov  qword [rsp+12], rax  ; 8 bytes
;     call FormatMessageW

;     mov  rcx, [MsgBuffer]
;     call wprintf

;     mov     rsp, rbp
;     pop     rbp
;     xor     rax, rax
;     ret


main:
    push rbp
    mov rbp, rsp
    sub rsp, 80

    call    _CRT_INIT

    mov     rcx, FakeLibName
    call    LoadLibraryA
;    call    printerror

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
