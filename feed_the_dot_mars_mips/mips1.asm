#O objetivo atual aqui no mars é construir por meio do bitmap junto ao mapeamento 
#de teclas, um joguinho da cobra.
# Logica implementada por Wesley geilson, o codigo a seguir não é a versão mais simplificada do jogo

#logica do jogo:
#1. A cobrinha iniciara na tela
#2. Se alguma tecla for pressionada, logo a cobrinha ira para a direção da tecla (WASD)
#3. Se a cobrinha se alimentar, havera aumento de pontuacao e aumento de velocidade
#4. Se a cobrinha enconstar na borda ela aparece no lado aposto (Wrap around)
#5. O jogo acaba quando a pontuação for igual a 5

#------------------------------------------------------------------------------------------------------------------------------------------------------------
#PASSO 01

#O display 16x16 tem suas respectivas memorias, se acessarmos e manipula-los estaremos controlando o player
# Seja a0 = base
# Seja a1 = x
# Seja a2 = y
# Seja a3 = x + y
# Seja v0 = endereço final no display


#------------------------------------------------------------------------------------------------------------------------------------------------------------

#PASSO 02
# Para a entrada do usuario, ele deve clicar para ou seja, havera alguma entrada por parte do usuario, seja essa entrada a0

#Seja s0 =w, s1=a, s2=s, s3=d
#Caractere 	Hexadecimal	Decimal
#w		0x77		119		cima
#a		0x61		97		esquerda
#s		0x73		115		baixo
#d		0x64		100		direita
#------------------------------------------------------------------------------------------------------------------------------------------------------------
#PASSO 03
#Para fazer a seleção usaremos um switch, tal que em pseudocodigo:

#	Escolha{
#		se for w: para frente
#		se for s: para baixo
#		se for d: para direita
#		se for a: para esquerda
#	}
#------------------------------------------------------------------------------------------------------------------------------------------------------------
#.....PASSO 04 
#.....PASSO 05

.data
.eqv SIZE 16

COLOR_SNAKE: .word 0x00FFFF00
COLOR_BG: .word 0x00000000

x_pos: .word 4
y_pos: .word 4

current_dir: .word 100

.text
.globl MAIN


MAIN:
# Desenhar pixel inicial
lw $a0, x_pos
lw $a1, y_pos
lw $a2, COLOR_SNAKE
jal WRITE_PIXEL
    


LOOP:
 # Pausa de 150 milissegundos
li $v0, 32
li $a0, 150
syscall

#referencia o x e o y e pinta de preto o pixel atual
lw $a0, x_pos
lw $a1, y_pos
lw $a2, COLOR_BG
jal WRITE_PIXEL

jal READ_KEYBOARD
beq $v0, $zero, MOVEMENT_LOGIC
sw $v0, current_dir

MOVEMENT_LOGIC:
lw $t3, current_dir
    
beq $t3, 119, IS_UP_PRESSED    # 'w' = 119
beq $t3, 115, IS_DOWN_PRESSED  # 's' = 115
beq $t3, 97,  IS_LEFT_PRESSED  # 'a' = 97
beq $t3, 100, IS_RIGHT_PRESSED # 'd' = 100

IS_RIGHT_PRESSED:
lw $t0, x_pos
addi $t0, $t0, 1
andi $t0, $t0, 15
sw $t0, x_pos
j REWRITE_BABY

IS_LEFT_PRESSED:
lw $t0, x_pos
addi $t0, $t0, -1
andi $t0, $t0, 15
sw $t0, x_pos
j REWRITE_BABY

IS_DOWN_PRESSED:
lw $t0, y_pos
addi $t0, $t0, 1
andi $t0, $t0, 15
sw $t0, y_pos
j REWRITE_BABY

IS_UP_PRESSED:
lw $t0, y_pos
addi $t0, $t0, -1
andi $t0, $t0, 15
sw $t0, y_pos
j REWRITE_BABY

REWRITE_BABY:
lw $a0, x_pos
lw $a1, y_pos
lw $a2,COLOR_SNAKE
jal WRITE_PIXEL
j LOOP

WRITE_PIXEL:
# Calcula endereço: base + (y*16 + x)*4

addi $sp,$sp,-4
sw $ra, 0($sp)

li $t0, 0x10008000
li $t1, SIZE
mul $t2, $a1, $t1
add $t2, $t2, $a0
sll $t2, $t2, 2
add $t0, $t0, $t2

sw $a2, 0($t0)
lw $ra, 0($sp)                 # Recupera o $ra
addi $sp, $sp, 4               # Fecha o espaço na pilha
jr $ra                         # Retorna para onde foi chamado

READ_KEYBOARD:
# fazemos o retorno ser armazenado na pilha 
addi $sp, $sp, -4
sw $ra, 0($sp)

li $t0, 0xFFFF0000
lw $t1, 0($t0)
andi $t1, $t1, 1 
beq $t1, $zero, NOT_PRESSED
lw   $v0, 4($t0)
     
j READ_END

NOT_PRESSED:
li   $v0, 0                # Retorna 0 (nenhuma tecla nova)

READ_END:
lw   $ra, 0($sp)           # Restaura o $ra
addi $sp, $sp, 4           # Fecha o espaço da pilha
jr   $ra                   # Volta para a MAIN


