		;Includes for constants
		INCLUDE core_cm4_constants.s
		INCLUDE stm32l476xx_constants.s
		
		AREA mydata, DATA, READWRITE

		AREA mycode, CODE, READONLY
		EXPORT __main
		ENTRY

__main PROC
		BL RCC_Init
		BL GPIO_Init
		LDR R0,=GPIOE_BASE
		
		ADR R1,seq1
		MOV R5, R1
		
		MOV R9,#0
		MOV R10,#0
		MOV R11,#0
			
loop	;polling loop for button presses
		LDR r7, =GPIOA_BASE		
		LDR r8, [r7, #GPIO_IDR]
		AND r8, #(0x8)
		CMP r8, #(0x8)
		BEQ up_press
		LDR r7, =GPIOA_BASE
		LDR r8, [r7, #GPIO_IDR]
		AND r8, #(0x1)
		CMP r8, #(0x1)
		BEQ speed
		LDR r7, =GPIOA_BASE
		LDR r8, [r7, #GPIO_IDR]
		AND r8, #(0x20)
		CMP r8, #(0x20)
		BEQ d_press
		LDR r7, =GPIOA_BASE
		LDR r8, [r7, #GPIO_IDR]
		AND r8, #(0x2)
		CMP r8, #(0x2)
		BEQ l_press
		LDR r7, =GPIOA_BASE
		LDR r8, [r7, #GPIO_IDR]
		AND r8, #(0x4)
		CMP r8, #(0x4)
		BEQ r_press
continue
		LDRB R2,[R1],#1
		CBNZ R2,next
		MOV R1,R5
		B loop
			
up_press  
		EOR r10,#0x1
		CMP r10,#1
		ADREQ r5,seq1
		CMP r10,#0
		ADREQ r5,seq2
		b continue

d_press  
		EOR r11,#0x1
		CMP r11,#1
		ADREQ r5,seq3
		CMP r11,#0
		ADREQ r5,seq4
		b continue

speed
		EOR r9,#0x1
		b continue
	
l_press 
		ADR r5,seq5
		b continue
		
r_press 
		ADR r5,seq6
		b continue
next
		LDR R3,[R0,#GPIO_ODR]
		LDR R4,=0x0F
		BIC R3,R3,R4,LSL #12
		ORR R3,R3,R2,LSL #12
		STR R3,[R0,#GPIO_ODR]
		CMP r9,#0
		BLEQ DelaySlow
		BL DelayFast
		B loop
		ENDP

RCC_Init PROC
		PUSH {R0,R1}
		LDR R0, =RCC_BASE
		LDR R1, [R0,#RCC_AHB2ENR]
		ORR R1,R1,#RCC_AHB2ENR_GPIOEEN
		ORR R1,R1,#RCC_AHB2ENR_GPIOAEN
		STR R1, [R0,#RCC_AHB2ENR]
		POP {R1,R0}
		BX LR
		ENDP

DelaySlow  PROC ;This will result in a slower motor speed
		push {r1}
		ldr r1, =2000   ;slow
againSlow   NOP  ;execute two no-operation instructions
		NOP
		subs r1, #1
		bne againSlow
		pop {r1}
		bx lr
		ENDP
			
DelayFast  PROC ;This will result in a faster motor speed
		push {r1}
		ldr r1, =1000   ;fast
againFast   NOP  ;execute two no-operation instructions
		NOP
		subs r1, #1
		bne againFast
		pop {r1}
		bx lr
		ENDP
			
GPIO_Init PROC
		PUSH {R0,R1,R2}
		LDR R0, =GPIOE_BASE
		LDR R1, [R0,#GPIO_MODER]
		LDR R2,=0x0FF
		BIC R1,R1,R2,LSL #24
		LDR R2,=0x55
		ORR R1, R1, R2, LSL #24
		STR R1, [R0,#GPIO_MODER]
		LDR R1, [R0,#GPIO_OSPEEDR]
		LDR R2, =0x0FF
		ORR R1, R1, R2, LSL #24
		STR R1, [R0,#GPIO_OSPEEDR]
		LDR R1, [R0,#GPIO_PUPDR]
		LDR R2, =0x0FF
		BIC  R1,R1,R2, LSL #24
		STR R1, [R0,#GPIO_PUPDR]
		LDR R1, [R0,#GPIO_OTYPER]
		LDR R2, =0x0F
		BIC  R1, R1, R2, LSL #12
		STR  R1, [R0,#GPIO_OTYPER]
			
			;PA3 PA5 init
		LDR R0,=GPIOA_BASE
		LDR R1,[R0,#GPIO_MODER]
		LDR R8,=0xCFF
		BIC R1,R1,R8
		STR R1,[R0, #GPIO_MODER]
		LDR R1,[R0, #GPIO_PUPDR]
		BIC R1,R1,R8
		LDR R9,=0x8AA
		ORR R1,R1,R9
		STR R1,[R0,#GPIO_PUPDR]

		POP  {R2,R1,R0}
		
		BX     LR
		ENDP
		

		
		ALIGN
seq1 DCB 2_0101,2_0110,2_1010,2_1001,2_0000
		ALIGN
seq2 DCB 2_0101,2_1001,2_1010,2_0110,2_0000
		ALIGN
seq3 DCB 2_0001,2_0100,2_0010,2_1000,2_0000
		ALIGN
seq4 DCB 2_0001,2_1000,2_0010,2_0100,2_0000
		ALIGN
seq5 DCB 2_0001,2_0101,2_0100,2_0110,2_0010,2_1010,2_1000,2_1001,2_0000	
		ALIGN
seq6 DCB 2_0001,2_1001,2_1000,2_1010,2_0010,2_0110,2_0100,2_0101,2_0000

		END