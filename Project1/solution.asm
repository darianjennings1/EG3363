; Darian Jennings , Project 1 , Micro I
        ORG $1000
start
        JSR INIT                 ; initialize all the parameters and subsystems
        JSR GET                 ; get the number N from user and pack it
        ;JSR checkNum                 ; make sure the number is <= 65535
         JSR OUT
        LDD #repmsg                 ; ask if user wants to repeat the process
        LDX printf                 ;
        JSR 0,X                 ;
        LDX getchar                 ;
        JSR 0,X                 ;
        CMPB #'Y'                 ; if user enters 'Y' or 'y', restart program
        BEQ start                 ;
        CMPB #'y'                 ;
        BEQ start                 ;
        SWI
INIT
        LDX #num                 ; load [X] with num
set                                 ; initialize variables
        CLR 1,X+                 ; clear X, clear num[] , then increment
        CPX #count                 ; compare X with count
        BNE set                 ; not equal keep setting the rest of num[] to 0
        MOVB #5,count                 ; [B] == count
        RTS
GET
        LDD #prompt                 ; message to get digits
        LDX printf
        JSR 0,X
L1
        LDX getchar                 ; get a digit
        JSR 0,X
        PSHD                         ; push into stack - save the character into acc D.
        LDX putchar                 ; putchar - echo the number entered to the screen
        JSR 0,X
        PULD                         ; pull back from stack
        CMPB #CR                 ; check if it is carriage return, return key
        BEQ cal                 ; if it is then -> order
        CMPB #$30                 ; $30 == 0
        BLO ERR                 ; if input is < $30 we have an error
        CMPB #$39                 ; $39 == 9
        BHI ERR                 ; if input is > $39 we have an error
        SUBB #$30                 ; ASCII offset to make a digit
        PSHB
        DEC count
        BNE L1                         ; if not 0 loop, bring in up to 5-digits
cal
        LDX #num+4
        LDAA count                 ; if 5-digit number was entered then count right now is 0
cont
        CMPA #5                 ; once count reaches 5 we are done
        BEQ pac
        PULB
        STAB 1,X-                 ; decrements [X] -> [X-1]
        INCA
        JMP cont
pac
        CLR res
        CLR res+1
        LDX #num                 ;X is pointing at the most significant digit (MSD)
pac1
        LDAB 1,X+                 ; B->X->[num] , and then increments X -> [num+1]
        LDY res                 ; res is intially 0, thus so is Y
        ABY
        LDD #10
        EMUL                         ; result is in D
        STD res                 ; store D into res
        CPX #num+4                 ; if it is num+4 we just need to add it else loop
        BLO pac1
        LDD res
        ADDB 0,X
        ADCA #0
        STD res
        RTS
checkNum                       ; checkNum checks each digit to ensure within cap number range (n <= cap)
        LDAB        #0                 ; example - count is 0 from GET/L1
        LDX         #num                 ; cap[], MSD
        LDY         #cap                 ; num[], MSD
checkNum1
        LDAA    1,X+
        CMPA    1,Y+
        BLT     OUT                 ; if num[] < cap[] then num is within the range
        BGT     ERR                 ; if num[] > cap[] then num is out of range
        INCB                         ; increment A until all numbers have been checked - if all previous were equal
        CMPA    #4                 ; increment A until back at 4
        BLS     checkNum1         ; keep looping to check all digits
        LDAA    0,X
        CMPA    0,Y
        BGT     ERR
        RTS
OUT
        LDD         res                 ; load acc.D with result
        PSHD                         ; psh res
        PSHD                         ; psh res
        LDD         #outmsg                 ; load the 1st parameter onto top of stack, LIFO
        LDX         printf                 ; send the result to the monitor
        JSR         0,X                 ;
        LEAS         4,SP                 ; [SP] = [SP-4], balance stack back
        RTS
ERR
        CLRB
        LDD         #errmsg                 ; load the errmsg into acc. D
        LDX         printf                 ; send the result to the monitor
        JSR         0,X
        LEAS         2,SP
        JMP         start                 ; restart the program
       
        ORG         $1200
num     DB          0,0,0,0,0
cap     DB          6,5,5,3,5                 ; upper limit for entered number
count   DB          5
res     RMB         2
repmsg  FCC         'Do you want to enter another number (Y/N)?'
        DB          $0D,0
errmsg  FCC         'You entered a number outside of the integer range 0-9, restarting program...'
        DB      $0D,0
prompt  FCC         'Enter a positive number up to 65536:'
        DB          $0D,0
outmsg  DB          $0D
        FCC         'The number you entered is %u and in HEX it is %X .'
        DB          $0D,$0D,0
printf  EQU         $EE88
putchar EQU         $EE86
getchar EQU         $EE84
CR      EQU         $0D
LF      EQU         $0A
        END
