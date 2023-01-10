; Darian Jennings , Microprocessors I , Project 3, 10/22/2020
    ORG $1000
     JSR pow10
main
     JSR INIT                    ; initialize all the parameters and clear
     JSR GET                     ; get the number N from user and store it in num ,

     LDX #num
     LDY #num1
     LDAB #7
move MOVW 2,X+,2,Y+
     DBNE B,move
     
     JSR GET
     JSR fourMult
     JSR SSub
     JSR OUT

     LDD #repmsg                 ; ask if user wants to repeat the process
     LDX printf                  ;
     JSR 0,X                     ;
     LDX getchar                 ;
     JSR 0,X                     ;
     CMPB #'Y'                   ; if user enters 'Y' or 'y', restart program
     BEQ main                   ;
     CMPB #'y'                   ;
     BEQ main                   ;
     SWI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INIT
    LDX #num                    ; load [X] with num

    LDAB        #10
clearNum                         ; initialize variables
    CLR 1,X+                    ; clear X, clear num[] all the way until num+4[] , then increment
    DBNE B,clearNum             ; not equal keep setting the rest of num[] to 0
    LDX #pnum
    LDAB #4
clearPnum
    CLR 1,X+
    DBNE B,clearPnum
    LDX #num1
    LDAB #10
clearNum1
    CLR 1,X+
    DBNE B,clearNum1
    LDX #pnum1
    LDAB #4
clearPnum1
    CLR 1,X+
    DBNE B,clearPnum1
    LDX #res
    LDAB #8
clearRes
    CLR 1,X+
    DBNE B,clearRes
    LDX #temp
    LDAB        #8
clearTemp
    CLR     1,X+
    DBNE    B,clearTemp
    RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GET
    LDX     #num
GET1
    CLR     1,X+
    CPX     #count
    BLO     GET1
        
    LDD #prompt                 ; message to get digits
    LDX printf
    JSR 0,X
    MOVB #10,count              ; set counter
GET2
    LDX getchar                 ; get a digit
    JSR 0,X
    PSHD                        ; push into stack - save the character into acc D.
    LDX putchar                 ; putchar - echo the number entered to the screen
    JSR 0,X
    PULD                        ; pull back from stack
    CMPB #CR                    ; check if it is carriage return, return key
    BEQ store                     ; if it is then -> order
    CMPB #$30                   ; $30 == 0
    LBLT ERR                     ; if input is < $30 we have an error
    CMPB #$39                   ; $39 == 9
    LBGT ERR                     ; if input is > $39 we have an error
    SUBB #$30                   ; ASCII offset to make a digit
    PSHB
    DEC count
    BNE GET2                    ; if not 0 loop, bring in up to 10-digits
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
store                           ; store numbers in num - num+9
    LDX #num+9
    LDAA count                  ; if 10-digit number was entered then count right now is 0
cont
    CMPA #10                    ; once count reaches 10 we are done
    BEQ PACK
    PULB
    STAB 1,X-                   ; decrements [X] -> [X-1], to next LSD of num
    INCA
    JMP cont
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PACK                             ; pack the number into 4-byte binary, includes mul10 and add N-byte
    LDX #pnum+3                   ;
    LDY #num                    ;Y is pointing at the most significant digit (MSD)
    MOVB #9,count
pack1
    CLC                         ; clear carry
    LDAB pnum+3                    ;add MSD digit to res
    ADCB 1,Y+
    STAB pnum+3
    LDAB pnum+2
    ADCB #0
    STAB pnum+2
    LDAB pnum+1
    ADCB #0
    STAB pnum+1
    LDAB pnum
    ADCB #0
    STAB pnum
    JSR mult10
    DEC count                   ; decrement counter for 10-digits
    BNE pack1                    ; check if count is 0, if not bring in a new digit

    LDAB pnum+3
    ADDB 0,Y
    STAB pnum+3
    LDAB pnum+2
    ADCB #0
    STAB pnum+2
    LDAB pnum+1
    ADCB #0
    STAB pnum+1
    LDAB pnum
    ADCB #0
    STAB pnum
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
checkNum
    LDX #num                    ; cap[], MSD
    LDY #cap                    ; num[], MSD
checkNum1
    LDAA 1,X+                   ; load acc. A with X, increment X after
    CMPA 1,Y+                   ; compare A with Y, increment Y after
    BLO esc                     ; if lower , then it's in range -> escape subroutine
    BHI ERR                     ; if numDigit < capDigit then it is within the range
                                ; if numDigit > capDigit then it is outside of the range
    CPX #num+9                  ; num -> num+8 is 9 digits, 10th digit is done manuallly
    BLE checkNum1
esc
    RTS
ERR
    LDD #errmsg                  ; load the errmsg into acc. D
    LDX printf                   ; send the result to the monitor
    JSR 0,X
    JMP main                    ; restart the program
    RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mult10
    CLC
    ROL pnum+3                    ; "A" loop iteration multiplies res*2 through rotates
    ROL pnum+2
    ROL pnum+1
    ROL pnum
    MOVW pnum,temp                ; store res (res*2) into temp - temp+2
    MOVW pnum+2,temp+2
    LDAB #2
mult1
    CLC
    ROL pnum+3
    ROL pnum+2
    ROL pnum+1
    ROL pnum
    DBNE B,mult1

    LDD pnum+2                    ; add 2 N-byte numbers together and store
    ADDD temp+2                   ; adding temp(res*2) + res(res*8)
    STD pnum+2
    LDD pnum
    ADCB temp+1
    ADCA temp
    STD pnum
    RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OUT                             ; OUTPUT FIRST MULTIPLICATION OPERAND
    LDD #blank                  ; new line for out message
    LDX printf
    JSR 0,X
    
    LDY #num1                   ; print out first number user entered
p
    CPY #num1+9
    BHI p2
    LDAB 0,Y
    BEQ p1                      ; check if 0 - if it is not then go increment to next digit and come check again
    BNE p2                      ; if not zero then go to output digits
p1
    INY
    JMP p
p2
    LDAB 0,Y
    ADDB #$30                   ; add ASCII offset
    CLRA
    PSHY                        ; save pointer in stack, so we don't lose it
    LDX putchar                 ; output character
    JSR 0,X
    PULY                        ; retrieve pointer
    INY
    CPY #num1+9                 ; check if all digits have been outputted
    BLS p2

    LDD #outmsg                 ; ' x '
    LDX printf
    JSR 0,X
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                               ; OUTPUT SECOND MULTIPLICATION OPERAND
    LDY #num                   ; print out second number user entered
print
    CPY #num+9
    BHS print2
    LDAB 0,Y
    BEQ print1                 ; check if 0 - if it is not then go increment to next digit and come check again
    BNE print2                 ; if not zero then go to output digits
print1
    INY
    JMP print
print2
    LDAB 0,Y
    ADDB #$30                  ; add ASCII offset
    CLRA
    PSHY                       ; save pointer in stack, so we don't lose it
    LDX putchar                ; output character
    JSR 0,X
    PULY                       ; retrieve pointer
    INY
    CPY #num+9                 ; check if all digits have been outputted
    BLS print2

    LDD #outmsg1               ; ' = '
    LDX printf
    JSR 0,X                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                               ; OUTPUT 20-DIGIT ANSWER - sitting in decnum
    LDY #decnum                ; print out second number user entered
printd
    CPY #decnum+19
    BHS printd2
    LDAB 0,Y
    BEQ printd1                ; check if 0 - if it is not then go increment to next digit and come check again
    BNE printd2                ; if not zero then go to output digits
printd1
    INY
    JMP printd
printd2
    LDAB 0,Y
    ADDB #$30                  ; add ASCII offset
    CLRA
    PSHY                       ; save pointer in stack, so we don't lose it
    LDX putchar                ; output character
    JSR 0,X
    PULY                       ; retrieve pointer
    INY
    CPY #decnum+19              ; check if all digits have been outputted
    BLS printd2

    LDD #CR                     ; print newline
    LDX putchar
    JSR 0,X
    RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pow10
    LDY #pow_10+150            ; set pointer Y to pow_10
    LDX #res
PL1 CLR 1,X+                   ; clear res-res+7 , set res+7 at 1
    CPX #res+7
    BLO PL1
    MOVB #1,0,X
PL6 LDAB #3                    ; multiply res by 10
PL4 LDAA #8
    CLC
PL2 ROL 1,X-
    DBNE A,PL2                 ; rotate 8 times
    CMPB #3                    ; on 1st iteration we have res*2 and we need to save it into temp
    BNE PL3
    MOVW res,temp              ; on 1st iteration save res*2 into temp
    MOVW res+2,temp+2          ; save res-res+7 (res*2) into temp
    MOVW res+4,temp+4
    MOVW res+6,temp+6
PL3 LDX #res+7                 ; reset pointer, do it 2 more times 2*(res*2) then 2*(res*4) gives us res*8
    DBNE B,PL4
    LDX #res+7
    LDAB #8
    CLC
PL5 LDAA 0,X                   ; ADD temp (res*2) to res(res*8)
    ADCA 8,X                   ; assumption is that temp is after res
    STAA 1,X-
    DBNE B,PL5                 ; multiply by 10
    MOVW res+6,2,Y-            ; store power of 10 into memory
    MOVW res+4,2,Y-
    MOVW res+2,2,Y-
    MOVW res,2,Y-
    LDX #res+7                 ; reset pointer at LSB of res
    CPY #pow_10                ; check if all powers have been stored
    LBHS PL6
    RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fourMult
    LDD pnum+2                 ; PICKUP LSB OF BOTH NUMBERS
    LDY pnum1+2
    EMUL                       ; multiply
    STY res+4                  ; store upper bit of product into upper-low byte (res+4 and res+5 of res
    STD res+6

    LDD pnum                   ; PICKUP MSB OF BOTH NUMBERS
    LDY pnum1
    EMUL                       ; multiply
    STY res                    ; store into MSB of res, Y is upper (res - res+1), D is lower (res+2 - res+3)
    STD res+2

    LDD pnum                   ; ADD PNUM(MSB)*PNUM1(LSB) to RES+2 - RES+5
    LDY pnum1+2
    EMUL
    ADDD res+4                 ; add LSB of PNUM(MSB)*PNUM1(LSB) to res+4 - res+5
    STD res+4                   ; store result in res+4 - res+5
    TFR Y,D                    ; trasnfer Y to D so we can ripple the carry using A & B

    ADCB res+3                 ; RIPPLE THE CARRY ACROSS res
    STAB res+3
    ADCA res+2
    STAA res+2
    LDAA res+1                 ; ripple carry through MSB
    ADCA #0
    STAA res+1
    LDAA res
    ADCA #0
    STAA res

    LDD pnum+2                 ; ADD PNUM(LSB)*PNUM1(MSB) to RES+2 - RES+5
    LDY pnum1
    EMUL
    ADDD res+4                 ; add LSB of PNUM(LSB)*PNUM1(MSB) to res+4 - res+5
    STD res+4                  ; store result in res+4 - res+5
    TFR Y,D                    ; trasnfer Y to D so we can ripple the carry using A & B

    ADCB res+3
    STAB res+3
    ADCA res+2
    STAA res+2
    LDAA res+1                 ; ripple carry through MSB
    ADCA #0
    STAA res+1
    LDAA res
    ADCA #0
    STAA res                   ; carry has been rippled through most significant bit - store
    RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SSub
    LDY #pow_10+7                ; point at LSB of first 8-bits
    LDX #decnum
    CLR count
    PSHX                        ; save decnum address so we can use X for Successive Subtraction
SL1 MOVW res,temp                ; keep result before subtraction
    MOVW res+2,temp+2
    MOVW res+4,temp+4
    MOVW res+6,temp+6
SL2 LDX #res+7
    LDAB #8
    CLC
SL3 LDAA 0,X                ; res - pow_10 -> res
    SBCA 1,Y-
    STAA 1,X-
    DBNE B,SL3
    BCS next                ; branch if carry set
    INC count                ; if branch is not set, increment count, move pointers,
    LEAY 8,Y                ; restart pointer to begin of 8-byte
    JMP SL1                        ; subtract the power again
next PULX
    MOVB count,1,X+                ; save value of count into decnum
    PSHX
    MOVW temp,res
    MOVW temp+2,res+2
    MOVW temp+4,res+4
    MOVW temp+6,res+6
    LEAY 16,Y                ; move Y to LSB of next pow_10
    CLR count
    CPY #pow_10+151                ; check if we have gone through all powers of 10
    BLS SL2
    PULX
    MOVB temp+7,0,X
    RTS
    
    ORG $1500
num     RMB  10
pnum    RMB  4
count   RMB  1
num1    RMB  10
pnum1   RMB  4
cap     DB   4,2,9,4,9,6,7,2,9,5
res     RMB  8
temp    RMB  8
pow_10  RMB  152                               ; holds 10^1 - 10^19
decnum  RMB  20                               ; 20-bytes for unpacked answer
repmsg  DB   CR,CR
        FCC  'Do you want to enter another number (Y/N)?'
        DB   $0D,0
errmsg  DB   CR
        FCC  'Invalaid input, restarting program...'
        DB   CR,0
prompt  DB   CR
        FCC  'Enter a positive number up to 4,294,967,295 :'
        DB   CR,0
blank   DB   CR,CR,LF,0
outmsg  FCC  ' x '
        DB   0
outmsg1 FCC  ' = '
        DB   0
printf  EQU  $EE88
putchar EQU  $EE86
getchar EQU  $EE84
CR      EQU  $0D
LF      EQU  $0A
        END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
