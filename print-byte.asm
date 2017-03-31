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
; d0 = byte to print
; d1 = color|'$'
PrintByte:
	moveq	#1,d2                      ; Want 2 digits
	move.w	d1,(a1)+

.put_digit_loop:
	rol.b	#4,d0                      ; Get a new nibble to print
	moveq	#$F,d3                     ; Want only the lowest nibble
	and.b	d0,d3                      ; Copy it to d3
	move.b	Hex2Char(pc,d3.w),d1       ; Convert to character and add in color
	move.w	d1,(a1)+                   ; Print the nibble
	dbra	d2,.put_digit_loop
	rts
; ===========================================================================

