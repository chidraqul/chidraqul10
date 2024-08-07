; chidraqul10 by ChillerDragon
; vim: set tabstop=4:softtabstop=4:shiftwidth=4
; vim: set expandtab:
; x86_64 assembly linux ( nasm )

; 64bit register
; 00000000 00000000 00000000 0000000 00000000 00000000 00000000 00000000
;                                                               \______/
;                                                                   |
;                                                                   al
;                                                      \_______________/
;                                                               |
;                                                               ax
;                                    \_________________________________/
;                                                    |
;                                                   eax
; \____________________________________________________________________/
;                               |
;                              rax

; +-----------------------------------+
; | 8-bit  | 16-bit | 32-bit | 64-bit |
; +--------+--------+--------+--------+
; | al     | ax     | eax    | rax    |
; | bl     | bx     | ebx    | rbx    |
; | cl     | cx     | ecx    | rcx    |
; | dl     | dx     | edx    | rdx    |
; | sil    | si     | esi    | rsi    |
; | dil    | di     | edi    | rdi    |
; | bpl    | bi     | ebp    | rbp    |
; | spl    | sp     | esp    | rsp    |
; | r8b    | r8w    | r8d    | r8     |
; | r9b    | r9w    | r9d    | r9     |
; | r10b   | r10w   | r10d   | r10    |
; | r11b   | r11w   | r11d   | r11    |
; | r12b   | r12w   | r12d   | r12    |
; | r13b   | r13w   | r13d   | r13    |
; | r14b   | r14w   | r14d   | r14    |
; | r15b   | r15w   | r15d   | r15    |
; +--------+--------+--------+--------+

; System call inputs
; +-----+----------+
; | Arg | Register |
; +-----+----------+
; | ID  | rax      |
; | 1   | rdi      |
; | 2   | rsi      |
; | 3   | rdx      |
; | 4   | r10      |
; | 5   | r8       |
; | 6   | r9       |
; +-----+----------+

; System call list
; /usr/include/asm/unistd_64.h
; /usr/include/x86_64-linux-gnu/asm/unistd_64.h
; https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/

; style guide:
; tab = 4 spaces
; 1-tab 3-tabs 3-tabs 3-tabs 2-tabs

global _start:

section    .data
    ; constants
    SYS_READ    equ         0
    SYS_WRITE   equ         1
    SYS_OPEN    equ         2
    SYS_CLOSE   equ         3
    SYS_EXIT    equ         60

    O_NONBLOCK  equ         2048
    F_SETFL     equ         4

    KEY_A       equ         0x61
    KEY_D       equ         0x64
    KEY_Q       equ         0x71
    KEY_ESC     equ         0x5B

    ; variables
    s_menu      db          "+--+ chidraqul10 +--+",0x0a
    l_menu      equ         $ - s_menu
    s_menu2     db          "| press q to quit   |",0x0a
    l_menu2     equ         $ - s_menu2
    s_menu3     db          "+-------------------+",0x0a
    l_menu3     equ         $ - s_menu3
    s_end       db          "quitting the game...",0x0a
    l_end       equ         $ - s_end
    s_a         db          "you pressed a",0x0a
    l_a         equ         $ - s_a
    s_d         db          "you pressed d",0x0a
    l_d         equ         $ - s_d
    orig        times       10000       db      0
    new         times       10000       db      0
    char        db          0,0,0,0,0

section     .text

print_menu:
    mov         rsi,        s_menu
    mov         rax,        SYS_WRITE
    mov         rdi,        1
    mov         rdx,        l_menu
    syscall
    mov         rsi,        s_menu2
    mov         rax,        SYS_WRITE
    mov         rdi,        1
    mov         rdx,        l_menu2
    syscall
    mov         rsi,        s_menu3
    mov         rax,        SYS_WRITE
    mov         rdi,        1
    mov         rdx,        l_menu3
    syscall
    ret

insane_console:
    ; fetch the current terminal settings
    mov         rax,        16          ; __NR_ioctl
    mov         rdi,        0           ; fd: stdin
    mov         rsi,        21505       ; cmd: TCGETS
    mov         rdx,        orig        ; arg: the buffer, orig
    syscall
    ; again, but this time for the 'new' buffer
    mov         rax,        16
    mov         rdi,        0
    mov         rsi,        21505
    mov         rdx,        new
    syscall
    ; change settings
    ; ~(IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | ICRNL | IXON)
    and         dword       [new+0],    -1516
    ; ~OPOST
    and         dword       [new+4],    -2
    ; ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN)
    and         dword       [new+12],   -32844
    ; ~(CSIZE | PARENB)
    and         dword       [new+8],    -305
    ; set settings (with ioctl again)
    mov         rax,        16          ; __NR_ioctl
    mov         rdi,        0           ; fd: stdin
    mov         rsi,        21506       ; cmd: TCSETS
    mov         rdx,        new         ; arg: the buffer, new
    syscall

    mov         rax,        16          ; __NR_ioctl
    mov         rdi,        0           ; fd: stdin
    mov         rsi,        F_SETFL     ; cmd: F_SETFL
    mov         rdx,        O_NONBLOCK  ; arg: the flag
    syscall
    ret

sane_console:
    push rax
    push rdi
    push rsi
    push rdx

    ; reset settings (with ioctl again)
    mov         rax,        16          ; __NR_ioctl
    mov         rdi,        0           ; fd: stdin
    mov         rsi,        21506       ; cmd: TCSETS
    mov         rdx,        orig        ; arg: the buffer, orig
    syscall

    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

key_a:
    mov         rsi,        s_a
    mov         rax,        SYS_WRITE
    mov         rdi,        1
    mov         rdx,        l_a
    syscall
    jz          keypress_end

key_d:
    mov         rsi,        s_d
    mov         rax,        SYS_WRITE
    mov         rdi,        1
    mov         rdx,        l_d
    syscall
    jz          keypress_end

keypresses:
    call        insane_console
    ; read char
    mov         rax,        SYS_READ    ; __NR_read
    mov         rdi,        0           ; fd: stdin
    mov         rsi,        char        ; buf: the temporary buffer, char
    mov         rdx,        1           ; count: the length of the buffer, 1
    syscall
    call        sane_console

    test rax, rax
    ; if read returned negative
    ; we do not process the read value as key press
    js keypress_end

    cmp         byte[char], KEY_A
    jz          key_a
    cmp         byte[char], KEY_D
    jz          key_d
    cmp         byte[char], KEY_Q
    jz          end
    cmp         byte[char], KEY_ESC
    jz          end
keypress_end:
    ret

gametick:
    call        keypresses
    jmp         gametick

_start:
    mov         rax,        72          ; __NR_fcntl
    mov         rdi,        0           ; fd: stdin
    mov         rsi,        F_SETFL     ; cmd: F_SETFL
    mov         rdx,        O_NONBLOCK  ; arg: the flag
    syscall

    call        print_menu
    call        gametick

end:
    call        sane_console
    ; print exit message
    mov         rsi,        s_end
    mov         rax,        SYS_WRITE
    mov         rdi,        1
    mov         rdx,        l_end
    syscall     ; sys_write(1, s_end, l_end)
    mov         rax,        SYS_EXIT
    mov         rdi,        0
    syscall     ; sys_exit(0)
