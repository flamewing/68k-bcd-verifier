; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;   This is free software: you can redistribute it and/or modify
;   it under the terms of the GNU General Public License as published by
;   the Free Software Foundation, either version 3 of the License, or
;   (at your option) any later version.
;
;   This software is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.
;
;   You should have received a copy of the GNU General Public License
;   along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Helper macro
testOp macro oper,flags,dst,src
	move.b	d3,d4                      ; Copy destination operand to d4
	moveq	#flags,d6                  ; Set initial condition codes
	move.w	d6,ccr                     ; Set initial condition codes
    if "src"<>""
	oper.b	src,dst                    ; Perform dest <- dest oper src
    else
	oper.b	dst                        ; Perform dest <- oper dest
    endif
	bsr.w	CheckResult
    endm
; ===========================================================================
TestBCDOps:
	dma68kToVDP TerminalFont,$0420,TerminalFont_End-TerminalFont,VRAM
	dma68kToVDP TerminalPal ,$0000,TerminalPal_End -TerminalPal ,CRAM
	lea BCD_Results(pc),a0
	lea (RAM_Start).l,a1
	lea (Failure_Counts).l,a2

	lea (RAM_Start+4*64*2).l,a1

	moveq	#0,d7
	moveq	#0,d6
	move.l	d6,(a2)                    ; Failure count: flags
	move.l	d6,4(a2)                   ; Failure count: results
	move.w	#WHITE|'a',(Current_Op).w  ; We are doing abcd
	move.l	#$a5a5a500,d2              ; Source operand with MSB bits set
	move.l	#$5a5a5a5a,d4              ; to trigger bugs in emulators

.abcd_outer_loop:
	moveq	#0,d3                      ; Destination operand

.abcd_inner_loop:
	testOp abcd,0,d4,d2
	testOp abcd,Z,d4,d2
	testOp abcd,X|C,d4,d2
	testOp abcd,X|Z|C,d4,d2
	addq.b	#1,d3
	bcc.s	.abcd_inner_loop
	addq.b	#1,d2
	bcc.s	.abcd_outer_loop

	addq.w	#8,a2
	moveq	#0,d6
	move.l	d6,(a2)                    ; Failure count: flags
	move.l	d6,4(a2)                   ; Failure count: results
	moveq	#0,d2                      ; Source operand
	move.w	#WHITE|'s',(Current_Op).w  ; We are doing sbcd

.sbcd_outer_loop:
	moveq	#0,d3                      ; Destination operand

.sbcd_inner_loop:
	testOp sbcd,0,d4,d2
	testOp sbcd,Z,d4,d2
	testOp sbcd,X|C,d4,d2
	testOp sbcd,X|Z|C,d4,d2
	addq.b	#1,d3
	bcc.s	.sbcd_inner_loop
	addq.b	#1,d2
	bcc.s	.sbcd_outer_loop

	addq.w	#8,a2
	moveq	#0,d6
	move.l	d6,(a2)                    ; Failure count: flags
	move.l	d6,4(a2)                   ; Failure count: results
	moveq	#0,d3                      ; Destination operand
	move.w	#WHITE|'n',(Current_Op).w  ; We are doing nbcd

.nbcd_loop:
	testOp nbcd,0,d4
	testOp nbcd,Z,d4
	testOp nbcd,X|C,d4
	testOp nbcd,X|Z|C,d4
	addq.b	#1,d3
	bcc.s	.nbcd_loop

	; Report failure counts
	lea (Failure_Counts).l,a3
	lea (RAM_Start+0*64*2+8*2).l,a1
	lea	HeaderText(pc),a2
	bsr.w	PrintText
	lea (RAM_Start+1*64*2+8*2).l,a1
	lea	abcdText(pc),a2
	bsr.w	PrintText
	move.l	(a3)+,d0
	move.w	#BLUE|'$',d1
	bsr.w	PrintLong
	move.w	#' ',(a1)+
	move.l	(a3)+,d0
	move.w	#BLUE|'$',d1
	bsr.w	PrintLong
	move.w	#' ',(a1)+
	lea (RAM_Start+2*64*2+8*2).l,a1
	lea	sbcdText(pc),a2
	bsr.w	PrintText
	move.l	(a3)+,d0
	move.w	#BLUE|'$',d1
	bsr.w	PrintLong
	move.w	#' ',(a1)+
	move.l	(a3)+,d0
	move.w	#BLUE|'$',d1
	bsr.w	PrintLong
	move.w	#' ',(a1)+
	lea (RAM_Start+3*64*2+8*2).l,a1
	lea	nbcdText(pc),a2
	bsr.w	PrintText
	move.l	(a3)+,d0
	move.w	#BLUE|'$',d1
	bsr.w	PrintLong
	move.w	#' ',(a1)+
	move.l	(a3)+,d0
	move.w	#BLUE|'$',d1
	bsr.w	PrintLong
	move.w	#' ',(a1)+

	dma68kToVDP RAM_Start, $C000,$1000,VRAM
	move.w	#$8174,(VDP_control_port).l

.done:
	nop
	nop
	bra.s	.done
; ---------------------------------------------------------------------------
HeaderText:
	dc.b " errors value  flags",0
abcdText:
	dc.b " abcd  ",0
sbcdText:
	dc.b " sbcd  ",0
nbcdText:
	dc.b " nbcd  ",0
	even
; ===========================================================================
CheckResult:
	move.w	sr,d5                      ; Copy sr to d5
	swap	d6                         ; Save initial condition codes
	move.w	d5,d6                      ; Copy condition codes to d6
	lsl.w	#8,d5                      ; Shift into place
	move.b	d4,d5                      ; Move operation result to low byte
	cmp.w	(a0),d5                    ; Does it match expected reault?
	beq.w	.done                      ; Branch if not
	cmp.b	(a0),d6                    ; Are flags the same?
	beq.s	.same_flags                ; Branch if yes
	addq.l	#1,(a2)                    ; Increment flag error count

.same_flags:
	cmp.b	1(a0),d4                   ; Are results the same?
	beq.s	.same_result               ; Branch if yes
	addq.l	#1,4(a2)                   ; Increment result error count

.same_result:
	addq.l	#1,d7                      ; Increment overall failure count
	cmpi.l	#24,d7                     ; Is it less than 24?
	bhi.w	.done                      ; Branch if not
	movem.l	d0-d7/a2,-(sp)
	movem.w	d2-d4,-(sp)
	move.l	a1,usp                     ; Save current position
	; "XNZVC Xbcd ($SS,)?$DD=$RR XNZVC ($RR XNZVC) "
	;  ^
	swap	d6
	move.b	d6,d0
	swap	d6
	move.b	d0,d1
	move.w	#BLUE,d3
	bsr.w	PrintFlags
	move.w	#' ',(a1)+
	; "XNZVC Xbcd ($SS,)?$DD=$RR XNZVC ($RR XNZVC) "
	;        ^
	move.w	(Current_Op).w,(a1)+       ; a|s|n
	move.w	#WHITE|'b',(a1)+
	move.w	#WHITE|'c',(a1)+
	move.w	#WHITE|'d',(a1)+
	move.w	#' ',(a1)+

	movem.w	(sp)+,d2-d4
	cmpi.w	#WHITE|'n',(Current_Op).w  ; Is this nbcd?
	beq.s	.report_common          ; Branch if yes
	; "XNZVC Xbcd $SS,$DD=$RR XNZVC ($RR XNZVC) "
	;             ^
	move.b	d2,d0
	move.w	#WHITE|'$',d1
	move.w	d3,-(sp)
	bsr.w	PrintByte
	move.w	#',',(a1)+
	move.w	(sp)+,d3

.report_common:
	; "XNZVC Xbcd ($SS,)?$DD=$RR XNZVC ($RR XNZVC) "
	;                    ^
	move.b	d3,d0
	move.w	#WHITE|'$',d1
	bsr.w	PrintByte
	; "XNZVC Xbcd ($SS,)?$DD=$RR XNZVC ($RR XNZVC) "
	;                       ^
	move.w	#WHITE|'=',(a1)+
	; "XNZVC Xbcd ($SS,)?$DD=$RR XNZVC ($RR XNZVC) "
	;                        ^
	move.b	d4,d0
	move.w	#GREEN|'$',d1
	cmp.b	1(a0),d0
	beq.s	.not_red
	move.w	#RED|'$',d1

.not_red:
	bsr.w	PrintByte
	move.w	#' ',(a1)+
	; "XNZVC Xbcd ($SS,)?$DD=$RR XNZVC ($RR XNZVC) "
	;                            ^
	move.b	d6,d0
	move.b	(a0),d1
	move.w	#GREEN,d3
	bsr.w	PrintFlags
	move.w	#' ',(a1)+
	; "XNZVC Xbcd ($SS,)?$DD=$RR XNZVC ($RR XNZVC) "
	;                                  ^
	move.w	#WHITE|'(',(a1)+
	move.b	1(a0),d0
	move.w	#WHITE|'$',d1
	bsr.w	PrintByte
	move.w	#' ',(a1)+
	; "XNZVC Xbcd ($SS,)?$DD=$RR XNZVC ($RR XNZVC) "
	;                                       ^
	move.b	(a0),d0
	move.b	d0,d1
	move.w	#WHITE,d3
	bsr.w	PrintFlags
	; "XNZVC Xbcd ($SS,)?$DD=$RR XNZVC ($RR XNZVC) "
	;                                            ^
	move.w	#WHITE|')',(a1)+
	; Restore registers and move to next line
	move.l	usp,a1                     ; Restore original position
	lea	64*2(a1),a1                    ; Move to next line
	movem.l	(sp)+,d0-d7/a2

.done:
	addq.l	#2,a0
	rts
; ===========================================================================

