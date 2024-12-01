MY_BREAK	macro
        db $fd,00
		endm


	OPT Z80
	OPT ZXNEXTREG    


    seg     CODE_SEG, 			 4:$0000,$8000
    seg     CODE_SEG
start: 

	MY_BREAK


	xor a

	scf

	or a		; or clears c flag
	

	ld sp , StackStart

	call SetPi

	MY_BREAK

 ReadNextReg:
       push bc
       ld bc,$243b
       out (c),a
       inc b
       in a,(c)
       pop bc
       ret


include "pi_coms.s"


StackEnd:
	ds	128*3
StackStart:
	ds  2


THE_END:

 	savenex "player.nex",start
