; chidraqul10 by ChillerDragon
; x86_64 assembly linux ( nasm )

global _start:

section     .data
    ; constants
    KEY_A   equ     97
    KEY_D   equ     100
    KEY_ESC equ     13
    ; variables
    s_menu  db      "+--+ chidraqul10 +--+",0x0a
    l_menu  equ     $ - s_menu
    s_end   db      "quitting the game...",0x0a
    l_end   equ     $ - s_end
    s_a     db      "you pressed a",0x0a
    l_a     equ     $ - s_a
    s_d     db      "you pressed d",0x0a
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

insane_console:
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

sane_console:
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
    call    insane_console
    ; read char
    mov     rax,    0       ; __NR_read
    mov     rdi,    0       ; fd: stdin
    mov     rsi,    char    ; buf: the temporary buffer, char
    mov     rdx,    1       ; count: the length of the buffer, 1
    syscall
    call    sane_console
    cmp     byte[char], KEY_A
    jz      key_a
    cmp     byte[char], KEY_D
    jz      key_d
    cmp     byte[char], KEY_ESC
    jz      end
keypress_end:
    ret

gametick:
    call    keypresses
    call    gametick
    ret

_start:
    call    print_menu
    call    gametick

end:
    call    sane_console
    ; print exit message
    mov     rsi,    s_end
    mov     rax,    1
    mov     rdi,    1
    mov     rdx,    l_end
    syscall                 ; sys_write(1, s_end, l_end)
    mov     rax,    60
    mov     rdi,    0
    syscall                 ; sys_exit(0)

