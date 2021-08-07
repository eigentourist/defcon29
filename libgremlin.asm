; Set 64-bit mode and relative addressing
bits 64
default rel

global DLLMain
global keyboardHook
global keyboard_hook

; External Windows API function
extern keybd_event

extern CallNextHookEx

segment .text

keyboard_hook:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32

    ; Store parameters
    mov     dword [code], ecx
    mov     [wParam], rdx
    mov     [lParam], r8

    push    rsi
    push    rdi

    ; Get struct pointed to by lParam
    mov     qword rsi, [lParam]
    mov     qword rdi, KBDLLHOOKSTRUCT
    mov     rcx, 0

copy_struct:
    mov     qword rax, [rsi]
    add     rsi, 8
    mov     qword [rdi], rax
    add     rdi, 8
    inc     rcx
    cmp     rcx, 4
    jl      copy_struct
    pop     rdi
    pop     rsi

    cmp     rdx, WM_KEYDOWN
    jne     pass
    cmp     byte [keycount], 5
    je      gremlin
    inc     byte [keycount]
    jmp     pass


gremlin:
    mov     al, [KBDLLHOOKSTRUCT]
    movzx   rax, al
    cmp     al, 0x41
    je      .mischief
    cmp     al, 0x5a
    jne     pass
.mischief
    mov     rcx, 0x58
    mov     rdx, 0
    mov     r8, 0
    mov     r9, 0
    call    keybd_event
    mov     rcx, 0x58
    mov     rdx, 0
    mov     r8, KEYEVENTF_KEYUP
    mov     r9, 0
    call    keybd_event

grend:
    mov     rax, 1
    jmp     end_hook

pass:
    mov     rcx, keyboardHook
    mov     dword edx, [code]
    mov     qword r8, [wParam]
    mov     qword r9, [lParam]
    call    CallNextHookEx

end_hook:
    leave
    ret

DLLMain:
    cmp     r9, DLL_PROCESS_ATTACH
    jne     detach

detach:
    mov     rax, 1
    leave   
    ret 


segment .data

WM_KEYDOWN          equ 0x0100
WM_KEYUP            equ 0x0101
KEYEVENTF_KEYUP     equ 0x0002
DLL_PROCESS_ATTACH  equ 1
DLL_PROCESS_DETACH  equ 0
keycount            db  0

segment .bss

code                resd 1
wParam              resq 1
lParam              resq 1
keyboardHook        resq 1
KBDLLHOOKSTRUCT     resq 3
