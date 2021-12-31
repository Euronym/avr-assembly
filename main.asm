;
; primeira_avaliacao_mic_mic.asm
;
; Created: 30/12/2021 09:54:37
; Author : Bruno Martins
start:
    LDI R16, 0x00 ; armazena o resultado a ser armazenado na mem�ria.
	MOV R0, R16 ; move o conte�do do registrador R16 para R0
	LDI R16, 0x02 ; b = 2.
	MOV R1, R16 ;  move o conte�do do registrador R16 para R1
	LDI R16, 0x05 ; a = 5.
	MOV R2, R16 ; move o conte�do do registrador R15 para R2
	LDI R16, 0x11 ; m = 17.
	MOV R3, R16 ; move o conte�do do registrador R16 para R3
	LDI R16, 0x00 ; inicializa R4 em zero, R4 = n.
	MOV R4, R16; move o conte�do do registrador R16 para R4
	LDI R26, 0x84 ; carrega o low-byte de X com 0x084
	LDI R27, 0x03 ; carrega o high-byte de X com 0x03
	LDI R16, 0x00 ; armazena o resultado da multiplica��o 5 * n
	MOV R6, R16; move o conte�do do registrador R16 para R6
	ST X+, R1 ; resultado trivial x[0] = 2, armazena o resultado indiretamente em 0x384.
    RJMP store_data ; chama a rotina para realiza��o de c�lculo envolvendo outras posi��es.
store_data:
	INC R4 ; incrementa n.
	CP R4, R3 ; compara o conte�do dos registradores R4 e R3.
	BRGE sum_result ; se n >= m, termina de preencher as posi��es e realiza a soma.
	RCALL multiply_by_5 ; realiza a multiplica��o 5 * n.
	ADD R0, R6; R0 = 5 * n.
	ADD R0, R1; R0 = 5 * n + 2.
	ST X+, R0 ; pr�-incrementa X e armazena o resultado na mem�ria.
	CLR R0 ; limpa R0 para novos resultados.
	CLR R6 ; limpa R6 para uma nova multiplica��o.
	RJMP store_data ; caso n < m, reexecuta os passos.
multiply_by_5:
	LDI R17, 0x00 ; inicializa o contador em 0.
	RCALL loop ; chama um loop para calcular a multiplica��o.
	RET ; retorna o resultado da multiplica��o.
	loop:
		INC R17 ; R17 = R7 + 1.
		ADD R6, R2 ; R6 = R6 + 5.
		CP R17, R4 ; verifica se o c�digo foi executado n vezes.
		BRNE loop ; se R7 != N, reexecuta o loop at� finalizar.
		RET ; sen�o, retorna para a rotina anterior.
sum_result:
	LDI R16, 0x00
	LDI R17, 0x10
	LDI R26, 0x84 ; carrega o low-byte de X com 0x084.
	LDI R27, 0x03 ; carrega o high-byte de X com 0x03.
	LDI R28, 0x00 ; carrega o low-byte de Y com 0x00.
	LDI R29, 0x00 ; carrega o high-byte de Y com 0x00.
	RCALL loop_sum ;  entra em um loop para calcular a soma 
	STS 0x8FE, R28 ; armazena o low-byte de Y na pen�ltima posi��o.
	STS 0x8FF, R29 ; armazena o high-byte de Y na �ltima posi��o.
	RJMP end ; finaliza o programa entrando em um la�o infinito.
	loop_sum:
		INC R16
		LD R18, X+ ; carrega em R18 o conte�do do endere�o de mem�ria.
		ADD Y, R18; Y = Y + R18.
		CP R16, R17 ; compara R16 e R17.
		BRNE loop_sum ; se R16 != R17 , continua o loop.
		RET ; caso contr�rio, retorna para onde a rotina foi chamada.
end:
	RJMP end