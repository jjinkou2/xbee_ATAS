OBJ
  ser : "FullDuplexSerial"

Pub Start (RXpin, TXPin, Mode, Baud)
    ser.Start(RXpin, TXpin, Mode, Baud)


PUB RxCheck
    '' See FullDuplex Serial Documentation
    return (ser.RxCheck)

PUB RxFlush
    '' See FullDuplex Serial Documentation
    ser.RxFlush


Pub Rx
    '' See FullDuplex Serial Documentation
    '' x := Serial.RX   ' receives a byte of data
    '' FOR Transparent (Non-API) MODE USE

    return (ser.rx)

pub AT_Config(stringptr)
    delay(100)
    ser.str(string("+++"))
    delay(100)
    ser.str(stringptr)
    ser.tx(13)
    ser.str(string("ATCN"))
    ser.tx(13)
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
    rxflush
    ser.str(string("ATGT 3,CN"))
    ser.tx(13)
    delay(500)
    rxFlush
    return 0


