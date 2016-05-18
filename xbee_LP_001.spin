OBJ
  ser : "Parallax Serial Terminal Extended_LP"

Pub Start (RXpin, TXPin, Mode, Baud)
    ser.StartRxTx(RXpin, TXpin, Mode, Baud)


PUB RxCheck
    '' See FullDuplex Serial Documentation
    return (ser.RxCheck)

PUB RxFlush
    '' See FullDuplex Serial Documentation
    ser.RxFlush

pub CharTime (ms)
    ser.CharTime (ms)

PUB RxCount : count
  ser.rxcount
Pub Rx
    '' See FullDuplex Serial Documentation
    '' x := Serial.RX   ' receives a byte of data
    '' FOR Transparent (Non-API) MODE USE

    return (ser.charin)

pub AT_Config(stringptr)
    delay(100)
    ser.str(string("+++"))
    delay(100)
    ser.str(stringptr)
    ser.CHAR(13)
    ser.str(string("ATCN"))
    ser.CHAR(13)
    delay(10)

Pub Delay(mS)
'' Delay routing
'' XB.Delay(1000)  ' pause 1 second
  waitcnt(clkfreq/1000 * mS + cnt)

Pub AT_Init
{{
    Configure for low guard time for AT mode.
    Requires 5 seconds.  Required if AT_Config used.
}}

    delay(3000)
    ser.str(string("+++"))
    delay(2000)
    ser.rxflush
    ser.str(string("ATGT 3,CN"))
    ser.CHAR(13)
    delay(500)
    ser.rxFlush
    return 0


