; this file gives the defination of random number generator function
; and a prototype for calling this function
[org 0x0100]

jmp start

startStr: db 'Press S for Single player and M for Multiplayer game', 0
startStr2:db 'Press any key to Start the game', 0
strScore: db 'Score: ', 0
strMissed: db'Missed:', 0

winText: db 'MUBARAKAN!!!! Tusi Jeet Gaye O',0
lossText: db 'O jaa oay haar gaye itni asaan game mein ',0
gameOverText:db 'You quit. Why bro game mein chass nai ayi?',0


endStr: db 'Game Over', 0
endStr2: db 'Press E to end and Press R to restart game', 0

rand: dw 0
randnum: dw 0

;Saving the old ISR for unhooking and jmp far functionality
oldTimer: dd 0
oldKeyboard: dd 0


;Single Player or Multiplayer
singlePlayer: dw 0
multiPlayer: dw 0

;ASCII of the 5 chaarcters will be stored in these variables
char1: dw 0
char2: dw 0
char3: dw 0
char4: dw 0
char5: dw 0

;If the characters have to be printed or not (used just when the program is started)
charBool1:dw 0
charBool2: dw 0
charBool3: dw 0
charBool4: dw 0
charBool5: dw 0

;for the speed of the characters
speed1: dw 0
speed2:dw 0
speed3: dw 0
speed4: dw 0
speed5: dw 0

;the constant speed of the characters. it is reduced when score is above 8
time1: dw 15
time2: dw 20
time3: dw 5
time4: dw 17
time5: dw 7

;for the timer of the game
speedSW: dw 0
SWsec: dw 0
SWmin: dw 0

;positions of the falling alphabets
position1: dw 0
position2: dw 0
position3: dw 0
position4: dw 0
position5: dw 0

;score variable and missed variable
score: dw 0
missed: dw 0

;position of the box
boxPosition: dw 3920  ;for single player

boxPosition2: dw 3880
boxPosition1: dw 3960

;boolean variables for winning and losing condition
matchLost: dw 0
matchWon:dw 0

gameOver: dw 0

playAgain: dw 0

;for speed 2x
shift: dw 0


;for stopWatch
timertick: dw 0
mins: dw 0
secs: dw 0


printNumber:
    push bp
    mov bp, sp
    push es
    push ax
    push bx
    push cx
    push dx
    push di
	push 0xb800
	pop es
    mov ax, [bp+4] ; load number in ax
    mov bx, 10 ; use base 10 for division
    mov cx, 0 ; initialize count of digits
	
nextDigit:
    mov dx, 0 ; zero upper half of dividend
    div bx ; divide by 10
    add dl, 0x30 ; convert digit into ascii value
    push dx ; save ascii value on stack
    inc cx ; increment count of values
    cmp ax, 0 ; is the quotient zero
    jnz nextDigit ; if no divide it again
    mov di, [bp+6] ; point di to 70th column
	
nextPosition:
    pop dx ; remove a digit from the stack
    mov dh, 0x07 ; use normal attribute
    mov [es:di], dx ; print char on screen
    add di, 2 ; move to next screen location
    loop nextPosition ; repeat for all digits on stack
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop es
    pop bp
    ret 4

printstr:
	push bp
	  mov  bp, sp 
	  push es 
	  push ax 
	  push cx 
	  push si 
	  push di 

	  push ds  
	  pop  es                 ; load ds in es 
	  mov  di, [bp+4]         ; point di to string 
	  mov  cx, 0xffff         ; load maximum number in cx 
	  xor  al, al             ; load a zero in al 
	  repne scasb             ; find zero in the string 
	  mov  ax, 0xffff         ; load maximum number in ax 
	  sub  ax, cx             ; find change in cx 
	  dec  ax                 ; exclude null from length 
	  jz   exit               ; no printing if string is empty

	  mov  cx, ax             ; load string length in cx 
	  mov  ax, 0xb800 
	  mov  es, ax             ; point es to video base 
	  mov  al, 80             ; load al with columns per row 
	  mul  byte [bp+8]        ; multiply with y position 
	  add  ax, [bp+10]        ; add x position 
	  shl  ax, 1              ; turn into byte offset 
	  mov  di,ax              ; point di to required location 
	  mov  si, [bp+4]         ; point si to string 
	  mov  ah, [bp+6]         ; load attribute in ah 

	  cld                     ; auto increment mode 
nextchar:     lodsb                   ; load next char in al 
	  stosw                   ; print char/attribute pair 
	  loop nextchar           ; repeat for the whole string 

exit:         pop  di 
	  pop  si 
	  pop  cx 
	  pop  ax 
	  pop  es 
	  pop  bp 
	  ret  8
	  
	  
	  
printBox:
push bp
mov bp, sp
push ax
push di
mov ax, 0xb800
mov es, ax
mov di, [boxPosition]
mov ah, 07
mov al, 0xDC
mov [es:di], ax
pop di
pop ax
pop bp
ret

 StartMenu:
; this is for the static start menu to display on screen at start of the game
push bp
mov bp, sp
call clrscr
pusha
push si
push di

printAgain:
push 12 ;x position
push 10; y position
push 6Bh ;attribute
push startStr
call printstr
mov ah, 0
int 16h ;wait for a keystroke

cmp al, 's'
jz aagayS
cmp al, 'm'
jz aagayM
call clrscr
jmp printAgain

aagayS:
mov word [singlePlayer], 1
jmp aagay
aagayM:
mov word [multiPlayer], 1
aagay:
call clrscr
push 20
push 10
push 6Bh
push startStr2
call printstr
mov ah, 0
int 16h

pop di
pop si
popa
pop bp
ret


endMenu:
push bp
mov bp, sp
; push 30
; push 10
; push 9Bh
; push endStr
; call printstr



; push 15
; push 12
; push 9Bh
; push endStr2
; call printstr

cmp word [matchLost],1
jz Lost

cmp word [matchWon],1
jz Won

cmp word [gameOver],1
jz over

jmp endofMenu
call clrscr
Lost:
	
	push 15
	push 12
	push 6Bh
	push lossText
	call printstr
	jmp endofMenu
Won:
	push 15
	push 12
	push 6Bh
	push winText
	call printstr
	jmp endofMenu
over:
	push 30
	push 10
	push 6Bh
	push gameOverText
	call printstr

endofMenu:
pop bp
ret

; stopWatch:
; push bp
; mov bp, sp
; inc word [speedSW]
; cmp [speedSW], 15
; jne endSW
; mov word [speedSW], 0


; endSW:
; pop bp
; ret

randG:
mov word [rand],0
mov word [randnum],0
push bp
mov bp, sp
pusha
cmp word [rand], 0
jne next
MOV AH, 00h 
INT 1AH
inc word [rand]
mov [randnum], dx
jmp next1
next:
mov ax, 25173
mul word  [randnum]
add ax, 13849
mov [randnum], ax
next1:xor dx, dx
mov ax, [randnum]
mov cx, [bp+4]
inc cx
div cx
add dl,'A'
mov [bp+6], dx
popa
pop bp
ret 2

randGnum:
mov word [rand],0
mov word [randnum],0
push bp
mov bp, sp
pusha
cmp word [rand], 0
jne nextt
MOV AH, 00h 
INT 1AH
inc word [rand]
mov [randnum], dx
jmp next2
nextt:
mov ax, 25173         
mul word  [randnum]   
add ax, 13849     
mov [randnum], ax
next2:xor dx, dx
mov ax, [randnum]
mov cx, [bp+4]
inc cx
div cx
mov [bp+6], dx
popa
pop bp
ret 2


;increment score and increment missed subroutine
incScore:
push bp
mov bp, sp
push es
push ax
push di 
add word [score], 1
call winningCondition 
cmp word [matchWon], 1 
je jeetGaye
;display the score on screen as well

push 76
push word [score]
call printNumber

jeetGaye:
pop di
pop ax
pop es
pop bp
ret

incMissed:
push bp
mov bp, sp
push es
push ax
push di
add word [missed], 1

;check for losing condition
call losingCondition
cmp word [matchLost], 0
jne matchLostt ;will not display 10 on screen
;display the score on screen as well

push 116
push word [missed]
call printNumber

matchLostt:
pop di
pop ax
pop es
pop bp
ret

losingCondition:
;returns 0in ax if match lost and 1 otherwise
push bp
mov bp, sp
push ax

mov ax, [missed]
cmp word [multiPlayer], 1
je multiLose

cmp ax, 10
je lostMatch
jmp endLosing

multiLose:
cmp ax, 20
je lostMatch
jmp endLosing

lostMatch:
mov word [matchLost], 1

endLosing:
pop ax
pop bp
ret


winningCondition:
push bp
mov bp,sp
push ax

cmp word [multiPlayer], 1
je multiWin
cmp word [score], 10
jne endWinning

mov word [matchWon], 1

multiWin:
cmp word [score], 20
jne endWinning
mov word [matchWon], 1

endWinning:
pop ax
pop bp
ret


changeEverything:
push ax
sub sp, 2
push 25
call randG
pop ax
mov ah, 0x0E
mov word[char1], ax
mov ax, 0
sub sp, 2
push 79
call randGnum
pop ax
shl ax, 1
add ax, 50
cmp ax, 160
jae mover1
add ax, 160
mover1:
mov word[position1], ax
pop ax
ret



changeEverything2:
push ax
sub sp, 2
push 25
call randG
pop ax
mov ah, 0x0E
mov word[char2], ax
mov ax, 0
sub sp, 2
push 79
call randGnum
pop ax
shl ax, 1
add ax, 60
cmp ax, 160
jae mover2
add ax, 160
mover2:
mov word[position2], ax
pop ax
ret
 
 

changeEverything3:
push ax
sub sp, 2
push 25
call randG
pop ax
mov ah, 0x0E
mov word[char3], ax
mov ax, 0
sub sp, 2
push 79
call randGnum
pop ax
shl ax, 1
add ax, 20
cmp ax, 160
jae mover3
add ax, 160
mover3:
mov word[position3], ax
pop ax
ret



changeEverything4:
push ax
sub sp, 2
push 25
call randG
pop ax
mov ah, 0x0E
mov word[char4], ax
mov ax, 0
sub sp, 2
push 79
call randGnum
pop ax
shl ax, 1
add ax, 30
cmp ax, 160
jae mover4
add ax, 160
mover4:
mov word[position4], ax
pop ax
ret



changeEverything5:
push ax
sub sp, 2
push 25
call randG
pop ax
mov ah, 0x0E
mov word[char5], ax
mov ax, 0
sub sp, 2
push 79
call randGnum
pop ax
shl ax, 1
add ax, 44
cmp ax, 160
jae mover5
add ax, 160
mover5:
mov word[position5], ax
pop ax
ret


printScore:
push bp
mov bp, sp
push es
push di
push ax

push 30
push 0
push 07
push strScore
call printstr

push 50
push 0
push 07
push strMissed
call printstr

push 0xb800
pop es
mov word di, 76
mov ah, 07
mov al, 0x30
mov [es:di], ax
mov word di, 116
mov [es:di], ax

pop ax
pop di
pop es
pop bp
ret


clrscr: 
	 pusha
	 pushf
	 mov ax, 0xb800
	 mov es, ax ; point es to video base
	 xor di, di ; point di to top left column
	 mov ax, 0x0720 ; space char in normal attribute
	 mov cx, 2000 ; number of screen locations
	 cld ; auto increment mode
	 rep stosw ; clear the whole screen
	 popf
	 popa
	 ret 

sleep:
	push bp
	mov bp, sp
    push si
    push cx
    mov cx, 0xFFFF
delay: 
    loop delay
	
    pop cx
    pop si
	pop bp
    ret 

; a function to generate random number between 0 and n
; input: n, can be accessed using bp+4
; output: random number can be accessed in function using bp+6
RANDNUM:
   push bp
   mov bp,sp
   push ax
   push cx
   push dx
   
   MOV AH, 00h  ; interrupts to get system time        
   INT 1AH      ; CX:DX now hold number of clock ticks since midnight      
   mov  ax, dx
   xor  dx, dx
   mov  cx, [bp+4] 
   inc cx   
   div  cx       ; here dx contains the remainder of the division - from 0 to 9
   mov [bp+6], dx
   pop dx
   pop cx
   pop ax
   pop bp   
   ret 2
   
generateAlpha:
    push bp
    mov bp, sp
    push ax
    push cx
    push dx

    ; Get system time for randomness
    mov ah, 00h
    int 1ah      ; CX:DX holds the number of clock ticks since midnight
    mov ax, dx   ; Move DX (the random seed) into AX
    xor dx, dx
    mov cx, [bp+4]  
    inc cx
    div cx          

    add dx, 41h     ; Convert 0-25 to ASCII 'A'-'Z' (41h is ASCII for 'A')

    mov [bp+6], dx  ; Store the result in the output location
    pop dx
    pop cx
    pop ax
    pop bp
    ret 2   	; Return and clean up the stack
	
	
calculatetimer:
inc word[timertick]

cmp word[timertick], 15
jne endtimer

mov word[timertick],0
inc word[secs]


cmp word[secs],59
jae incmin


jmp endtimer
incmin:
mov word[secs],0
inc word[mins]

endtimer:
ret
printStopWatch:
call calculatetimer
mov ax,0
push ax
push word[mins]
call printNumber
mov ax,0xb800
mov es,ax
mov al,':'
mov ah,0x0F
mov [es:2],ax
mov ax,4
push ax
push word[secs]
call printNumber
ret



	
saveTimer:
push bp
mov bp, sp
cli
	xor ax, ax
	mov es, ax
	mov ax, [es:8*4] ;timer segment
	mov [oldTimer], ax
	mov ax, [es:8*4+2] ;timer offset
	mov [oldTimer+2], ax
	sti
    pop bp
	ret
	
hookTimer:
	push bp
	mov bp, sp
	cli
	xor ax, ax
	mov es, ax
	mov [es:8*4+2], cs
	mov word [es:8*4], newTimer
	sti
	pop bp
	ret
	
newTimer:
	;all the movement of the alphabets is here
	call printStopWatch
	xor bx, bx
	call characterDisplay
	call characterDisplay2
	call characterDisplay3
	call characterDisplay4
	call characterDisplay5

	
	jmp far [cs:oldTimer]
	






saveKeyboard:
push bp
mov bp, sp
push ax
push es
xor ax, ax
mov es, ax
mov ax, [es:9*4]
mov [oldKeyboard], ax
mov ax, [es:9*4+2]
mov [oldKeyboard], ax
pop es
pop ax
pop bp
ret

hookKeyboard:
push bp
mov bp, sp
push es
push ax
cli
xor ax, ax
mov es, ax
mov word [es:9*4], newKeyboard
mov word [es:9*4+2], cs
sti
pop ax
pop es
pop bp
ret

newKeyboard:
push ax
push 0xb800
pop es

in al, 0x60
;if right shift pressed, set bool

cmp al, 0x01
je escPressedS

cmp al, 0x36
jne cmpLeftShift
mov word [shift], 1
jmp endKeyboard

;if left shift pressed set bool
cmpLeftShift:
cmp al, 0x2a
jne cmpRshiftRelease
mov word [shift], 1
jmp endKeyboard

;if shift released, reset bool
cmpRshiftRelease:
cmp al, 0xB6
jne cmpLShiftRelease
mov word [shift], 0
jmp endKeyboard

cmpLShiftRelease:
cmp al, 0xaa
jne noShift
mov word [shift], 0
jmp endKeyboard

noShift:
cmp byte al, 0x4b
jz moveLeft
cmp byte al, 0x4d
jz moveRight
jmp exitKB

moveLeft:
mov di, [boxPosition]
mov word [es:di], 0x0720 ;erasing previous box position
cmp word di, 3840  ;comparing with left most position
jbe rightMost
sub di, 2
sub word [boxPosition], 2
cmp word [shift], 1
jne speed2x

sub di, 2
sub word [boxPosition], 2

speed2x:

mov ah, 07
mov al, 0xDC
mov [es:di], ax
jmp endKeyboard

rightMost:
mov word [boxPosition], 3998
mov word di, 3998
mov ah, 07
mov al, 0xDC
mov [es:di], ax
jmp endKeyboard


moveRight:
mov di, [boxPosition]
mov word [es:di], 0x0720 ;erasing previous box position
cmp word di, 3998
jae leftMost
add di, 2
add word [boxPosition], 2
cmp word [shift], 1
jne speed2xR

add word[boxPosition], 2
add di, 2


speed2xR:
mov ah, 07
mov al, 0xDC
mov [es:di], ax
jmp endKeyboard

leftMost:
mov word [boxPosition], 3840
mov word di, 3840
mov ah, 07
mov al, 0xDC
mov [es:di], ax
jmp endKeyboard

escPressedS:
mov word [gameOver], 1



endKeyboard:
; jmp far [cs: oldKeyboard]

exitKB:
mov al, 0x20
out 0x20, al
pop ax
iret


	
characterDisplay:
inc word [speed1]
; cmp word [score], 8
; jb noChange1
; mov word [time1], 7;increasing speed
; noChange1:
mov bx, [time1]
cmp word [speed1], bx
jb end1
mov word [speed1], 0
cmp word [charBool1], 0
jne movdown1
mov word [rand], 0
mov word [randnum], 0
call changeEverything
mov ax, 0xb800
mov es, ax
mov di, [position1]
mov ax, [char1]
mov word[es:di], ax
inc word [charBool1]
jmp end1
movdown1:
mov di, [position1]
mov word[es:di], 0x0720
add word [position1], 160
cmp word [position1], 3840
ja changechar1
mov di, [position1]
mov ax, [char1]
mov ah, 01
mov word[es:di], ax
jmp end1
changechar1:
;check if box position is equal to this position, add to score, else add to Missed
mov ax, [position1]

cmp word [multiPlayer], 1
je MP1

;for Single player
cmp ax, [boxPosition]
je addScore
call incMissed
;if match is lost. we have to end the program
jmp missedAdded


MP1:
;for Multiplayer
cmp ax, [boxPosition1]
je addScore
cmp ax, [boxPosition2]
je addScore
call incMissed
jmp missedAdded

addScore:
call incScore


missedAdded:
mov word[rand], 0
mov word[randnum], 0
call changeEverything

end1:
ret




characterDisplay2:
 inc word [speed2]
; cmp word [score], 8
; jb noChange2
; mov word [time2], 10 ;increasing speed
; noChange2:
mov bx, [time2]
cmp word [speed2], bx
jb midend2
mov word [speed2], 0
cmp word [charBool2], 0
jne movdown2
mov word[rand], 0
mov word[randnum], 0
call changeEverything2
mov ax, 0xb800
mov es, ax
mov di, [position2]
mov ax, [char2]
mov ah, 2
mov word[es:di], ax
inc word [charBool2]
jmp end2
movdown2:
mov di, [position2]
mov word[es:di], 0x0720
add word [position2], 160
cmp word [position2], 3840
ja changechar2
mov di, [position2]
mov ax, [char2]
mov ah, 2
mov word[es:di], ax
midend2:
jmp end2
changechar2:
mov ax, [position2]
cmp word [multiPlayer], 1
je MP2

;for Single player
cmp ax, [boxPosition]
je addScore2
call incMissed
;if match is lost. we have to end the program
jmp missedAdded2


MP2:
;for Multiplayer
cmp ax, [boxPosition1]
je addScore2
cmp ax, [boxPosition2]
je addScore2
call incMissed
jmp missedAdded2

addScore2:
call incScore


missedAdded2:
mov word[rand], 0
mov word[randnum], 0
call changeEverything2

end2:
ret


characterDisplay3:
inc word [speed3]
; cmp word [score], 8
; jb noChange3
; mov word [time3], 2;increasing speed
; noChange3:
mov bx, [time3]
cmp word [speed3], bx
jb midend3
mov word [speed3], 0
cmp word [charBool3], 0
jne movdown3
mov word[rand], 0
mov word[randnum], 0
call changeEverything3
mov ax, 0xb800
mov es, ax
mov di, [position3]
mov ax, [char3]
mov word[es:di], ax
inc word [charBool3]
jmp end3
movdown3:
mov di, [position3]
mov word[es:di], 0x0720
add word [position3], 160
cmp word [position3], 3840
ja changechar3
mov di, [position3]
mov ah, 3
mov ax, [char3]
mov ah, 3
mov word[es:di], ax
midend3:
jmp end3
changechar3:

mov ax, [position3]
cmp word [multiPlayer], 1
je MP3

;for Single player
cmp ax, [boxPosition]
je addScore3
call incMissed
;if match is lost. we have to end the program
jmp missedAdded3


MP3:
;for Multiplayer
cmp ax, [boxPosition1]
je addScore3
cmp ax, [boxPosition2]
je addScore3
call incMissed
jmp missedAdded3

addScore3:
call incScore


missedAdded3:
mov word[rand], 0
mov word[randnum], 0
call changeEverything3

end3:
ret


characterDisplay4:
inc word [speed4]
; cmp word [score], 8
; jb noChange4
; mov word [time4], 8 ;increasing speed
; noChange4:
mov bx, [time4]
cmp word [speed4], bx
jb midend4
mov word [speed4], 0
cmp word [charBool4], 0
jne movdown4
mov word[rand], 0
mov word[randnum], 0
call changeEverything4
mov ax, 0xb800
mov es, ax
mov di, [position4]
mov ax, [char4]
mov ah, 4
mov word[es:di], ax
inc word [charBool4]
jmp end4
movdown4:
mov di, [position4]
mov word[es:di], 0x0720
add word [position4], 160
cmp word [position4], 3840
ja changechar4
mov di, [position4]
mov ax, [char4]
mov ah, 4
mov word[es:di], ax
midend4:
jmp end4
changechar4:

mov ax, [position4]

cmp word [multiPlayer], 1
je MP4

;for Single player
cmp ax, [boxPosition]
je addScore4
call incMissed
;if match is lost. we have to end the program
jmp missedAdded4


MP4:
;for Multiplayer
cmp ax, [boxPosition1]
je addScore4
cmp ax, [boxPosition2]
je addScore4
call incMissed
jmp missedAdded4

addScore4:
call incScore


missedAdded4:
mov word[rand], 0
mov word[randnum], 0
call changeEverything4

end4:
ret

characterDisplay5:
inc word [speed5]
; cmp word [score], 8
; jb noChange5
; mov word [time5], 3;increasing speed
; noChange5:
mov bx, [time5]
cmp word [speed5], bx
jb midend5
mov word [speed5], 0
cmp word [charBool5], 0
jne movdown5
mov word[rand], 0
mov word[randnum], 0
call changeEverything5
mov ax, 0xb800
mov es, ax
mov di, [position5]

mov ax, [char5]
mov ah, 5
mov word[es:di], ax
inc word [charBool5]
jmp end5
movdown5:
mov di, [position5]
mov word[es:di], 0x0720
add word [position5], 160
cmp word [position5], 3840
ja changechar5
mov di, [position5]
mov ax, [char5]
mov ah, 5
mov word[es:di], ax
midend5:
jmp end5
changechar5:

mov ax, [position5]

cmp word [multiPlayer], 1
je MP5

;for Single player
cmp ax, [boxPosition]
je addScore5
call incMissed
;if match is lost. we have to end the program
jmp missedAdded5


MP5:
;for Multiplayer
cmp ax, [boxPosition1]
je addScore5
cmp ax, [boxPosition2]
je addScore5
call incMissed
jmp missedAdded5

addScore5:
call incScore


missedAdded5:
mov word[rand], 0
mov word[randnum], 0
call changeEverything5

end5:
ret  
;-------------------------------------------------MULTIPLAYER FUNCTIONALITY-----------------------------------------

   	  
printBoxM:
push bp
mov bp, sp
push ax
push di
mov ax, 0xb800
mov es, ax
mov di, [boxPosition1]
mov ah, 07
mov al, 0xDC
mov [es:di], ax

mov di, [boxPosition2]
mov ah, 07
mov al, 0xDC
mov [es:di], ax

pop di
pop ax
pop bp
ret



; hookTimerM:
	; push bp
	; mov bp, sp
	; cli
	; xor ax, ax
	; mov es, ax
	; mov [es:8*4+2], cs
	; mov word [es:8*4], newTimerM
	; sti
	; pop bp
	; ret

hookKeyboardM:
push bp
mov bp, sp
push es
push ax
cli
xor ax, ax
mov es, ax
mov word [es:9*4], newKeyboardM
mov word [es:9*4+2], cs
sti
pop ax
pop es
pop bp
ret


newKeyboardM:
push ax
push 0xb800
pop es

in al, 0x60
;if right shift pressed, set bool
cmp al, 0x01
je escPressed

cmp al, 0x36
jne cmpLeftShiftM

mov word [shift], 1
jmp endKeyboardM

;if left shift pressed set bool
cmpLeftShiftM:
cmp al, 0x2a
jne cmpRshiftReleaseM
mov word [shift], 1
jmp endKeyboardM

;if shift released, reset bool
cmpRshiftReleaseM:
cmp al, 0xB6
jne cmpLShiftReleaseM
mov word [shift], 0
jmp endKeyboardM

cmpLShiftReleaseM:
cmp al, 0xaa
jne noShiftM
mov word [shift], 0
jmp endKeyboardM


;for left and right keys
noShiftM:
cmp byte al, 0x4b
jz moveLeftM1

cmp byte al, 0x4d
jz moveRightM1

cmp byte al, 30
jz moveLeftM2

cmp byte al, 32
jz moveRightM2

jmp endKeyboardM

moveLeftM1:

mov di, [boxPosition1]
cmp di, [boxPosition2]
je noErase1
mov word [es:di], 0x0720 ;erasing previous box position
noErase1:
cmp word di, 3840  ;comparing with left most position
jbe rightMostM1
sub di, 2
sub word [boxPosition1], 2
cmp word [shift], 1
jne speed2xM1

sub di, 2
sub word [boxPosition1], 2

speed2xM1:

mov ah, 07
mov al, 0xDC
mov [es:di], ax
jmp endKeyboardM

rightMostM1:
mov word [boxPosition1], 3998
mov word di, 3998
mov ah, 07
mov al, 0xDC
mov [es:di], ax
jmp endKeyboardM


moveRightM1:
mov di, [boxPosition1]
cmp di, [boxPosition2]
je noErase2
mov word [es:di], 0x0720 ;erasing previous box position
noErase2:
cmp word di, 3998
jae leftMostM1
add di, 2
add word [boxPosition1], 2
cmp word [shift], 1
jne speed2xRM1

add word[boxPosition1], 2
add di, 2


speed2xRM1:
mov ah, 07
mov al, 0xDC
mov [es:di], ax
jmp endKeyboardM

leftMostM1:
mov word [boxPosition1], 3840
mov word di, 3840
mov ah, 07
mov al, 0xDC
mov [es:di], ax
jmp endKeyboardM




moveLeftM2:

mov di, [boxPosition2]
cmp di, [boxPosition1]
je noErase3
mov word [es:di], 0x0720 ;erasing previous box position
noErase3:
cmp word di, 3840  ;comparing with left most position
jbe rightMostM2
sub di, 2
sub word [boxPosition2], 2
cmp word [shift], 1
jne speed2xM2

sub di, 2
sub word [boxPosition2], 2

speed2xM2:

mov ah, 07
mov al, 0xDC
mov [es:di], ax
jmp endKeyboardM

rightMostM2:
mov word [boxPosition2], 3998
mov word di, 3998
mov ah, 07
mov al, 0xDC
mov [es:di], ax
jmp endKeyboardM


moveRightM2:
mov di, [boxPosition2]
cmp di, [boxPosition1]
je noErase4
mov word [es:di], 0x0720 ;erasing previous box position
noErase4:
cmp word di, 3998
jae leftMostM2
add di, 2
add word [boxPosition2], 2
cmp word [shift], 1
jne speed2xRM2

add word[boxPosition2], 2
add di, 2


speed2xRM2:
mov ah, 07
mov al, 0xDC
mov [es:di], ax
jmp endKeyboardM

leftMostM2:
mov word [boxPosition2], 3840
mov word di, 3840
mov ah, 07
mov al, 0xDC
mov [es:di], ax
jmp endKeyboardM

escPressed:
mov word [gameOver], 1

endKeyboardM:
exitKBM:
mov al, 0x20
out 0x20, al
pop ax
iret



   
   
   
   
   ;----------------------------------------end game loop----------------------------------------------
   escapeLoop:
   hey:
   cmp word [gameOver], 1
   je endEscLoop
   cmp word [matchLost], 1
   je endEscLoop
   cmp word [matchWon], 1
   je endEscLoop
   
   cmp word [score], 8
   jb hey
   ja hey
   ;else change the speeds of falling alphabets
     ; mov ax, [time1]
    ; shr ax, 1
    mov word [time1], 7
   
     ; mov ax, [time2]
     ; shr ax, 1
    mov word [time2], 10
   
     ; mov ax, [time3]
     ; shr ax, 1
    mov word [time3], 2

     ; mov ax, [time4]
     ; shr ax, 1
    mov word [time4], 8
   
     ; mov ax, [time5]
     ; shr ax, 1
    mov word [time5], 3
 

   jmp hey
   endEscLoop:
   ret

start:

	call clrscr
	call StartMenu
	call clrscr
	call printScore
	call saveTimer
	call saveKeyboard

	cmp word [singlePlayer], 1
	jnz mPlayer
	call printBox
	cli
	call hookKeyboard
	call hookTimer
	sti
    call escapeLoop
	call clrscr
	cli
	xor ax, ax
	mov es, ax
	mov ax, [oldTimer]
	mov [es:8*4], ax
	mov ax, [oldTimer+2]
	mov [es:8*4+2], ax
	
	mov ax, [oldKeyboard]
	mov [es:9*4], ax
	mov ax, [oldKeyboard+2]
	mov [es:9*4+2], ax
	sti
	jmp endGame
	
	 mPlayer:
	 call printBoxM
	 cli
	 call hookKeyboardM
	 call hookTimer
	 sti
	 call escapeLoop
	 call clrscr
	 
	 cli
	xor ax, ax
	mov es, ax
	mov ax, [oldTimer]
	mov [es:8*4], ax
	mov bx, [oldTimer+2]
	mov [es:8*4+2], bx
	
	mov cx, [oldKeyboard]
	mov [es:9*4], cx
	mov dx, [oldKeyboard+2]
	mov [es:9*4+2], dx
	sti
	jmp endGame
	
	
	
endGame:
call endMenu
mov word [multiPlayer], 0
mov word [singlePlayer], 0
mov word [charBool1], 0
mov word [charBool2], 0
mov word [charBool4], 0
mov word [charBool3], 0
mov word [charBool5], 0
mov word[matchLost], 0
mov word [matchWon], 0
mov word [gameOver], 0
mov word [score], 0
mov word [missed], 0
mov word [boxPosition], 3920  ;for single player

mov word [boxPosition2], 3880
mov word [boxPosition1], 3960


again1:

mov ax, 0
int 16h
cmp al, 'e'
je endgame1
cmp al, 'r'
je start 
call clrscr
jmp again1


endgame1:
mov dx, start
add dx,15
mov cl, 4
shr dx, cl
mov ax, 0x3100
int 21h