


convert macro
        dw 28000000  / \0; VGA base
        dw 28571429  / \0; VGA set 1
        dw 29464286  / \0; VGA set 2
        dw 30000000  / \0; VGA set 3
        dw 31000000  / \0; VGA set 4
        dw 32000000  / \0; VGA set 5
        dw 33000000  / \0; VGA set 6
        dw 27000000  / \0; Digital
        endm


spd_192000:
        convert 192000

SetPi:
        ; the baud rate 
        ld hl,spd_192000

        ld a,$11          ; video timing
        call ReadNextReg

        
        add a,a           ; its words so 2 bytes oer entry
        add hl,a

        ld a, $40
        call WriteCtrl    ; select the PI

        ; write the prescalar
        ld e,(hl)
        inc hl
        ld d,(hl)
        call WriteRX

        ; PI Peripheral Enable : For communication with Pi
        ; $10 = Connect Rx to GPIO 14, Tx to GPIO 15
        ; $20 = Enable UART on GPIO 14,15

        NextReg $a0,$30 

        ret


ReadCtrl:
        push bc         
        ld bc, $153b
        in a,(c)
        pop bc
        ret

WriteCtrl:
        push bc
        ld bc, $153b
        out (c),a
        pop bc
        ret

ReadRX:                 ; return with a or 0 if empty
        push bc
        ld bc, $143b
        in a,(c)
        pop bc
        ret



; The UART's baud rate is determined by the prescalar 
; according to this formula:
; prescalar = Fsys / baudrate 
; Fsys = system clock from Video Timing Register ($11)

WriteRX:                // set prescaler HL
        push bc
        ld bc, $143b

        ld a,$7f      ; low 7 bits of prescaler, A msb = 0
        and l
        out (c),a

        add hl,hl

        ld a,$80      ; yop 7 bits of prescaler , A msb = 1
        or h
        out (c),a

        pop bc
        ret

WriteTX:
        push bc
        ld bc,$133b
        out (c),a
        pop bc
        ret

ReadTX:
        push bc
        ld bc,$133b
        in a,(c)
        pop bc
        ret

PiWriteWait: 
        call ReadTX
        and 2                   ; tx buffer is full
        jr z,PiWriteWait
        ret

PiReadWait: 
        call ReadTX
        and 1                   ; Rx buffer contains a byte
        jr z,PiReadWait
        ret


PiTx:   ; memory hl , length bc
        ld a,b
        or c
        ret z

        call PiWriteWait
        
        ld a,(hl)
        inc hl

        call WriteTX

        dec bc
        jr  PiTx

PiRx:   ; memory hl , length bc
        ld a,b
        or c
        ret z

        call PiReadWait

        call ReadRX

        ld (hl),a
        inc hl

        dec bc
        jr  PiRx

