; chidraqul10 by ChillerDragon
; x86_64 assembly linux ( nasm )

global _start:

section     .data
    s_menu  db      0x0a,"+--+ chidraqul10 +--+",0x0a
    l_menu  equ     $ - s_menu
    s_end   db      0x0a,"quitting the game...",0x0a
    l_end   equ     $ - s_end
    s_a     db      0x0a,"you pressed a",0x0a
    l_a     equ     $ - s_a
    s_d     db      0x0a,"you pressed d",0x0a
    l_d     equ     $ - s_d
    orig    times   10000   db      0
    new     times   10000   db      0
    char    db      0,0,0,0,0

section     .text

print_menu:
    mov     rsi,    s_menu
    mov     rax,    1
    mov     rdi,    1
    mov     rdx,    l_menu
    syscall                 ; sys_write(1, s_end, l_end)
    ret

init_console:
    ; fetch the current terminal settings
    mov     rax,    16      ; __NR_ioctl
    mov     rdi,    0       ; fd: stdin
    mov     rsi,    21505   ; cmd: TCGETS
    mov     rdx,    orig    ; arg: the buffer, orig
    syscall
    ; agian, but this time for the 'new' buffer
    mov     rax,    16
    mov     rdi,    0
    mov     rsi,    21505
    mov     rdx,    new
    syscall
    ; change settings
    and dword [new+0], -1516    ; ~(IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | ICRNL | IXON)
    and dword [new+4], -2       ; ~OPOST
    and dword [new+12], -32844  ; ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN)
    and dword [new+8], -305     ; ~(CSIZE | PARENB)
    ; set settings (with ioctl again)
    mov     rax,    16      ; __NR_ioctl
    mov     rdi,    0       ; fd: stdin
    mov     rsi,    21506   ; cmd: TCSETS
    mov     rdx,    new     ; arg: the buffer, new
    syscall
    ret

reset_console:
    ; reset settings (with ioctl again)
    mov     rax,    16      ; __NR_ioctl
    mov     rdi,    0       ; fd: stdin
    mov     rsi,    21506   ; cmd: TCSETS
    mov     rdx,    orig    ; arg: the buffer, orig
    syscall
    ret

key_a:
    mov     rsi,    s_a
    mov     rax,    1
    mov     rdi,    1
    mov     rdx,    l_a
    syscall
    jz      keypress_end

key_d:
    mov     rsi,    s_d
    mov     rax,    1
    mov     rdi,    1
    mov     rdx,    l_d
    syscall
    jz      keypress_end

keypresses:
    ; read char
    mov     rax,    0       ; __NR_read
    mov     rdi,    0       ; fd: stdin
    mov     rsi,    char    ; buf: the temporary buffer, cahr
    mov     rdx,    1       ; count: the length of the buffer, 1
    syscall
    cmp     byte[char], 97  ; a
    jz      key_a
    cmp     byte[char], 100 ; d
    jz      key_d
    cmp     byte[char], 13  ; esc
    jz      end
keypress_end:
    ret

gametick:
    call    keypresses
    call    gametick
    ret

_start:
    call    init_console
    call    print_menu
    call    gametick

end:
    call    reset_console
    ; print exit message
    mov     rsi,    s_end
    mov     rax,    1
    mov     rdi,    1
    mov     rdx,    l_end
    syscall                 ; sys_write(1, s_end, l_end)
    mov     rax,    60
    mov     rdi,    0
    syscall                 ; sys_exit(0)

