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
; Z80 addresses
Z80_RAM =                     $A00000 ; start of Z80 RAM
Z80_RAM_End =                 $A02000 ; end of non-reserved Z80 RAM
Z80_Bus_Request =             $A11100
Z80_Reset =                   $A11200
; ===========================================================================
; I/O Area
HW_Version =                  $A10001
HW_Port_1_Data =              $A10003
HW_Port_2_Data =              $A10005
HW_Expansion_Data =           $A10007
HW_Port_1_Control =           $A10009
HW_Port_2_Control =           $A1000B
HW_Expansion_Control =        $A1000D
HW_Port_1_TxData =            $A1000F
HW_Port_1_RxData =            $A10011
HW_Port_1_SCtrl =             $A10013
HW_Port_2_TxData =            $A10015
HW_Port_2_RxData =            $A10017
HW_Port_2_SCtrl =             $A10019
HW_Expansion_TxData =         $A1001B
HW_Expansion_RxData =         $A1001D
HW_Expansion_SCtrl =          $A1001F
; ===========================================================================
; TMSS
Security_Addr =               $A14000
; ===========================================================================
; VDP addressses
VDP_data_port =               $C00000
VDP_control_port =            $C00004
VDP_HV_counter =              $C00008
PSG_input =                   $C00011
; ===========================================================================
; RAM
RAM_Start       EQU ramaddr($FFFF0000)
RAM_End         EQU ramaddr($00000000)
System_Stack    EQU ramaddr($FFFFFE00)
DMA_data_thunk  EQU ramaddr($FFFFFEFC)
Current_Op      EQU ramaddr($FFFFFEFE)
Failure_Counts  EQU ramaddr($FFFFFF00)
; ===========================================================================

