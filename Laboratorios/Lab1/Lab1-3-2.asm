# -----------------------------------------------------------------
# dft.s
#
# Contém o procedimento DFT(float *x, float *X_real, float *X_imag, int N)
#
# Argumentos (conforme a questao):
# a0: Endereço do vetor de entrada x[n]
# a1: Endereço do vetor de saída X_real[k]
# a2: Endereço do vetor de saída X_imag[k]
# a3: Número de pontos, N
#
# Depende da função 'sincos' (de Lab1-3-1.s)
# -----------------------------------------------------------------

    .section .rodata
    .align 2
C_TWO_PI:   .float 6.2831853    # 2 * pi
C_ZERO:     .float 0.0

    .text
    .globl DFT

# --------------------------------
# void DFT(a0: *x, a1: *X_real, a2: *X_imag, a3: N)
# --------------------------------
DFT:
    # Salvar registradores
    # ra (return address)
    # s0-s5 (loop counters, N, ponteiros base)
    # fs0-fs2 (somas parciais, constante 2*pi/N)
    addi    sp, sp, -48       # Aloca 48 bytes no stack
    sw      ra, 44(sp)        # Salva ra
    sw      s0, 40(sp)        # Salva s0 (usado para *x)
    sw      s1, 36(sp)        # Salva s1 (usado para *X_real)
    sw      s2, 32(sp)        # Salva s2 (usado para *X_imag)
    sw      s3, 28(sp)        # Salva s3 (usado para N)
    sw      s4, 24(sp)        # Salva s4 (usado para k)
    sw      s5, 20(sp)        # Salva s5 (usado para n)
    fsw     fs0, 16(sp)       # Salva fs0 (usado para sum_real)
    fsw     fs1, 12(sp)       # Salva fs1 (usado para sum_imag)
    fsw     fs2, 8(sp)        # Salva fs2 (usado para (2*pi)/N )

    # Inicialização
    mv      s0, a0            # s0 = *x
    mv      s1, a1            # s1 = *X_real
    mv      s2, a2            # s2 = *X_imag
    mv      s3, a3            # s3 = N

    # Calcular a constante (2 * pi) / N
    la		t0, C_TWO_PI	# C_TWO_PI = 6.2831853
    flw     	ft0, 0(t0)      # ft0 = 2 * pi
    fcvt.s.w 	ft1, s3       	# ft1 = float(N)
    fdiv.s  	fs2, ft0, ft1	# fs2 = (2*pi) / N

    # Carregar 0.0 para os acumuladores
    la      t0, C_ZERO
    flw     fs0, 0(t0)        # fs0 = sum_real (será 0.0)
    flw     fs1, 0(t0)        # fs1 = sum_imag (será 0.0)

    # Loop Externo (k)
    li      s4, 0             # k = 0

LOOP_OUTER_K:
    bge     s4, s3, LOOP_OUTER_K_END	# k < N ?

    # Reinicia as somas para este 'k'
    la      t0, C_ZERO
    flw     fs0, 0(t0)        # sum_real = 0.0
    flw     fs1, 0(t0)        # sum_imag = 0.0

    # Loop Interno (n)
    li      s5, 0             # n = 0

LOOP_INNER_N:
    bge     s5, s3, LOOP_INNER_N_END	# n < N ?

    # Calcular o ângulo: theta = (2*pi*n*k)/N
    fcvt.s.w ft3, s5          # ft3 = float(n)
    fcvt.s.w ft4, s4          # ft4 = float(k)
    fmul.s  ft5, fs2, ft3     # ft5 = (2*pi/N) * n
    fmul.s  fa0, ft5, ft4     # fa0 = theta (argumento para sincos)

    # Chamar sincos(theta)
    # Retorno: fa0 = cos(theta), fa1 = sin(theta))
    jal     ra, sincos

    # Pegar x[n]
    slli    t0, s5, 2         # t0 = n * 4 (offset)
    add     t1, s0, t0        # t1 = endereço de x[n]
    flw     ft6, 0(t1)        # ft6 = x[n]

    # Calcular termos da soma
    # term_real = x[n] * cos(theta)
    fmul.s  ft7, ft6, fa0
    # term_imag = -x[n] * sin(theta)
    fmul.s  ft8, ft6, fa1
    fneg.s  ft8, ft8

    # Acumular
    fadd.s  fs0, fs0, ft7     # sum_real += term_real
    fadd.s  fs1, fs1, ft8     # sum_imag += term_imag

    # Fim do loop interno
    addi    s5, s5, 1         # n++
    j       LOOP_INNER_N

LOOP_INNER_N_END:
    # Loop interno (n) terminou

    # Armazenar os resultados X[k]
    # X_real[k] = sum_real
    slli    t0, s4, 2         # t0 = k * 4 (offset)
    add     t1, s1, t0        # t1 = endereço de X_real[k]
    fsw     fs0, 0(t1)        # Salva sum_real

    # X_imag[k] = sum_imag
    add     t1, s2, t0        # t1 = endereço de X_imag[k] (reusa t0)
    fsw     fs1, 0(t1)        # Salva sum_imag

    # Fim do loop externo
    addi    s4, s4, 1         # k++
    j       LOOP_OUTER_K

LOOP_OUTER_K_END:
    # Loop externo (k) terminou

    # Restaurar registradores
    lw      ra, 44(sp)        # Restaura ra
    lw      s0, 40(sp)
    lw      s1, 36(sp)
    lw      s2, 32(sp)
    lw      s3, 28(sp)
    lw      s4, 24(sp)
    lw      s5, 20(sp)
    flw     fs0, 16(sp)
    flw     fs1, 12(sp)
    flw     fs2, 8(sp)
    addi    sp, sp, 48        # Libera espaço do stack

    ret
