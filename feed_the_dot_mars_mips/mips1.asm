#O objetivo atual aqui no mars é construir por meio do bitmap junto ao mapeamento 
#de teclas, um joguinho da cobra.
# Logica implementada por Wesley geilson e gagau, o codigo a seguir não é a versão mais simplificada do jogo

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




WRITE_GRID:		#void write_grid(int x, int y, cor)

#preparamento da pilha: Reservamos a chamada final
addi $sp, -4
sw $ra, 0($sp)

#execucao do algoritmo:
li $t4, 0x00FFFF00
li $a0, 0x10008000 	#adicionamos o primeiro endereço (endereço base) do display no registrador t1
sll $a2, $a2, 4 	#(y * 16)
add $a3, $a1, $a2 	#(y + x)
sll $a3, $a3, 2 	#(y + x)*4
add $v0, $a0 ,$a3	#base + (y + x)
sw $t4, $v0		#pinta o quadradinho de amarelo

#restauramento da pilha:
lw ra,0($sp)
addi $sp,4
jr $ra


IS_KEY_PRESSED:		#int read_key() // OBS: ESSA FUNCAO NAO EST�? FUNCIONANDO

li $v0, 5		#o nosso cod para chamar o sistema e dizer "Estou lendo seu numero agora"
move $a1, $v0
beq s0 ,a1, case_w 	#Se a entrada que eu der em a1 for igual a t1 (sendo s1 = w, s2 = a, s3 = s, s4 = d)
beq s1 ,a1, case_a
beq s2 ,a1, case_s
beq s3 ,a1, case_d

case_w:
li a1,4
j WRITE_GRID
case_a:
case_s:
case_d:
		

MAIN:

li $t4, 0x00FFFF00    # cor amarela no t4
sw $t4, 0($v0)        # armazena a cor amarela no endereço que calculamos


