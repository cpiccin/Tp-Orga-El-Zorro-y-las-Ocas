%include "macros_y_variables.asm"
global mostrarTableroConFormato
extern matrizPrincipal

section .text 
mostrarTableroConFormato:
    mPuts lineaSuperior
loopFilas:
    cmp dword [fila], 8 
    je end

    mPrintf formatoFila, [fila]
loopColumna:

    cmp dword [columna], 8
    je finColumna

    mExtraerCaracter fila, columna
    mov [valor], al
    mPrintf formatoCelda, [valor]
    inc dword [columna]
    jmp loopColumna

finColumna:
    mPrintf formatoSalto, 10
    mov dword [columna], 1
    inc dword [fila]
    jmp loopFilas
end: 
    mov dword [columna], 1
    mov dword [fila], 1
    ret 