;EL MEJOR TP DE LA HISTORIA
    
	    LIST P=16F887		
	    #include <p16f887.inc>
	
	    __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_OFF
    
NUMAL	    EQU 0x7F	; Numero aleatorio generado por el ADC
POSINICIAL  EQU 0x7E	; Posicion de memoria donde se guarda la direccion de memoria donde empieza la secuencia
POSFINAL    EQU 0x7D	; Posicion de memoria donde se guarda el último espacio de memoria utilizado para la secuencia
 
INDICE	    EQU 0x7A ; índice de tecla pulsada (0?15)
COL	    EQU 0x7B ; en que columna estoy (1-4)
COLMASK	    EQU 0x7C ; Mascara de columna

BANDERA_JUG EQU 0x79
 
PARTIDA	    EQU 0x78

 
	    ORG 0x00
	    GOTO START

	    ORG 0x04
	    GOTO ISR
    
START:
    ; BANCO 3
    ; Configuraciones: ANSEL y ANSELH. Se configura el puerto A0 como entrada analógia
    ; El resto de puertos como digitales
	    BANKSEL ANSEL
	    CLRF ANSEL	    
	    CLRF ANSELH
	    BSF ANSEL,0    ;Configuro la unica entrada analogica. El resto digital
    
    
    ; BANCO 2
    ; Configuraciones: ninguna
    
    ; BANCO 1
    ; Configuraciones: TRISA, TRISB, TRISC, TRISD, TRISE, IOCB, ADCON1 ... (seguramente el puerto serial)
    ; Se configura parte del puerto A como entrada (A0) y el resto como salidas.
    ; Se configura todo el puerto B como entrada (teclado)
    ; Se configuran los puertos C, D y E como salidas.
    ; Se configura la mitad del puerto B para interrupcion por cambio.
    ; Se configura una parte de las caracteristicas del ADC: Justifiacion a la derecha, voltajes de referencia
	    BANKSEL TRISA
	    MOVLW 0x01	     
	    MOVWF TRISA	    ; 0000 0001 - De RA1 a RA7 como salidas RA4-RA7 display. RA0 como entrada

	    MOVLW 0x0F
	    MOVWF TRISB	    ; 0000 1111 - RB0 a RB3 entradas. RB4 a RB7 salidas

	    CLRF TRISC	    ; 0000 0000 - C0-C3 Salidas para display
	    CLRF TRISD	    ; 0000 0000 - Salidas para leds
	    CLRF TRISE	    ; 0000 0000 E0-E1 mux de displays.

	    MOVLW 0x0F	    ; 0000 1111 - RB0 a RB3 con interrupcion por cambio
	    MOVWF IOCB

	    BSF ADCON1,7   ; Justificado a la derecha
	    BCF ADCON1,5   ; Voltaje negativo de referencia igual que el PIC
	    BCF ADCON1,4   ; Voltaje positivo de referencia igual que el PIC (-----por ahora--------)

	    MOVLW   0x26              ; BRGH=1, enable TX y Serial
	    MOVWF   TXSTA

	    MOVLW   0x19                ; Baud Rate 9600 con Fosc=4MHz (SPBRG=25)
	    MOVWF   SPBRG
	    CLRF    SPBRGH 
    
    ; BANCO 0
    ; Configuraciones: PORTA, PORTB, PORTC, PORTD, PORTE, INTCON, OPTION_REG, ADCON0 ... (y lo del puerto serie)
    ; Todos los puertos como salida se setean en cero
    ; Se activan las interrupciones por cambio del puerto B
    ; Se activan las Pull-Up
    ; Se enciende el ADC (ADON)
    ; Se setea el canal (A0)
    ; Se setea el clock del ADC
    ; -----La interrupcion general se activa despues del saludo---------
	    BANKSEL PORTA
	    CLRF PORTA
	    CLRF PORTB
	    CLRF PORTC
	    CLRF PORTD
	    CLRF PORTE
	    BSF ADCON0,0	    ; Activo ADC. Configuro canal 0. Clock ADC = Fosc/2 (por defecto 0000 0000)
	    BSF	RCSTA,7

LIMPIAR_RAM:
	    CLRF FSR     ; Inicializa el puntero en 0x00
	    MOVF FSR,W
	    ADDLW 0x20          ; Offset para llegar a 0x20
	    MOVWF FSR           ; FSR apunta a dirección actual
	    
LIMPIAR_BUCLE:
	    CLRF INDF           ; Limpia contenido apuntado
	    MOVF FSR,W         ; Recupera FSR en W
	    SUBLW 0x7F          ; ¿Llegamos a 0x7F?
	    BTFSC STATUS,Z
	    GOTO LIMPIAR_FIN
	    INCF FSR,F         ; Siguiente dirección
	    GOTO LIMPIAR_BUCLE

LIMPIAR_FIN:    
    ;CONFIGURACION DE VALORES PARA VARIABLES
	    MOVLW 0x20
	    MOVWF POSFINAL
	    MOVWF POSINICIAL
    
SALUDO:
PARPADEO:
	    MOVLW 0xFF
	    MOVWF PORTD
	    CALL DELAY_200MS
	    CALL DELAY_200MS
	    MOVLW 0x00
	    MOVWF PORTD
	    CALL DELAY_200MS
	    CALL DELAY_200MS
	    MOVLW 0xFF
	    MOVWF PORTD
	    CALL DELAY_200MS
	    CALL DELAY_200MS
	    MOVLW 0x00
	    MOVWF PORTD
	    CALL DELAY_200MS
	    CALL DELAY_200MS
	    MOVLW 0xFF
	    MOVWF PORTD
	    CALL DELAY_200MS
	    CALL DELAY_200MS
	    MOVLW 0x00
	    MOVWF PORTD
	    CALL DELAY_200MS
	    CALL DELAY_200MS
	    MOVLW 0x01
	    MOVWF PORTD
	    
CORTINA_LEFT:
	    CALL DELAY_200MS
	    CALL DELAY_200MS
	    RLF PORTD, 1
	    BTFSS STATUS, 0
	    GOTO CORTINA_LEFT
	    MOVLW 0x80
	    MOVWF PORTD
	    BCF STATUS, 0
    
CORTINA_RIGHT:
	    CALL DELAY_200MS
	    CALL DELAY_200MS
	    RRF PORTD, 1
	    BTFSS STATUS, 0
	    GOTO CORTINA_RIGHT
	    CLRF PORTD
	    CALL DELAY_200MS
	    CALL DELAY_200MS
	    GOTO MOSTRAR_SEC 
    
; -------------------------------
; |         TABLA LEDS          |
; -------------------------------
TABLA_LEDS:
	    ADDWF PCL,1
	    RETLW 0X01	
	    RETLW 0X02
	    RETLW 0X04
	    RETLW 0X08
	    RETLW 0X10
	    RETLW 0X20
	    RETLW 0X40
	    RETLW 0X80
   
; -------------------------------
; |       TABLA DISPLAYS        |
; -------------------------------
TABLA_SEGMENTOS2:
	    ADDWF PCL, 1
	    RETLW 0xF1 ; 0 ;1111 0001
	    RETLW 0xFF ; 1
	    RETLW 0xF2 ; 2
	    RETLW 0xF6 ; 3
	    RETLW 0xFC ; 4
	    RETLW 0xF4 ; 5
	    RETLW 0xF0 ; 6
	    RETLW 0xFF ; 7
	    RETLW 0xF0 ; 8
	    RETLW 0xFC ; 9
    
TABLA_SEGMENTOS1:
	    ADDWF PCL, 1
	    RETLW 0x8F ; 0 ;1000 1111
	    RETLW 0xCF ; 1
	    RETLW 0xAF ; 2
	    RETLW 0x8F ; 3
	    RETLW 0xCF ; 4
	    RETLW 0x9F ; 5
	    RETLW 0x9F ; 6
	    RETLW 0x8F ; 7
	    RETLW 0x8F ; 8
	    RETLW 0x8F ; 9
    
; -------------------------------
; |         ESTADO 1            |
; -------------------------------
; Se genera el valor aleatorio y se muestra la secuencia
MOSTRAR_SEC:
	    BCF INTCON,7
	    BCF BANDERA_JUG,0
	    CALL NUMRAND
	    CALL GUARDAR_DATO
	    CALL MOSTRAR_LEDS
	    CALL SUMAR_PARTIDA
	    MOVLW 0xFF
	    MOVWF PORTD
	    CALL DELAY_200MS
	    CLRF PORTD
	    CALL DELAY_200MS
	    BTFSS PORTB,0
	    NOP
	    BCF INTCON,0   	; Limpiás la bandera de interrupción por cambio
	    BSF INTCON,3   ; Habilitás la interrupción por cambio en RB4?RB7
	    BSF INTCON,7    ; Ahora sí activás interrupciones globales
	    MOVF POSINICIAL,0
	    MOVWF FSR
	    GOTO JUGADOR_JUGANDO
   
; -------------------------------
; |         ESTADO 2            |
; -------------------------------
; Queda a la espera de que el jugador toque un boton. 
; Y salta a la rutina de interrupcion que revisa si es correcto
JUGADOR_JUGANDO:
	    CALL MUX_DISPLAYS
	    BTFSS BANDERA_JUG,0
	    GOTO JUGADOR_JUGANDO
	    GOTO MOSTRAR_SEC
    
; -------------------------------
; |         ESTADO 3            |
; -------------------------------
; Gameover
GAMEOVER:
    
ENVIAR_PARTIDA_USART:
	    MOVLW    0x0F
	    ANDWF    PARTIDA,0        ; Cargar el valor de PARTIDA en W
	    ADDLW   0x30    
	    MOVWF   TXREG             ; Cargar W en TXREG
	    CALL    DELAY_20MS
    
LOOP_GAMEOVER:
	    CLRF PORTD
	    CALL DELAY_200MS
	    CALL DELAY_200MS
	    MOVLW 0xFF
	    MOVWF PORTD
	    CALL DELAY_200MS
	    CALL DELAY_200MS
	    GOTO LOOP_GAMEOVER
  
; -------------------------------
; |           ISR               |
; -------------------------------
ISR:
	    CALL ESCANEAR_TECLA
	    CALL VERIFICAR    
	    BCF INTCON,0
	    RETFIE

SUMAR_PARTIDA:
	    INCF PARTIDA,1
	    MOVF PARTIDA,0
	    ANDLW 0x0F        ; ¿Unidades >= 10?
	    SUBLW 0x0A
	    BTFSC STATUS,2
	    CALL AJUSTAR_BCD
	    ; Si PARTIDA >= 0x10 (decimal 16), reiniciar todo
	    MOVF PARTIDA,0
	    SUBLW 0x10
	    BTFSC STATUS,Z
	    CALL REINICIAR_PARTIDA
	    RETURN

AJUSTAR_BCD:
	    MOVLW 0x0A
	    SUBWF PARTIDA,1  ; Resto 10 a las unidades
	    MOVLW 0x10
	    ADDWF PARTIDA,1  ; Sumo 1 a las decenas
	    RETURN

REINICIAR_PARTIDA:
	    CLRF PARTIDA
	    MOVLW 0x20
	    MOVWF POSINICIAL
	    MOVWF POSFINAL
	    RETURN
    
ESCANEAR_TECLA:
	    CLRF  COL	    ; col 1
	    MOVLW 0xEF	    ; RB3 1110 1111
	    MOVWF COLMASK	    ; en alto
ESCANEAR_FILAS:		    ; detectar fila
	    CLRF  INDICE
	    MOVF  COLMASK, 0
	    MOVWF PORTB
	    BTFSS PORTB,3	    ; fila 1 en bajo?
	    GOTO  OFFSET_COL	    ; si -> offset=0
	    CALL  SUMO_4	    ; no -> Indice += 4, y sigo
	    BTFSS PORTB,2	    ; fila 2 en bajo?
	    GOTO  OFFSET_COL	    ; si -> offset=4
	    CALL  SUMO_4	    ; no -> Indice += 4, y sigo
	    BTFSS PORTB,1	    ; fila 3 en bajo?
	    GOTO  OFFSET_COL	    ; si -> offset=8	    
	    CALL  SUMO_4	    ; no -> Indice += 4, y sigo
	    BTFSS PORTB,0	    ; fila 4 en bajo?
	    GOTO  OFFSET_COL	    ; si -> offset=12
	    RLF   COLMASK	    ; no -> siguiente columna
	    MOVLW 0x01
	    ADDWF  COL,1	    ; 
	    MOVLW 0x04
	    SUBWF COL,0
	    BTFSS STATUS,2	    ; todas las columnas?
	    GOTO  ESCANEAR_FILAS; no -> seguimos
	    MOVLW 0xFF	    ; si -> volvemos
	    MOVF  INDICE,1	    ;	    con el indice en 0xFF
	    RETURN
	    
OFFSET_COL:
	    MOVF  COL,0
	    NOP
	    ADDWF INDICE,1
	    CALL WAIT_RELEASE
	    CALL DELAY_200MS
	    RETURN		    
    
SUMO_4:
	    MOVLW 0x04	    ; Sumo 4
	    ADDWF INDICE	    ; al indice
	    RETURN
    
WAIT_RELEASE:
	    CLRF PORTB
	    MOVF PORTB,0
	    ANDLW 0x0F
	    XORLW 0x0F
	    BTFSC STATUS,2
	    RETURN
	    GOTO WAIT_RELEASE
    
VERIFICAR:
	    MOVF INDICE,0
	    CALL TABLA_LEDS
	    SUBWF INDF,0    ;Verifico si son iguales - Guardo el resultado en W
	    BTFSS STATUS,2
	    GOTO GAMEOVER
	    INCF FSR,1
	    MOVF POSFINAL,0
	    SUBWF FSR,0
	    BTFSC STATUS,2
	    BSF BANDERA_JUG,0
	    RETURN
    
NUMRAND:
	    BSF ADCON0,1	; ADCON0, GO se inicia la conversion
	    BTFSC ADCON0,1	; ADCON0, DONE?
	    GOTO $-1
	    BANKSEL ADRESL	; El ADRESL está en el banco 1
	    MOVF ADRESL,0   
	    ANDLW 0X01
	    BANKSEL PORTA	; Vuelvo al banco 0
	    MOVWF NUMAL
	    BSF ADCON0,1	; ADCON0, GO se inicia la conversion
	    BTFSC ADCON0,1	; ADCON0, DONE?
	    GOTO $-1
	    BANKSEL ADRESL     
	    MOVLW 0X01
	    ANDWF ADRESL,1
	    BCF STATUS,0	; Se limpia el carry
	    RLF ADRESL,0	; Rotacion hacia la izquierda
	    BANKSEL PORTA
	    ADDWF NUMAL		; Se suma con variable NUMAL
	    BSF ADCON0,1	; ADCON0, GO se inicia la conversion
	    BTFSC ADCON0,1	; ADCON0, DONE?
	    GOTO $-1
	    BANKSEL ADRESL
	    MOVLW 0X01
	    ANDWF ADRESL,1
	    BCF STATUS,0	; Se limpia el carry
	    RLF ADRESL,1	; Rotacion hacia la izquierda
	    RLF ADRESL,0	; Rotacion hacia la izquierda
	    BANKSEL PORTA
	    ADDWF NUMAL		; Se suma con variable NUMAL
	    RETURN
    
GUARDAR_DATO:
	    MOVF POSFINAL,0
	    MOVWF FSR
	    INCF POSFINAL,1   ; La posicion final queda en el siguiente lugar vacio
	    MOVF NUMAL,0
	    CALL TABLA_LEDS
	    MOVWF INDF	    ; Cargo el valor codificado en la posicion apuntada por el FSR
	    RETURN
    
MOSTRAR_LEDS:
	    MOVF POSINICIAL,0	; Cargo el valor de la posicion inicial en w
	    MOVWF FSR		; Muevo el FSR a la posicion inicial
    
LED_LOOP:
	    MOVF INDF,0	; Cargo el valor de la posicion donde esta el FSR
	    MOVWF PORTD		; Muestro el valor por los leds
	    CALL DELAY_200MS	; Delay 
	    CALL DELAY_200MS	; Delay 
	    CALL DELAY_200MS
	    CALL DELAY_200MS
	    CLRF PORTD
	    CALL DELAY_200MS	; Delay de 1s
	    CALL DELAY_200MS	; Delay de 1s
	    CALL DELAY_200MS
	    CALL DELAY_200MS
	    INCF FSR, 1
	    MOVF POSFINAL,0	; Muevo a w la POSFINAL
	    SUBWF FSR,0	; ¿Son iguales?
	    BTFSC STATUS,2	; Si son iguales (zero = 1) entonces se acabo la secuencia y retorno.
	    RETURN
	    GOTO LED_LOOP
    
    ; Retardo de 20 ms usando Timer1
DELAY_20MS:
SETEAR_TIMER1:
    ; Configuración del Timer1
    ; Por defecto el T1CON es 0000 0000
    ; Eso es equivalente a:
    ;	*Preescaler 1:1
    ;	*Oscilador interno
    ;	*Sincronizacion activada pero no se utiliza porque no hay fuente externa
	    MOVLW 0xD8		; Precarga TMR1H
	    MOVWF TMR1H
	    MOVLW 0xF0		; Precarga TMR1L
	    MOVWF TMR1L
	    BCF PIR1,0		; Limpia la bandera de desbordamiento
	    BSF T1CON,0	; Activa Timer1
    
ESPERAR_DESBORDE:
	    BTFSS PIR1,0	; Espera el desbordamiento
	    GOTO ESPERAR_DESBORDE
	    BCF T1CON,0	; Detiene Timer1
	    RETURN
    
    ; Retardo de 200 ms llamando 10 veces a 20 ms
DELAY_200MS:
	    MOVLW 0x0A
	    MOVWF NUMAL
LOOP_200MS:
	    CALL DELAY_20MS
	    DECFSZ NUMAL,1
	    GOTO LOOP_200MS
	    RETURN

    ; Retardo de 1 segundo llamando 5 veces a 200 ms
DELAY_1S:
	    MOVLW 0x05
	    MOVWF NUMAL
LOOP_1S:
	    CALL DELAY_200MS
	    DECFSZ NUMAL,1
	    GOTO LOOP_1S
	    RETURN
    
MUX_DISPLAYS:
    ; Mostrar unidad
	    BCF PORTE,0        ; Apagar ambos display (RE1 en 1)
	    BCF PORTE,1        ; 
	    MOVF PARTIDA,0
	    ANDLW 0x0F
	    CALL TABLA_SEGMENTOS1
	    MOVWF PORTA
	    MOVF PARTIDA,0
	    ANDLW 0x0F
	    CALL TABLA_SEGMENTOS2
	    MOVWF PORTC
	    BSF PORTE,0        ; Apagar display 1
	    BCF PORTE,1
	    CALL DELAY_20MS
    ; Mostrar decena
	    BCF PORTE,0        ; Apagar display 1
	    BCF PORTE,1        ; Encender display 2
	    MOVF PARTIDA,0
	    ANDLW 0xF0         ; obtengo nibble alto
	    MOVWF NUMAL        ; lo guardo en NUMAL
	    BCF STATUS,0      ; limpio carry antes de rotar
	    RRF NUMAL          ; 4 desplazamientos a la derecha para traer decena al nibble bajo
	    RRF NUMAL
	    RRF NUMAL
	    RRF NUMAL
	    MOVF NUMAL,0
	    CALL TABLA_SEGMENTOS1
	    MOVWF PORTA
	    MOVF NUMAL,0
	    CALL TABLA_SEGMENTOS2
	    MOVWF PORTC
	    BCF PORTE,0        
	    BSF PORTE,1
	    CLRF NUMAL
	    CALL DELAY_20MS
	    RETURN
    
	    END