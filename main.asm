;
; primeira_avaliacao_mic_mic.asm
;
; Created: 30/12/2021 09:54:37
; Author : Bruno Martins

start:
    LDI R16, 0x00 ; armazena o resultado a ser armazenado na memória.
	MOV R0, R16 ; move o conteúdo do registrador R16 para R0
	LDI R16, 0x02 ; b = 2.
	MOV R1, R16 ;  move o conteúdo do registrador R16 para R1
	LDI R16, 0x05 ; a = 5.
	MOV R2, R16 ; move o conteúdo do registrador R15 para R2
	LDI R16, 0x11 ; m = 17.
	MOV R3, R16 ; move o conteúdo do registrador R16 para R3
	LDI R16, 0x00 ; inicializa R4 em zero, R4 = n.
	MOV R4, R16; move o conteúdo do registrador R16 para R4
	LDI R26, 0x84 ; carrega o low-byte de X com 0x084
	LDI R27, 0x03 ; carrega o high-byte de X com 0x03
	LDI R16, 0x00 ; armazena o resultado da multiplicação 5 * n
	MOV R6, R16; move o conteúdo do registrador R16 para R6
	ST X+, R1 ; resultado trivial x[0] = 2, armazena o resultado indiretamente em 0x384.
    RJMP store_data ; chama a rotina para realização de cálculo envolvendo outras posições.
store_data:
	INC R4 ; incrementa n.
	CP R4, R3 ; compara o conteúdo dos registradores R4 e R3.
	BRGE sum_result ; se n >= m, termina de preencher as posições e realiza a soma.
	RCALL multiply_by_5 ; realiza a multiplicação 5 * n.
	ADD R0, R6; R0 = 5 * n.
	ADD R0, R1; R0 = 5 * n + 2.
	ST X+, R0 ; pré-incrementa X e armazena o resultado na memória.
	CLR R0 ; limpa R0 para novos resultados.
	CLR R6 ; limpa R6 para uma nova multiplicação.
	RJMP store_data ; caso n < m, reexecuta os passos.
multiply_by_5:
	LDI R17, 0x00 ; inicializa o contador em 0.
	RCALL loop ; chama um loop para calcular a multiplicação.
	RET ; retorna o resultado da multiplicação.
loop:
	INC R17 ; R17 = R7 + 1.
	ADD R6, R2 ; R6 = R6 + 5.
	CP R17, R4 ; verifica se o código foi executado n vezes.
	BRNE loop ; se R7 != N, reexecuta o loop até finalizar.
	RET ; senão, retorna para a rotina anterior.
sum_result:
	LDI R16, 0x00 ; registrador sentinela para controlar as iterações do loop.
	LDI R17, 0x11 ; limite superior do loop.
	LDI R19, 0x00 ; armazena o byte inferior da soma 
	LDI R20, 0x00 ; armazena o byte superior da soma
	LDI R26, 0x84 ; carrega o low-byte de X com 0x084.
	LDI R27, 0x03 ; carrega o high-byte de X com 0x03.
	LDI R28, 0x00 ; carrega o low-byte de Y com 0x00.
	LDI R29, 0x00 ; carrega o high-byte de Y com 0x00.
	RCALL loop_sum ;  entra em um loop para calcular a soma 
	STS 0x8FE, R28 ; armazena o low-byte de Y na penúltima posição da SRAM.
	STS 0x8FF, R29 ; armazena o high-byte de Y na última posição da SRAM.
	RJMP end ; finaliza o programa entrando em um laço infinito.
loop_sum:
	INC R16 ; realiza uma iteração do loop
	LD R18, X+ ; carrega em R18 o conteúdo do endereço de memória.
	ADD R19, R18 ; R19 = R19 + R18
	ADC R20, R20 ; R20 = R20 + carry
	ADD R28, R19 ; R28 = R28 + R19
	ADC R29, R20 ; R29 = R29 + R20 + carry 
	CLR R19 ; limpa o registrador auxiliar R19
	CLR R20 ; limpa o registrador auxiliar R20
	CP R16, R17 ; compara R16 e R17.
	BRNE loop_sum ; se R16 != R17 , continua o loop.
	RET ; caso contrário, retorna para onde a rotina foi chamada.
end:
	RJMP end