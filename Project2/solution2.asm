; Darian Jennings , Microprocessors I , Project 2, 10/15/2020
    ORG $1000
start
    JSR CLEAR
    JSR INIT                    ; initialize all the parameters and subsystems
    JSR GET                     ; get the number N from user and store it in num

    LDD #pk1msg                ; 'packing is complete '
    LDX printf
    JSR 0,X                      ;
    JSR checkNum                ; check if input < cap

    JSR convert                 ; adjust 2 or 3 byte num to 4-byte
    LDD #conmsg                ; 'conversion complete '
    LDX printf
    JSR 0,X                      ;

    JSR calc                    ; calculate the square root of res
    LDD #pk2msg                ; 'square root has been calculated '
    LDX printf
    JSR 0,X                      ;

    JSR fixAns                  ; adjust ans based on flag
    JSR display
    
    LDD #repmsg                 ; ask if user wants to repeat the process
    LDX printf                  ;
    JSR 0,X                     ;
    LDX getchar                 ;
    JSR 0,X                     ;
    CMPB #'Y'                   ; if user enters 'Y' or 'y', restart program
    BEQ start                   ;
    CMPB #'y'                   ;
    BEQ start                   ;
    SWI
INIT
    LDX #num                    ; load [X] with num
set                             ; initialize variables
    CLR 1,X+                    ; clear X, clear num[] all the way until num+4[] , then increment
    CPX #count                  ; compare X with count
    BNE set                     ; not equal keep setting the rest of num[] to 0
    MOVB #10,count               ; [B] == count
    RTS
CLEAR
    LDX #pnum                     ; clear bytes of res - set to 0
    LDAB #4
clearPnum
    CLR 1,X+
    DBNE B,clearPnum
    LDX #sum                     ; clear bytes of sum - set to 0
    LDAB #4
clearSum
    CLR 1,X+
    DBNE B,clearSum
    LDX #c1
    LDAB #2
clearc1
    CLR 1,X+
    DBNE B,clearc1
    RTS
GET
    LDD #prompt                 ; message to get digits
    LDX printf
    JSR 0,X
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
store
    LDD #stmsg                 ; 'storing numbers... '
    LDX printf
    JSR 0,X                      ;
    
    LDX #num+9
    LDAA count                  ; if 10-digit number was entered then count right now is 0
cont
    CMPA #10                    ; once count reaches 10 we are done
    BEQ PACK
    PULB
    STAB 1,X-                   ; decrements [X] -> [X-1], to next LSD of num
    INCA
    JMP cont
PACK                             ; pack the number into 4-byte binary, includes mul10 and add N-byte
    LDX #pnum+3
    LDD #pkmsg                 ; 'storing numbers... '
    LDX printf
    JSR 0,X                      ;
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
    RTS
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
checkNum
    LDD #ckmsg                 ; 'storing numbers... '
    LDX printf
    JSR 0,X                      ;

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
    PSHD
    LDX printf                   ; send the result to the monitor
    JSR 0,X
    LEAS 2,SP                    ; [SP] = [SP-2], balance stack back
    JMP start                    ; restart the program
convert
    LDD pnum                     ; get 2-bytes, res & res+1
    BEQ two                     ; if both bytes are 0 then multiply by 10,000
    CMPA #0                     ; compare MS-byte (res)
    BEQ one                     ; if 0 then multiply by 100
    MOVB #0,flag
    RTS                         ; otherwise no adjustment
two
    LDD pnum+2                   ; get 2-bytes LS
    LDY #10000                  ; multiply by 10,000
    EMUL
    STD pnum+2                   ; store the result
    STY pnum
    MOVB #2,flag                ; set flag
    RTS
one
    LDD pnum+2
    LDY #100
    EMUL
    STD pnum+2                   ; store 1st part of multiplication
    LDD pnum                     ; pickup 2-byte of num
    STY pnum                     ; store 2nd part of multipplication
    LDY #100                    ; multiply 2nd part by 100
    EMUL
    ADDD pnum                    ;add result last 2-byte to 1st product
    STD pnum                     ; store result
    MOVB #1,flag                ; set flag
    RTS
calc
    CLR c1
    CLR c1+1
calc1
    LDD c1                      ; calculate sqrt of number
    CPD #$FFFF
    LBEQ done
    ADDD sum+2
    STD sum+2
    LDD sum
    ADCB #0
    ADCA #0
    STD sum
    LDD c1
    ADDD #1
    STD c1
    
    ADDD sum+2
    STD sum+2
    LDD sum
    ADCB #0
    ADCA #0
    STD sum
    
    LDD pnum
    CPD sum
    BHI calc1
    BLO done
    
    LDD pnum+2
    CPD sum+2
    BHI calc1
done
RTS
fixAns
    LDD #akmsg                ; 'adjusting sqrt'
    LDX printf
    JSR 0,X                      ;
    
    LDAA flag                  ; check what the flag value is
    CMPA #2
    BEQ fixAns2

    CMPA #1
    BEQ fixAns1
    
    MOVB #$30,rem1            ; if flag is 0/4 then remainder/decimal is 0
    MOVB #$30,rem2            ; if flag is 0/4 then remainder/decimal is 0
    RTS                                ;
fixAns2
    LDD c1
    LDX #100
    IDIV                        ; D/X , whole number is in X, remainder is in D
    STX c1                     ; store the whole-number integer value (X)
    LDX #10
    IDIV                        ; D/X , whole number is in X, remainder is in D
    ADDB #$30
    STAB rem2                   ; store 2nd decimal into rem2
    XGDX
    ADDB #$30                  ; X has what we need switch it to D
    STAB rem1                   ; add offset
    RTS
fixAns1
    LDD c1
    LDX #10
    IDIV                        ; D/X , whole number is in X, remainder is in D
    STX c1                     ; store the whole-number integer value (X)
    ADDB #$30
    STAB rem1
    MOVB #$30,rem2
    RTS
display
    LDD #outmsg                  ; 'The square root of '
    LDX printf
    JSR 0,X                      ;
    LDY #num
printI
    LDAB 0,Y
    BEQ printI1                  ; check if 0 - if it is not then print digit
    BNE printI2
printI1
    INY
    JMP printI
    CPY #num+9
    BLO printI                   ; loop to remove all leading zeroes
printI2
    LDAB 0,Y
    ADDB #$30                    ; add ASCII offset
    CLRA
    PSHY                        ; save pointer in stack, so we don't lose it
    LDX putchar                 ; output character
    JSR 0,X
    PULY                        ; retrieve pointer
    INY
    CPY #num+9                 ; check if all digits have been outputted
    BLS printI2

    LDD c1                      ; integer part of sqrt
    PSHD
    LDD #outmsg1                ; ' is %u.'
    LDX printf
    JSR 0,X                      ;
    LEAS 2,SP                    ; [SP] = [SP-2], balance stack back
    RTS
    

    ORG $1500
cap     DB   4,2,9,4,9,6,7,2,9,5
num     DB   0,0,0,0,0,0,0,0,0,0
count   DB   10
pnum    RMB  4                     ; used to convert num to 4-byte packed number
temp    RMB  4                     ; used for mul10, temp is res*2
flag    DB   0
sum     RMB  4
ans     RMB  4                     ; used to store sqrt value
c1      RMB  2                   ; i-counter for sqrt loop
repmsg  FCC  'Do you want to enter another number (Y/N)?'
        DB   $0D,0
errmsg  FCC  'You entered a number outside of the max number range, restarting program...'
        DB   $0D,0
stmsg   DB   $0D
        FCC  'storing numbers....'
        DB   $0D,0
ckmsg   FCC  'checking range of number...'
        DB   $0D,0
conmsg   FCC  'conversion complete....'
        DB   $0D,0
pkmsg   FCC  'packing num to 4-bytes....'
        DB   $0D,0
akmsg   FCC  'adjusting sqrt....'
        DB   $0D,0
pk1msg  FCC  'packing is complete'
        DB   $0D,0
pk2msg  FCC  'the square root has been calculated'
        DB   $0D,0
prompt  FCC  'Enter a positive number up to 4,294,967,295 :'
        DB   $0D,0
outmsg  DB   $0D
        FCC  'The square root of '
        DB   0
outmsg1 FCC  ' is %u.'
rem1    DB   $20                     ; store remainder from sqrt calculation dd
rem2    DB   $20,$0D,0

printf  EQU  $EE88
putchar EQU  $EE86
getchar EQU  $EE84
CR      EQU  $0D
LF      EQU  $0A
        END
