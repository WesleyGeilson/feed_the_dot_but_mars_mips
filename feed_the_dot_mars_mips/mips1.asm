# teste_minimo.asm
# Versão mínima para testar apenas um movimento
.data
.eqv BASE_ADDRESS 0x10040000
.eqv KEYBOARD_ADDR 0xFFFF0000
.eqv SIZE 16

COLOR_SNAKE: .word 0x00FF0000
COLOR_BG: .word 0x00000000

x_pos: .word 4
y_pos: .word 4

.text
.globl main

main:
    # Desenhar pixel inicial
    lw $a0, x_pos
    lw $a1, y_pos
    lw $a2, COLOR_SNAKE
    jal write_pixel
    
loop:
    # Ler tecla
    li $t0, KEYBOARD_ADDR
    lw $t1, 0($t0)
    andi $t1, $t1, 1
    beq $t1, $zero, loop
    
    lw $t2, 4($t0)          # tecla pressionada
    
    # Se for 'd' (100), mover para direita
    li $t3, 100
    bne $t2, $t3, loop
    
    # Apagar posição atual
    lw $a0, x_pos
    lw $a1, y_pos
    lw $a2, COLOR_BG
    jal write_pixel
    
    # Mover para direita
    lw $t0, x_pos
    addi $t0, $t0, 1
    sw $t0, x_pos
    
    # Desenhar nova posição
    lw $a0, x_pos
    lw $a1, y_pos
    lw $a2, COLOR_SNAKE
    jal write_pixel
    
    j loop

write_pixel:
    # Calcula endereço: base + (y*16 + x)*4
    li $t0, BASE_ADDRESS
    li $t1, SIZE
    mul $t2, $a1, $t1
    add $t2, $t2, $a0
    sll $t2, $t2, 2
    add $t0, $t0, $t2
    
    sw $a2, 0($t0)
    jr $ra
