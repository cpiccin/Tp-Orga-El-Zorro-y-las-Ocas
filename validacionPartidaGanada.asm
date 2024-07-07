%include "macros_y_variables.asm"

global validarGanoZorro
global validarGanoOcas
global quienGanoPartida
extern indice_x_zorro
extern indice_y_zorro
extern matrizPrincipal
extern cantOcasComidas
extern mostrarTableroConFormato

section .data
    quienGanoPartida db 'N', 0 ; N = nadie, Z = zorro, O = oca

section .text
validarGanoZorro:
    cmp byte [cantOcasComidas], 12 ; si el zorro comio 12 ocas gana
    je mensajeGanoZorro
    ret
mensajeGanoZorro:
    mPuts msgGanoZorro
    mov byte [quienGanoPartida], 'Z'
    ret

validarGanoOcas:
    ; tengo que chequear si las ocas encerraron al zorro o si hay 6 ocas en la parte inferior del tablero
    mov byte [sePuedeMover], 'N'
    ; para ver si el zorro esta encerrado en todos los sentidos de movimiento

    ; chequeo arriba
    mov dword [deltaY], -1
    mov dword [deltaX], 0
    call chequeoMovimiento
    ; chequeo abajo
    mov dword [deltaY], 1
    mov dword [deltaX], 0
    call chequeoMovimiento
    ; chequeo izquierda
    mov dword [deltaY], 0
    mov dword [deltaX], -1 
    call chequeoMovimiento
    ; chequeo derecha
    mov dword [deltaY], 0
    mov dword [deltaX], 1
    call chequeoMovimiento
    ; chequeo diagonal izquierda arriba
    mov dword [deltaY], -1
    mov dword [deltaX], -1
    call chequeoMovimiento
    ; chequeo diagonal izquierda abajo
    mov dword [deltaY], 1
    mov dword [deltaX], -1
    call chequeoMovimiento
    ; chequeo diagonal derecha arriba
    mov dword [deltaY], -1
    mov dword [deltaX], 1
    call chequeoMovimiento
    ; chequeo diagonal derecha abajo
    mov dword [deltaY], 1
    mov dword [deltaX], 1
    call chequeoMovimiento

    ; para chequear si las 6 ocas llegaron a la parte inferior del tablero.
    ; el zorro puede no estar encerrado pero si 6 ocas llegan abajo ya no se pueden mover y ganan
    call chequearLlegaron6Abajo ; puede modificar el valor de sePuedeMover
    cmp byte [sePuedeMover], 'S'
    jne mensajeGanoOcas
    ret ; si llega hasta aca es que todavia no ganaron y sigue el juego

chequeoMovimiento:
    call ajustarIndices

    mov rax, [deltaY]
    add [auxY], rax 
    mov rax, [deltaX]
    add [auxX], rax
    mExtraerCaracter auxY, auxX
    mov [valor1], al

    mov rax, [deltaY]
    add [auxY], rax 
    mov rax, [deltaX]
    add [auxX], rax
    mExtraerCaracter auxY, auxX
    mov [valor2], al

    call chequeoIgualdad

    ret

mensajeGanoOcas:
    call mostrarTableroConFormato 
    mPuts msgGanoOca
    mov byte [quienGanoPartida], 'O'
    ret

ajustarIndices:
    mov eax, [indice_x_zorro]
    mov [auxX], eax 
    inc dword [auxX]

    mov eax, [indice_y_zorro]
    mov [auxY], eax
    inc dword [auxY]

    ret

chequeoIgualdad:
    cmp byte [valor1], '-'
    jne chequeoIgualdad2
    je siSePuedeMover
    chequeoIgualdad2:
    cmp byte [valor2], '-'
    je siSePuedeMover
    ret 
    siSePuedeMover:
    mov byte [sePuedeMover], 'S'
    ret 
chequearLlegaron6Abajo:
    ; Inicializar los contadores de posición
    mov dword [auxX], 3
    mov dword [auxY], 6

    ; bucle para verificar 3 posiciones consecutivas
    verificarLoop:
        mExtraerCaracter auxY, auxX
        cmp al, 'O'
        jne todaviaNoGanan
        inc dword [auxX]
        cmp dword [auxX], 6  
        jl verificarLoop   

    mov dword [auxX], 3
    mov dword [auxY], 7 ; voy a la siguiente fila
    cmp dword [auxY], 8
    je verificarLoop ; es para que quede un loop infinito
    ; Si se verificaron las 6 posiciones y todas son 'O', entonces no se puede mover
    mov byte [sePuedeMover], 'N'
    ret

    todaviaNoGanan:
    ret
