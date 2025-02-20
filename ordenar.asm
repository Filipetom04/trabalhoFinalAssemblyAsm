section .data
    nome_arquivo db "arquivo.txt", 0
    msg_ordenados db "Números em ordem crescente: ", 0
    newline db 10, 0
    len_msg_ordenados equ $-msg_ordenados

section .bss
    buffer resb 3           ; Buffer para 2 dígitos + newline
    fd resq 1               ; Descritor do arquivo
    num1 resd 1             ; Armazenar 4 números
    num2 resd 1
    num3 resd 1
    num4 resd 1

section .text
    global _start

_start:
    ; Abrir o arquivo
    mov rax, 2
    mov rdi, nome_arquivo
    mov rsi, 0
    syscall
    cmp rax, 0
    jl sair_erro
    mov [fd], rax

    ; Ler os 4 números
    call ler_numero
    mov [num1], eax

    call ler_numero
    mov [num2], eax

    call ler_numero
    mov [num3], eax

    call ler_numero
    mov [num4], eax

    ; Fechar o arquivo
    mov rax, 3
    mov rdi, [fd]
    syscall

    ; Ordenar os 4 números
    mov eax, [num1]
    mov ebx, [num2]
    cmp eax, ebx
    jle passo2
    mov [num1], ebx
    mov [num2], eax

passo2:
    mov eax, [num2]
    mov ebx, [num3]
    cmp eax, ebx
    jle passo3
    mov [num2], ebx
    mov [num3], eax

passo3:
    mov eax, [num3]
    mov ebx, [num4]
    cmp eax, ebx
    jle passo4
    mov [num3], ebx
    mov [num4], eax

passo4:
    mov eax, [num1]
    mov ebx, [num2]
    cmp eax, ebx
    jle passo5
    mov [num1], ebx
    mov [num2], eax

passo5:
    mov eax, [num2]
    mov ebx, [num3]
    cmp eax, ebx
    jle passo6
    mov [num2], ebx
    mov [num3], eax

passo6:
    mov eax, [num1]
    mov ebx, [num2]
    cmp eax, ebx
    jle exibir
    mov [num1], ebx
    mov [num2], eax

exibir:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_ordenados
    mov rdx, len_msg_ordenados
    syscall

    mov eax, [num1]
    call exibir_numero
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    mov eax, [num2]
    call exibir_numero
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    mov eax, [num3]
    call exibir_numero
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    mov eax, [num4]
    call exibir_numero
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall

sair_erro:
    mov rax, 60
    mov rdi, 1
    syscall

; Ler número do arquivo (retorna em EAX)
ler_numero:
    push rbx
    mov rax, 0
    mov rdi, [fd]
    mov rsi, buffer
    mov rdx, 3
    syscall

    ; Converter ASCII para inteiro
    xor eax, eax           ; Limpar EAX
    movzx ebx, byte [buffer]   ; Primeiro dígito
    sub ebx, '0'
    imul ebx, 10
    movzx ecx, byte [buffer+1] ; Segundo dígito
    sub ecx, '0'
    add eax, ebx
    add eax, ecx

    pop rbx
    ret

; Exibir número em EAX
exibir_numero:
    push rax
    push rbx

    ; Converter para ASCII
    mov ebx, 10
    xor edx, edx
    div ebx                ; EAX = quociente, EDX = resto
    add dl, '0'            ; Segundo dígito
    mov [buffer+1], dl
    add al, '0'            ; Primeiro dígito
    mov [buffer], al

    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    mov rdx, 2
    syscall

    pop rbx
    pop rax
    ret
