%include "macros_y_variables.asm"
global main
global indice_x_zorro
global indice_y_zorro
global matrizPrincipal
global cantOcasComidas
extern validarGanoZorro
extern validarGanoOcas
extern quienGanoPartida
extern mostrarTableroConFormato

section .data
    matrizPrincipal db " ", " ", "O", "O", "O", " ", " ", 10
                    db " ", " ", "O", "O", "O", " ", " ", 10
                    db "O", "O", "O", "O", "O", "O", "O", 10
                    db "O", "-", "-", "-", "-", "-", "O", 10
                    db "O", "-", "-", "X", "-", "-", "O", 10
                    db " ", " ", "-", "-", "-", " ", " ", 10
                    db " ", " ", "-", "-", "-", " ", " ", 10, 0
    indice_y_zorro dq 0
    indice_x_zorro dq 0

    indice_x_nuevo dq 0
    indice_y_nuevo dq 0

    indice_x_viejo dq 0
    indice_y_viejo dq 0
    
    cantOcasComidas dd 9

section .text
    global _start

main:
    mClear
    ; Configurar el valor del índice y del zorro
    mov rax, 4
    mov qword [indice_y_zorro], rax

    mov rax, 3
    mov qword [indice_x_zorro], rax

mostrarTablero:
    call mostrarTableroConFormato 
    jmp moverSegunTurno

moverSegunTurno: 
    mov rax, [turno]
    cmp rax, 1
    je movimientoZorro ;si es el turno del zorro voy a mov del zorro
    jne movimientoOca ;si no es el turno del zorro voy a mov de la oca
; -------------------------------OCAS---------------------------------
movimientoOca:
    mPuts msgTurnoOca
    ;seleccion de la oca. Pido fila y columna
    mPuts msgSelOcaF
    mov rdi, pos_y_ocaSelStr 
    mGets 
    mov rdi, pos_y_ocaSelStr
    call checkeoTerminarPartida

    mPuts msgSelOcaC
    mov rdi, pos_x_ocaSelStr
    mGets
    mov rdi, pos_x_ocaSelStr
    call checkeoTerminarPartida
    ;paso a int los indices, los uso despues para calcular el desplazamiento
    mSscanf pos_y_ocaSelStr, format, pos_y_ocaViejo
    mSscanf pos_x_ocaSelStr, format, pos_x_ocaViejo
    mov eax, [pos_y_ocaViejo]
    mov [pos_y_ocaNuevo], eax
    mov eax, [pos_x_ocaViejo]
    mov [pos_x_ocaNuevo], eax
    ; verifico que se selecciono una oca valida
    call validarPosicionOca
    cmp byte [ocaValida], 'S'
    jne movimientoOca
    ; pregunto y guardo a donde se quiere mover la oca seleccionada.
recibirMovimientoOca:
    mPuts msgMovOca
    mov rdi, moverOcaA
    mGets
    mov rdi, moverOcaA
    call checkeoTerminarPartida
    ; defino que pasa para cada movimiento, si es invalido vuelvo a preguntar
    cmp byte [moverOcaA], '1'
    je incrementarY
    cmp byte [moverOcaA], '2'
    je decrementarX
    cmp byte [moverOcaA], '3'
    je incrementarX
    ; si no encuentra alguno de los 3 movimientos validos, muestro un mensaje de error y vuelvo a preguntar
    call msgInputMovInvalido ; si llega aca es que no era valido
    jmp recibirMovimientoOca
    
validarPosicionOca:
    ; obtengo la direccion de memoria de la posicion que se selecciono
    mExtraerCaracter pos_y_ocaViejo, pos_x_ocaViejo
    cmp al, 'O'
    je esIgual
    jne msgOcaInvalida
    ret

esIgual:
    mov al, 'S'
    mov [ocaValida], al
    ret
msgOcaInvalida:
    mov byte [ocaValida], 'N'
    mPuts msgPosOcaInvalida
    ret

msgInputMovInvalido:
    mPuts msgMovInvalido
    mov byte [ocaValida], 'N'
    ret
incrementarY:
    mov eax, [pos_y_ocaViejo]
    add eax, 1
    mov [pos_y_ocaNuevo], eax
    jmp validarNuevaPosicionOca
decrementarX:
    mov eax, [pos_x_ocaViejo]
    sub eax, 1
    mov [pos_x_ocaNuevo], eax
    jmp validarNuevaPosicionOca
incrementarX:
    mov eax, [pos_x_ocaViejo]
    add eax, 1
    mov [pos_x_ocaNuevo], eax
    jmp validarNuevaPosicionOca

validarNuevaPosicionOca:
    ; veo que la oca no se pueda mover a una posicion ocupada o que no sea un '-' (lugar vacio)
    mExtraerCaracter pos_y_ocaNuevo, pos_x_ocaNuevo
    cmp al, '-'
    je moverOca
    jne msgMovFueraDeRangoOca
msgMovFueraDeRangoOca:
    mPuts msgMovInvalido
    mov eax, dword [pos_x_ocaViejo]
    mov [pos_x_ocaNuevo], eax
    mov eax, dword [pos_y_ocaViejo]
    mov [pos_y_ocaNuevo], eax
    jmp movimientoOca
moverOca:
    mDesplazamiento pos_y_ocaViejo, pos_x_ocaViejo
    mov al, [char1]
    mov [ebx], al

    mDesplazamiento pos_y_ocaNuevo, pos_x_ocaNuevo
    mov al, [char2]
    mov [ebx], al

    mov byte [turno], 1 ; cambio el turno

    call validarGanoOcas 
    cmp byte [quienGanoPartida], 'O'
    je fin

    mClear

    jmp mostrarTablero
; ------------------------------ZORRO--------------------------------
movimientoZorro:
    ; preguntar a donde se mueve el zorro
    mPuts msgTurnoZorro
    mPuts moverZorro
    mov rdi, moverZorroA
    mGets
    mov rdi, moverZorroA
    call checkeoTerminarPartida

    mov rax, qword [indice_x_zorro]
    mov qword [indice_x_viejo], rax

    mov rax, qword [indice_y_zorro]
    mov qword [indice_y_viejo], rax
obtenerNuevaPosicion:
    ; mov direccion, rdi

    cmp byte [moverZorroA], '1'
    je  moverArriba

    cmp byte [moverZorroA], '2'
    je  moverAbajo
    
    cmp byte [moverZorroA], '3'
    je  moverIzquierda
    
    cmp byte [moverZorroA], '4'
    je  moverDerecha

    cmp byte [moverZorroA], '5'
    je  moverArribaIzquierda

    cmp byte [moverZorroA], '6'
    je  moverArribaDerecha

    cmp byte [moverZorroA], '7'
    je  moverAbajoIzquierda

    cmp byte [moverZorroA], '8'
    je  moverAbajoDerecha

    jne msgMovInvalidoZorro 
    ; Si no es una opción válida tendria que no actualizar el turno y volver a preguntar
    jmp obtenerNuevaPosicion
msgMovInvalidoZorro:
    mPuts msgMovInvalido
    jmp movimientoZorro

moverArriba:
    mov rax, qword [indice_y_viejo]
    sub rax, 1
    mov qword [indice_y_nuevo], rax
    
    mov rbx, qword [indice_x_viejo]
    mov qword [indice_x_nuevo], rbx
    
    jmp calcularIndice

moverAbajo:
    mov rax, qword [indice_y_viejo]
    add rax, 1
    mov qword [indice_y_nuevo], rax

    mov rbx, qword [indice_x_viejo]
    mov qword [indice_x_nuevo], rbx

    jmp calcularIndice

moverIzquierda:
    mov rax, qword [indice_x_viejo]
    sub rax, 1
    mov qword [indice_x_nuevo], rax

    mov rbx, qword [indice_y_viejo]
    mov qword [indice_y_nuevo], rbx

    jmp calcularIndice

moverDerecha:
    mov rax, qword [indice_x_viejo]
    add rax, 1
    mov qword[indice_x_nuevo], rax

    mov rbx, qword [indice_y_viejo]
    mov qword [indice_y_nuevo], rbx

    jmp calcularIndice

moverArribaIzquierda:
    mov rax, qword [indice_x_viejo]
    sub rax, 1
    mov qword [indice_x_nuevo], rax

    mov rbx, qword [indice_y_viejo]
    sub rbx, 1
    mov qword [indice_y_nuevo], rbx

    jmp calcularIndice

moverArribaDerecha:
    mov rax, qword [indice_x_viejo]
    add rax, 1
    mov qword [indice_x_nuevo], rax

    mov rbx, qword [indice_y_viejo]
    sub rbx, 1
    mov qword [indice_y_nuevo], rbx

    jmp calcularIndice

moverAbajoIzquierda:
    mov rax, qword [indice_x_viejo]
    sub rax, 1
    mov qword [indice_x_nuevo], rax

    mov rbx, qword [indice_y_viejo]
    add rbx, 1
    mov qword [indice_y_nuevo], rbx

    jmp calcularIndice

moverAbajoDerecha:
    mov rax, qword [indice_x_viejo]
    add rax, 1
    mov qword [indice_x_nuevo], rax

    mov rbx, qword [indice_y_viejo]
    add rbx, 1
    mov qword [indice_y_nuevo], rbx

    jmp calcularIndice

calcularIndice:
    mov rbx, qword[indice_y_viejo]
    imul rbx, 7
    mov r10, qword[indice_y_viejo]
    add r10, qword[indice_x_viejo]
    add rbx, r10
    mov r8, rbx

    mov rbx, qword[indice_y_nuevo]
    imul rbx, 7
    mov r11, qword[indice_y_nuevo]
    add r11, qword[indice_x_nuevo]
    add rbx, r11
    mov r9, rbx

validacionDeTablero:
    ; mov rdi, validacionDeTableromsj
    ; mPuts
    mov rbx, qword[indice_y_nuevo]
    cmp rbx, 6
    jg movimientoZorro
    cmp rbx, 0
    jl movimientoZorro

    mov rbx, qword[indice_x_nuevo]
    cmp rbx, 6
    jg movimientoZorro
    cmp rbx, 0
    jl movimientoZorro

;-------------------------
validarPosicionZorro:
    ; obtengo la direccion de memoria de la posicion que se selecciono
    ; mExtraerCaracter indice_y_nuevo, indice_x_nuevo

    mov al, byte[matrizPrincipal + r9]
    cmp al, '-'
    je cambiarPosicion

    ; mExtraerCaracter indice_y_nuevo, indice_x_nuevo
    mov al, byte[matrizPrincipal + r9]
    cmp al, ' '
    je msgMoverZorro
    
    ; mExtraerCaracter indice_y_nuevo, indice_x_nuevo
    mov al, byte[matrizPrincipal + r9]
    cmp al, 'O'
    je validarComerZorro

msgMoverZorro:
    mPuts msgPosZorroInvalida
    mov byte[hayOcas], "N"

    jmp movimientoZorro

validarComerZorro:
    cmp byte[hayOcas], "S"
    je msgMoverZorro

    cmp byte[hayOcas], "N"    
    je guardarDatosOca

    jmp cambiarPosicion

guardarDatosOca:
    mov qword[indiceZorro], r8
    mov byte[hayOcas], "S"

    mov rbx, qword[indice_x_nuevo]
    mov qword[indice_x_viejo], rbx

    mov rdx, qword[indice_y_nuevo]
    mov qword[indice_y_viejo], rdx

    inc dword[cantOcasComidas]

    jmp obtenerNuevaPosicion

borrarZorro:
    mov rdx, qword[indiceZorro]  ; posición vieja del zorro
    mov byte[matrizPrincipal + rdx], "-"
    jmp reseteo

cambiarPosicion:
    mov byte[matrizPrincipal + r8], '-'

    mov byte[matrizPrincipal + r9], 'X'
    
    mov byte [turno], 0 ; cambio el turno

    cmp byte[hayOcas], "S"
    je borrarZorro

reseteo:
    mov byte[hayOcas], "N"
    mov rdx, qword[indice_x_nuevo]
    mov qword[indice_x_zorro], rdx
    mov rdx, qword[indice_y_nuevo]
    mov qword[indice_y_zorro], rdx

    call validarGanoZorro
    cmp byte [quienGanoPartida], 'Z'
    je fin

    mClear

    jmp mostrarTablero
; ------------------- TERMINAR PARTIDA -------------------
checkeoTerminarPartida:
    cmp byte [rdi], 'Q'
    je fin
    ret

fin:
    ; Terminar el programa
    mov rax, 60  ; syscall: exit
    xor rdi, rdi  ; status: 0
    syscall
    
    ret