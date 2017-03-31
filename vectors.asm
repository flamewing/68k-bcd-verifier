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
Vectors:
	dc.l System_Stack, EntryPoint     , ErrorTrap        , ErrorTrap      ; 4
	dc.l ErrorTrap   , ErrorTrap      , ErrorTrap        , ErrorTrap      ; 8
	dc.l ErrorTrap   , ErrorTrap      , ErrorTrap        , ErrorTrap      ; 12
	dc.l ErrorTrap   , ErrorTrap      , ErrorTrap        , ErrorTrap      ; 16
	dc.l ErrorTrap   , ErrorTrap      , ErrorTrap        , ErrorTrap      ; 20
	dc.l ErrorTrap   , ErrorTrap      , ErrorTrap        , ErrorTrap      ; 24
	dc.l ErrorTrap   , ErrorTrap      , ErrorTrap        , ErrorTrap      ; 28
	dc.l H_int       , ErrorTrap      , V_int            , ErrorTrap      ; 32
	dc.l ErrorTrap   , ErrorTrap      , ErrorTrap        , ErrorTrap      ; 36
	dc.l ErrorTrap   , ErrorTrap      , ErrorTrap        , ErrorTrap      ; 40
	dc.l ErrorTrap   , ErrorTrap      , ErrorTrap        , ErrorTrap      ; 44
	dc.l ErrorTrap   , ErrorTrap      , ErrorTrap        , ErrorTrap      ; 48
	dc.l ErrorTrap   , ErrorTrap      , ErrorTrap        , ErrorTrap      ; 52
	dc.l ErrorTrap   , ErrorTrap      , ErrorTrap        , ErrorTrap      ; 56
	dc.l ErrorTrap   , ErrorTrap      , ErrorTrap        , ErrorTrap      ; 60
	dc.l ErrorTrap   , ErrorTrap      , ErrorTrap        , ErrorTrap      ; 64
; ===========================================================================

