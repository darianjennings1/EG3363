; Darian Jennings , Microprocessors I , 11/12/2020
; Project 5 - Linked Lists
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ORG $1000
        MOVB #120,count
        LDX #Buff
clear   CLR 1,X+
        CPX #count
        BNE clear
        MOVB #0,count
menu
        LDD #menuMsg
        LDX printf
        JSR 0,X
        
        LDX getchar
        JSR 0,X
        PSHD
        LDX putchar
        JSR 0,X
        PULD
        CMPB #$31
        BEQ INSERT
        CMPB #$32
        LBEQ DELETE
        CMPB #$33
        LBEQ print1
        CMPB #$34
        LBEQ COMPACT
        CMPB #$35
        BEQ QUIT
        JMP menu
QUIT
        SWI
print1
        JSR PRINT
        JMP menu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INSERT
        CLRA
        CLRB
        JSR PRINT
        
        LDAB count
        CMPB #20
        LBHS buffFull
        
        LDD #prompt1
        LDX printf
        JSR 0,X
        LDX getchar                 ; get the character from user
        JSR 0,X
        PSHD
        LDX putchar
        JSR 0,X
        PULD
        STAB char

        LDD #prompt2                ; get the priority from user
        LDX printf
        JSR 0,X
        LDX getchar
        JSR 0,X
        PSHD
        LDX putchar
        JSR 0,X
        PULD
        SUBB #$30
        LDAA #10
        MUL                         ; multiply decimal*10 ---- result is in acc. B
        STAB prio

        LDX getchar
        JSR 0,X
        PSHD
        LDX putchar
        JSR 0,X
        PULD
        SUBB #$30
        ADDB prio
        STAB prio
insert1
        LDY Empnode                  ; get empnode and check if it is in range
        CPY #Buff+114
        BGT outOfRange
        
        LDAB count
        CMPB #0
        BEQ first
        CMPB #20
        BLT insert2
        
        LDD #fullmsg
        LDX printf
        JSR 0,X
        RTS
outOfRange
        JSR COMPACT
        BRA insert1

first
        LDX #Buff                    ; set up first node
        STX Head
        MOVW #$0004,0,X
        MOVW #$D601,2,X

        LDAB prio
        STAB 4,X
        LDAB char
        STAB 5,X
        
        INC count                    ; increment count of total nodes
        LEAX 6,X                     ; set up next node - will be empty
        STX Empnode
        
        JSR PRINT
        JMP menu
insert2                              ; we have 1-19 nodes, check where to insert
        LDX Head
        LDAA 4,X                     ; grab prio of Head
        CMPA prio                    ; compare to user entered prio
        LBLT  topI                    ; if less than Head then insert at top
        LBEQ  prioErr
insert3
        LDD 2,X                      ; compare to TAIL
        CPD #$D601
        BEQ bottomI                   ; if it is the insert at the end of the linked-lists
        
        LDX 2,X
        LDAB 4,X                     ; check if it is in the middle
        CMPB prio
        BLT middleI
        LBEQ prioErr                 ; if not top, middle, or bottom then it is an error
        BRA insert3
topI                                  ; new node is now the Head node, switch accordingly
        LDY Empnode
        MOVW #$0004,0,Y              ; new Head node
        STX 2,Y                      ; N.A. of new Head is the address of previous Head
        
        MOVB prio,4,Y                ; store char & prio for new Head node
        MOVB char,5,Y
        STY 0,X                      ; P.A. of previous Head is now new Head, newHead -> previousHead
        
        LDX Empnode
        STX Head
        INC count
        BRA fixEmpnode               ; increment since we added in a new node
middleI                              ; insert is in the middle
        LDY Empnode
        
        LDD 0,X                      ; swap data from P.A. and N.A. to input new node in the middle
        STD 0,Y
        STY 0,X
        STX 2,Y
        
        XGDX
        STY 2,X
        
        MOVB prio,4,Y
        MOVB char,5,Y
        INC count                    ; increment since we added in a new node
        BRA fixEmpnode
bottomI
        LDY Empnode
        MOVW #$D601,2,Y              ; next node will be the new TAIL / END NODE, move word into
        STX 0,Y                      ; store P.A. into new TAIL
        STY 2,X                      ; store address of  TAIL NODE into the previous node, endNode-1 -> endNode
        
        LDAB prio
        STAB 4,Y                     ; store char & prio into new TAIL node
        LDAB char
        STAB 5,Y
        INC count                    ; increment since we added in a new node
fixEmpnode                           ; create new Empnode - empty - 6 bytes
        LEAY 6,Y
        STY Empnode
        JSR PRINT
        JMP menu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DELETE
        LDAB count
        CMPB #0
        LBEQ buffEmpty
        
        JSR PRINT
        
        LDD #prompt1
        LDX printf
        JSR 0,X
        LDX getchar                 ; get the character from user
        JSR 0,X
        PSHD
        LDX putchar
        JSR 0,X
        PULD
        STAB char
        
        LDX Head                    ; point at first character of the first node
search
        LDAA 5,X
        CMPA char
        BEQ found

        LDD 2,X                      ; check if all nodes have been checked
        CPD Tail
        LBEQ notFound
        
        LDX 2,X                      ; go to N.A. of current node
        JMP search
found
        DEC count
        LDY 0,X
        CPY #$0004
        BEQ topDel
        
        LDY 2,X
        CPY #$D601
        BEQ bottomDel

        BRA middleDel
        CPY #$0004
topDel
        LDY 2,X                      ; Y is at N.A.
        MOVW #$0004,0,Y              ; P.A. of next node is Head - $0004
        CLR 5,X                      ; 5,X is char - delete
        STY Head
        JMP menu
middleDel
        LDY 2,X                      ; Y is at N.A.
        MOVW 0,X,0,Y                  ; move P.A. of nodeDeleting to nextNode
        CLR 5,X
        
        LDX 0,X                      ; move N.A. of previous to node after deletedNode
        STY 2,X
        JMP menu
bottomDel
        LDY 0,X                      ; Y is currently at the N.A.
        MOVW #$D601,2,Y              ; N.A. is TAIL, move word to do so
        CLR 5,X                      ; clear the character of the node (X+5)
        JMP menu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
COMPACT
        LDX #Buff
loop1   CPX Empnode                ; check if Buff is empnode, if it is then cannot comact any further
        BEQ done
        LDAB 5,X                     ; check if char is empty, if it is then we can compact accordingly
        CMPB #0
        BEQ cont1

cont2  LDAB #6                       ; increment to character of nextNode
        ABX
        BRA loop1                    ; loop back to check char of nextNode
cont1
        PSHX                         ; save location [X]
        LDD Empnode                  ; check previous node before Empnode,  Empnode-6
        SUBD #6
        XGDY
        PULX

        PSHY
        CPX 0,SP
        BEQ done1                     ; if this node is the same, then done and update empnode

        PULY
        LDAB 5,X                      ; check if character is cleared, if yes then we can adjust Empnode and continue to compact - done2

        CMPB #0
        BEQ done2

        MOVW 0,Y,0,X
        MOVW 2,Y,2,X
        MOVW 4,Y,4,X

        CLR 5,Y
        STY Empnode

        LDY 0,X

        CPY #$0004                     ; compare to see if head
        BEQ loop2

        STX 2,Y                        ; adjust Empnode
loop3   LDY 2,X
        STX 0,Y
        LDX 2,X
        BRA cont2

loop2   STX Head                       ; UPDATE LOCATION OF HEAD (NEW)
        BRA loop3
done
        LDD #compmsg1                  ; no available space - compact cannot be completed
        LDX printf
        JSR 0,X
        JMP menu
done1
        PULY                           ; adjust for new Empnode
        STY Empnode
        LDD #compmsg                   ; compact completed
        LDX printf
        JSR 0,X
        JMP menu                            ; return sub-routine
done2
        STY Empnode                     ; adjust new Empnode and go back to check for available space to compact
        BRA cont1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRINT
        LDD  #prmsg
        LDX  printf
        JSR  0,X
        LDAB count
        BNE  norm
        RTS
norm    LDY  Head
redo    PSHY
        LDAB 5,Y
        CLRA
        LDX putchar
        JSR 0,X
        PULY
        PSHY
        LDAB 4,Y
        CLRA
        PSHD
        LDD 2,Y
        PSHD
        LDD 0,Y
        PSHD
        LDD #nprmsg
        LDX printf
        JSR 0,X
        LEAS 6,SP
        PULY
        LDY 2,Y
        CPY #$D601
        BNE redo
        RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
buffFull
        LDD #fullmsg
        LDX printf
        JSR 0,X
        JMP menu
buffEmpty
        LDD #emptymsg
        LDX printf
        JSR 0,X
        JMP menu
prioErr
        LDD #prioE
        LDX printf
        JSR 0,X
        JMP menu
notfound
        LDD #nFoundmsg
        LDX printf
        JSR 0,X
        JMP menu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ORG $2000
Buff    RMB 120
count   RMB  1
prio    RMB 1
char    RMB 1
Head    RMB 2
Empnode RMB 2
Tail    DW $D601
printf  EQU $EE88
putchar EQU $EE86
getchar EQU $EE84
fullmsg DB CR
        FCC 'The buffer is full...'
        DB CR,LF,0
emptymsg DB CR
        FCC 'The buffer is empty...'
        DB CR,LF,0
prmsg   DB  CR,CR
        FCC 'Char   P.A.   N.A.   Prio '
        DB  CR
        FCC '__________________________'
        DB  CR,LF,0
nprmsg  FCC '       %X     %X     %u   '
        DB  CR,LF,0
prompt1 DB CR
        FCC 'Enter the desired character'
        DB  CR,0
prompt2 DB CR
        FCC 'Enter the desired priority (1-20)'
        DB  CR,0
nFoundmsg DB CR
        FCC 'The character you want to delete does no exist.....'
        DB  CR,0
prioE   DB CR
        FCC 'This priority already exists, Try again.'
        DB CR,0
compmsg DB CR
        FCC 'Compact successfully completed.'
        DB CR,0
compmsg1 DB CR
        FCC 'There is no available space to compact.....'
        DB CR,0
menuMsg DB CR,CR
        FCC 'Linked Lists Menu'
        DB  CR
        FCC '____________________________'
        DB CR
        FCC '1. Insert Data'
        DB  CR
        FCC '2. Delete Data'
        DB  CR
        FCC '3. Print Queue'
        DB  CR
        FCC '4. Compact Buffer'
        DB  CR
        FCC '5. Quit'
        DB  CR,LF,0
CR      EQU $0D
LF      EQU $0A
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
