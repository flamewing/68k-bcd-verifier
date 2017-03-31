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
; a1 = destination
; d0 = flags
; d1 = expected flags
; d3 = color if flag is correct
PrintFlags:
	lea	FlagArray(pc),a2
	moveq	#4,d2
	eor.b	d0,d1                      ; Now d1 is the set of wrong flags
	move.w	#RED,d4

.loop:
	move.w	d3,d5                      ; Lets pretend it is correct
	btst	d2,d1                      ; Is it actually correct?
	beq.s	.right                     ; Branch if yes
	move.w	d4,d5                      ; It is not; color it red

.right:
	move.b	(a2),d5                    ; Assume it is unset
	btst	d2,d0                      ; Is it actually unset?
	beq.s	.unset                     ; Branch if yes
	move.b	1(a2),d5                   ; It is not

.unset:
	move.w	d5,(a1)+                   ; Write it
	addq.l	#2,a2
	dbra	d2,.loop
	rts
; ---------------------------------------------------------------------------
FlagArray:
	dc.b	"xXnNzZvVcC"
	even
; ===========================================================================

