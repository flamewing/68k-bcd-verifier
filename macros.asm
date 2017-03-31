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
; simplifying macros and functions
; ===========================================================================
; define the even pseudo-instruction
even macro
	if (*)&1
		dc.b 0 ;ds.b 1
	endif
    endm
; ===========================================================================
; makes a VDP address difference
vdpCommDelta function addr,((addr&$3FFF)<<16)|((addr&$C000)>>14)
; ---------------------------------------------------------------------------
; makes a VDP command
vdpComm function addr,type,rwd,(((type&rwd)&3)<<30)|((addr&$3FFF)<<16)|(((type&rwd)&$FC)<<2)|((addr&$C000)>>14)
; ---------------------------------------------------------------------------
; values for the type argument
VRAM  = %100001
CRAM  = %101011
VSRAM = %100101
; ---------------------------------------------------------------------------
; values for the rwd argument
READ  = %001100
WRITE = %000111
DMA   = %100111
; ---------------------------------------------------------------------------
; Like vdpComm, but starting from an address contained in a register
vdpCommReg macro reg,type,rwd,clr
	lsl.l	#2,reg							; Move high bits into (word-swapped) position, accidentally moving everything else
    if ((type&rwd)&3)<>0
	addq.w	#((type&rwd)&3),reg				; Add upper access type bits
    endif
	ror.w	#2,reg							; Put upper access type bits into place, also moving all other bits into their correct (word-swapped) places
	swap	reg								; Put all bits in proper places
    if clr <> 0
	andi.w	#3,reg							; Strip whatever junk was in upper word of reg
    endif
    if ((type&rwd)&$FC)==$20
	tas.b	reg								; Add in the DMA flag -- tas fails on memory, but works on registers
    elseif ((type&rwd)&$FC)<>0
	ori.w	#(((type&rwd)&$FC)<<2),reg		; Add in missing access type bits
    endif
    endm
; ---------------------------------------------------------------------------
; tells the VDP to copy a region of 68k memory to VRAM or CRAM or VSRAM
dma68kToVDP macro source,dest,length,type
	lea	(VDP_control_port).l,a5
	move.l	#(($9400|((((length)>>1)&$FF00)>>8))<<16)|($9300|(((length)>>1)&$FF)),(a5)
	move.l	#(($9600|((((source)>>1)&$FF00)>>8))<<16)|($9500|(((source)>>1)&$FF)),(a5)
	move.w	#$9700|(((((source)>>1)&$FF0000)>>16)&$7F),(a5)
	move.w	#((vdpComm(dest,type,DMA)>>16)&$FFFF),(a5)
	move.w	#(vdpComm(dest,type,DMA)&$FFFF),(DMA_data_thunk).w
	move.w	(DMA_data_thunk).w,(a5)
    endm
; ---------------------------------------------------------------------------
; tells the VDP to fill a region of VRAM with a certain byte
dmaFillVRAM macro byte,addr,length
	lea	(VDP_control_port).l,a5
	move.w	#$8F01,(a5) ; VRAM pointer increment: $0001
	move.l	#(($9400|((((length)-1)&$FF00)>>8))<<16)|($9300|(((length)-1)&$FF)),(a5) ; DMA length ...
	move.w	#$9780,(a5) ; VRAM fill
	move.l	#$40000080|(((addr)&$3FFF)<<16)|(((addr)&$C000)>>14),(a5) ; Start at ...
	move.w	#(byte)<<8,(VDP_data_port).l ; Fill with byte
.loop:
	move.w	(a5),d1
	btst	#1,d1
	bne.s	.loop ; busy loop until the VDP is finished filling...
	move.w	#$8F02,(a5) ; VRAM pointer increment: $0002
    endm
; ===========================================================================
; calculates initial loop counter value for a dbra loop
; that writes n bytes total at 4 bytes per iteration
bytesToLcnt function n,n>>2-1
; ---------------------------------------------------------------------------
; calculates initial loop counter value for a dbra loop
; that writes n bytes total at 2 bytes per iteration
bytesToWcnt function n,n>>1-1
; ===========================================================================
; Definition of RAM constants that can work in both 16- and 32-bit
; address modes.
ramaddr function x,-(-x)&$FFFFFFFF
; ===========================================================================
enableInts macro
	move	#$2300,sr
    endm
; ---------------------------------------------------------------------------
disableInts macro
	move	#$2700,sr
    endm
; ===========================================================================
signmask function val,nBits,-(-(val&$80))&(1<<(nBits-1))
signextend function val,nBits,(val+signmask(val,nBits))!signmask(val,nBits)
bit2mask function bit,signextend(1<<bit,8)
bit2maskU function bit,(1<<bit)
bit2mask16 function bit,signextend(1<<bit,16)
; ===========================================================================

