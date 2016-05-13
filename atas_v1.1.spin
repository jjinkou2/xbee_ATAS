CON

  _clkmode        = xtal1 + pll16x              'Use crystal * 16
  _xinfreq        = 5_000_000                   '5MHz * 16 = 80 MHz

  ' Set pins and Baud rate for XBee comms
  XB_Rx           = 7                 ' XBee DOUT
  XB_Tx           = 6                 ' XBee Din
  XB_Baud         = 9600

  ' Set pins and baud rate for PC comms
  PC_Baud         = 115_200

  CR              = 13
  LF              = 10
  Length          = 250
  MaxSSID         = 10                ' nb max of SSID to collect

  #0,ASC,DESC

VAR
  long stack[50]                ' stack space for second cog
  byte strReturn[Length]
  byte XBchar
  word ptrSSID[MaxSSID]
  word ptrRSSI[MaxSSID]       'ptr adress of RSSI in string strReturn
  byte RSSI[MaxSSID]       'ptr adress of RSSI in string strReturn

OBJ

  PC            : "Parallax Serial Terminal Extended"
  XB            : "XBee_Object_1"           'XBee communication methods
  STR           : "Strings2.2"

PUB Start

  Init
  Send_Atas
  extractData
  printDatas

PUB printDatas | i, strPrint[32]

  pc.newline
  pc.newline
  bytefill(@strPrint,0,32)
  ' print title line
  bytemove (@strPrint,string("SSID"),4)
  Str.pad(@strPrint,20,string(" "),STR#PAD_RIGHT)
'  Str.Concatenate(@strPrint,string("RSSI"))
  pc.str(@strPrint)
  pc.str(string("RSSI"))
  pc.newline

  bytefill(@strPrint,0,32)
  bytemove(@strPrint,string("-"),1)
  str.StrRepeat(@strPrint,31)
  pc.str(@strPrint)

  ' print Data lines
  pc.newline
  i:=0

  repeat while i<10
    bytefill(@strPrint,0,32)
    bytemove (@strPrint,ptrSSID[i],strsize(ptrSSID[i]))
    'strPrint[strsize(SSID[i])]:=0
    Str.pad(@strPrint,20,string(" "),STR#PAD_RIGHT)

    pc.str(@strPrint)
    pc.str(ptrRSSI[i])

    pc.str(string(" ("))
    pc.dec(~RSSI[i])           ' negative number => complement it to sign number
    pc.str(string(" dB)"))
    pc.newline
    i++


PUB Send_Atas

  XB.AT_Config(string("ATNR"))   ' request value
  XB.AT_Config(string("ATAS"))   ' request value

PUB extractData

  XB_to_Str(@strReturn,Length)
  strToArrays(@strReturn,MaxSSID)
  insertionsort(@RSSI,@ptrSSID,@ptrRSSI)


PRI strToArrays (srcAddr,NbSSID) | i,crpos

  i:=0
  crpos:=0

  repeat while i < NbSSID
    ' Find RSSI
    repeat 3
        crpos := STR.strpos (srcAddr,string(CR),crpos + 1)   ' skip 3 CR
    srcAddr += crpos + 1

    ptrRSSI[i] := srcAddr          ' stores the RSSI adress mem
'    ptrRSSI_Sort[i] := srcAddr          ' stores the RSSI adress mem

     ' End of RSSI
    crpos   := STR.strpos (srcAddr,string(CR),0) ' find next CR
    byte[srcAddr][crpos] := 0         ' replace CR with O for making a string RSSI
    RSSI[i] := -1*hex2dec(srcAddr)       ' convert into dB
'    RSSI_Sort[i] := -1*hex2dec(srcAddr)       ' convert into dB

    ' Find SSID
    srcAddr += crpos + 1
    ptrSSID[i] := srcAddr              ' stores the SSID adress mem
    'ptrSSID_Sort[i] := srcAddr              ' stores the SSID adress mem
    ' End of SSID
    crpos   := STR.strpos (srcAddr,string(CR),0) ' fin du SSID
    byte[srcAddr][crpos] := 0         ' replace CR with O for making a string RSSI
    srcAddr += crpos + 1

    ' Loop
    i++
    crpos:=0

PRI XB_to_Str(desString,len) | i

    bytefill (desString,0,len)
    XB.rxFlush                    ' Empty buffer for data from XB

    i:=0
    repeat while (XBchar:=XB.RX)=>0 and i<len
      byte[desString][i]:=XBchar
      i++
    byte[desString][i-1]:=0

    XB.rxFlush                    ' Empty buffer for data from XB


PUB Init
  XB.Start(XB_Rx, XB_Tx, 0, XB_Baud)          ' Propeller Comms - RX,TX, Mode, Baud

  PC.Start(PC_Baud)                           ' Start Parallax Serial Terminal

  XB.RxFlush
  XB.AT_Init

'  startReadXB:=true
 ' cognew(XB_to_PC,@stack)       ' Start cog for XBee--> PC comms


PRI hex2dec(p_str) | c, value

'' Returns value from {indicated} hex string
'' -- p_str is pointer to binary string
'' -- n is maximum number of digits to process

  repeat 2
    c := str.StrToUpper(byte[p_str++])
    case c
      "0".."9":                                                  ' digit?
        value := (value << 4) | (c - "0")                        '  update value


      "A".."F":                                                  ' hex digit?
        value := (value << 4) | (c - "A" + 10)


      "_":
        { skip }

      other:
        quit

  return value



PUB insertionsort (RSSIArrayAddr, SSIDArrayAddr,RSSIHexArrayAddr) | j, i, val, val2,val3, len
'' for smaller arrays, faster than shell sort


  len := MaxSSID - 1                       ' reduce this so it doesn't re-evaluate each loop                                     '
  REPEAT i FROM 1 TO len
    val  := byte[RSSIArrayAddr][i]                                                   ' store value for later
    val2 := word[SSIDArrayAddr][i]                                                   ' store value for later
    val3 := word[RSSIHexArrayAddr][i]                                                   ' store value for later
    j := i - 1

    REPEAT WHILE byte[RSSIArrayAddr][j] < val  ' compare values
      byte[RSSIArrayAddr][j + 1]    :=  byte[RSSIArrayAddr][j]                           ' insert value
      word[SSIDArrayAddr][j + 1]    :=  word[SSIDArrayAddr][j]                           ' insert value
      word[RSSIHexArrayAddr][j + 1] :=  word[RSSIHexArrayAddr][j]                           ' insert value

      IF (--j < 0)
        QUIT

    byte[RSSIArrayAddr][j + 1]    := val                                               ' place value (from earlier)
    word[SSIDArrayAddr][j + 1]    := val2                                               ' place value (from earlier)
    word[RSSIHexArrayAddr][j + 1] := val3                                               ' place value (from earlier)



PRI strcmp (s1, s2)
'' copied from OBJ sort string obj available at OBEX

'' thanks Jon "JonnyMac" McPhalen (aka Jon Williams) (jon@jonmcphalen.com) for the majority of this code
'' altered so results are not case sensitive, and slightly faster (when considering the case insensitivity)
'' may have unexpected results if string1/2 are identical up to where string1 has a space and string2 ends (0 byte)

'' Returns 0 if strings equal, positive if s1 > s2, negative if s1 < s2

  REPEAT WHILE ((byte[s1] & constant(!$20)) == (byte[s2] & constant(!$20)))     ' if equal (not perfect case insensitivity, but fast -- we mostly work with just a-z/0-9)
    IF (byte[s1] == 0 AND byte[s2] == 0)                                        '  if at end
      RETURN 0                                                                  '    done
    ELSE
      s1++                                                                      ' advance pointers
      s2++

  RETURN (byte[s1] & constant(!$20)) - (byte[s2] & constant(!$20))              ' (not perfect case insensitivity, but fast -- we mostly work with just a-z/0-9)


