;===================================================================
; Name: Alexis Moret
; Email: amore156@ucr.edu
; 
; Lab: lab 6, ex 2
; Lab section: 022
; TA: Abhishek Premnath
; 
;===================================================================

.ORIG x3000                 ; Program begins
;--------------
; Instructions
;--------------
.BLKW #6                    ; set up a blank array of 6 spots
LD R1, DATA_PTR             ; load array's address in R1
LD R2, ARRAY_SIZE           ; load array's size in R2
LD R0, LETTER_A             ; R0 <- x61
LD R4, BASE                 ; R4 <- xA000
LD R5, MAX                  ; R5 <- xA005
ADD R6, R6, R4              ; R6 <- R6 + R4

STORE_LOOP
    STR R0, R1, #0          ; Mem[R1 + x0] <- R0
    ADD R0, R0, #1          ; R0 <- R0 + 1
    ADD R1, R1, #1          ; R1 <- R1 + 1
    ADD R2, R2, #-1         ; R2 <- R2 - 1
    BRp STORE_LOOP          ; if (R2 > 0) goto STORE_LOOP
END_STORE_LOOP

LD R1, DATA_PTR             ; load array's address in R1
LD R2, ARRAY_SIZE           ; load array's size in R2
LD R3, PUSH_PTR             ; load PUSH subroutine's address in R3

PUSH_LOOP
    LDR R0, R1, #0          ; R0 <- Mem[R1 + x0]
    JSRR R3                 ; transfer control to R3's subroutine
    ADD R1, R1, #1          ; R1 <- R1 + 1
    ADD R2, R2, #-1         ; R2 <- R2 - 1
    BRp PUSH_LOOP           ; if (R2 > 0) goto PUSH_LOOP
END_PUSH_LOOP

LD R1, DATA_PTR             ; load array's address in R1
LD R2, ARRAY_SIZE           ; load array's size in R2
LD R3, POP_PTR              ; load POP subroutine's address in R3

POP_LOOP
    JSRR R3
    ADD R1, R1, #1          ; R1 <- R1 + 1
    ADD R2, R2, #-1         ; R2 <- R2 - 1
    BRp POP_LOOP            ; if (R2 > 0) goto POP_LOOP
END_POP_LOOP
    
HALT                        ; Program ends

;------------
; Local data
;------------
DATA_PTR    .FILL   x3000
ARRAY_SIZE  .FILL   #6
LETTER_A    .FILL   x1
PUSH_PTR    .FILL   x3200
POP_PTR     .FILL   x3400
BASE        .FILL   xA000
MAX         .FILL   xA005

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

.END

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