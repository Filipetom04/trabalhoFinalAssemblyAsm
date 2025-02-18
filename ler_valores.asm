section .data
    msg_erro_formato db "Erro: Formato inválido. Digite um número de dois dígitos.", 10, 0
    nome_arquivo db "arquivo.txt", 0
    newline db 10, 0      ; Nova linha
    len_msg_erro_formato equ $-msg_erro_formato

section .bss
    buffer resb 3          ; 2 dígitos + newline
    descritor_arquivo resd 1 ; Descritor do arquivo

section .text
    global _start

_start:
    ; Abrir ou criar o arquivo para escrita
    mov eax, 5             ; syscall para 'open'
    mov ebx, nome_arquivo  ; Nome do arquivo
    mov ecx, 577           ; Flags: O_WRONLY | O_CREAT | O_APPEND
    mov edx, 438           ; Permissões: 0666 (rwx para todos)
    int 0x80

    ; Verificar se o arquivo foi aberto com sucesso
    cmp eax, 0
    js erro_abrir_arquivo

    mov [descritor_arquivo], eax ; Salvar descritor do arquivo

ler_entrada:
    ; Ler a entrada do usuário
    mov eax, 3            ; syscall para 'read'
    mov ebx, 0            ; stdin
    mov ecx, buffer       ; Endereço do buffer
    mov edx, 3            ; Número de bytes a ler
    int 0x80

    ; Verificar EOF
    cmp eax, 0
    je finalizar_programa

    ; Validar formato da entrada
    cmp byte [buffer+2], 10 ; Verificar se há newline (10)
    jne formato_invalido

    cmp byte [buffer], '0'
    jb formato_invalido

    cmp byte [buffer], '9'
    ja formato_invalido

    cmp byte [buffer+1], '0'
    jb formato_invalido

    cmp byte [buffer+1], '9'
    ja formato_invalido

    ; Verificar se a entrada é "00"
    cmp word [buffer], '00'
    je finalizar_programa

    ; Escrever o valor no arquivo
    mov eax, 4             ; syscall para 'write'
    mov ebx, [descritor_arquivo] ; Descritor do arquivo
    mov ecx, buffer        ; Endereço do buffer
    mov edx, 3             ; Número de bytes (2 dígitos + newline)
    int 0x80

    ; Voltar ao início para ler novamente
    jmp ler_entrada

formato_invalido:
    ; Exibir mensagem de erro
    mov eax, 4             ; syscall para 'write'
    mov ebx, 1             ; stdout
    mov ecx, msg_erro_formato
    mov edx, len_msg_erro_formato
    int 0x80
    jmp ler_entrada

erro_abrir_arquivo:
    ; Exibir erro genérico e sair
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_erro_formato
    mov edx, len_msg_erro_formato
    int 0x80
    jmp finalizar_programa

finalizar_programa:
    ; Fechar o arquivo
    mov eax, 6             ; syscall para 'close'
    mov ebx, [descritor_arquivo]
    int 0x80

    ; Sair do programa
    mov eax, 1             ; syscall para 'exit'
    xor ebx, ebx           ; Código de saída 0
    int 0x80
