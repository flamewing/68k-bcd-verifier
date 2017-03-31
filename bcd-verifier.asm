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
	CPU 68000
	padding off         ; We don't want AS padding out dc.b instructions
	listing purecode    ; We want listing file, but only the final code in expanded macros
	page	0           ; Don't want form feeds
	supmode on          ; We don't need warnings about privileged instructions
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	include "macros.asm"
	include "constants.asm"
	include "memory.asm"
StartOfRom:
	include "vectors.asm"
	include "header.asm"

; ===========================================================================
; ; Don't need/want to do anything here.
ErrorTrap:
	nop
	nop
	bra.s	ErrorTrap
; ===========================================================================
	include "inithw.asm"
; ===========================================================================
GameProgram:
	; clear VDP's write-pending flag
	tst.w	(VDP_control_port).l

.wait_dma:
	move.w	(VDP_control_port).l,d1    ; Fetch status word
	btst	#1,d1                      ; Is DMA bit set?
	bne.s	.wait_dma                  ; Wait here if it is

	lea	(RAM_Start&$FFFFFF).l,a6
	moveq	#0,d7
	move.w	#bytesToLcnt(RAM_End-RAM_Start),d6

.clr_ram:
	move.l	d7,(a6)+
	dbra	d6,.clr_ram

	bsr.w	VDPSetup
	bra.w	TestBCDOps
; ===========================================================================
VDPSetup:
	lea	(VDP_control_port).l,a0
	lea	(VDP_data_port).l,a1
	lea	(VDPSetupArray).l,a2
	moveq	#bytesToWcnt(VDPSetupArray_End-VDPSetupArray),d7

.reg_loop:
	move.w	(a2)+,(a0)
	dbra	d7,.reg_loop               ; set the VDP registers

	moveq	#0,d0
	move.l	#vdpComm($0000,VSRAM,WRITE),(VDP_control_port).l
	move.w	d0,(a1)
	move.w	d0,(a1)
	move.l	#vdpComm($0000,CRAM,WRITE),(VDP_control_port).l
	move.w	#bytesToWcnt(palette_line_size*4),d7

.clr_cram:
	move.w	d0,(a1)
	dbra	d7,.clr_cram

	dmaFillVRAM 0,$0000,$10000         ; fill entire VRAM with 0
	rts
; End of function VDPSetup
; ===========================================================================
VDPSetupArray:
	dc.w $8004      ; H-INT disabled, Enable HV counter read
	dc.w $8134      ; Display disabled, Genesis mode, DMA enabled, V-INT enabled, V res 28 cells
	dc.w $8230      ; PNT A base: $C000
	dc.w $8328      ; PNT W base: $A000
	dc.w $8407      ; PNT B base: $E000
	dc.w $857C      ; Sprite attribute table base: $F800
	dc.w $8600      ; Sprite Pattern Generator Base Address on low 64KB VRAM
	dc.w $8700      ; Background palette/color: 0/0
	dc.w $8800
	dc.w $8900
	dc.w $8A00      ; H-INT every scanline
	dc.w $8B00      ; EXT-INT off, V scroll by screen, H scroll by screen
	dc.w $8C81      ; H res 40 cells, no interlace, S/H disabled
	dc.w $8D3F      ; H scroll table base: $FC00
	dc.w $8E00      ; Nametable Pattern Generator Base Address on low 64KB VRAM
	dc.w $8F02      ; VRAM pointer increment: $0002
	dc.w $9001      ; Scroll table size: 64x32
	dc.w $9100      ; Disable window
	dc.w $9200      ; Disable window
	dc.w $93FF      ; DMA Length Counter $FFFF
	dc.w $94FF      ; See above
	dc.w $9500      ; DMA Source Address $0
	dc.w $9600      ; See above
	dc.w $9780      ; See above + VRAM fill mode
VDPSetupArray_End:
; ===========================================================================
H_int:
	rte
; ===========================================================================
V_int:
	rte
; ===========================================================================
TerminalFont:
	BINCLUDE "data/TerminalFont.bin"
TerminalFont_End
	even
; ===========================================================================
TerminalPal:
	BINCLUDE "data/TerminalPal.bin"
TerminalPal_End
	even
; ===========================================================================
	include "test-bcd.asm"
	include "print-text.asm"
	include "print-flags.asm"
	include "print-byte.asm"
	include "print-long.asm"
; ===========================================================================
Hex2Char:
	dc.b	'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'
; ===========================================================================
BCD_Results:
	BINCLUDE "data/bcd-table.bin"
; ===========================================================================
EndOfRom:
	END
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

