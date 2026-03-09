# ======================================================================
# snake_mips_ultra_simples.asm
# Jogo da Cobrinha - SEM FUNÇÕES, apenas um bloco
# ======================================================================

.data
# Constantes
.eqv BASE_ADDRESS 0x10008000
.eqv SIZE 16
.eqv SIZE_M1 15
.eqv KEYBOARD_ADDR 0xFFFF0000

# Cores
.eqv COLOR_SNAKE 0x00FF0000
.eqv COLOR_FOOD  0x00FF0000
.eqv COLOR_BG    0x00000000

# Teclas
.eqv KEY_LEFT  1
.eqv KEY_DOWN  2
.eqv KEY_RIGHT 4
.eqv KEY_UP    8

# Variáveis
x_pos_cur:    .word 4
y_pos_cur:    .word 4
x_pos_next:   .word 4
y_pos_next:   .word 4
x_food:       .word 2
y_food:       .word 2
delay_time:   .word 256
score:        .word 0
key_pressed:  .word 0

# Strings
msg_score:    .asciiz "Pontuacao: "
msg_newline:  .asciiz "\n"
msg_gameover: .asciiz "FIM DE JOGO! Pontuacao final: "

.text
.globl main

main:
    # ===== INICIALIZAÇÃO =====
    # Limpar tela
    li $t8, BASE_ADDRESS
    li $t9, COLOR_BG
    li $s0, 0  # y
    
limpa_y:
    li $s1, 0  # x
limpa_x:
    mul $t0, $s0, SIZE
    add $t0, $t0, $s1
    sll $t0, $t0, 2
    add $t0, $t8, $t0
    sw $t9, 0($t0)
    
    addi $s1, $s1, 1
    blt $s1, SIZE, limpa_x
    
    addi $s0, $s0, 1
    blt $s0, SIZE, limpa_y
    
    # Valores iniciais
    li $t0, 4
    sw $t0, x_pos_cur
    sw $t0, y_pos_cur
    sw $t0, x_pos_next
    sw $t0, y_pos_next
    
    li $t0, 2
    sw $t0, x_food
    sw $t0, y_food
    
    li $t0, 256
    sw $t0, delay_time
    
    li $t0, 0
    sw $t0, score
    
    # Desenhar cobra inicial
    lw $t0, x_pos_cur
    lw $t1, y_pos_cur
    li $t2, COLOR_SNAKE
    
    mul $t3, $t1, SIZE
    add $t3, $t3, $t0
    sll $t3, $t3, 2
    add $t3, $t8, $t3
    sw $t2, 0($t3)
    
    # Desenhar comida inicial
    lw $t0, x_food
    lw $t1, y_food
    li $t2, COLOR_FOOD
    
    mul $t3, $t1, SIZE
    add $t3, $t3, $t0
    sll $t3, $t3, 2
    add $t3, $t8, $t3
    sw $t2, 0($t3)
    
    # ===== LOOP PRINCIPAL =====
game_loop:
    # Ler tecla (não-bloqueante)
    li $t0, KEYBOARD_ADDR
    lw $t1, 0($t0)
    andi $t1, $t1, 1
    beq $t1, $zero, no_key
    
    lw $t2, 4($t0)
    
    # Converter ASCII para número
    li $t3, '1'
    bne $t2, $t3, test_2_ascii
    li $t4, KEY_LEFT
    sw $t4, key_pressed
    j no_key
    
test_2_ascii:
    li $t3, '2'
    bne $t2, $t3, test_4_ascii
    li $t4, KEY_DOWN
    sw $t4, key_pressed
    j no_key
    
test_4_ascii:
    li $t3, '4'
    bne $t2, $t3, test_8_ascii
    li $t4, KEY_RIGHT
    sw $t4, key_pressed
    j no_key
    
test_8_ascii:
    li $t3, '8'
    bne $t2, $t3, no_key
    li $t4, KEY_UP
    sw $t4, key_pressed
    
no_key:
    # Processar tecla pressionada
    lw $t0, key_pressed
    beq $t0, $zero, process_movement
    
    # Carregar posições atuais
    lw $t1, x_pos_cur
    lw $t2, y_pos_cur
    
    # Verificar qual tecla
    li $t3, KEY_LEFT
    bne $t0, $t3, test_down_key
    # Esquerda
    addi $t1, $t1, -1
    blt $t1, 0, left_wrap_key
    sw $t1, x_pos_next
    j process_movement
left_wrap_key:
    li $t1, SIZE_M1
    sw $t1, x_pos_next
    j process_movement
    
test_down_key:
    li $t3, KEY_DOWN
    bne $t0, $t3, test_right_key
    # Baixo
    addi $t2, $t2, 1
    li $t3, SIZE
    beq $t2, $t3, down_wrap_key
    sw $t2, y_pos_next
    j process_movement
down_wrap_key:
    li $t2, 0
    sw $t2, y_pos_next
    j process_movement
    
test_right_key:
    li $t3, KEY_RIGHT
    bne $t0, $t3, test_up_key
    # Direita
    addi $t1, $t1, 1
    li $t3, SIZE
    beq $t1, $t3, right_wrap_key
    sw $t1, x_pos_next
    j process_movement
right_wrap_key:
    li $t1, 0
    sw $t1, x_pos_next
    j process_movement
    
test_up_key:
    li $t3, KEY_UP
    bne $t0, $t3, process_movement
    # Cima
    addi $t2, $t2, -1
    blt $t2, 0, up_wrap_key
    sw $t2, y_pos_next
    j process_movement
up_wrap_key:
    li $t2, SIZE_M1
    sw $t2, y_pos_next
    
process_movement:
    # Verificar se comeu comida
    lw $t0, x_pos_next
    lw $t1, y_pos_next
    lw $t2, x_food
    lw $t3, y_food
    
    bne $t0, $t2, skip_food_eat
    bne $t1, $t3, skip_food_eat
    
    # Comeu comida - gerar nova posição
    li $v0, 42
    li $a1, SIZE
    syscall
    sw $a0, x_food
    
    li $v0, 42
    li $a1, SIZE
    syscall
    sw $a0, y_food
    
    # Desenhar nova comida
    lw $t4, x_food
    lw $t5, y_food
    li $t6, COLOR_FOOD
    
    mul $t7, $t5, SIZE
    add $t7, $t7, $t4
    sll $t7, $t7, 2
    add $t7, $t8, $t7
    sw $t6, 0($t7)
    
    # Aumentar velocidade
    lw $t4, delay_time
    srl $t4, $t4, 1
    li $t5, 10
    bge $t4, $t5, save_delay_val
    li $t4, 10
save_delay_val:
    sw $t4, delay_time
    
    # Incrementar pontuação
    lw $t4, score
    addi $t4, $t4, 1
    sw $t4, score
    
skip_food_eat:
    # Apagar posição anterior da cobra
    lw $t0, x_pos_cur
    lw $t1, y_pos_cur
    li $t2, COLOR_BG
    
    mul $t3, $t1, SIZE
    add $t3, $t3, $t0
    sll $t3, $t3, 2
    add $t3, $t8, $t3
    sw $t2, 0($t3)
    
    # Atualizar posição atual
    lw $t0, x_pos_next
    sw $t0, x_pos_cur
    lw $t0, y_pos_next
    sw $t0, y_pos_cur
    
    # Desenhar nova posição da cobra
    lw $t0, x_pos_cur
    lw $t1, y_pos_cur
    li $t2, COLOR_SNAKE
    
    mul $t3, $t1, SIZE
    add $t3, $t3, $t0
    sll $t3, $t3, 2
    add $t3, $t8, $t3
    sw $t2, 0($t3)
    
    # Mostrar pontuação
    li $v0, 4
    la $a0, msg_score
    syscall
    li $v0, 1
    lw $a0, score
    syscall
    li $v0, 4
    la $a0, msg_newline
    syscall
    
    # Delay
    lw $a0, delay_time
    li $v0, 32
    syscall
    
    # Verificar fim de jogo
    lw $t0, score
    li $t1, 5
    bne $t0, $t1, game_loop
    
    # Fim de jogo
    li $v0, 4
    la $a0, msg_gameover
    syscall
    li $v0, 1
    lw $a0, score
    syscall
    li $v0, 4
    la $a0, msg_newline
    syscall
    
    # Exit
    li $v0, 10
    syscall