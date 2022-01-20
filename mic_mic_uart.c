uint8_t uartTxOk  (void);        //verifica se dado pode ser enviado
void    uartTx    (uint8_t dado);//Envia um byte pela porta uart
uint8_t uartRxOk  (void);        //verifica se uart possui novo dado
uint8_t uartRx    ();            //Ler byte recebido na porta uart
void    uartString(char *c);     //Envia string. Ultimo valor 0


// mapeamento:
// - PB3 = LED VERDE
// - PB4 = LED AMARELO
// - PB5 = LED VERMELHO
int main (void)
{ 
	uint8_t  cont = 0; // variável sentinela para controlar as execuções do laço
	uint8_t  dado_rx; //variável para armazenar dado recebido
	DDRB  = 0b0111111; //Pinos de PB entrada, exceto PB5 (saída). 00111111
	uartBegin(BAUD, F_CPU);//inicializar uart
	uartString("pressione b para iniciar o semáforo: \r\n"); // sinaliza ao usuário o botão a ser pressionado.
	while(1){
		if(uartRxOk()){
			dado_rx = uartRx(); // lê os dados e passa à variável.
			if(dado_rx == 'b'){ // se o usuário digitou b, execute.
				while(1){ 
					cont++; // incrementa a variável sentinela.
					PORTB = 0b0100000; // acende vermelho
					_delay_ms(1000); // delay de 1 segundo entre cada LED.
					PORTB = 0b0010000; // acende amarelo
					_delay_ms(1000);
					PORTB = 0b0001000; // acende verde
					_delay_ms(1000);
					if(cont >= 5){ // se o led executou 5 vezes, finalize.
						uartString("execução finalizada, pressione b novamente. ");
						cont = 0; // zera o valor da variável contadora.
						break; // quebra o laço e pede ao usuário uma nova en
					}
				}
			}
		}			
	}
}

//inicializa a porta de comunicação uart do ATmega328
void uartBegin(uint32_t baud, uint32_t freq_cpu)
{ uint16_t myubrr = freq_cpu/16/baud-1;//calcula valor do registrador UBRR
	UBRR0H = (uint8_t)(myubrr >> 8);     //ajusta a taxa de transmissão
	UBRR0L = (uint8_t)myubrr;
	UCSR0A = 0;//desabilitar velocidade dupla (no Arduino é habilitado por padrão)
	UCSR0B = (1<<RXEN0)|(1<<TXEN0);//habilita a transmissão e recepção. Sem interrupcao
	UCSR0C = (1<<UCSZ01)|(1<<UCSZ00);//assíncrono, 8 bits, 1 bit de parada, sem paridade
}



//verifica se novo dado pode ser enviado pela UART
//retorna valor 32 se novo dado pode ser enviado. Zero se não.
uint8_t uartTxOk (void)
{ return (UCSR0A & (1<<UDRE0));}


//Envia um byte pela porta uart
void uartTx(uint8_t dado)
{ UDR0 = dado;//envia dado
}


//verifica se UART possui novo dado
//retorna valor 128 se existir novo dado recebido. Zero se não.
uint8_t uartRxOk (void)
{ return (UCSR0A & (1<<RXC0));
}


//Ler byte recebido na porta uart
uint8_t uartRx()
{ return UDR0; //retorna o dado recebido
}


//Envia uma string pela porta uart. Ultimo valor da string deve ser 0.
void uartString(char *c)
{ for (; *c!=0; c++)
	{ while (!uartTxOk());//aguarda último dado ser enviado
		uartTx(*c);
	}
}



