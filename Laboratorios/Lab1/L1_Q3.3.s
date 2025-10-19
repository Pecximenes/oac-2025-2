.data
N: .word 8                                   
x: .float 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 
X_real: .float 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 
X_imagi: .float 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 

# strings para a impressão
label_xn: .string "x[n]\tX[k]\n"
tab:      .string "\t"
plus_i:   .string " + "
newline:  .string "i\n"

.text
main: 
    
    # jal DFT        

    # Passando os mesmos argumentos da função DFT para a função show_dft
    la a0, x
    la a1, X_real
    la a2, X_imagi
    lw a3, N
    jal SHOW_DFT

    # Prepara para encerar o programa
    li a7, 10
    ecall
    
    
SHOW_DFT:
    # Copia para os registradores temporários (para não alterar os ponteiros originais)
    mv t1, a0   # t1 para x
    mv t2, a1   # t2 para X_real
    mv t3, a2   # t3 para X_imagi
    
    # Imprime "x[n]   X[k]\n"
    la a0, label_xn
    li a7, 4        
    ecall
    
    # Inicia o contador do loop
    mv t0, zero     # k = 0
    
loop_start:
    # Se k >= N, fim do loop
    bge t0, a3, loop_end

    # Imprime x[k] (float)
    flw fa0, 0(t1)  # Carrega o float da memória para o registrador de float fa0
    li a7, 2        
    ecall

    # Imprime "\t"
    la a0, tab
    li a7, 4
    ecall
    
    # Imprime X_real[k] (float)
    flw fa0, 0(t2)
    li a7, 2
    ecall
    
    # Imprime " + "
    la a0, plus_i
    li a7, 4
    ecall
    
    # Imprime X_imagi[k] (float)
    flw fa0, 0(t3)
    li a7, 2
    ecall
    
    # Imprime "i\n"
    la a0, newline
    li a7, 4
    ecall
    
    # Avança para o próximo elemento
    addi t1, t1, 4  # x++
    addi t2, t2, 4  # X_real++
    addi t3, t3, 4  # X_imagi++
    addi t0, t0, 1  # k++
    
    j loop_start    

loop_end:    
    ret






