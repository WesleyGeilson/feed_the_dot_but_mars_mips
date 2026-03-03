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

#O display 16x16 tem suas respectivas memorias, se acessarmos e manipula-los estaremos controlando o player
# Seja a0 = base
# Seja a1 = x
# Seja a2 = y
# Seja a3 = x + y
# Seja v0 = endereço final no display


#------------------------------------------------------------------------------------------------------------------------------------------------------------

# Para a entrada do usuario, ele deve clicar para ou seja, havera alguma entrada por parte do usuario, seja essa entrada a0



#------------------------------------------------------------------------------------------------------------------------------------------------------------


WRITE_GRID:		#void write_grid(int x, int y, int value)

li $a0, 0x10008000 	#adicionamos o primeiro endereço (endereço base) do display no registrador t1
sll $a2, $a2, 4 	#(y * 16)
add $a3, $a1, $a2 	#(y + x)
sll $a3, $a3, 2 	#(y + x)*4
add $v0, $a0 ,$a3	#base + (y + x)

IS_KEY_PRESSED:		#int read_key()





MAIN:

li $t4, 0x00FFFF00    # cor amarela no t4
sw $t4, 0($v0)        # armazena a cor amarela no endereço que calculamos


