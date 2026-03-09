# Jogo da Cobrinha (Snake) para MIPS MARS
# Configurações:
# - Display: Bitmap Display 16x16, tamanho 256x256
# - Keyboard MMIO Simulator para entrada
# 
# Autor: Adaptado do código C fornecido
# Data: 2024

.data
    # Endereços de memória mapeada
    .eqv    BASE_ADDRESS    0x10008000    # Endereço base do Bitmap Display
    .eqv    KEYBOARD_CTRL   0xFFFF0000    # Controle do teclado
    .eqv    KEYBOARD_DATA   0xFFFF0004    # Dado do teclado
    
    # Cores (formato 0x00RRGGBB)
    .eqv    COR_FUNDO       0x00000000    # Preto
    .eqv    COR_COBRA       0x00FFFFFF    # Branco
    .eqv    COR_COMIDA      0x00FF0000    # Vermelho
    
    # Tamanhos
    .eqv    TAMANHO_GRADE   16            # Grade 16x16
    .eqv    TAMANHO_CELULA  16            # 16 pixels por célula
    .eqv    LARGURA_TELA    256           # 16 * 16
    .eqv    ALTURA_TELA     256           # 16 * 16
    
    # Teclas de controle (ASCII)
    .eqv    TECLA_W         0x77          # w minúsculo
    .eqv    TECLA_A         0x61          # a minúsculo
    .eqv    TECLA_S         0x73          # s minúsculo
    .eqv    TECLA_D         0x64          # d minúsculo
    .eqv    TECLA_W_MAIUS   0x57          # W maiúsculo
    .eqv    TECLA_A_MAIUS   0x41          # A maiúsculo
    .eqv    TECLA_S_MAIUS   0x53          # S maiúsculo
    .eqv    TECLA_D_MAIUS   0x44          # D maiúsculo
    
    # Direções
    .eqv    DIR_CIMA        0
    .eqv    DIR_BAIXO       1
    .eqv    DIR_ESQUERDA    2
    .eqv    DIR_DIREITA     3
    
    # Variáveis do jogo
    x_cobra:        .word 7                # Posição x da cobra
    y_cobra:        .word 7                # Posição y da cobra
    x_comida:       .word 5                # Posição x da comida
    y_comida:       .word 5                # Posição y da comida
    direcao_atual:  .word DIR_DIREITA      # Direção atual
    direcao_prox:   .word DIR_DIREITA      # Próxima direção
    pontuacao:      .word 0                # Pontuação atual
    delay:          .word 256              # Delay entre movimentos
    tecla_pressionada: .byte 0              # Última tecla pressionada
    tecla_disponivel:  .byte 0              # Flag indicando tecla disponível
    
    # Mensagens
    msg_inicio:     .asciiz "=== JOGO DA COBRINHA ===\n"
    msg_controles:  .asciiz "Controles: W (cima), A (esquerda), S (baixo), D (direita)\n"
    msg_pontuacao:  .asciiz "Pontuação: "
    msg_fim:        .asciiz "\nFIM DE JOGO! Pontuação final: "
    msg_nova_linha: .asciiz "\n"
    
.text
.globl main

##############################################################################
# Função: main
# Descrição: Função principal do jogo
##############################################################################
main:
    # Prólogo - salva $ra na pilha
    addiu   $sp, $sp, -4
    sw      $ra, 0($sp)
    
    # Inicialização
    jal     inicializar_jogo
    
    # Loop principal do jogo
loop_principal:
    # Verifica entrada do teclado (não bloqueante)
    jal     ler_teclado
    
    # Atualiza direção baseada na tecla
    jal     processar_tecla
    
    # Move a cobra
    jal     mover_cobra
    
    # Desenha tudo
    jal     desenhar_tela
    
    # Delay
    jal     aplicar_delay
    
    # Verifica se comeu comida
    jal     verificar_comida
    
    # Loop infinito
    j       loop_principal
    
    # Fim (nunca deve chegar aqui)
    lw      $ra, 0($sp)
    addiu   $sp, $sp, 4
    jr      $ra

##############################################################################
# Função: inicializar_jogo
# Descrição: Inicializa variáveis e desenha estado inicial
##############################################################################
inicializar_jogo:
    # Prólogo
    addiu   $sp, $sp, -4
    sw      $ra, 0($sp)
    
    # Limpa a tela
    jal     limpar_tela
    
    # Mostra mensagens iniciais
    li      $v0, 4
    la      $a0, msg_inicio
    syscall
    
    li      $v0, 4
    la      $a0, msg_controles
    syscall
    
    # Posiciona cobra no centro
    li      $t0, 7
    sw      $t0, x_cobra
    sw      $t0, y_cobra
    
    # Gera comida em posição aleatória
    jal     gerar_posicao_comida
    
    # Desenha estado inicial
    jal     desenhar_tela
    
    # Epílogo
    lw      $ra, 0($sp)
    addiu   $sp, $sp, 4
    jr      $ra

##############################################################################
# Função: limpar_tela
# Descrição: Preenche toda a tela com a cor de fundo
##############################################################################
limpar_tela:
    # Prólogo
    addiu   $sp, $sp, -4
    sw      $ra, 0($sp)
    
    li      $t0, BASE_ADDRESS        # Endereço base
    li      $t1, 0                    # Contador
    li      $t2, 256                  # Total de pixels (16x16)
    
limpar_loop:
    beq     $t1, $t2, limpar_fim
    
    # Escreve cor de fundo
    li      $t3, COR_FUNDO
    sw      $t3, 0($t0)
    
    addiu   $t0, $t0, 4               # Próximo pixel
    addiu   $t1, $t1, 1                # Incrementa contador
    j       limpar_loop
    
limpar_fim:
    lw      $ra, 0($sp)
    addiu   $sp, $sp, 4
    jr      $ra

##############################################################################
# Função: desenhar_tela
# Descrição: Desenha a cobra e a comida na tela
##############################################################################
desenhar_tela:
    # Prólogo
    addiu   $sp, $sp, -12
    sw      $ra, 8($sp)
    sw      $s0, 4($sp)
    sw      $s1, 0($sp)
    
    # Limpa a tela primeiro
    jal     limpar_tela
    
    # Desenha a cobra
    lw      $a0, x_cobra
    lw      $a1, y_cobra
    li      $a2, COR_COBRA
    jal     desenhar_pixel
    
    # Desenha a comida
    lw      $a0, x_comida
    lw      $a1, y_comida
    li      $a2, COR_COMIDA
    jal     desenhar_pixel
    
    # Mostra pontuação no console
    li      $v0, 4
    la      $a0, msg_pontuacao
    syscall
    
    li      $v0, 1
    lw      $a0, pontuacao
    syscall
    
    li      $v0, 4
    la      $a0, msg_nova_linha
    syscall
    
    # Epílogo
    lw      $s1, 0($sp)
    lw      $s0, 4($sp)
    lw      $ra, 8($sp)
    addiu   $sp, $sp, 12
    jr      $ra

##############################################################################
# Função: desenhar_pixel
# Descrição: Desenha um pixel na posição (x, y) com a cor especificada
# Parâmetros:
#   $a0: coordenada x
#   $a1: coordenada y
#   $a2: cor
##############################################################################
desenhar_pixel:
    # Calcula endereço: base + (y * 16 + x) * 4
    li      $t0, BASE_ADDRESS
    li      $t1, TAMANHO_GRADE        # 16
    
    # endereço = base + (y * 16 + x) * 4
    mul     $t2, $a1, $t1              # y * 16
    addu    $t2, $t2, $a0              # + x
    sll     $t2, $t2, 2                # * 4
    addu    $t0, $t0, $t2              # + base
    
    # Escreve a cor
    sw      $a2, 0($t0)
    
    jr      $ra

##############################################################################
# Função: ler_teclado
# Descrição: Lê teclado de forma não bloqueante usando MMIO
##############################################################################
ler_teclado:
    # Verifica se há tecla disponível
    lui     $t0, 0xFFFF                # Endereço base do controle
    lw      $t1, 0($t0)                # Lê registro de controle
    
    andi    $t1, $t1, 1                # Verifica bit 0
    beq     $t1, $zero, ler_teclado_fim
    
    # Lê a tecla
    lw      $t2, 4($t0)                # Lê dado do teclado
    sb      $t2, tecla_pressionada     # Salva tecla
    li      $t3, 1
    sb      $t3, tecla_disponivel
    
ler_teclado_fim:
    jr      $ra

##############################################################################
# Função: processar_tecla
# Descrição: Processa a tecla pressionada e atualiza a direção
##############################################################################
processar_tecla:
    # Prólogo
    addiu   $sp, $sp, -4
    sw      $ra, 0($sp)
    
    # Verifica se há tecla disponível
    lb      $t0, tecla_disponivel
    beq     $t0, $zero, processar_fim
    
    # Limpa flag
    sb      $zero, tecla_disponivel
    
    # Lê tecla
    lb      $t1, tecla_pressionada
    
    # Verifica qual tecla foi pressionada
    beq     $t1, TECLA_W, direcao_cima
    beq     $t1, TECLA_W_MAIUS, direcao_cima
    beq     $t1, TECLA_S, direcao_baixo
    beq     $t1, TECLA_S_MAIUS, direcao_baixo
    beq     $t1, TECLA_A, direcao_esquerda
    beq     $t1, TECLA_A_MAIUS, direcao_esquerda
    beq     $t1, TECLA_D, direcao_direita
    beq     $t1, TECLA_D_MAIUS, direcao_direita
    j       processar_fim
    
direcao_cima:
    li      $t0, DIR_CIMA
    sw      $t0, direcao_prox
    j       processar_fim
    
direcao_baixo:
    li      $t0, DIR_BAIXO
    sw      $t0, direcao_prox
    j       processar_fim
    
direcao_esquerda:
    li      $t0, DIR_ESQUERDA
    sw      $t0, direcao_prox
    j       processar_fim
    
direcao_direita:
    li      $t0, DIR_DIREITA
    sw      $t0, direcao_prox
    
processar_fim:
    lw      $ra, 0($sp)
    addiu   $sp, $sp, 4
    jr      $ra

##############################################################################
# Função: mover_cobra
# Descrição: Move a cobra na direção atual com wrap-around
##############################################################################
mover_cobra:
    # Prólogo
    addiu   $sp, $sp, -8
    sw      $ra, 4($sp)
    sw      $s0, 0($sp)
    
    # Atualiza direção atual com a próxima direção
    lw      $t0, direcao_prox
    sw      $t0, direcao_atual
    
    # Carrega posição atual
    lw      $t0, x_cobra
    lw      $t1, y_cobra
    
    # Move baseado na direção
    lw      $t2, direcao_atual
    
    beq     $t2, DIR_CIMA, mover_cima
    beq     $t2, DIR_BAIXO, mover_baixo
    beq     $t2, DIR_ESQUERDA, mover_esquerda
    beq     $t2, DIR_DIREITA, mover_direita
    j       mover_fim
    
mover_cima:
    addiu   $t1, $t1, -1
    bltz    $t1, wrap_cima
    j       atualizar_posicao
    
wrap_cima:
    li      $t1, 15
    j       atualizar_posicao
    
mover_baixo:
    addiu   $t1, $t1, 1
    li      $t2, 16
    beq     $t1, $t2, wrap_baixo
    j       atualizar_posicao
    
wrap_baixo:
    li      $t1, 0
    j       atualizar_posicao
    
mover_esquerda:
    addiu   $t0, $t0, -1
    bltz    $t0, wrap_esquerda
    j       atualizar_posicao
    
wrap_esquerda:
    li      $t0, 15
    j       atualizar_posicao
    
mover_direita:
    addiu   $t0, $t0, 1
    li      $t2, 16
    beq     $t0, $t2, wrap_direita
    j       atualizar_posicao
    
wrap_direita:
    li      $t0, 0
    
atualizar_posicao:
    # Salva nova posição
    sw      $t0, x_cobra
    sw      $t1, y_cobra
    
mover_fim:
    lw      $s0, 0($sp)
    lw      $ra, 4($sp)
    addiu   $sp, $sp, 8
    jr      $ra

##############################################################################
# Função: verificar_comida
# Descrição: Verifica se a cobra comeu a comida
##############################################################################
verificar_comida:
    # Prólogo
    addiu   $sp, $sp, -4
    sw      $ra, 0($sp)
    
    # Carrega posições
    lw      $t0, x_cobra
    lw      $t1, y_cobra
    lw      $t2, x_comida
    lw      $t3, y_comida
    
    # Compara posições
    bne     $t0, $t2, verificar_fim
    bne     $t1, $t3, verificar_fim
    
    # Comeu comida!
    
    # Incrementa pontuação
    lw      $t4, pontuacao
    addiu   $t4, $t4, 1
    sw      $t4, pontuacao
    
    # Aumenta velocidade (diminui delay)
    lw      $t5, delay
    srl     $t5, $t5, 1                # Divide por 2
    sw      $t5, delay
    
    # Verifica se atingiu pontuação máxima (5)
    li      $t6, 5
    beq     $t4, $t6, fim_de_jogo
    
    # Gera nova comida
    jal     gerar_posicao_comida
    
verificar_fim:
    lw      $ra, 0($sp)
    addiu   $sp, $sp, 4
    jr      $ra

##############################################################################
# Função: gerar_posicao_comida
# Descrição: Gera posição aleatória para a comida
##############################################################################
gerar_posicao_comida:
    # Prólogo
    addiu   $sp, $sp, -4
    sw      $ra, 0($sp)
    
    # Gera posição x aleatória
    li      $v0, 42                    # Serviço para número aleatório
    li      $a1, 16                     # Limite superior
    syscall
    
    sw      $a0, x_comida               # Salva x da comida
    
    # Gera posição y aleatória
    li      $v0, 42
    li      $a1, 16
    syscall
    
    sw      $a0, y_comida               # Salva y da comida
    
    # Verifica se comida não está na posição da cobra
    lw      $t0, x_cobra
    lw      $t1, x_comida
    bne     $t0, $t1, gerar_fim
    
    lw      $t0, y_cobra
    lw      $t1, y_comida
    bne     $t0, $t1, gerar_fim
    
    # Comida na cobra - gera nova posição
    j       gerar_posicao_comida
    
gerar_fim:
    lw      $ra, 0($sp)
    addiu   $sp, $sp, 4
    jr      $ra

##############################################################################
# Função: aplicar_delay
# Descrição: Aplica delay entre movimentos
##############################################################################
aplicar_delay:
    # Prólogo
    addiu   $sp, $sp, -8
    sw      $s0, 4($sp)
    sw      $s1, 0($sp)
    
    lw      $s0, delay                   # Carrega tempo de delay
    
delay_loop:
    beqz    $s0, delay_fim
    
    # Loop interno para delay mais preciso
    li      $s1, 1000
delay_interno:
    beqz    $s1, delay_continue
    addiu   $s1, $s1, -1
    j       delay_interno
    
delay_continue:
    addiu   $s0, $s0, -1
    j       delay_loop
    
delay_fim:
    lw      $s1, 0($sp)
    lw      $s0, 4($sp)
    addiu   $sp, $sp, 8
    jr      $ra

##############################################################################
# Função: fim_de_jogo
# Descrição: Mostra mensagem de fim de jogo e encerra
##############################################################################
fim_de_jogo:
    # Mostra mensagem de fim
    li      $v0, 4
    la      $a0, msg_fim
    syscall
    
    li      $v0, 1
    lw      $a0, pontuacao
    syscall
    
    # Encerra programa
    li      $v0, 10
    syscall