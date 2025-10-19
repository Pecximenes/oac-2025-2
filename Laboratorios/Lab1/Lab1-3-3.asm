# -----------------------------------------------------------------
# q3_3.s
#
# Programa principal para testar a DFT conforme a Questão 3.3.
#
# -----------------------------------------------------------------

# ---------------------------------
# Definições da Questão
# ---------------------------------
.data
N:      .word 8
x:      .float 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0
X_real: .float 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
X_imag: .float 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0

# Strings para impressão no formato "x[n]   X[k]"
MSG_HEADER: .asciz "x[n]  X[k]\n"
MSG_SPACE:  .asciz "   "    # Espaçamento
MSG_PLUS:   .asciz "+"
MSG_I:      .asciz "i\n"    # 'i' e nova linha

# ---------------------------------
# Programa Principal
# ---------------------------------
.text
.globl main

main:
    # --- Configurar argumentos para a chamada da DFT ---
    
    # Carrega N (da memória, não é imediato)
    la      t0, N
    lw      s3, 0(t0)         # s3 = 8 (guardamos N em s3)

    # Carrega os ponteiros
    la      a0, x             # a0 = float *x
    la      a1, X_real        # a1 = float *X_real
    la      a2, X_imag        # a2 = float *X_imag
    mv      a3, s3            # a3 = N (passa o argumento)

    # --- Chamar a função DFT ---
    jal     ra, DFT

    # --- Impressão dos Resultados ---
    # DFT foi executada. Agora, imprimir no formato pedido.
    
    # Imprime o cabeçalho
    la      a0, MSG_HEADER
    li      a7, 4
    ecall

    # Inicializa ponteiros e contador para o loop de impressão
    li      s0, 0             # s0 = k (contador do loop, 0 a N-1)
    la      s1, x             # s1 = ponteiro base para x
    la      s2, X_real        # s2 = ponteiro base para X_real
    la      s4, X_imag        # s4 = ponteiro base para X_imag
                              # s3 ainda contém N = 8
PRINT_LOOP:
    # Condição: k >= N ?
    bge     s0, s3, PRINT_LOOP_END

    # Calcula o offset (k * 4 bytes)
    slli    t0, s0, 2         # t0 = k * 4
    
    # --- Imprime x[n] (usando k como índice n) ---
    add     t1, s1, t0        # t1 = endereço de x[k]
    flw     fa0, 0(t1)        # fa0 = x[k]
    li      a7, 2             # ecall: print float
    ecall

    # --- Imprime espaço ---
    la      a0, MSG_SPACE
    li      a7, 4             # ecall: print string
    ecall

    # --- Imprime X_real[k] ---
    add     t1, s2, t0        # t1 = endereço de X_real[k]
    flw     fa0, 0(t1)        # fa0 = X_real[k]
    li      a7, 2
    ecall
    
    # --- Imprime "+" ---
    la      a0, MSG_PLUS
    li      a7, 4
    ecall

    # --- Imprime X_imag[k] ---
    add     t1, s4, t0        # t1 = endereço de X_imag[k]
    flw     fa0, 0(t1)        # fa0 = X_imag[k]
    li      a7, 2
    ecall

    # --- Imprime "i\n" ---
    la      a0, MSG_I
    li      a7, 4
    ecall

    # Fim do loop de impressão
    addi    s0, s0, 1         # k++
    j       PRINT_LOOP
PRINT_LOOP_END:

    # --- Encerra o programa ---
    li      a7, 10            # ecall: exit
    ecall