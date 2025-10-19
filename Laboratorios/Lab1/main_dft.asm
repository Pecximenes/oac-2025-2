# -----------------------------------------------------------------
# main_dft.s
#
# Programa principal para testar a função DFT.
# 
# Instruções:
# 1. Mantenha 3 arquivos na mesma pasta:
#    - Lab1-3-1.s (com 'sincos' e suas constantes)
#    - dft.s      (com 'DFT' e suas constantes)
#    - main_dft.s (este arquivo)
# 2. No RARS, ative "Settings" -> "Assemble all files in directory"
# 3. Abra este arquivo (main_dft.s) e deixe-o ativo.
# 4. Monte (F3) e Rode (F5).
# -----------------------------------------------------------------

.text
.globl main

main:
    # --- Declarar argumentos para DFT ---
    la      a0, x_data        	# a0 = float *x
    la      a1, X_real_data   	# a1 = float *X_real
    la      a2, X_imag_data   	# a2 = float *X_imag
    li      a3, 4      	      	# a3 = int N (4)

    jal     ra, DFT		# Chamando DFT

    # --- Análise dos resultados ---
    # Loop de 0 a N-1, mostrando resultados
    
    li      s0, 0             	# s0 = k (contador)
    la      s1, X_real_data   	# s1 = ponteiro para X_real
    la      s2, X_imag_data   	# s2 = ponteiro para X_imag
    li      s3, 4      		# s3 = N (Deve ser o mesmo valor de a3)

PRINT_LOOP:
    bge     s0, s3, PRINT_LOOP_END	# k >= N ?

    # Imprime "K = "
    la      a0, MSG_K
    li      a7, 4
    ecall

    # Imprime k
    mv      a0, s0
    li      a7, 1
    ecall

    # Imprime ": Real="
    la      a0, MSG_REAL
    li      a7, 4
    ecall

    # Carrega e imprime X_real[k]
    slli    t0, s0, 2         # t0 = k * 4 (offset)
    add     t1, s1, t0        # t1 = endereço de X_real[k]
    flw     fa0, 0(t1)        # fa0 = X_real[k]
    li      a7, 2             # print float
    ecall

    # Imprime ", Imag="
    la      a0, MSG_IMAG
    li      a7, 4
    ecall

    # Carrega e imprime X_imag[k]
    add     t1, s2, t0        # t1 = endereço de X_imag[k] (reusa t0)
    flw     fa0, 0(t1)        # fa0 = X_imag[k]
    li      a7, 2
    ecall
    
    # Imprime nova linha
    la      a0, NL_MAIN       # (Usando um NL local)
    li      a7, 4
    ecall

    # Fim do loop de impressão
    addi    s0, s0, 1         # k++
    j       PRINT_LOOP
PRINT_LOOP_END:

    # --- Encerra o programa ---
    li      a7, 10
    ecall

# ----------------
# Dados para o main
# ----------------
.data
# N_PONTOS:   .word 0x0004 	# Fazendo teste nessa parte mas nao deu certo 

# Sinal de entrada: x = [1.0, 0.0, 1.0, 0.0]
x_data:
    .float 1.0
    .float 0.0
    .float 1.0
    .float 0.0

# Espaço para os resultados (N * 4 bytes)
X_real_data:
    .space 16   # 4 * 4 bytes
X_imag_data:
    .space 16   # 4 * 4 bytes

# Strings de impressão
MSG_K:      .asciz "K = "
MSG_REAL:   .asciz ": Real="
MSG_IMAG:   .asciz ", Imag="
NL_MAIN:    .asciz "\n"
