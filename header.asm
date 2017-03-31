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
Header:
	dc.b "SEGA GENESIS    "            ; Console name
	dc.b "(C)FLAME2016.SEP"            ; Copyright/Date
	dc.b "Flamewing's BCD Test ROM                        " ; Domestic name
	dc.b "Flamewing's BCD Test ROM                        " ; International name
	dc.b "FW 00000001-01"              ; Version
Checksum:
	dc.w $0000                         ; Checksum (patched later if incorrect)
	dc.b "J               "            ; I/O Support; 4=4-way multitap, 6=6-pad; for more: http://forums.sonicretro.org/index.php?showtopic=23817&st=0&start=0
	dc.l StartOfRom                    ; ROM Start
ROMEndLoc:
	dc.l EndOfRom-1                    ; ROM End
	dc.l RAM_Start&$FFFFFF             ; RAM Start
	dc.l (RAM_End-1)&$FFFFFF           ; RAM End
	dc.b "    "                        ; Backup RAM ID
	dc.l $20202020                     ; Backup RAM start address
	dc.l $20202020                     ; Backup RAM end address
	dc.b "            "                ; Modem support
	dc.b "                                        "	; Notes
	dc.b "JUE             "            ; Country
EndOfHeader:
; ===========================================================================

