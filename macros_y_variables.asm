global macros_y_variables

extern puts
extern gets
extern sscanf
extern printf
extern system

%macro mPuts 1
    mov rdi, %1
    sub rsp, 8
    call puts
    add rsp, 8
%endmacro

%macro mGets 0
    sub rsp, 8
    call gets
    add rsp, 8
%endmacro

%macro mSscanf 3
    sub rsp, 8
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    call sscanf
    add rsp, 8
%endmacro

%macro mExtraerCaracter 2
    ; en ebx tengo la direccion de memoria de la posicion que quiero ver
    ; el caracter se devuelve en 'al'
    mDesplazamiento %1, %2
    mov [valor], ebx 
    mov rdi, [valor]
    movzx eax, byte [rdi]
%endmacro

%macro mDesplazamiento 2
    mov ebx, matrizPrincipal
    mov eax, [%1]
    sub eax, 1 
    imul eax, 8 
    mov ecx, eax 
    mov eax, [%2]
    sub eax, 1 
    add ecx, eax 
    add ebx, ecx
%endmacro 

%macro mClear 0
    sub rsp, 8
    mov rdi, clear
    call system
    add rsp, 8
%endmacro

%macro mPrintf 2
    sub rsp, 8
    mov rdi, %1
    mov rsi, %2
    xor rax, rax
    call printf
    add rsp, 8
%endmacro


section .data
    msgTurnoZorro db "Turno del ZORRO", 0
    msgTurnoOca db "Turno de las OCAS", 0
    moverZorro db "Ingrese una opción 1: Arriba, 2: Abajo, 3: Izquierda, 4: Derecha, 5: DiagArrIzq, 6: DiagArrDer, 7: DiagAbjIzq, 8: DiagAbjDer, Q: Salir", 0

    msgSelOcaF db "Ingrese fila de la oca que quiere seleccionar o 'Q' para salir: ", 0
    msgSelOcaC db "Ingrese columna de la oca que quiere seleccionaro 'Q' para salir: ", 0
    msgMovOca  db "Ingrese una opcion de movimiento 1: Adelante, 2: Izquierda, 3: Derecha, Q: Salir: ", 0
    msgPosOcaInvalida db "Posicion de oca invalida, ingrese una posicion valida", 10, 0
    msgMovInvalido db "Movimiento invalido, ingrese un movimiento valido", 10, 0
    msgPosZorroInvalida db "Posicion del zorro invalida, ingrese una posicion valida", 10, 0


    msgGanoZorro db "Gano el zorro!", 10, 0
    msgGanoOca db "Ganaron las ocas!", 10, 0

    ocaValida db 'N', 0

    turno dq 1 ; 1 = zorro, 0 = oca

    format db "%lli", 0

    char1 db "-", 0
    char2 db "O", 0

    sePuedeMover db 'N', 0

    clear db "clear", 0
    
    hayOcas db "N", 0
    indiceZorro dq 0
    comioOca dq 0 
    
    ; uso en mostrarTableroConFormato
    lineaSuperior   db "   | 1 | 2 | 3 | 4 | 5 | 6 | 7 |", 0
    formatoFila     db " %d |", 0 ; Para imprimir el número de fila
    formatoCelda    db " %c |", 0 ; Para imprimir el valor de la celda
    formatoSalto    db "%c", 0 ; Para imprimir un salto de línea
    saltoDeLinea    dd 10
    columna         dd 1
    fila            dd 1

section .bss
    moverZorroA resb 100

    posOcaSeleccionada resb 100 
    pos_y_ocaSelStr resb 2 ; solo los uso para pasarlos a int
    pos_x_ocaSelStr resb 2

    pos_y_ocaViejo resd 10
    pos_x_ocaViejo resd 10
    pos_y_ocaNuevo resd 10
    pos_x_ocaNuevo resd 10

    valor resb 100

    moverOcaA resb 100

    auxY resd 10
    auxX resd 10
    valor1 resb 100
    valor2 resb 100
