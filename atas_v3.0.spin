CON

  _clkmode        = xtal1 + pll16x              'Use crystal * 16
  _xinfreq        = 5_000_000                   '5MHz * 16 = 80 MHz

  ' Set pins and Baud rate for XBee comms
  XB_Rx           = 7                 ' XBee DOUT
  XB_Tx           = 6                 ' XBee Din
  XB_Baud         = 9600

  ' Set baud rate for PC comms
  PC_Baud         = 115_200

  ' Set pins and Baud rate for OLED
  OLEDrxpin       = 0
  OLEDtxpin       = 1
  OLEDreset       = 2
  OLEDBaud        = 115_200

  CR              = 13
  Length          = 400
  MaxSSID         = 20                ' nb max of SSID to collect

VAR
  long stack[10]                ' stack space for second cog
  byte strReturn[Length]
  word ptrSSID[MaxSSID]
  word ptrRSSI[MaxSSID]       'ptr adress of RSSI in string strReturn
  byte RSSI[MaxSSID]          'ptr adress of RSSI in string strReturn
  byte NbSSIDDectected          ' count how many ssid are dectected
  byte CogIdent
  byte endOfXBData
  byte OledrowMax
  byte OledsizeMax


OBJ

  PC            : "Parallax Serial Terminal Extended_LP"
  XB            : "xbee_LP_001"           'XBee communication methods
  STR           : "Strings2.2"
  LED           : "OLED-128-G2_v2.2"

PUB Start

  Init


  GetXbeeData
  ParseString     'extract Data
    'printSSID
  OledDisplay
  '  waitcnt(clkfreq * 10 + cnt) ' pause 5s



PUB GetXbeeData
  endOfXBData:=0                            ' initialize the flag waiting for the end of XB data
 ' CogIdent:=cognew(XB_to_PC(@strReturn),@stack)       ' Start cog for XBee--> PC comms
  XB_to_PC(@strReturn)

PUB OledDisplay | row, strOled[18]

  OledrowMax := NbSSIDDectected <# 13                    ' no more than 13 rows available
  LED.ClearScreen                                         ''Clear the Display screen
  LED.TextBackgroundColor(LED.RGB(0,0,0))                 ''Make text background color BLACK
  LED.TextForegroundColor(LED.RGB(255,255,255))           ''Make text foreground color White
  LED.MoveCursor(0,0)
  LED.PutString(string("SSID("),0)
  LED.MoveCursor(0,5)
  LED.PutString(LED.decstr(NbSSIDDectected),0)


  LED.MoveCursor(0,7)
  LED.PutString(string(")        dB"),0)
  LED.MoveCursor(1,0)
  LED.PutString(string("------------------"),0)

  repeat row from 2 to OledrowMax
    OledsizeMax := strsize(ptrSSID[row-2]) <# 14 ' truncate at 15th char
    LED.MoveCursor(row,0)
    bytefill(@strOled,0,18)
    bytemove(@strOled,ptrSSID[row-2],OledsizeMax)
    LED.PutString(@strOled,15)
    LED.MoveCursor(row,15)
    LED.PutString(LED.decstr(~RSSI[row-2]),0)

PUB printSSID | i, strPrint[32]

  pc.newline
  pc.newline
  bytefill(@strPrint,0,32)
  pc.str(string("NB SSID dectected: "))
  pc.dec(NbSSIDDectected)
  pc.newline
  ' print title line
  bytemove (@strPrint,string("SSID"),4)
  Str.pad(@strPrint,20,string(" "),STR#PAD_RIGHT)
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

  repeat while i<NbSSIDDectected
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

  XB.RxFlush
  XB.AT_Init

  XB.AT_Config(string("ATNR"))   ' request value
  XB.AT_Config(string("ATAS"))   ' request value

PUB ParseString

 ' repeat until endOfXBData==1    ' wait for cog finishing filling strReturn

  strToArrays(@strReturn)
  insertionsort(@RSSI,@ptrSSID,@ptrRSSI)

PUB strToArrays (srcAddr) | i, crpos

' retrieve RSSI and SSID from a string
' String = "[(OK,CR,)x4],03,CR,04,CR,05,CR,[RSSI],CR,[SSID],CR,[loop]"

   i:=0
   NbSSIDDectected:=0

   ' skip the first 4 OK at the string's start
   crpos:=11

   repeat while crpos <> -1
    ' Find RSSI
    repeat 3
        crpos := STR.strpos (srcAddr,string(CR),crpos + 1)   ' skip 3 CR
        if crpos==-1
          quit                                          ' exit the loop if nothing's found

    if crpos <>-1

      NbSSIDDectected++              ' one more SSID detected

      srcAddr += crpos + 1           ' pointer to the RSSI address
      ptrRSSI[i] := srcAddr          ' stores the RSSI adress mem

      ' End of RSSI
      crpos   := STR.strpos (srcAddr,string(CR),0) ' find next CR
      byte[srcAddr][crpos] := 0         ' replace CR with O for making a string RSSI
      RSSI[i] := -1*hex2dec(srcAddr)       ' convert into dB

      ' Find SSID
      srcAddr += crpos + 1
      ptrSSID[i] := srcAddr              ' stores the SSID adress mem

      ' End of SSID
      crpos   := STR.strpos (srcAddr,string(CR),0) ' fin du SSID
      byte[srcAddr][crpos] := 0         ' replace CR with O for making a string RSSI
      srcAddr += crpos + 1

      ' Loop
      i++
      crpos:=0

PUB XB_to_PC(desString)

    Send_Atas
    FromXbeeToString(desString)
   ' cogstop(CogIdent)

PUB FromXbeeToString(desString)  | c1,c2, i

    bytefill (@strReturn,0,length)
    i:=0

    repeat
      if endOfXBData==0
        if (c1:=XB.RX)==CR
          if (c2:=XB.RX)==CR                ' end of SSID list
             byte[desString][i++]:=c1
             endOfXBData:=1                 ' exit this cog, send a message
             quit                           ' to the calling cog
          else
             byte[desString][i++]:=c1
             byte[desString][i++]:=c2
        else
          byte[desString][i++]:=c1


PUB Init


  XB.Start(XB_Rx, XB_Tx, 0, XB_Baud)          ' Start Xbee

 ' PC.Start(PC_Baud)                           ' Start Parallax Serial Terminal


  LED.start(OLEDrxpin, OLEDtxpin, OLEDreset, OLEDBaud)                ''Starts uOLED display

PUB insertionsort (RSSIArrayAddr, SSIDArrayAddr,RSSIHexArrayAddr) | j, i, val, val2,val3, len
'' for smaller arrays, faster than shell sort
'' sorting is only done on comparing RSSIArrayAddr decimal values.
'' the other tables (SSIDArrayAddr,RSSIHexArrayAddr) are then sorted
'' along to the RSSIArrayAddr

  len := strsize(RSSIArrayAddr) - 1
  REPEAT i FROM 1 TO len
    val  := byte[RSSIArrayAddr][i]                                                   ' store value for later
    val2 := word[SSIDArrayAddr][i]                                                   ' store value for later
    val3 := word[RSSIHexArrayAddr][i]                                                   ' store value for later
    j := i - 1

    REPEAT WHILE byte[RSSIArrayAddr][j] < val                                      ' compare values
      byte[RSSIArrayAddr][j + 1]    :=  byte[RSSIArrayAddr][j]                   ' sort them accordingly
      word[SSIDArrayAddr][j + 1]    :=  word[SSIDArrayAddr][j]
      word[RSSIHexArrayAddr][j + 1] :=  word[RSSIHexArrayAddr][j]

      IF (--j < 0)
        QUIT

    byte[RSSIArrayAddr][j + 1]    := val                                               ' place value (from earlier)
    word[SSIDArrayAddr][j + 1]    := val2                                               ' place value (from earlier)
    word[RSSIHexArrayAddr][j + 1] := val3                                               ' place value (from earlier)



PUB hex2dec(p_str) | c, value

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
