# Jogo da Cobrinha com comida, pontuação e fim de jogo
# Adicionado por: Assistente
# Baseado no código original de Wesley Geilson

.data
.eqv SIZE 16
.eqv TARGET_SCORE 5          # Pontuação alvo para fim de jogo

COLOR_SNAKE: .word 0x00FFFF00    # Amarelo
COLOR_FOOD:  .word 0x00FF0000    # Vermelho
COLOR_BG:    .word 0x00000000    # Preto

x_pos: .word 4
y_pos: .word 4

x_food: .word 8                  # Posição inicial da comida
y_food: .word 8

current_dir: .word 100           # Direção inicial (d = direita)
score: .word 0                   # Pontuação inicial
delay: .word 150                  # Delay inicial (ms)

# Mensagens
msg_score: .asciiz "Pontuacao: "
msg_newline: .asciiz "\n"
msg_game_over: .asciiz "\n=== FIM DE JOGO! Pontuacao final: "
msg_congrats: .asciiz "\nParabens! Voce venceu!\n"

.text
.globl MAIN

MAIN:
    # Inicializa semente aleatória
    li $v0, 30                    # Get system time
    syscall
    move $a1, $a0                  # Use time as seed
    li $v0, 40                     # Set seed
    syscall
    
    # Gera posição inicial da comida (diferente da cobra)
    jal GENERATE_FOOD
    
    # Desenha pixel inicial da cobra
    lw $a0, x_pos
    lw $a1, y_pos
    lw $a2, COLOR_SNAKE
    jal WRITE_PIXEL
    
    # Desenha comida inicial
    lw $a0, x_food
    lw $a1, y_food
    lw $a2, COLOR_FOOD
    jal WRITE_PIXEL
    
    # Mostra pontuação inicial
    jal DISPLAY_SCORE

LOOP:
    # Verifica se atingiu pontuação máxima
    lw $t0, score
    li $t1, TARGET_SCORE
    beq $t0, $t1, GAME_OVER_WIN
    
    # Delay baseado na pontuação
    lw $a0, delay
    li $v0, 32
    syscall

    # Apaga posição atual da cobra
    lw $a0, x_pos
    lw $a1, y_pos
    lw $a2, COLOR_BG
    jal WRITE_PIXEL

    # Lê teclado
    jal READ_KEYBOARD
    beq $v0, $zero, MOVEMENT_LOGIC
    sw $v0, current_dir

MOVEMENT_LOGIC:
    lw $t3, current_dir
    
    beq $t3, 119, IS_UP_PRESSED    # 'w' = 119
    beq $t3, 115, IS_DOWN_PRESSED  # 's' = 115
    beq $t3, 97,  IS_LEFT_PRESSED  # 'a' = 97
    beq $t3, 100, IS_RIGHT_PRESSED # 'd' = 100
    j REWRITE_BABY                  # Se tecla inválida, mantém direção

IS_RIGHT_PRESSED:
    lw $t0, x_pos
    addi $t0, $t0, 1
    andi $t0, $t0, 15
    sw $t0, x_pos
    j CHECK_FOOD_COLLISION

IS_LEFT_PRESSED:
    lw $t0, x_pos
    addi $t0, $t0, -1
    andi $t0, $t0, 15
    sw $t0, x_pos
    j CHECK_FOOD_COLLISION

IS_DOWN_PRESSED:
    lw $t0, y_pos
    addi $t0, $t0, 1
    andi $t0, $t0, 15
    sw $t0, y_pos
    j CHECK_FOOD_COLLISION

IS_UP_PRESSED:
    lw $t0, y_pos
    addi $t0, $t0, -1
    andi $t0, $t0, 15
    sw $t0, y_pos
    j CHECK_FOOD_COLLISION

CHECK_FOOD_COLLISION:
    # Verifica se cobra comeu a comida
    lw $t0, x_pos
    lw $t1, y_pos
    lw $t2, x_food
    lw $t3, y_food
    
    bne $t0, $t2, REWRITE_BABY
    bne $t1, $t3, REWRITE_BABY
    
    # Comeu a comida!
    
    # Incrementa pontuação
    lw $t4, score
    addi $t4, $t4, 1
    sw $t4, score
    
    # Aumenta velocidade (diminui delay)
    lw $t5, delay
    li $t6, 20                      # Delay mínimo
    beq $t5, $t6, SKIP_DELAY_REDUCE
    addi $t5, $t5, -10               # Reduz 10ms a cada comida
    sw $t5, delay
    
SKIP_DELAY_REDUCE:
    # Mostra pontuação atualizada
    jal DISPLAY_SCORE
    
    # Gera nova comida
    jal GENERATE_FOOD
    
    # Desenha nova comida
    lw $a0, x_food
    lw $a1, y_food
    lw $a2, COLOR_FOOD
    jal WRITE_PIXEL

REWRITE_BABY:
    # Desenha cobra na nova posição
    lw $a0, x_pos
    lw $a1, y_pos
    lw $a2, COLOR_SNAKE
    jal WRITE_PIXEL
    
    j LOOP

# Função para gerar nova posição para a comida
GENERATE_FOOD:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Gera posição x aleatória (0-15)
    li $v0, 42
    li $a1, 16
    syscall
    sw $a0, x_food
    
    # Gera posição y aleatória (0-15)
    li $v0, 42
    li $a1, 16
    syscall
    sw $a0, y_food
    
    # Verifica se comida não está na posição da cobra
    lw $t0, x_food
    lw $t1, x_pos
    bne $t0, $t1, GENERATE_FOOD_END
    
    lw $t0, y_food
    lw $t1, y_pos
    bne $t0, $t1, GENERATE_FOOD_END
    
    # Se estiver na cobra, gera nova posição
    j GENERATE_FOOD
    
GENERATE_FOOD_END:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Função para mostrar pontuação no console
DISPLAY_SCORE:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    li $v0, 4
    la $a0, msg_score
    syscall
    
    li $v0, 1
    lw $a0, score
    syscall
    
    li $v0, 4
    la $a0, msg_newline
    syscall
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Função para desenhar pixel no Bitmap Display
WRITE_PIXEL:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    li $t0, 0x10008000
    li $t1, SIZE
    mul $t2, $a1, $t1
    add $t2, $t2, $a0
    sll $t2, $t2, 2
    add $t0, $t0, $t2

    sw $a2, 0($t0)
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Função para ler teclado via MMIO (não bloqueante)
READ_KEYBOARD:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    li $t0, 0xFFFF0000
    lw $t1, 0($t0)
    andi $t1, $t1, 1 
    beq $t1, $zero, NOT_PRESSED
    lw $v0, 4($t0)
    j READ_END

NOT_PRESSED:
    li $v0, 0

READ_END:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Função de fim de jogo (vitória)
GAME_OVER_WIN:
    # Mostra mensagem de parabéns
    li $v0, 4
    la $a0, msg_congrats
    syscall
    
    # Mostra pontuação final
    li $v0, 4
    la $a0, msg_game_over
    syscall
    
    li $v0, 1
    lw $a0, score
    syscall
    
    # Encerra o programa
    li $v0, 10
    syscall