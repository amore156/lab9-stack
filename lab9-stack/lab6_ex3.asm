;===================================================================
; Name: Alexis Moret
; Email: amore156@ucr.edu
; 
; Lab: lab 6, ex 3
; Lab section: 022
; TA: Abhishek Premnath
; 
;===================================================================

.ORIG x3000                 ; Program begins
;--------------
; Instructions
;--------------
LD R4, BASE                 ; R4 <- xA000
LD R5, MAX                  ; R5 <- xA005
ADD R6, R6, R4              ; R6 <- R6 + R4
LD R1, CONVERT
NOT R1, R1
ADD R1, R1, #1
LD R3, PUSH_PTR             ; load PUSH subroutine's address in R3

; First operand
LEA R0, intro			    ; get starting address of prompt string
PUTS			    	    ; invokes BIOS routine to output string
GETC                        ; R0 <- user's character
OUT                         ; prints user's character
ADD R0, R0, R1
JSRR R3                     ; transfer control to R3's subroutine

; Second operand
LEA R0, intro			    ; get starting address of prompt string
PUTS			    	    ; invokes BIOS routine to output string
GETC                        ; R0 <- user's character
OUT                         ; prints user's character
ADD R0, R0, R1
JSRR R3                     ; transfer control to R3's subroutine

; Operation symbol
LEA R0, symbol			    ; get starting address of prompt string
PUTS			    	    ; invokes BIOS routine to output string
GETC                        ; R0 <- user's character
OUT                         ; prints user's character

; Multiplication
LD R3, RPN_ADD_PTR          ; load RPN_ADD subroutine's address in R3
JSRR R3                     ; transfer control to R3's subroutine

; Result
LEA R0, result			    ; get starting address of prompt string
PUTS			    	    ; invokes BIOS routine to output string
LD R3, POP_PTR              ; load POP subroutine's address in R3
JSRR R3                     ; transfer control to R3's subroutine
LD R3, PRINT_PTR            ; load PRINT subroutine's address in R3
JSRR R3                     ; transfer control to R3's subroutine

LD R0, newline              ; R0 <- x0A
OUT                         ; prints x0A as a character

HALT                        ; Program ends

;------------
; Local data
;------------
PUSH_PTR    .FILL       x3200
POP_PTR     .FILL       x3400
RPN_ADD_PTR .FILL       x3600
PRINT_PTR   .FILL       X3800
BASE        .FILL       xA000
MAX         .FILL       xA005
CONVERT     .FILL       x30
newline     .FILL       x0A

intro       .STRINGZ    "\nEnter a single digit numeric character: "
symbol      .STRINGZ    "\nEnter the operation symbol: "
result      .STRINGZ    "\nThe result is "


;===================================================================
; Subroutine: SUB_PRINT_DIGIT_3800
; Parameter (R0): The value to be printed in ASCII.
; Postcondition: The subroutine converts R0's value to ASCII format
;                and prints it.
; Return Value: No return value.
;===================================================================

.ORIG x3800
;-------------------------
; Subroutine Instrustions
;-------------------------

; (1) Backup Registers
ST R0, backup_r0_3800
ST R1, backup_r1_3800
ST R7, backup_r7_3800

; (2) Subroutine Algorithm
LD R1, CONVERT_3800
ADD R0, R0, R1
OUT

; (3) Restore Registers
LD R0, backup_r0_3800
LD R1, backup_r1_3800
LD R7, backup_r7_3800

; (4) Return
RET

;-----------------
; Subroutine Data
;-----------------
backup_r0_3800  .BLKW   #1
backup_r1_3800  .BLKW   #1
backup_r7_3800  .BLKW   #1

CONVERT_3800    .FILL   x30


;===================================================================
; Subroutine: SUB_RPN_ADDITION_3600
; Parameter (R4): BASE: A pointer to the base of the stack.
; Parameter (R5): MAX: The "highest" available address in the stack.
; Parameter (R6): TOS: A pointer to the current top of the stack.
; Postcondition: The subroutine has popped off the top two values 
;                of the stack, added them together, and pushed the 
;                resulting value back onto the stack.
; Return Value: R6 ← updated TOS address
;===================================================================

.ORIG x3600
;-------------------------
; Subroutine Instrustions
;-------------------------

; (1) Backup Registers
ST R0, backup_r0_3600
ST R1, backup_r1_3600
ST R2, backup_r2_3600
ST R3, backup_r3_3600
ST R7, backup_r7_3600

; (2) Subroutine Algorithm
LD R3, POP_PTR_3600
AND R1, R1, x0

JSRR R3
ADD R2, R0, #0
JSRR R3
ADD R0, R0, #0
BRz END_DO_WHILE_LOOP_3600
DO_WHILE_LOOP_3600
    ADD R1, R1, R2
    ADD R0, R0, #-1
    BRp DO_WHILE_LOOP_3600
END_DO_WHILE_LOOP_3600

LD R3, PUSH_PTR_3600
ADD R0, R1, #0
JSRR R3

; (3) Restore Registers
LD R0, backup_r0_3600
LD R1, backup_r1_3600
LD R2, backup_r2_3600
LD R3, backup_r3_3600
LD R7, backup_r7_3600

; (4) Return
RET

;-----------------
; Subroutine Data
;-----------------
backup_r0_3600  .BLKW   #1
backup_r1_3600  .BLKW   #1
backup_r2_3600  .BLKW   #1
backup_r3_3600  .BLKW   #1
backup_r7_3600  .BLKW   #1

PUSH_PTR_3600    .FILL       x3200
POP_PTR_3600     .FILL       x3400


;===================================================================
; Subroutine: SUB_STACK_POP_3400
; Parameter (R4): BASE: A pointer to the base of the stack.
; Parameter (R5): MAX: The "highest" available address in the stack.
; Parameter (R6): TOS: A pointer to the current top of the stack.
; Postcondition: The subroutine has popped MEM[TOS] off of the stack 
;                and copied it to R0.
;		         If the stack was already empty (TOS = BASE), 
;                the subroutine has printed an underflow
;                error message and terminated.
; Return Values: R0 ← value popped off the stack
;		         R6 ← updated TOS
;===================================================================

.ORIG x3400
;-------------------------
; Subroutine Instrustions
;-------------------------

; (1) Backup Registers
ST R1, backup_r1_3400
ST R4, backup_r4_3400
ST R7, backup_r7_3400

; (2) Subroutine Algorithm
NOT R4, R4
ADD R4, R4, #1

; POP
ADD R1, R6, R4
BRp GREATER_3400
LEA R0, underflow_3400
PUTS
RET
GREATER_3400
LDR R0, R6, #0              ; R0 <- Mem[R6 + x0]
ADD R6, R6, #-1

; (3) Restore Registers
LD R1, backup_r1_3400
LD R4, backup_r4_3400
LD R7, backup_r7_3400

; (4) Return
RET

;-----------------
; Subroutine Data
;-----------------
backup_r1_3400  .BLKW   #1
backup_r4_3400  .BLKW   #1
backup_r7_3400  .BLKW   #1

underflow_3400 	.STRINGZ	"\nError: underflow detected!\n"


;===================================================================
; Subroutine: SUB_STACK_PUSH_3200
; Parameter (R0): The value to push onto the stack.
; Parameter (R4): BASE: A pointer to the base of the stack.
; Parameter (R5): MAX: The "highest" available address in the stack.
; Parameter (R6): TOS: A pointer to the current top of the stack.
; Postcondition: The subroutine has pushed (R0) onto the stack. 
;		         If the stack was already full (TOS = MAX), 
;                the subroutine has printed an overflow
;		         error message and terminated.
; Return Value: R6 ← updated TOS
;===================================================================

.ORIG x3200
;-------------------------
; Subroutine Instrustions
;-------------------------

; (1) Backup Registers
ST R1, backup_r1_3200
ST R5, backup_r5_3200
ST R7, backup_r7_3200

; (2) Subroutine Algorithm
NOT R5, R5
ADD R5, R5, #1

; PUSH
ADD R1, R6, R5
BRn LESS_3200
LEA R0, overflow_3200
PUTS
RET
LESS_3200
ADD R6, R6, #1
STR R0, R6, #0              ; Mem[R6 + x0] <- R0

; (3) Restore Registers
LD R1, backup_r1_3200
LD R5, backup_r5_3200
LD R7, backup_r7_3200

; (4) Return
RET

;-----------------
; Subroutine Data
;-----------------
backup_r1_3200  .BLKW   #1
backup_r5_3200  .BLKW   #1
backup_r7_3200  .BLKW   #1

overflow_3200 	.STRINGZ	"\nError: overflow detected!\n"

.END