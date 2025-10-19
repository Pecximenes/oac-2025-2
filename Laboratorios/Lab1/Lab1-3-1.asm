    .text
    .globl sincos


# --------------------------------
# sincos(theta): cos->fa0, sin->fa1
# range reduction para r em [-pi/4, pi/4]
# --------------------------------
sincos:
    # k = round(theta/(pi/2)) = round(theta * (2/pi))
    la      t6, TWO_OVER_PI
    flw     ft0, 0(t6)          # ft0 = 2/pi
    fmul.s  ft1, fa0, ft0       # ft1 = theta * (2/pi)
    fcvt.w.s t0, ft1            # t0 = round(ft1) (RNE)
    fcvt.s.w ft2, t0            # ft2 = float(k)

    # r = theta - k*(pi/2)
    la      t6, PI_2
    flw     ft3, 0(t6)          # ft3 = pi/2
    fmul.s  ft4, ft2, ft3       # k*(pi/2)
    fsub.s  ft5, fa0, ft4       # ft5 = r

    # prepara potencias: r2 = r**2
    fmul.s  ft6, ft5, ft5       # ft6 = r2

    # ---------------------------
    # cos_r via Horner (ordem 10)
    # cos(r) ~ 1 + c2*r2 + c4*r2**2 + c6*r2**3 + c8*r2**4 + c10*r2**5
    # ---------------------------
    la      t6, C_COS_C10
    flw     ft7, 0(t6)          # ft7 = c10
    fmul.s  ft7, ft7, ft6       # c10*r2
    la      t6, C_COS_C8
    flw     fa2, 0(t6)          # fa2 = c8
    fadd.s  ft7, ft7, fa2       # c10*r2 + c8
    fmul.s  ft7, ft7, ft6       # (..)*r2
    la      t6, C_COS_C6
    flw     fa2, 0(t6)          # fa2 = c6
    fadd.s  ft7, ft7, fa2
    fmul.s  ft7, ft7, ft6
    la      t6, C_COS_C4
    flw     fa2, 0(t6)          # fa2 = c4
    fadd.s  ft7, ft7, fa2
    fmul.s  ft7, ft7, ft6
    la      t6, C_COS_C2
    flw     fa2, 0(t6)          # fa2 = c2
    fadd.s  ft7, ft7, fa2
    fmul.s  ft7, ft7, ft6
    la      t6, C_ONE
    flw     fa2, 0(t6)          # fa2 = 1.0
    fadd.s  fa3, ft7, fa2       # fa3 = cos_r (temporario)

    # ---------------------------
    # sin_r via Horner (ordem 9)
    # sin(r) ~ r * (1 + c3*r2 + c5*r2**2 + c7*r2**3 + c9*r2**4)
    # ---------------------------
    la      t6, C_SIN_C9
    flw     ft7, 0(t6)          # ft7 = c9
    fmul.s  ft7, ft7, ft6       # c9*r2
    la      t6, C_SIN_C7
    flw     fa2, 0(t6)          # fa2 = c7
    fadd.s  ft7, ft7, fa2
    fmul.s  ft7, ft7, ft6
    la      t6, C_SIN_C5
    flw     fa2, 0(t6)          # fa2 = c5
    fadd.s  ft7, ft7, fa2
    fmul.s  ft7, ft7, ft6
    la      t6, C_SIN_C3
    flw     fa2, 0(t6)          # fa2 = c3
    fadd.s  ft7, ft7, fa2
    fmul.s  ft7, ft7, ft6
    la      t6, C_ONE
    flw     fa2, 0(t6)          # fa2 = 1.0
    fadd.s  ft7, ft7, fa2       # (1 + ...)
    fmul.s  fa4, ft7, ft5       # fa4 = sin_r (temporario)

    # ---------------------------
    # aplica tabela por k mod 4
    # ---------------------------
    andi    t1, t0, 3           # t1 = k & 3
    beqz    t1, .quad0          # 0
    addi    t2, zero, 1
    beq     t1, t2, .quad1      # 1
    addi    t2, zero, 2
    beq     t1, t2, .quad2      # 2
    # caso 3
.quad3:
    # cos = +sin_r ; sin = -cos_r
    fmv.s   fa0, fa4            # cos(theta)
    fneg.s  fa1, fa3            # sin(theta)
    ret
.quad2:
    # cos = -cos_r ; sin = -sin_r
    fneg.s  fa0, fa3
    fneg.s  fa1, fa4
    ret
.quad1:
    # cos = -sin_r ; sin = +cos_r
    fneg.s  fa0, fa4
    fmv.s   fa1, fa3
    ret
.quad0:
    # cos = +cos_r ; sin = +sin_r
    fmv.s   fa0, fa3
    fmv.s   fa1, fa4
    ret

# ----------------
# constantes
# ----------------
    .section .rodata
    .align 2
TWO_PI:       .float 6.2831853      # 2*pi (mantido se quiser testar a versao antiga)
PI_2:         .float 1.5707964      # pi/2
PI_4:         .float 0.7853982      # pi/4
TWO_OVER_PI:  .float 0.63661975     # 2/pi
C_ONE:        .float 1.0

# cos coef (até r**10)
# 1 - r**2/2! + r**4/4! - r**6/6! + r**8/8! - r**10/10!
C_COS_C2:   .float -0.5                 # -1/2!
C_COS_C4:   .float 0.041666667          # +1/4!
C_COS_C6:   .float -0.0013888889        # -1/6!
C_COS_C8:   .float 0.000024801587       # +1/8!
C_COS_C10:  .float -0.00000027557319    # -1/10!

# sin coef (até r**9)
# r * (1 - r**2/3! + r**4/5! - r**6/7! + r**8/9!)
C_SIN_C3:   .float -0.16666667          # -1/3!
C_SIN_C5:   .float 0.0083333333         # +1/5!
C_SIN_C7:   .float -0.00019841270       # -1/7!
C_SIN_C9:   .float 0.0000027557319      # +1/9!

    .data
MSG_COS: .asciz "cos = "
MSG_SIN: .asciz "sin = "
NL:      .asciz "\n"
