; Estados de los semaforos

SemaNorteSurVerde				EQU		0x20000000
SemaNorteSurAmarillo			EQU		0x20000004
SemaNorteSurRojo				EQU		0x20000008
SemaEsteOesteVerde				EQU		0x2000000C
SemaEsteOesteAmarillo			EQU		0x20000010
SemaEsteOesteRojo				EQU		0x20000014
SemaPeatonalNorteSurVerde		EQU		0x20000018
SemaPeatonalNorteSurRojo		EQU		0x2000001C
SemaPeatonalEsteOesteVerde		EQU		0x20000020
SemaPeatonalEsteOesteRojo		EQU		0x20000024
	
	PRESERVE8
    THUMB

    AREA RESET, DATA, READONLY

    EXPORT __Vectors

__Vectors    DCD 0x2000200
            DCD Reset_Handler

            ALIGN

            AREA MYCODE, CODE, READONLY
            ENTRY
            EXPORT Reset_Handler

;R0: Contador
;R1: Valor de memoria
;R2: Puntero

;R3: 1 si hay carro de Norte a Sur o viceversa, 0 si no hay.
;R4: 1 si hay carro de Este a Oeste o viceversa, 0 si no hay.
;R5: 1 si hay peaton de Norte a Sur o viceversa, 0 si no hay.
;R6: 1 si hay peaton de Este a Oeste o viceversa, 0 si no hay.

;R7: 1 si hay carros o peatones en todos los sentidos (caso extremo).

Reset_Handler
		
		MOV		R0,#0 ;contador empieza en 0
		MOV		R1,#0 ;ningun valor de memoria asignado todavía
		MOV		R2,#0 ;ningun puntero asignado todavía
		
		;Valores semaforo Norte Sur para carros:
		MOV		R1,#1 ;valor pivote del estado de semaforo a cambiar
		LDR		R2,=SemaNorteSurVerde ;estado semaforoNorteSurVerde = 1
		STR		R1, [R2] ;actualiza el estado R1 del semaforo al que apunta R2
		;LDR		R3, [R2]
		
		MOV		R1,#0 ;valor pivote del estado de semaforo a cambiar
		LDR		R2,=SemaNorteSurAmarillo ;estado SemaNorteSurAmarillo = 0
		STR		R1, [R2] ;actualiza el estado R1 del semaforo al que apunta R2
		
		MOV		R1,#0 ;valor pivote del estado de semaforo a cambiar
		LDR		R2,=SemaNorteSurRojo ;estado SemaNorteSurRojo = 0
		STR		R1, [R2] ;actualiza el estado R1 del semaforo al que apunta R2

		;Valores semaforo Este Oeste para carros:
		MOV		R1,#0 ;valor pivote del estado de semaforo a cambiar
		LDR		R2,=SemaEsteOesteVerde ;estado SemaEsteOesteVerde = 0
		STR		R1, [R2] ;actualiza el estado R1 del semaforo al que apunta R2
		
		MOV		R1,#0 ;valor pivote del estado de semaforo a cambiar
		LDR		R2,=SemaEsteOesteAmarillo ;estado SemaEsteOesteAmarillo = 0
		STR		R1, [R2] ;actualiza el estado R1 del semaforo al que apunta R2
		
		MOV		R1,#1 ;valor pivote del estado de semaforo a cambiar
		LDR		R2,=SemaEsteOesteRojo ;estado SemaEsteOesteRojo = 1
		STR		R1, [R2] ;actualiza el estado R1 del semaforo al que apunta R2
		
		;Valores semaforo peatonal Norte Sur
		MOV		R1,#1 ;valor pivote del estado de semaforo a cambiar
		LDR		R2,=SemaPeatonalNorteSurVerde ;estado SemaPeatonalNorteSurVerde = 1
		STR		R1, [R2] ;actualiza el estado R1 del semaforo al que apunta R2
		
		MOV		R1,#0 ;valor pivote del estado de semaforo a cambiar
		LDR		R2,=SemaPeatonalNorteSurRojo ;estado SemaPeatonalNorteSurRojo = 0
		STR		R1, [R2] ;actualiza el estado R1 del semaforo al que apunta R2
		
		;Valores semaforo peatonal Este Oeste
		MOV		R1,#0 ;valor pivote del estado de semaforo a cambiar
		LDR		R2,=SemaPeatonalEsteOesteVerde ;estado SemaPeatonalNorteSurVerde = 0
		STR		R1, [R2] ;actualiza el estado R1 del semaforo al que apunta R2
		
		MOV		R1,#1 ;valor pivote del estado de semaforo a cambiar
		LDR		R2,=SemaPeatonalEsteOesteRojo ;estado SemaPeatonalEsteOesteRojo = 1
		STR		R1, [R2] ;actualiza el estado R1 del semaforo al que apunta R2
		
Main
		MOV		R3,#0 ;hay carro de norte a sur (estado inicial)
		MOV		R4,#1 ;hay carro de este a oeste (estado inicial)
		MOV		R5,#0 ;no hay peaton de norte a sur (estado inicial)
		MOV		R6,#1 ;hay peaton de este a oeste (estado inicial)
		
		MOV		R7,#0
		
		;Cuenta 30 segundos en el estado inicial
		BL		VerificadorCritico ;Verifica cual contador usar dependiendo de R7 (bandera critica)
		MOV		R0,	#0 ;Para reiniciar el contador 
		
		;Ahora se deben cambiar los semaforos para ajustarse a las condiciones iniciales
		BL		CambiarSemaforos
		
		;Se cambian las condiciones en las vias
		MOV		R3, #1 ;Hay carro de N a S
		MOV		R5, #0 ;Hay peaton de N a S
		MOV		R4,	#0 ;No hay carro de E a O
		MOV		R6,	#0 ;No hay peaton de E a O
		
		ORR		R8, R3, R5 ;Verifica si hay carros o peatones de Norte a Sur o viceversa, deberia ser 1
		ORR		R9, R4, R6 ;Verifica si hay carros o peatones de Este a Oeste o viceversa, deberia ser 0
		AND		R7, R8, R9 ;Bandera situacion critica debería estar desactivada por las nuevas condiciones
		
		BL		VerificadorCritico ;Verifica cual contador usar dependiendo de R7 (bandera critica) 
		MOV		R0,	#0 ;Para reiniciar el contador 
		
		;Ahora se deben cambiar los semaforos para ajustarse a las nuevas condiciones
		BL		CambiarSemaforos
		
		;Se cambian las condiciones en las vias
		MOV		R3, #1 ;Hay carro de N a S
		MOV		R5, #1 ;Hay peaton de N a S
		MOV		R4,	#1 ;No hay carro de E a O
		MOV		R6,	#1 ;No hay peaton de E a O
		
		ORR		R8, R3, R5 ;Verifica si hay carros o peatones de Norte a Sur o viceversa, deberia ser 1
		ORR		R9, R4, R6 ;Verifica si hay carros o peatones de Este a Oeste o viceversa, deberia ser 0
		AND		R7, R8, R9 ;Bandera situacion critica debería estar desactivada por las nuevas condiciones
		
		BL		VerificadorCritico ;Verifica cual contador usar dependiendo de R7 (bandera critica) 
		MOV		R0,	#0 ;Para reiniciar el contador 
		
		;Ahora se deben cambiar los semaforos para ajustarse a las nuevas condiciones
		BL		CambiarSemaforos
		
		B		Main ;Cambiar por Final para solo hacer un ciclo.

VerificadorCritico
		CMP 	R7, #1 ;Situacion critica activada
		BEQ		Contador60
		
		CMP		R7, #0 ;Situacion normal
		BEQ		Contador30
		
Contador30
		;Contador para cuando la situacion no es critica
		ADD 	R0, #1
		CMP 	R0, #30 ;pasan 30 segundos
		BEQ 	Retornar
		B 		Contador30
	
Contador60
		;Contador para cuando la situacion es critica
		ADD 	R0, #1
		CMP 	R0, #60 ;pasa 1 minuto
		BEQ		Retornar
		B		Contador60

CambiarSemaforos
		
		LDR		R2, =SemaNorteSurVerde
		LDR		R1, [R2]
		CMP		R1, #1 
		BEQ		ApagarNorteSur ;Si es 1 apaga Norte Sur y luego enciende Este Oeste
		
		B		ApagarEsteOeste

ApagarEsteOeste
		LDR		R2, =SemaEsteOesteVerde
		STR		R1, [R2] ;Apaga SemaEsteOesteVerde para carros
		LDR		R2, =SemaPeatonalEsteOesteVerde
		STR		R1, [R2] ;Apaga SemaEsteOesteVerde para peatones
		
		MOV		R1, #1
		LDR		R2, =SemaEsteOesteAmarillo ;Enciende SemaEsteOesteAmarillo para carros
		STR		R1, [R2]
		MOV		R1, #0
		STR		R1, [R2] ;Apaga SemaEsteOesteAmarillo para carros
		
		MOV 	R1, #1
		LDR		R2, =SemaEsteOesteRojo
		STR		R1, [R2] ;Enciende SemaEsteOesteRojo para carros
		LDR		R2, =SemaPeatonalEsteOesteRojo
		STR		R1, [R2] ;Enciende SemaEsteOesteRojo para peatones
		
		B		EncenderNorteSur
		
EncenderNorteSur

		MOV		R1, #0
		LDR		R2, =SemaNorteSurRojo
		STR		R1, [R2] ;Apaga SemaEsteOesteRojo para carros
		LDR		R2,	=SemaPeatonalNorteSurRojo
		STR		R1, [R2] ;Apaga SemaEsteOesteRojo para peatones
		
		MOV		R1, #1
		LDR		R2, =SemaNorteSurVerde
		STR		R1, [R2] ;Enciende SemaEsteOesteVerde para carros
		LDR		R2,	=SemaPeatonalNorteSurVerde
		STR		R1, [R2] ;Enciende SemaEsteOesteVerde para peatones

		B		Retornar
		
ApagarNorteSur
		
		MOV		R1, #0
		STR		R1, [R2] ;Apaga el semaforo SemaNorteSurVerde para carros
		LDR		R2, =SemaPeatonalNorteSurVerde
		STR		R1,	[R2] ;Apaga el semaforo SemaNorteSurVerde para peatones
		
		MOV		R1, #1
		LDR		R2, =SemaNorteSurAmarillo ;Eciende SemaNorteSurAmarillo para carros
		STR		R1, [R2]
		MOV		R1, #0
		STR		R1, [R2] ;Apaga SemaNorteSurAmarillo para carros
		
		MOV		R1, #1 ;
		LDR		R2, =SemaNorteSurRojo
		STR		R1, [R2] ;Eciende SemaNorteSurRojo para carros
		LDR		R2, =SemaPeatonalNorteSurRojo
		STR		R1, [R2] ;Eciende SemaNorteSurRojo para peatones
		
		B		EncenderEsteOeste

EncenderEsteOeste
		
		MOV		R1, #0
		LDR		R2, =SemaEsteOesteRojo
		STR		R1, [R2] ;Apaga SemaEsteOesteRojo para carros
		LDR		R2,	=SemaPeatonalEsteOesteRojo
		STR		R1, [R2] ;Apaga SemaEsteOesteRojo para peatones
		
		MOV		R1, #1
		LDR		R2, =SemaEsteOesteVerde
		STR		R1, [R2] ;Enciende SemaEsteOesteVerde para carros
		LDR		R2,	=SemaPeatonalEsteOesteVerde
		STR		R1, [R2] ;Enciende SemaEsteOesteVerde para peatones
		
		B		Retornar

Retornar
		BX 		LR

Final
    B 			Final ;Finaliza el programa
	END