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
EntryPoint:
	; Skip the setup code if it was done already.
	tst.l	(HW_Port_1_Control-1).l              ; test ports A and B control
	bne.w	GameProgram
	tst.w	(HW_Expansion_Control-1).l           ; test port C control
	bne.w	GameProgram

	lea	.setup_values(pc),a5
	movem.w	(a5)+,d5-d7
	movem.l	(a5)+,a0-a4
	move.b	HW_Version-Z80_Bus_Request(a1),d0    ; get hardware version
	andi.b	#$F,d0
	; branch if hardware is older than Genesis III
	beq.s	.skip_tmss
	; TMSS initialization
	move.l	#'SEGA',Security_Addr-Z80_Bus_Request(a1)

.skip_tmss:
	move.w	(a4),d0                              ; clear VDP's write-pending flag
	moveq	#0,d0
	movea.l	d0,a6
	move.l	a6,usp                               ; set usp to $0
	moveq	#.vdp_init_values_End-.vdp_init_values-1,d1

.vdp_loop:
	move.b	(a5)+,d5                             ; add $8000 to value
	move.w	d5,(a4)                              ; move value to VDP register
	add.w	d7,d5                                ; next register
	dbra	d1,.vdp_loop

	move.l	(a5)+,(a4)                           ; set VRAM write mode
	move.w	d0,(a3)                              ; clear the screen
	move.w	d7,(a1)                              ; stop the Z80
	move.w	d7,(a2)                              ; reset the Z80

.wait_z80:
	btst	d0,(a1)                              ; has the Z80 stopped?
	bne.s	.wait_z80                            ; if not, branch

	moveq	#z80_code_End-z80_code_Begin-1,d2

.z80_loop:
	move.b	(a5)+,(a0)+
	dbra	d2,.z80_loop

	move.w	d0,(a2)
	move.w	d0,(a1)                              ; start the Z80
	move.w	d7,(a2)                              ; reset the Z80

.ram_loop:
	move.l	d0,-(a6)
	dbra	d6,.ram_loop                         ; clear the entire RAM

	move.l	(a5)+,(a4)                           ; set VDP display mode and increment
	move.l	(a5)+,(a4)                           ; set VDP to CRAM write
	moveq	#bytesToLcnt($80),d3

.cram_loop:
	move.l	d0,(a3)
	dbra	d3,.cram_loop                        ; clear CRAM

	move.l	(a5)+,(a4)
	moveq	#bytesToLcnt($50),d4

.vsram_loop:
	move.l	d0,(a3)
	dbra	d4,.vsram_loop

	moveq	#psg_init_values_End-psg_init_values-1,d5

.psg_loop:
	move.b	(a5)+,PSG_input-VDP_data_port(a3)    ; reset the PSG
	dbra	d5,.psg_loop

	move.w	d0,(a2)
	movem.l	(a6),d0-a6                           ; clear all registers
	disableInts
	bra.s	GameProgram
; ===========================================================================
.setup_values:
	dc.w	$8000,bytesToLcnt($10000),$100

	dc.l	Z80_RAM
	dc.l	Z80_Bus_Request
	dc.l	Z80_Reset
	dc.l	VDP_data_port, VDP_control_port

.vdp_init_values:     ; values for VDP registers
	dc.b 4         ; Command $8004 - HInt off, Enable HV counter read
	dc.b $14       ; Command $8114 - Display off, VInt off, DMA on, PAL off
	dc.b $30       ; Command $8230 - Scroll A Address $C000
	dc.b $3C       ; Command $833C - Window Address $F000
	dc.b 7         ; Command $8407 - Scroll B Address $E000
	dc.b $6C       ; Command $856C - Sprite Table Addres $D800
	dc.b 0         ; Command $8600 - Sprite Pattern Generator Base Address on low 64KB VRAM
	dc.b 0         ; Command $8700 - Background color Pal 0 Color 0
	dc.b 0         ; Command $8800 - Null
	dc.b 0         ; Command $8900 - Null
	dc.b $FF       ; Command $8AFF - Hint timing $FF scanlines
	dc.b 0         ; Command $8B00 - Ext Int off, VScroll full, HScroll full
	dc.b $81       ; Command $8C81 - 40 cell mode, shadow/highlight off, no interlace
	dc.b $37       ; Command $8D37 - HScroll Table Address $DC00
	dc.b 0         ; Command $8E00 - Nametable Pattern Generator Base Address on low 64KB VRAM
	dc.b 1         ; Command $8F01 - VDP auto increment 1 byte
	dc.b 1         ; Command $9001 - 64x32 cell scroll size
	dc.b 0         ; Command $9100 - Window H left side, Base Point 0
	dc.b 0         ; Command $9200 - Window V upside, Base Point 0
	dc.b $FF       ; Command $93FF - DMA Length Counter $FFFF
	dc.b $FF       ; Command $94FF - See above
	dc.b 0         ; Command $9500 - DMA Source Address $0
	dc.b 0         ; Command $9600 - See above
	dc.b $80       ; Command $9700	- See above + VRAM fill mode
.vdp_init_values_End:
	dc.l	vdpComm($0000,VRAM,DMA)
; ===========================================================================
	; Initial Z80 instructions.
z80_code_Begin:
    save
    CPU Z80        ; start compiling Z80 code
    phase 0        ; pretend we're at address 0
	xor	a          ; clear a to 0
	ld	bc,((Z80_RAM_End-Z80_RAM)-.zcode_end)-1
	ld	de,.zcode_end+1      ; initial destination address
	ld	hl,.zcode_end        ; initial source address
	ld	sp,hl      ; set the address the stack starts at
	ld	(hl),a     ; set first byte of the stack to 0
	ldir           ; loop to fill the stack (entire remaining available Z80 RAM) with 0
	pop	ix         ; clear ix
	pop	iy         ; clear iy
	ld	i,a        ; clear i
	ld	r,a        ; clear r
	pop	de         ; clear de
	pop	hl         ; clear hl
	pop	af         ; clear af
	ex	af,af'     ; swap af with af'
	exx            ; swap bc/de/hl with their shadow registers too
	pop	bc         ; clear bc
	pop	de         ; clear de
	pop	hl         ; clear hl
	pop	af         ; clear af
	ld	sp,hl      ; clear sp
	di             ; clear iff1 (for interrupt handler)
	im	1          ; interrupt handling mode = 1
	ld	(hl),0E9H  ; replace the first instruction with a jump to itself
	jp	(hl)       ; jump to the first instruction (to stay there forever)
.zcode_end:
    dephase        ; stop pretending
    restore
    padding off    ; unfortunately our flags got reset so we have to set them again...
z80_code_End:

	dc.w $8104     ; value for VDP display mode
	dc.w $8F02     ; value for VDP increment
	dc.l vdpComm($0000,CRAM,WRITE)     ; value for CRAM write mode
	dc.l vdpComm($0000,VSRAM,WRITE)    ; value for VSRAM write mode

psg_init_values:
	dc.b $9F,$BF,$DF,$FF     ; values for PSG channel volumes
psg_init_values_End:
	even
; ===========================================================================

