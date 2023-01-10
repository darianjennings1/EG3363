; Darian Jennings , Microprocessors I , 11/10/2020
; Project 4 - Create a tic tac toe game to be played by two players. Program should keep track of entries and prompt the users in
; case of error as well as win, loss, or draw. The game should be repeatable if user desires so. The state of the game should be displayed so
; the user can decide their next move.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ORG $1000
main
      JSR init
      JSR play
      SWI
init                              ; reset tic-tac-toe character elements to spaces
      MOVB #0,count
      MOVB #$20,One
      MOVB #$20,Two
      MOVB #$20,Three
      MOVB #$20,Four
      MOVB #$20,Five
      MOVB #$20,Six
      MOVB #$20,Seven
      MOVB #$20,Eight
      MOVB #$20,Nine
      MOVW #0,user1               ; reset bits for user1 & user2
      MOVW #0,user2
      RTS
repeat
      LDD #repmsg                 ; ask if user wants to repeat the process
      LDX printf                  ;
      JSR 0,X                     ;
      LDX getchar                 ;
      JSR 0,X                     ;
      CMPB #'Y'                   ; if user enters 'Y' or 'y', restart program
      BEQ main                   ;
      CMPB #'y'                   ;
      BEQ main                   ;
      LDD #endmsg
      LDX printf
      JSR 0,X
      SWI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
play
      LDD #Gmsg                             ; starting game message
      LDX printf
      JSR 0,X
      LDD #Pat                              ; display pattern
      LDX printf
      JSR 0,X
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
again1
      MOVB #0,flag
      LDD #prompt1                           ; ask user1 to enter a number
      LDX printf
      JSR 0,X
      LDX getchar                 ; get a digit
      JSR 0,X
      PSHD                        ; push into stack - save the character into acc D.
      LDX putchar                 ; putchar - echo the number entered to the screen
      JSR 0,X
      PULD                        ; pull back from stack
      CMPB #$30                   ; $30 == 0
      LBLE inpErr1                     ; if input is < $30 we have an error
      CMPB #$39                   ; $39 == 9
      LBGT inpErr1                     ; if input is > $39 we have an error
      SUBB #$30                   ; ASCII offset to make a digit
      PSHB

      JMP checkInput              ; convert input and check if able to place
                                  ; if placed successfully will RTS here, if not will ask user to try again1
continue1
      LDD #Pat                    ; display pattern
      LDX printf
      JSR 0,X

      JMP checkWinner
finish1
      INC count                   ; increment counter for total moves made, check if winner
      LDAA count
      CMPA #9
      LBHS tie
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
again2
      MOVB #1,flag                ; user2 turn
      LDD #prompt2               ; ask user2 to enter a number
      LDX printf
      JSR 0,X
      LDX getchar                 ; get a digit
      JSR 0,X
      PSHD                        ; push into stack - save the character into acc D.
      LDX putchar                 ; putchar - echo the number entered to the screen
      JSR 0,X
      PULD                        ; pull back from stack
      CMPB #$30                   ; $30 == 0
      LBLT inpErr2                     ; if input is < $30 we have an error
      CMPB #$39                   ; $39 == 9
      LBGT inpErr2                     ; if input is > $39 we have an error
      SUBB #$30                   ; ASCII offset to make a digit
      PSHB

      JMP checkInput              ; check if there is a space or not if there is place the input if not ask to enter new digit
                                  ; if placed successfully will RTS here, if not will ask user to try again2
continue2
      LDD #Pat
      LDX printf
      JSR 0,X

      JMP checkWinner
finish2
      INC count
      LDAA count
      CMPA #9
      LBLO again1                ; if count < 9 then there are still available moves - keep playing
      LBHS tie
checkTurn
      LDAA flag
      CMPA #0
      BEQ finish1
      JMP finish2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
checkInput                       ; check what user entered
        CMPB #1
        LBEQ first
        CMPB #2
        LBEQ second
        CMPB #3
        LBEQ third
        CMPB #4
        LBEQ fourth
        CMPB #5
        LBEQ fifth
        CMPB #6
        LBEQ sixth
        CMPB #7
        LBEQ seventh
        CMPB #8
        LBEQ eighth
        CMPB #9
        LBEQ ninth
        RTS
first                              ; check if the spot they entered is a space or not
        LDD One
        CMPA #$20
        LBNE nonSpace              ; jmp if not a space

        LDAA flag                  ; if it is a space then check who's turn it is
        CMPA #0
        BNE placeOne
        BSET user1,$80             ; user1's turn
        MOVB #$58,One
        JMP continue1
placeOne                           ; user2's turn
        MOVB #$4F,One
        BSET user2,$80
        JMP continue2
second
        LDD Two
        CMPA #$20
        LBNE nonSpace

        LDAA flag
        CMPA #0
        BNE placeTwo
        BSET user1,$40             ; user1's turn
        MOVB #$58,Two
        JMP continue1
placeTwo
        MOVB #$4F,Two
        BSET user2,$40             ; user2's turn
        JMP continue2
third
        LDD Three
        CMPA #$20
        LBNE nonSpace
        LDAA flag
        CMPA #0
        BNE placeThree             ; user1's turn
        BSET user1,$20
        MOVB #$58,Three
        JMP continue1
placeThree                         ; user2's turn
        MOVB #$4F,Three
        BSET user2,$20
        JMP continue2
fourth
        LDD Four
        CMPA #$20
        LBNE nonSpace
        LDAA flag
        CMPA #0
        BNE placeFour
        BSET user1,$10             ; user1's turn
        MOVB #$58,Four
        JMP continue1
placeFour
        MOVB #$4F,Four             ; user2's turn
        BSET user2,$10
        JMP continue2
fifth
        LDD Five
        CMPA #$20
        LBNE nonSpace
        LDAA flag
        CMPA #0
        BNE placeFive
        BSET user1,$08             ; user1's turn
        MOVB #$58,Five
        JMP continue1
placeFive
        MOVB #$4F,Five             ; user2's turn
        BSET user2,$08
        JMP continue2
sixth
        LDD Six
        CMPA #$20
        LBNE nonSpace
        LDAA flag
        CMPA #0
        BNE placeSix
        BSET user1,$04             ; user1's turn
        MOVB #$58,Six
        JMP continue1
placeSix
        MOVB #$4F,Six              ; user2's turn
        BSET user2,$04
        JMP continue2
seventh
        LDD Seven
        CMPA #$20
        LBNE nonSpace
        LDAA flag
        CMPA #0
        BNE placeSeven
        BSET user1,$02             ; user1's turn
        MOVB #$58,Seven
        JMP continue1
placeSeven
        MOVB #$4F,Seven            ; user2's turn
        BSET user2,$02
        JMP continue2
eighth
        LDD Eight
        CMPA #$20
        LBNE nonSpace
        LDAA flag
        CMPA #0
        BNE placeEight
        BSET user1,$01             ; user1's turn
        MOVB #$58,Eight
        JMP continue1
placeEight
        MOVB #$4F,Eight            ; user2's turn
        BSET user2,$01
        JMP continue2
ninth
        LDD Nine
        CMPA #$20
        LBNE nonSpace
        LDAA flag
        CMPA #0
        BNE placeNine
        INC user1+1                ; user1's turn
        MOVB #$58,Nine
        JMP continue1
placeNine
        MOVB #$4F,Nine             ; user2's turn
        INC user2+1
        JMP continue2
nonSpace                                      ; if it was a space
        LDAA flag
        CMPA #0                             ; check who's turn it was
        LBNE moveErr2                          ; jump accordingly
        JMP moveErr1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
checkWinner
      BRSET user1,$E0,win1                  ; check if user1 has won using bit combinations of win
      BRSET user1,$1C,win1
      BRSET user1,$92,win1
      BRSET user1,$49,win1
      BRSET user1,$2A,win1

      LDAB user1+1                          ; check if 9th bit of user1 is set to 1
      BEQ cont                              ; if it is 0 then continue to check if user2 has won
      BRSET user1,$88,win1                  ; else if it is set then see if user1 has won
      BRSET user1,$24,win1
      BRSET user1,$03,win1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cont
      BRSET user2,$E0,win2                  ; check if user2 has won using bit combinations of win
      BRSET user2,$1C,win2
      BRSET user2,$92,win2
      BRSET user2,$49,win2
      BRSET user2,$2A,win2
      LDAB user2+1                          ; check if 9th bit of user2 is set to 1
      BNE cont1                             ; if it is NOT 0 then continue to check if user2 has won
      JMP checkTurn                                 ; not 0, then user2 has not won
cont1
      BRSET user2,$88,win2                  ; else if it is set then see if user1 has won
      BRSET user2,$24,win2
      BRSET user2,$03,win2
      JMP checkTurn
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
win1
      LDD #W1msg
      LDX printf
      JSR 0,X
      JMP repeat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
win2
      LDD #W2msg
      LDX printf
      JSR 0,X
      JMP repeat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tie
      LDD #Tiemsg                                       ; if >= 9 then board is full - TIE
      LDX printf
      JSR 0,X
      JMP repeat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
inpErr1
      LDD #Ierr
      LDX printf
      JSR 0,X
      JMP again1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
inpErr2
      LDD #Ierr
      LDX printf
      JSR 0,X
      JMP again2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveErr1
      LDD #Merr
      LDX printf
      JSR 0,X
      JMP again1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveErr2
      LDD #Merr
      LDX printf
      JSR 0,X
      JMP again2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ORG $1500
user1  DW 0                                                            ; first byte is first 8 numbers, second byte is 0 or 1 and is 9th slot
user2  DW 0                                                            ; word is 2-bytes
count  DB 0                                                            ; use count for 9 total turns
flag   DB 0                                                            ; use to track who's turn it is
Pat    DB        $0D,$0D,$31,$20,$20,$7C,$32,$20,$20,$7C,$33,$0D,$20       ; $7C = | , $20 = space, $2D = -
One    DB        $20,$20,$7C,$20
Two    DB        $20,$20,$7C,$20
Three  DB        $20,$0D,$20,$20,$20,$7C,$20,$20,$20,$7C,$0D
       DB        $2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D
       DB        $0D,$34,$20,$20,$7C,$35,$20,$20,$7C,$36,$0D,$20
Four   DB        $20,$20,$7C,$20
Five   DB        $20,$20,$7C,$20
Six    DB        $20,$0D,$20,$20,$20,$7C,$20,$20,$20,$7C,$0D
       DB        $2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D
       DB        $0D,$37,$20,$20,$7C,$38,$20,$20,$7C,$39,$0D,$20
Seven  DB        $20,$20,$7C,$20
Eight  DB        $20,$20,$7C,$20
Nine   DB        $20,$0D,$20,$20,$20,$7C,$20,$20,$20,$7C,$0D,0
repmsg DB   CR
       FCC  'Do you want to play again (Y/N)?'
       DB   $0D,0
endmsg DB   CR
       FCC  'You choose to end the game...goodbye!'
       DB   $0D,0
inputMsg DB CR
       FCC 'Enter a digit to place your move (1-9)'
       DB CR,0
W1msg  DB   CR
       FCC  '*******User1 has won!!!*******'
       DB   $0D,0
W2msg  DB   CR
       FCC  '*******User2 has won!!!*******'
       DB   $0D,0
Tiemsg DB   CR
       FCC  'Result of game is a tie...'
       DB   CR,CR,0
Gmsg   DB   CR
       FCC  'This is a two player tic-tac-toe game....START!'
       DB   CR,0
prompt1 DB   CR
       FCC  'User1 - Enter a number (1-9):'
       DB   CR,0
prompt2 DB   CR
       FCC  'User2 - Enter a number (1-9):'
       DB   CR,0
Ierr    DB   CR
       FCC  'Invalid input, restarting game...'
       DB   CR,0
Merr    DB   CR
       FCC  'Invalid move, place is occupied already, try again...'
       DB   CR,0
printf EQU  $EE88
putchar EQU  $EE86
getchar EQU  $EE84
CR     EQU  $0D
LF     EQU  $0A
       END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
