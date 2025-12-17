#Requires AutoHotkey v2.0.0+
#Include %A_ScriptDir%
#Include .\lib\LongIntString.ahk
;==============================================================
; strUInt64ToInt64 — Convert UInt64 (hex/decimal string) to signed Int64 with range validation
;
; GitHub: https://github.com/SevenKeyboard/str-uint64-to-int64
; Author: SevenKeyboard Ltd. (2025)
; License: The Unlicense
;
; Documentation / References:
;   UInt64 <--> Int64: Using large unsigned hex/decimals
;     https://www.autohotkey.com/board/topic/16888-uint64-int64-using-large-unsigned-hexdecimals/
;==============================================================

/*
Example Usage:
    msgbox strUInt64ToInt64("0x0")                              ;  0
            . "`n" strUInt64ToInt64("0x7FFFFFFFFFFFFFFF")       ;  9223372036854775807
            . "`n" strUInt64ToInt64("0x8000000000000000")       ;  -9223372036854775808
            . "`n" strUInt64ToInt64("0xFFFFFFFFFFFFFFFF")       ;  -1
            . "`n" strUInt64ToInt64("0x10000000000000000")      ;  ""
            . "`n"
            . "`n" strUInt64ToInt64("0")                        ;  0
            . "`n" strUInt64ToInt64("9223372036854775807")      ;  9223372036854775807
            . "`n" strUInt64ToInt64("9223372036854775808")      ;  -9223372036854775808
            . "`n" strUInt64ToInt64("18446744073709551615")     ;  -1
            . "`n" strUInt64ToInt64("18446744073709551616")     ;  ""

    msgbox format("0x{:X}",0)                                   ;  0x0
            . "`n" format("0x{:X}",9223372036854775807)         ;  0x7FFFFFFFFFFFFFFF
            . "`n" format("0x{:X}",-9223372036854775808)        ;  0x8000000000000000
            . "`n" format("0x{:X}",-1)                          ;  0xFFFFFFFFFFFFFFFF
            . "`n"
            . "`n" format("{:u}",0)                             ;  0
            . "`n" format("{:u}",9223372036854775807)           ;  9223372036854775807
            . "`n" format("{:u}",-9223372036854775808)          ;  9223372036854775808
            . "`n" format("{:u}",-1)                            ;  18446744073709551615
*/

/*
    Hex     |   0x0         0x7FFFFFFFFFFFFFFF      0x8000000000000000      0xFFFFFFFFFFFFFFFF

    Int64   |   0           9223372036854775807     -9223372036854775808    -1
    UInt64  |   0           9223372036854775807     9223372036854775808     18446744073709551615
*/

class VersionManager_strUInt64ToInt64
{
    static _ := this._init()
    static _init()    {
        global
        STRUINT64TOINT64_VERSION := "1.0.0"
        if (!this._verCheck(&LONGINTSTRING_VERSION, "1.0.0"))
            throw error("LongIntString version 1.x is required (minimum 1.0.0).")
        return true
    }
    static _verCheck(&actual, required)    {
        if !isSet(actual)
            return false
        actualMajor     := strSplit(actual, ".",, 2)[1]
        requiredMajor   := strSplit(required, ".",, 2)[1]
        if (actualMajor !== requiredMajor)
            return false
        return verCompare(actual, ">=" required)
    }
}
strUInt64ToInt64(i)    {
    static listUInt64MaxDigits := [1,8,4,4,6,7,4,4,0,7,3,7,0,9,5,5,1,6,1,5]
    if (regExMatch(i,"D`a)^0[xX][a-fA-F0-9]{1,16}$",&m))    { ;  0x0 ~ 0xFFFFFFFFFFFFFFFF
        return integer(m.Len[0]<18
            ?format("{:i}",i)
            :(subStr(i,1,-1)<<4)+abs("0x" subStr(i,-1)))
    }  else if (i~="D`a)^\d+$")    {
        if ((i:=lTrim(i,"0"))=="")
            i:="0"
        j:=i
        if (i~="^" format("{:i}",integer(j)) "$")   ;  0 ~ 9223372036854775807
            return (0<=i?format("{:u}",i):"")
        d:=strSplit(format("{:020}",i))             ;  9223372036854775808 ~ 18446744073709551615
        if (d.Length!==20)
            return ""
        for v in listUInt64MaxDigits    {
            switch
            {
                default:                return ""
                case (d[A_Index]<v):    break
                case (d[A_Index]==v):   continue
            }
        }
        return integer(LongIntString.sub(i,"18446744073709551616"))
    }
}