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
X    EQU (1<<4)
N    EQU (1<<3)
Z    EQU (1<<2)
V    EQU (1<<1)
C    EQU (1<<0)
; ===========================================================================
palette_bit_0       =      5
palette_bit_1       =      6
palette_line_0      =      0
palette_line_1      =      bit2mask16(palette_bit_0+8)
palette_line_2      =      bit2mask16(palette_bit_1+8)
palette_line_3      =      palette_line_1|palette_line_2
; ===========================================================================
palette_line_size   =      $10*2    ; 16 word entries
; ===========================================================================
WHITE = palette_line_0
BLUE  = palette_line_1
RED   = palette_line_2
GREEN = palette_line_3
; ===========================================================================

