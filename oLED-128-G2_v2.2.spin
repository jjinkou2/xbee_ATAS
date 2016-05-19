{{
*****************************************
* uLCD(SK)-32PTU display driver    v2.2 *
* Author: Beau Schwabe                  *
* Copyright (c) 2013 Parallax           *
* See end of file for terms of use.     *
*****************************************
See end of file for terms of use:

File: OLED-128-G2_v2.2.spin
---------------------------------------------------------------------------------------------------------------------------
Revision History:  uOLED-128-G2

10-05-2013      V1.0            - first release
---------------------------------------------------------------------------------------------------------------------------
10-25-2013      V1.1            - added two functions that were undocumented in original GOLDELOX-SPE-COMMAND-SET-REV1.3 datasheet
                                - changed constant naming to reflect PICASO-GFX2-4DGL-Internal-Functions-rev3  datasheet
---------------------------------------------------------------------------------------------------------------------------
11-07-2013      V2.0            - improvements to Fxn call reducing overall code by 98 LONGS
                                - significant overall speed improvements through optimization
---------------------------------------------------------------------------------------------------------------------------
11-08-2013      V2.1            - compatibility updates to command structure
---------------------------------------------------------------------------------------------------------------------------

11-08-2013      V2.2            - small bug on dec, binary and hex. exchange row and column to be consistent with placestring
---------------------------------------------------------------------------------------------------------------------------



Special thanks to Harrison Saunders(Aka, Ravenkallen) for setting the blue-print when writing code for the OLED-96-G1




See end of file for terms of use:


General info:

This is a simple/small driver for the OLED-128-G2.  This driver uses the common Parallax serial terminal as it's main
communication system.  This OLED is a good choice for many reasons and seems to have a little bit of everything.  It
can draw boxes, lines, triangles. It can display text and graphics and makes it relatively easy to understand.  It is
capable of 65 thousand colors in two bytes and has a resolution of 128x128 pixels.  It also uses a reliable
communication system.  In order to use this display, the user must first declare the "start" method. This will initialize
the display and start communication at the desired baud rate... Depending on your baud rate, you may need to add a small
delay between all commands involving the OLED. 10 milliseconds works for most commands. Erase commands will take a
little more time.


Features(from the datasheet):
        
    * Low-cost OLED display graphics user interface solution.
    * 128 x 128 resolution, 65K true to life colors, PMOLED screen.
    * 1.5" diagonal size, 45.5 x 33.5 x 6.1mm. Active Area: 27mm x 27mm.
    * No back lighting with near 180° viewing angle.
    * Easy 10 pin interface to any external device: VCC, TX, RX, GND, RESET, IO1, IO2, 3.3V.
    * Powered by the 4D-Labs GOLDELOX graphics processor highly optimized for 4DGL,
      the high level 4D Graphics Language.
    * 2 x GPIO ports supports:
        Digital I/O
        A/D converter with 8/10 bit resolution
        Complex sound generation
        Dedicated RTTTL tune engine
        Multi-Switch Joystick
        Dallas 1-Wire

    * 10K bytes of flash memory for user code storage and 510 bytes of RAM for user variables (255 x 16bit vars)
    * 1 x Asynchronous hardware serial port, TTL interface, with 300 baud to 600K baud.
    * On-board micro-SD memory card adapter for storing of icons, images, animations, etc.
      Supports 64Mb to 2Gig micro-SD memory cards. A SPI compatible micro-SD card is required.
    * Comprehensive set of built in high level 4DGL graphics functions and algorithms that can draw lines,
      circles, text, and much more.
    * Display full color images, animations, icons and video clips.
    * Supports all available Windows fonts and characters (imported as external fonts).
    * 4.0V to 5.5V range operation (single supply).
    * Module dimensions: 45.6 x 36 x 13.7mm (including corner plates).
    * Weighing ~11g.
    * Display Viewing Area: 27 x 27mm
    * Back plate with 4 x 3mm holes for mechanical mounting.
    * RoHS Compliant.




Setup: Seeing as the Propeller uses(and outputs) 3.3 volts, the uOLED-128-G2 requires a 5V supply although most of my
testing and writing of this code has been with a 3.3V supply.  Your mileage may vary though.  Since there is no auto baud
detection with this module, it is necessary to connect the RESet line.  Since there are also several commands which
report back information, it is also necessary to connect the RX line.

Simply connect the RES, TX and RX pins to the prop pins of your choice and, hook up power and ground and you are all set.


Notes: Check out the datasheet for this device to know more about it.

I found that the GOLDELOX-SPE-COMMAND-SET-REV1.3.pdf was most useful in the development of this driver.

If you have used the uOLED-96-G1 in the past, while there are some differences in command, I tried to make the look and
feel of the commands as close as possible.  Some of the commands that were available in the uOLED-96-G1 are no longer
present in the uOLED-128-G2 so the functionality was derived.  Some commands had slightly different behavior as well, but
for the most part with only minor tweaking this driver should be backward command compatible with what you are already
familiar with.  


}}
con

''-------------------------------------------------------------------
''Constants used for communication...

Cmd_gfx_BGcolor            = $FF6E
Cmd_gfx_Changecolor        = $FFBE
Cmd_gfx_Circle             = $FFCD
Cmd_gfx_CircleFilled       = $FFCC
Cmd_gfx_Clipping           = $FF6C
Cmd_gfx_ClipWindow         = $FFBF
Cmd_gfx_Cls                = $FFD7
Cmd_gfx_Contrast           = $FF66
Cmd_gfx_FrameDelay         = $FF69
Cmd_gfx_GetPixel           = $FFCA
Cmd_gfx_Line               = $FFD2
Cmd_gfx_LinePattern        = $FF65
Cmd_gfx_LineTo             = $FFD4
Cmd_gfx_MoveTo             = $FFD6
Cmd_gfx_Orbit              = $0003
Cmd_gfx_Outlinecolor       = $FF67
Cmd_gfx_Polygon            = $0004
Cmd_gfx_PolyLine           = $0005
Cmd_gfx_PutPixel           = $FFCB
Cmd_gfx_Rectangle          = $FFCF
Cmd_gfx_RectangleFilled    = $FFCE
Cmd_gfx_ScreenMode         = $FF68
Cmd_gfx_Set                = $FFD8
Cmd_gfx_SetClipRegion      = $FFBC
Cmd_gfx_Transparency       = $FF6A  'Added 10-25-2013
Cmd_gfx_Transparencycolor  = $FF6B  'Added 10-25-2013
Cmd_gfx_Triangle           = $FFC9
'----------------------------------------------
Cmd_txt_Attributes         = $FF72
Cmd_txt_BGcolor            = $FF7E
Cmd_txt_Bold               = $FF76
Cmd_txt_FGcolor            = $FF7F
Cmd_txt_FontID             = $FF7D
Cmd_txt_Height             = $FF7B
Cmd_txt_Inverse            = $FF74
Cmd_txt_Italic             = $FF75
Cmd_txt_MoveCursor         = $FFE4
Cmd_txt_Opacity            = $FF77
Cmd_txt_Set                = $FFE3
Cmd_txt_Underline          = $FF73
Cmd_txt_Width              = $FF7C
Cmd_txt_Xgap               = $FF7A
Cmd_txt_Ygap               = $FF79
'----------------------------------------------
Cmd_media_Flush            = $FFB2
Cmd_media_Image            = $FFB3
Cmd_media_init             = $FFB1
Cmd_media_ReadByte         = $FFB7
Cmd_media_ReadWord         = $FFB6
Cmd_media_SetAdd           = $FFB9
Cmd_media_SetSector        = $FFB8
Cmd_media_Video            = $FFBB
Cmd_media_VideoFrame       = $FFBA
Cmd_media_WriteByte        = $FFB5
Cmd_media_WriteWord        = $FFB4
'----------------------------------------------
_Beep                  = $FFDA
_BlitComtoDisplay      = $000A
_CharHeight            = $0001
_CharWidth             = $0002
_Joystick              = $FFD9
_peekB                 = $FFF6
_peekW                 = $FFF5
_pokeB                 = $FFF4
_pokeW                 = $FFF3
_putCH                 = $FFFE
_PutStr                = $0006
_SSMode                = $000E
_SSSpeed               = $000D
_SSTimeout             = $000C
Cmd_sys_GetModel           = $0007
Cmd_sys_GetVersion         = $0008
Cmd_sys_GetPmmC            = $0009

_SetBaud               = $000B


obj
ser: "parallax serial terminal Extended_LP"

var
byte    _Ack
long    strAddress
word    color,GaugeValue[4], BarValue[4],C0L0RPalette[256]

pub stop                                                
'-------------------------------------------------------------------------
'--------------------------------┌──────┐---------------------------------
'--------------------------------│ Stop │---------------------------------
'--------------------------------└──────┘---------------------------------
'-------------------------------------------------------------------------

''Dummy method at the beginning of code to prevent accidental execution

pub start(rxpin, txpin, reset , Baud)
'-------------------------------------------------------------------------
'--------------------------------┌───────┐--------------------------------
'--------------------------------│ Start │--------------------------------
'--------------------------------└───────┘--------------------------------
'-------------------------------------------------------------------------

'' This method must be called first to start up the serial com port, the auto baud feature is not present with the G2 and
'' must make use of the RESET pin to negotiate a desired Baude upon startup of the display

outa[reset]~                                            ''Reset uOLED                                            
dira[reset]~~
waitcnt(Clkfreq/16 + cnt)
outa[reset]~~
dira[reset]~                                                        

waitcnt(Clkfreq * 2  + cnt)                             ''Give time for system to settle down
Ser.startrxtx(rxpin, txpin, 0, 9600)                    ''Start Communications with default Baud
waitcnt(Clkfreq + cnt)                                  ''Give time for system to settle down
SetBaud(BaudIndex(Baud))                                ''Set New Baud speed
waitcnt(Clkfreq/200 + cnt)                              ''Give time for system to settle down
Ser.Stop                                                ''Change Communication Baud                                                
Ser.startrxtx(rxpin, txpin, 0, Baud)                    ''Start Communications with new Baud
waitcnt(Clkfreq/200 + cnt)                              ''Give time for system to settle down
ClearScreen                                             ''Erase OLED display ; at new baud speed


'-----------------------------------------------------------------------------------------------------------------
'-----------------------------------------------------------------------------------------------------------------
'-----------------------------------------------------------------------------------------------------------------
'-----------------------------------------------------------------------------------------------------------------

pub BackgroundColor2(Co)                           
'-------------------------------------------------------------------------
'--------------------------------┌─────────────────┐----------------------
'--------------------------------│ BackgroundColor │----------------------
'--------------------------------└─────────────────┘----------------------
'-------------------------------------------------------------------------
{{
Description:
sets the screen background color based on NEW color

Returns:
None
}}
_Ack := Fxn(1,Cmd_gfx_BGcolor,@Co)
pub backgroundcolor             ''Alias                                     ''sets the screen background color based on current color
    BackgroundColor2(color)

pub ChangeColor(OldColor,NewColor)                      
'-------------------------------------------------------------------------
'--------------------------------┌─────────────┐--------------------------
'--------------------------------│ ChangeColor │--------------------------
'--------------------------------└─────────────┘--------------------------
'-------------------------------------------------------------------------
{{
Description:
changes ALL Old Color pixels to NewColor pixels

Returns:
None
}}
_Ack := Fxn(2,Cmd_gfx_Changecolor,@OldColor) ''Note: Image writes mess with the graphics area
                                                        ''      that color changes would normall affect.
                                                        ''      There is a way around this, but it needs
                                                        ''      further testing

pub DrawCircle(X,Y,R,Co)                             
'-------------------------------------------------------------------------
'--------------------------------┌────────────┐---------------------------
'--------------------------------│ DrawCircle │---------------------------
'--------------------------------└────────────┘---------------------------
'-------------------------------------------------------------------------
{{
Description:
draws a circle with center at X,Y with radius R using the specified color

Returns:
None
}}
_Ack := Fxn(4,Cmd_gfx_Circle,@X)
pub circle(X,Y,R)               ''Alias                 ''draws a circle with center at X,Y with radius R
    DrawCircle(X,Y,R,color)                             ''using the current color

pub DrawFilledCircle(X,Y,R,C0L0R)                       
'-------------------------------------------------------------------------
'--------------------------------┌──────────────────┐---------------------
'--------------------------------│ DrawFilledCircle │---------------------
'--------------------------------└──────────────────┘---------------------
'-------------------------------------------------------------------------
{{
Description:
draws a solid circle with center at X,Y with radius R using the specified color

Returns:
None
}}
_Ack := Fxn(4,Cmd_gfx_CircleFilled,@X)
pub gfx_DrawFilledCircle(X,Y,R,C0L0R)    ''Alias
DrawFilledCircle(X,Y,R,C0L0R)

pub Clipping(mode)                                   
'-------------------------------------------------------------------------
'--------------------------------┌──────────┐-----------------------------
'--------------------------------│ Clipping │-----------------------------
'--------------------------------└──────────┘-----------------------------
'-------------------------------------------------------------------------
{{
Description:
Enables or Disables the ability for Clipping to be used

Returns:
None
}}
_Ack := Fxn(1,Cmd_gfx_Clipping,@mode)         ''0=Clipping Disabled ; 1=Clipping Enabled

pub SetClipWindow(x1,y1,x2,y2)|varstore,index           
'-------------------------------------------------------------------------
'--------------------------------┌───────────────┐------------------------
'--------------------------------│ SetClipWindow │------------------------
'--------------------------------└───────────────┘------------------------
'-------------------------------------------------------------------------
{{
Description:
specifies a clipping window region on the screen that any objects and text placed onto the screen will be clipped
and displayed only within that region

Returns:
None
}} 
_Ack := Fxn(4,Cmd_gfx_ClipWindow,@x1)         ''Note: Need to enable first with the Clipping function

pub ClearScreen                                         
'-------------------------------------------------------------------------
'--------------------------------┌─────────────┐--------------------------
'--------------------------------│ ClearScreen │--------------------------
'--------------------------------└─────────────┘--------------------------
'-------------------------------------------------------------------------
{{
Description:
This will just erase the OLED...

Returns:
None
}}
_Ack := Fxn(0,Cmd_gfx_Cls,0)
waitcnt(Clkfreq/4 + cnt)                                ''Give time for display to clear
pub Erase                       ''Alais
    ClearScreen

pub Contrast(level)                                   
'-------------------------------------------------------------------------
'--------------------------------┌──────────┐-----------------------------
'--------------------------------│ Contrast │-----------------------------
'--------------------------------└──────────┘-----------------------------
'-------------------------------------------------------------------------
{{
Description:
sets the contrast of the display, or turns it On/Off depending on the display model

Returns:
None
}} 
_Ack := Fxn(1,Cmd_gfx_Contrast,@level)         ''0 = Display OFF ; 1-15 = Contrast

pub displaycontrol(mode, value)                         
'-------------------------------------------------------------------------
'--------------------------------┌────────────────┐-----------------------
'--------------------------------│ displaycontrol │-----------------------
'--------------------------------└────────────────┘-----------------------
'-------------------------------------------------------------------------
{{
Description:
This command will access the display control functions.  There are two different commands that can be given.

Display on or off...Mode = 1, value = 1(on) or 0(off)
OLED contrast....Mode = 2, value = 0 - 15(15 being highest setting and 0 being lowest setting)

Returns:
None
}}
case mode
   0     : value:=0
   1     : value:=15
   2     : value:=value
   other : value:=0 
Contrast(value)

pub Powerdown                                           
'-------------------------------------------------------------------------
'--------------------------------┌───────────┐----------------------------
'--------------------------------│ Powerdown │----------------------------
'--------------------------------└───────────┘----------------------------
'-------------------------------------------------------------------------
{{
Description:
It is recommended by the company(4D systems) to power down the OLED after use, instead of turning off the power.
Damage may occur to the display with an improper power down

Returns:
None
}}
Contrast(0)

pub FrameDelay(delay)       ''UNTESTED FUNCTION       
'-------------------------------------------------------------------------
'--------------------------------┌────────────┐---------------------------
'--------------------------------│ FrameDelay │---------------------------
'--------------------------------└────────────┘---------------------------
'-------------------------------------------------------------------------
{{
Description:
sets the inter frame delay for the "Media Video" command

Returns:
None
}} 
_Ack := Fxn(1,Cmd_gfx_FrameDelay,@delay)       ''0-255 milliseconds

pub ReadPixel(x,y)                                      
'-------------------------------------------------------------------------
'--------------------------------┌───────────┐----------------------------
'--------------------------------│ ReadPixel │----------------------------
'--------------------------------└───────────┘----------------------------
'-------------------------------------------------------------------------
{{
Description:
reads the color value of the pixel at position x,y

Returns:
Pixel color result returned
}}
_Ack := Fxn(2,Cmd_gfx_GetPixel,@x)
result := Get_WORD_Response                             
pub pixelread(x, y)             ''Alias
result := ReadPixel(x,y)

pub DrawLine(X1,Y1,X2,Y2,C0L0R)                         
'-------------------------------------------------------------------------
'--------------------------------┌──────────┐-----------------------------
'--------------------------------│ DrawLine │-----------------------------
'--------------------------------└──────────┘-----------------------------
'-------------------------------------------------------------------------
{{
Description:
draws a line from X1,Y1 to X2,Y2 using the specified color

Returns:
None
}}
_Ack := Fxn(5,Cmd_gfx_Line,@X1)
pub line(x1, y1, x2, y2)        ''Alias                 ''draws a line from X1,Y1 to X2,Y2 using the current color
DrawLine(x1, y1, x2, y2,color)

pub LinePattern(pattern)                                
'-------------------------------------------------------------------------
'--------------------------------┌─────────────┐--------------------------
'--------------------------------│ LinePattern │--------------------------
'--------------------------------└─────────────┘--------------------------
'-------------------------------------------------------------------------
{{
Description:
sets the line draw pattern for drawing.  If set to zero, lines are solid, else each '1' bit represents a pixel that
is turned off

Returns:
None
}} 
_Ack := Fxn(1,Cmd_gfx_LinePattern,@pattern)

pub DrawLineMoveOrigin(x,y)                             
'-------------------------------------------------------------------------
'--------------------------------┌────────────────────┐-------------------
'--------------------------------│ DrawLineMoveOrigin │-------------------
'--------------------------------└────────────────────┘-------------------
'-------------------------------------------------------------------------
{{
Description:
draws line from the current origin to a new x,y position.

Returns:
None
}}
_Ack := Fxn(2,Cmd_gfx_LineTo,@x)                 ''The origin is then set to the new position

pub MoveOrigin(x,y)                                     
'-------------------------------------------------------------------------
'--------------------------------┌────────────┐---------------------------
'--------------------------------│ MoveOrigin │---------------------------
'--------------------------------└────────────┘---------------------------
'-------------------------------------------------------------------------
{{
Description:
moves the origin to a new x,y position

Returns:
None
}}
_Ack := Fxn(2,Cmd_gfx_MoveTo,@x)
pub gfx_MoveTo(x,y)             'Alias
MoveOrigin(x,y)

pub CalculateOrbit(Angle,Distance)
'-------------------------------------------------------------------------
'--------------------------------┌────────────────┐-----------------------
'--------------------------------│ CalculateOrbit │-----------------------
'--------------------------------└────────────────┘-----------------------
'-------------------------------------------------------------------------
{{
Description:
calculates the x,y coordinates of a distant point relative to the current origin

Returns:
''Xdist returned in upper WORD ; Ydist returned in lower WORD
}}
_Ack := Fxn(2,Cmd_gfx_Orbit,@Angle)
result := (Get_WORD_Response<<16) + Get_WORD_Response
pub gfx_Orbit(Angle,Distance)   ''Alias
result := CalculateOrbit(Angle,Distance)
pub Orbit(Angle,Distance)       ''Alias
result := CalculateOrbit(Angle,Distance) 

PUB ElipseOrbit(x,y,Xrad,Yrad,_Angle)|XY,distance,deviation                     
'-------------------------------------------------------------------------
'--------------------------------┌─────────────┐--------------------------
'--------------------------------│ ElipseOrbit │--------------------------
'--------------------------------└─────────────┘--------------------------
'-------------------------------------------------------------------------
{{
Description:
function calculates the x, y coordinates of a distant point relative to the current origin of an Ellipse
from a series of two stacked Orbits with opposite degrees and different radius, where the only known
parameters are the angle and the distance from the current origin


Returns:
Xdist returned in upper WORD ; Ydist returned in lower WORD
}}
deviation :=(Xrad - Yrad)>>1                                                
distance := (Xrad + Yrad)>>1                                                 
gfx_MoveTo(x,y)                                                             
XY := gfx_Orbit(_Angle,distance)                                   
gfx_MoveTo(XY >> 16,XY & $FFFF)                                
result := gfx_Orbit(360-_Angle,deviation) 

pub OutlineColor(Co)                               
'-------------------------------------------------------------------------
'--------------------------------┌──────────────┐-------------------------
'--------------------------------│ OutlineColor │-------------------------
'--------------------------------└──────────────┘-------------------------
'-------------------------------------------------------------------------
{{
Description:
sets the outline color for rectangles and circles

Returns:
None
}}
_Ack := Fxn(1,Cmd_gfx_OutlineColor,@Co)

pub DrawPolygon(N,xArray,yArray,Co)                  
'-------------------------------------------------------------------------
'--------------------------------┌─────────────┐--------------------------
'--------------------------------│ DrawPolygon │--------------------------
'--------------------------------└─────────────┘--------------------------
'-------------------------------------------------------------------------
{{
Description:
plots lines between points specified by a pair of arrays using the specified color within each array element 

Returns:
None
}}
SendData(Cmd_gfx_Polygon)                                   ''The last point is drawn back to the first point
DrawPoly(N,xArray,yArray,Co)

pub DrawPolyLine(N,xArray,yArray,C0L0R)                 
'-------------------------------------------------------------------------
'--------------------------------┌──────────────┐-------------------------
'--------------------------------│ DrawPolyLine │-------------------------
'--------------------------------└──────────────┘-------------------------
'-------------------------------------------------------------------------
{{
Description:
plots lines between points specified by a pair of arrays using the specified color within each array element

Returns:
None
}}
SendData(Cmd_gfx_PolyLine)                                 
DrawPoly(N,xArray,yArray,C0L0R)

pri DrawPoly(N,xArray,yArray,C0L0R)|idx
{{
------------------------------
dat                            ''Example Array Setup

xArray
byte 10,50,20
yArray   
byte 10,40,120
------------------------------
}}
SendData(N)
idx := 0
repeat N
  ser.char(0)
  ser.char(byte[xArray][idx++])
idx := 0  
repeat N  
  ser.char(0)
  ser.char(byte[yArray][idx++])     
SendData(C0L0R)
_Ack := ser.CharIn

pub PutPixel(x,y,C0L0R)                  
'-------------------------------------------------------------------------
'--------------------------------┌──────────┐-----------------------------
'--------------------------------│ PutPixel │-----------------------------
'--------------------------------└──────────┘-----------------------------
'-------------------------------------------------------------------------
{{
Description:
draws a pixel at position x,y using the specified color.

Returns:
None
}}
_Ack := Fxn(3,Cmd_gfx_PutPixel,@x)
pub gfx_PutPixel(x,y,C0L0R)     ''Alias
PutPixel(x,y,C0L0R)                
pub pixel(x, y)                 ''Alias                                         ''draws a pixel at position x,y using the current color.
PutPixel(x,y,color)

pub DrawRectangle(X1,Y1,X2,Y2,C0L0R)                    
'-------------------------------------------------------------------------
'--------------------------------┌───────────────┐------------------------
'--------------------------------│ DrawRectangle │------------------------
'--------------------------------└───────────────┘------------------------
'-------------------------------------------------------------------------
{{
Description:
draws a rectangle from X1,Y1 to X2,Y2 using the specified color

Returns:
None
}}
_Ack := Fxn(5,Cmd_gfx_Rectangle,@X1)
pub rectangle(X1,Y1,X2,Y2)      ''Alias                 ''draws a rectangle from X1,Y1 to X2,Y2 using the current
    DrawRectangle(X1,Y1,X2,Y2,color)                    ''color

pub DrawFilledRectangle(X1,Y1,X2,Y2,C0L0R)              
'-------------------------------------------------------------------------
'--------------------------------┌─────────────────────┐------------------
'--------------------------------│ DrawFilledRectangle │------------------
'--------------------------------└─────────────────────┘------------------
'-------------------------------------------------------------------------
{{
Description:
draws a filled rectangle from X1,Y1 to X2,Y2 using the specified color

Returns:
None
}}
_Ack := Fxn(5,Cmd_gfx_RectangleFilled,@X1)

pub ScreenMode(mode)                                 
'-------------------------------------------------------------------------
'--------------------------------┌────────────┐---------------------------
'--------------------------------│ ScreenMode │---------------------------
'--------------------------------└────────────┘---------------------------
'-------------------------------------------------------------------------
{{
Description:
alters the graphics orientation

Returns:
None
}}   
_Ack := Fxn(1,Cmd_gfx_ScreenMode,@mode) ''0=Landscape ; 1=Landscape reverse ; 2=Portrait ; 3=Portrait reverse  

pub SetGraphicsParameters(Function,Value)
'-------------------------------------------------------------------------
'--------------------------------┌───────────────────────┐----------------
'--------------------------------│ SetGraphicsParameters │----------------
'--------------------------------└───────────────────────┘----------------
'-------------------------------------------------------------------------
{{
Description:
Sets various parameters for the Graphics Commands.

Returns:
None
}}
_Ack := Fxn(2,Cmd_gfx_Set,@Function)

pub PenSize(mode)                                    
'-------------------------------------------------------------------------
'--------------------------------┌─────────┐------------------------------
'--------------------------------│ PenSize │------------------------------
'--------------------------------└─────────┘------------------------------
'-------------------------------------------------------------------------
{{
Description:
This will set the OLED to use either a wire frame or solid filling

Returns:
None
}} 
    SetGraphicsParameters(0,mode)

pub ObjectColor(Co)                                
'-------------------------------------------------------------------------
'--------------------------------┌─────────────┐--------------------------
'--------------------------------│ ObjectColor │--------------------------
'--------------------------------└─────────────┘--------------------------
'-------------------------------------------------------------------------
{{
Description:
Generic color for Cmd_gfx_LineTo(...)

Returns:
None
}}
    SetGraphicsParameters(2,Co)    

pub ExtendClipRegion                                    
'-------------------------------------------------------------------------
'--------------------------------┌──────────────────┐---------------------
'--------------------------------│ ExtendClipRegion │---------------------
'--------------------------------└──────────────────┘---------------------
'-------------------------------------------------------------------------
{{
Description:
forces the clip region to the extent of the last text that was printed, or the last image that was shown

Returns:
None
}}
_Ack := Fxn(0,Cmd_gfx_SetClipRegion,0)          ''Note: Need to enable first with the Clipping function

pub Transparency(Mode)                                   
'-------------------------------------------------------------------------
'--------------------------------┌──────────────┐-------------------------
'--------------------------------│ Transparency │-------------------------
'--------------------------------└──────────────┘-------------------------
'-------------------------------------------------------------------------
{{
Description:
Turn the transparency ON or OFF.                      '' 1=ON ; 0=OFF

Returns:
None
}}
_Ack := Fxn(1,Cmd_gfx_Transparency,@Mode)

pub Transparentcolor(Co)                                   
'-------------------------------------------------------------------------
'--------------------------------┌───────────────────┐--------------------
'--------------------------------│ Transparentcolor │--------------------
'--------------------------------└───────────────────┘--------------------
'-------------------------------------------------------------------------
{{
Description:
color that needs to be made transparent.             ''color, 0-65535

Returns:
None
}}
_Ack := Fxn(1,Cmd_gfx_Transparencycolor,@Co)

pub DrawTriangle(x1,y1,x2,y2,x3,y3,C0L0R)|varstore,index
'-------------------------------------------------------------------------
'--------------------------------┌──────────────┐-------------------------
'--------------------------------│ DrawTriangle │-------------------------
'--------------------------------└──────────────┘-------------------------
'-------------------------------------------------------------------------
{{
Description:
draws a triangle outline between x1,y1,x2,y2,x3,y3 using a specified color

Returns:
None
}}
_Ack := Fxn(7,Cmd_gfx_Triangle,@x1)
pub Triangle(x1,y1,x2,y2,x3,y3) ''Alias                 ''draws a triangle outline between x1,y1,x2,y2,x3,y3 using
DrawTriangle(x1,y1,x2,y2,x3,y3,color)                   ''current color

pub TextAttributes(Mode)                             
'-------------------------------------------------------------------------
'--------------------------------┌────────────────┐-----------------------
'--------------------------------│ TextAttributes │-----------------------
'--------------------------------└────────────────┘-----------------------
'-------------------------------------------------------------------------
{{
Description:
sets the text to underline

Returns:
None
}}
_Ack := Fxn(1,Cmd_txt_Attributes,@mode)       ''attribute cleared once the text (character or string)
                                                        ''is displayed
''                              BIT 5 = Bold
''                              BIT 6 = Italic
''                              BIT 7 = Inverse
''                              BIT 8 = Underlined

pub TextBackgroundColor(Co)                       
'-------------------------------------------------------------------------
'--------------------------------┌─────────────────────┐------------------
'--------------------------------│ TextBackgroundColor │------------------
'--------------------------------└─────────────────────┘------------------
'-------------------------------------------------------------------------
{{
Description:
Command Sets the text background color

Returns:
None
}}
_Ack := Fxn(1,Cmd_txt_BGcolor,@Co)

pub TextBold(mode)                                   
'-------------------------------------------------------------------------
'--------------------------------┌──────────┐-----------------------------
'--------------------------------│ TextBold │-----------------------------
'--------------------------------└──────────┘-----------------------------
'-------------------------------------------------------------------------
{{
Description:
sets the BOLD attribute for text

Returns:
None
}}
_Ack := Fxn(1,Cmd_txt_Bold,@mode)             ''attribute cleared once the text (character or string)
                                                        ''is displayed
                                                        ''                1=ON ; 0=OFF

pub TextForegroundColor(Co)                       
'-------------------------------------------------------------------------
'--------------------------------┌─────────────────────┐------------------
'--------------------------------│ TextForegroundColor │------------------
'--------------------------------└─────────────────────┘------------------
'-------------------------------------------------------------------------
{{
Description:
Command Sets the text foreground color

Returns:
None
}} 
_Ack := Fxn(1,Cmd_txt_FGcolor,@Co)

pub SetFont(id)
'-------------------------------------------------------------------------
'--------------------------------┌─────────┐------------------------------
'--------------------------------│ SetFont │------------------------------
'--------------------------------└─────────┘------------------------------
'-------------------------------------------------------------------------
{{
Description:
This will set the required font using it's ID. 0 for System font (default Fonts) ; 7 for Media fonts

Returns:
None
}}
_Ack := Fxn(1,Cmd_txt_FontID,@id)           ''* Needs further testing

pub TextHeight(height)                                 
'-------------------------------------------------------------------------
'--------------------------------┌────────────┐---------------------------
'--------------------------------│ TextHeight │---------------------------
'--------------------------------└────────────┘---------------------------
'-------------------------------------------------------------------------
{{
Description:
sets the text height multiplier

Returns:
None
}}
_Ack := Fxn(1,Cmd_txt_Height,@height)           ''1-16 Default = 1

pub TextInverse(mode)                                
'-------------------------------------------------------------------------
'--------------------------------┌─────────────┐--------------------------
'--------------------------------│ TextInverse │--------------------------
'--------------------------------└─────────────┘--------------------------
'-------------------------------------------------------------------------
{{
Description:
inverts the Foreground and Background color

Returns:
None
}}
_Ack := Fxn(1,Cmd_txt_Inverse,@mode)          ''attribute cleared once the text (character or string)
                                                        ''is displayed
                                                        ''                1=ON ; 0=OFF

pub TextItalic(mode)                                 
'-------------------------------------------------------------------------
'--------------------------------┌────────────┐---------------------------
'--------------------------------│ TextItalic │---------------------------
'--------------------------------└────────────┘---------------------------
'-------------------------------------------------------------------------
{{
Description:
sets the text to italic

Returns:
None
}}
_Ack := Fxn(1,Cmd_txt_Italic,@mode)           ''attribute cleared once the text (character or string)
                                                        ''is displayed
                                                        ''                1=ON ; 0=OFF

pub MoveCursor(row,column)                              
'-------------------------------------------------------------------------
'--------------------------------┌────────────┐---------------------------
'--------------------------------│ MoveCursor │---------------------------
'--------------------------------└────────────┘---------------------------
'-------------------------------------------------------------------------
{{
Description:
Move text cursor tp a screen position

Returns:
None
}}
_Ack := Fxn(2,Cmd_txt_MoveCursor,@row)

pub TextOpacity(mode)                                
'-------------------------------------------------------------------------
'--------------------------------┌─────────────┐--------------------------
'--------------------------------│ TextOpacity │--------------------------
'--------------------------------└─────────────┘--------------------------
'-------------------------------------------------------------------------
{{
Description:
determines if background pixels are drawn

Returns:
None
}}
_Ack := Fxn(1,Cmd_txt_Opacity,@mode)          ''attribute cleared once the text (character or string)
                                                        ''is displayed
                                                        ''                1=ON(Opaque) ; 0=OFF(Transparent)
pub opaquetext(data)            ''Alias
 TextOpacity(data)                                                        

pub SetTextParameters(Function,Value)                   
'-------------------------------------------------------------------------
'--------------------------------┌───────────────────┐--------------------
'--------------------------------│ SetTextParameters │--------------------
'--------------------------------└───────────────────┘--------------------
'-------------------------------------------------------------------------
{{
Description:
Sets various parameters for the Text commands

Returns:
None
}}
_Ack := Fxn(2,Cmd_txt_Set,@Function)

pub TextPrintDelay(delay)                               
'-------------------------------------------------------------------------
'--------------------------------┌────────────────┐-----------------------
'--------------------------------│ TextPrintDelay │-----------------------
'--------------------------------└────────────────┘-----------------------
'-------------------------------------------------------------------------
{{
Description:
Sets the Delay between the characters being printed through Put Character or Put String functions

Returns:
None
}}
    SetTextParameters(7,delay)                          ''0 - 255 msec ; Default = 0

pub TextUnderline(mode)                              
'-------------------------------------------------------------------------
'--------------------------------┌───────────────┐------------------------
'--------------------------------│ TextUnderline │------------------------
'--------------------------------└───────────────┘------------------------
'-------------------------------------------------------------------------
{{
Description:
sets the text to underline

Returns:
None
}}
_Ack := Fxn(1,Cmd_txt_Underline,@mode)        ''attribute cleared once the text (character or string)
                                                        ''is displayed
                                                        ''                1=ON ; 0=OFF

pub TextWidth(multiplier)                                  
'-------------------------------------------------------------------------
'--------------------------------┌───────────┐----------------------------
'--------------------------------│ TextWidth │----------------------------
'--------------------------------└───────────┘----------------------------
'-------------------------------------------------------------------------
{{
Description:
sets the text width multiplier

Returns:
None
}}
_Ack := Fxn(1,Cmd_txt_Width,@multiplier)            ''1-16 Default = 1

pub TextXgap(pixels)                                   
'-------------------------------------------------------------------------
'--------------------------------┌──────────┐-----------------------------
'--------------------------------│ TextXgap │-----------------------------
'--------------------------------└──────────┘-----------------------------
'-------------------------------------------------------------------------
{{
Description:
sets the pixel gap between characters (x-axis)

Returns:
None
}}
_Ack := Fxn(1,Cmd_txt_Xgap,@pixels)             ''0-32 Default = 0

pub TextYgap(pixels)                                   
'-------------------------------------------------------------------------
'--------------------------------┌──────────┐-----------------------------
'--------------------------------│ TextYgap │-----------------------------
'--------------------------------└──────────┘-----------------------------
'-------------------------------------------------------------------------
{{
Description:
sets the pixel gap between characters (y-axis)

Returns:
None
}}
_Ack := Fxn(1,Cmd_txt_Ygap,@pixels)             ''0-32 Default = 0

pub FlushMedia                                          ''UNTESTED FUNCTION                                          
'-------------------------------------------------------------------------
'--------------------------------┌────────────┐---------------------------
'--------------------------------│ FlushMedia │---------------------------
'--------------------------------└────────────┘---------------------------
'-------------------------------------------------------------------------
{{
Description:
After writing any data to a sector, the Flush Media command should be called to ensure data is written correctly

Returns:
None
}} 
_Ack := Fxn(0,Cmd_media_Flush,0)
result := Get_WORD_Response

pub DisplayImage(X,Y)                                   ''UNTESTED FUNCTION            
'-------------------------------------------------------------------------
'--------------------------------┌──────────────┐-------------------------
'--------------------------------│ DisplayImage │-------------------------
'--------------------------------└──────────────┘-------------------------
'-------------------------------------------------------------------------
{{
Description:
Displays an image from the media storage at the specified co-ordinates.  The image is previously specified with the
"Set Byte Address" or the "Set Sector Address".

Returns:
None
}}  
_Ack := Fxn(2,Cmd_media_Image,@X)

pub MediaInit                                           
'-------------------------------------------------------------------------
'--------------------------------┌───────────┐----------------------------
'--------------------------------│ MediaInit │----------------------------
'--------------------------------└───────────┘----------------------------
'-------------------------------------------------------------------------
{{
Description:
initializes a uSD/SD/SDHC memory card for further operations

Returns:
returned word represents memory type
}} 
_Ack := Fxn(0,Cmd_media_Init,0)                                         
result := Get_WORD_Response                             ''0  = No Memory Card

pub ReadByte                                            
'-------------------------------------------------------------------------
'--------------------------------┌──────────┐-----------------------------
'--------------------------------│ ReadByte │-----------------------------
'--------------------------------└──────────┘-----------------------------
'-------------------------------------------------------------------------
{{
Description:
returns byte value from current media address
}} 
_Ack := Fxn(0,Cmd_media_ReadByte,0)                                           
result := Get_WORD_Response

pub ReadWord                                            
'-------------------------------------------------------------------------
'--------------------------------┌──────────┐-----------------------------
'--------------------------------│ ReadWord │-----------------------------
'--------------------------------└──────────┘-----------------------------
'-------------------------------------------------------------------------
{{
Description:
returns word value from current media address
}} 
_Ack := Fxn(0,Cmd_media_ReadWord,0)                                           
result := Get_WORD_Response

pub SetByteAddress(HIword,LOword)                       
'-------------------------------------------------------------------------
'--------------------------------┌────────────────┐-----------------------
'--------------------------------│ SetByteAddress │-----------------------
'--------------------------------└────────────────┘-----------------------
'-------------------------------------------------------------------------
{{
Description:
Sets the media memory internal address pointer for access at non-sector aligned byte address

Returns:
None
}} 
_Ack := Fxn(2,Cmd_media_SetAdd,@HIword)

pub SetSectorAddress(HIword,LOword)                     
'-------------------------------------------------------------------------
'--------------------------------┌──────────────────┐---------------------
'--------------------------------│ SetSectorAddress │---------------------
'--------------------------------└──────────────────┘---------------------
'-------------------------------------------------------------------------
{{
Description:
Sets the media memory internal address pointer for sector access

Returns:
None
}} 
_Ack := Fxn(2,Cmd_media_SetSector,@HIword)

pub DisplayVideo(X,Y)                                   ''UNTESTED FUNCTION            
'-------------------------------------------------------------------------
'--------------------------------┌──────────────┐------------------------
'--------------------------------│ DisplayVideo │-------------------------
'--------------------------------└──────────────┘-------------------------
'-------------------------------------------------------------------------
{{
Description:
Displays a video clip from the media storage at the specified co-ordinates.  The image is previously specified with
the "Set Byte Address" or the "Set Sector Address".

Returns:
None
}}  
_Ack := Fxn(2,Cmd_media_Video,@X)

pub DisplayVideoFrame(x,y,Frame)                        ''UNTESTED FUNCTION         
'-------------------------------------------------------------------------
'--------------------------------┌───────────────────┐--------------------
'--------------------------------│ DisplayVideoFrame │--------------------
'--------------------------------└───────────────────┘--------------------
'-------------------------------------------------------------------------
{{
Description:
Displays a video frame from the media storage at the specified co-ordinates.  The image is previously specified with
the "Set Byte Address" or the "Set Sector Address".

Returns:
None
}}

_Ack := Fxn(3,Cmd_media_VideoFrame,@X)

pub WriteByte(value)                                  
'-------------------------------------------------------------------------
'--------------------------------┌───────────┐----------------------------
'--------------------------------│ WriteByte │----------------------------
'--------------------------------└───────────┘----------------------------
'-------------------------------------------------------------------------
{{
Description:
writes a byte value from current media address

Returns:
result Non Zero for successful media response ; 0 for attempt failed
}} 
_Ack := Fxn(1,Cmd_media_WriteByte,@value)                                     
result := Get_WORD_Response

pub WriteWord(value)                                  
'-------------------------------------------------------------------------
'--------------------------------┌───────────┐----------------------------
'--------------------------------│ WriteWord │----------------------------
'--------------------------------└───────────┘----------------------------
'-------------------------------------------------------------------------
{{
Description:
writes a word value from current media address

Returns:
result Non Zero for successful media response ; 0 for attempt failed
}} 
_Ack := Fxn(1,Cmd_media_WriteWord,@value)                               
result := Get_WORD_Response

pub Beep(Note,Duration)                                 
'-------------------------------------------------------------------------
'--------------------------------┌──────┐---------------------------------
'--------------------------------│ Beep │---------------------------------
'--------------------------------└──────┘---------------------------------
'-------------------------------------------------------------------------
{{
Description:
Produce a single musical note for the required duration through IO2

Note     - specifying frequency of note ranging from 0 to 64        Note: Using a Servo Extender cable and
Duration - time in milliseconds that the note will play for               aligning it on the uOLED so that
                                                                          the Black wire is connected to GND
                                                                          then IO1 is RED and IO2 is WHITE
                                                                          you can bring the I/O functionality
                                                                          of your uOLED to your project.
                                                                    Note: Beep is a single threaded process
                                                                          Beep is not a background task
Returns:
None
}}
_Ack := Fxn(2,_Beep,@Note)

pub BlitCom2Display(x,y,width,height,data)|idx        
'-------------------------------------------------------------------------
'--------------------------------┌─────────────────┐----------------------
'--------------------------------│ BlitCom2Display │----------------------
'--------------------------------└─────────────────┘----------------------
'-------------------------------------------------------------------------
{{
Description:
BLIT(BLock Image Transfer) 16 Bit pixel data from the COM port to the screen

Returns:
None
}}
SendData(_BlitComtoDisplay)
SendData(x)
SendData(y)
SendData(width)
SendData(height)
idx := 0
repeat width * height
   SendData(word[data][idx++])
_Ack := ser.CharIn

pub image(x, y, h, w, mode, data)|index,BMPdataTable,temp,R,G,B,Co
'-------------------------------------------------------------------------      Note: The image should be a standard
'--------------------------------┌───────┐--------------------------------            8-Bit 256 color BMP image and 
'--------------------------------│ image │--------------------------------            not exceed 128x128.
'--------------------------------└───────┘--------------------------------            To save space, use a 64x64 image
'-------------------------------------------------------------------------            with mode set to 1
{{
Description:
display image based on the string of data input in the "data" parameter. starting at location x,y with height "h"
and width "W"... 'mode' is legacy compatibility and is not used the same as before. It was used for defining an 8-bit
color reference or 16-Bit color reference to save program space.  Which sacrificed color depth for resolution.  The 
function implemented here uses the full 16-bit color reference and instead to save space sacrifices resolution. When
mode is equal to 0 you get the full color and full resolution.  When mode is equal to 1 you get the full color and half
the resolution.  In other words, the image is displayed twice as big in both the X and the Y.

MODE = 0  16 bit 5-6-5 color 128x128 pixel images
MODE = 1  16 bit 5-6-5 color 64x64 pixel images (saves space)

Returns:
Ack = 255
}}
mode &= 1                                               
''       find BMP data table                            
index := $0D                                                                         
BMPdataTable := byte[data][index--]                        
repeat 3                                                                                          
  BMPdataTable := BMPdataTable<<8 + byte[data][index--] 
                                                        
''       Go to beginning of BMP color table             
index := $36                                            
''color data is arranged in GBRA (Blue,Green,Red,Alpha) and there are 256 colors each of which are 8 bits.  To convert  
''the 8-8-8 BMP into the uOLED 5-6-5 format we need to divide the Red and Blue channel by 8 while dividing the Green      
''Channel by 4 and then create a composite which is only 1 WORD wide.

''      Load 256 palette table into user space
repeat temp from 1 to 256                            
  B := byte[data][index++]>>3                           '<-- Convert colors from 8-8-8 to 5-6-5
  G := byte[data][index++]>>2
  R := byte[data][index++]>>3
                  index++                               '<-- Place holder for Alpha ; not used
  C0L0RPalette[temp] := R<<11+G<<5+B                    '<-- pack 5-6-5 colors into WORD

''       Go to beginning of BMP data table
index := BMPdataTable
''The remaining BYTES define the data.  Each BYTE represents one pixel where the value
''points to one of the 256 colors in the color palette defined above.

SendData(_BlitComtoDisplay)                               
SendData(x)                                               
SendData(y)                                                
SendData(w<<mode)                                          
SendData(h<<mode)

waitcnt(clkfreq/500+cnt)                                          
                                                           
index += (w * (h-1) )                                      
repeat h                                                   
  repeat 1<<mode
    repeat w
      temp := index++
      repeat 1<<mode
        Co := C0L0RPalette[byte[data][temp]+1]
        SendData(Co)
        
    index -= w
  index -= w

_Ack := ser.CharIn

pub CharacterHeight(height)
'-------------------------------------------------------------------------
'--------------------------------┌─────────────────┐----------------------
'--------------------------------│ CharacterHeight │----------------------
'--------------------------------└─────────────────┘----------------------
'-------------------------------------------------------------------------
{{
Description:
Used to calculate the height in pixel units for a character based on the currently selected font.

Returns:
returns a calculated character height
}}
SendData(_CharHeight)
ser.char(height)
_Ack    := ser.CharIn
result := Get_WORD_Response

pub CharacterWidth(width)    
'-------------------------------------------------------------------------
'--------------------------------┌────────────────┐-----------------------
'--------------------------------│ CharacterWidth │-----------------------
'--------------------------------└────────────────┘-----------------------
'-------------------------------------------------------------------------
{{
Description:
Used to calculate the width in pixel units for a character based on the currently selected font.

Returns:
returns a calculated character width
}}
SendData(_CharWidth)
ser.char(width)
_Ack    := ser.CharIn
result := Get_WORD_Response

pub Joystick                                            
'-------------------------------------------------------------------------
'--------------------------------┌──────────┐-----------------------------
'--------------------------------│ Joystick │-----------------------------
'--------------------------------└──────────┘-----------------------------
'-------------------------------------------------------------------------
{{
Description:
Returns the value of the Joystick position from 0-5
}} 
_Ack := Fxn(0,_Joystick,0)
result := Get_WORD_Response                             ''0=Released
                                                        ''1=Up          Note: Using a Servo Extender cable and
                                                        ''2=Left              aligning it on the uOLED so that
                                                        ''3=Down              the Black wire is connected to GND
                                                        ''4=Right             then IO1 is RED and IO2 is WHITE
                                                        ''5=Press             you can bring the I/O functionality
                                                        ''                    of your uOLED to your project.
pub BytePeek(value)                                   
'-------------------------------------------------------------------------
'--------------------------------┌──────────┐-----------------------------
'--------------------------------│ BytePeek │-----------------------------
'--------------------------------└──────────┘-----------------------------
'-------------------------------------------------------------------------
{{
Description:
returned the EVE system Byte Register value
}} 
_Ack := Fxn(1,_peekB,@value)                                           
result := Get_WORD_Response

pub WordPeek(value)                              
'-------------------------------------------------------------------------
'--------------------------------┌──────────┐-----------------------------
'--------------------------------│ WordPeek │-----------------------------
'--------------------------------└──────────┘-----------------------------
'-------------------------------------------------------------------------
{{
Description:
returned the EVE system Word Register value
}}
_Ack := Fxn(1,_peekW,@value)                                           
result := Get_WORD_Response

pub BytePoke(Register,value)                          
'-------------------------------------------------------------------------
'--------------------------------┌──────────┐-----------------------------
'--------------------------------│ BytePoke │-----------------------------
'--------------------------------└──────────┘-----------------------------
'-------------------------------------------------------------------------
{{
Description:
sets the EVE system Byte Register value

Returns:
None
}}
if ByteRegisterCheck(Register)==1 
   _Ack := Fxn(2,_pokeB,@Register)
else
   _Ack := 0

pub WordPoke(Register,value)                          
'-------------------------------------------------------------------------
'--------------------------------┌──────────┐-----------------------------
'--------------------------------│ WordPoke │-----------------------------
'--------------------------------└──────────┘-----------------------------
'-------------------------------------------------------------------------
{{
Description:
sets the EVE system Word Register value

Returns:
None
}}
if WordRegisterCheck(Register)==1
   _Ack := Fxn(2,_pokeW,@Register)
else
   _Ack := 0

pub PutCharacter(chr)
'-------------------------------------------------------------------------
'--------------------------------┌──────────────┐-------------------------
'--------------------------------│ PutCharacter │-------------------------
'--------------------------------└──────────────┘-------------------------
'-------------------------------------------------------------------------
{{
Description:
Prints a single character to display

Returns:
None
}}
_Ack := Fxn(1,_putCH,@chr)

pub PutString(data,size)                                
'-------------------------------------------------------------------------
'--------------------------------┌───────────┐----------------------------
'--------------------------------│ PutString │----------------------------
'--------------------------------└───────────┘----------------------------
'-------------------------------------------------------------------------
{{
Description:
Prints a Null terminated string string to the display

Note: If size is set to a number less than the actual string   
      length, then only that number of characters in the string
      are printed.  If size is set to 0 or a number larger than
      the string length, then the entire string is printed.

Returns:
None      
}}
if size == 0 or size > strsize(data)                    
   size := strsize(data)                                
SendData(_PutStr)               
repeat until size == 0          
  ser.char(byte[data++])       
  size--                        
ser.char(0)
_Ack := ser.CharIn

pub ScreenSaverMode(mode)                               
'-------------------------------------------------------------------------
'--------------------------------┌─────────────────┐----------------------
'--------------------------------│ ScreenSaverMode │----------------------
'--------------------------------└─────────────────┘----------------------
'-------------------------------------------------------------------------
{{
Description:
Set Screen Saver Scroll Direction

uLCD-144-G2  n/a                          
uOLED-96-G2  n/a                          
uOLED-128-G2 n/a                          
uOLED-160-G2 0-Up, 1-Down, 2-Left, 3-Right
uTOLED-20-G2 0-Left, 1-Right, 3-Down, 7-Up
             4-Left/Down, 5-Down/Right    
             8-Top/Left, 9-Top/Right

Returns:
None
}}
_Ack := Fxn(1,_SSMode,@mode)

pub ScreenSaverTimeout(timeout)                         
'-------------------------------------------------------------------------
'--------------------------------┌────────────────────┐-------------------
'--------------------------------│ ScreenSaverTimeout │-------------------
'--------------------------------└────────────────────┘-------------------
'-------------------------------------------------------------------------
{{
Description:
Set the Screen Saver Timeout

0 disables the screen saver
1-65535 specifies the timeout in milliseconds

Returns:
None
}}
_Ack := Fxn(1,_SSTimeout,@timeout)

pub ScreenSaverSpeed(speed)                             
'-------------------------------------------------------------------------
'--------------------------------┌──────────────────┐---------------------
'--------------------------------│ ScreenSaverSpeed │---------------------
'--------------------------------└──────────────────┘---------------------
'-------------------------------------------------------------------------
{{
Description:
Set the Screen Saver speed

Returns:
None
}}
_Ack := Fxn(1,_SSSpeed,@speed)                          ''uLCD-144-G2  n/a
                                                        ''uOLED-96-G2  0-3   (Fastest-Slowest)
                                                        ''uOLED-128-G2 0-3   (Fastest-Slowest)
                                                        ''uOLED-160-G2 0-255 (Fastest-Slowest)
                                                        ''uTOLED-20-G2 1-16  (Fastest-Slowest)

pub GetDisplayModel|index                               
'-------------------------------------------------------------------------
'--------------------------------┌─────────────────┐----------------------
'--------------------------------│ GetDisplayModel │----------------------
'--------------------------------└─────────────────┘----------------------
'-------------------------------------------------------------------------
{{
Description:
Returns the Display Model in the form of a string address
}}
_Ack := Fxn(0,Cmd_sys_GetModel,0)
ClearStr
index := 0
repeat Get_WORD_Response
   byte[strAddress][index++] := ser.CharIn
result := strAddress
pub requestinfo                 ''Alias                 ''Returns the Display Model in the form of a string address
result := GetDisplayModel

pub GetPmmCVersion                                      
'-------------------------------------------------------------------------
'--------------------------------┌────────────────┐-----------------------
'--------------------------------│ GetPmmCVersion │-----------------------
'--------------------------------└────────────────┘-----------------------
'-------------------------------------------------------------------------
{{
Returns:
Returns the PmmC Version installed on the module in Hex

}}
_Ack := Fxn(0,Cmd_sys_GetPmmC,0)
result := Get_WORD_Response

pub GetSPEVersion                                       
'-------------------------------------------------------------------------
'--------------------------------┌───────────────┐------------------------
'--------------------------------│ GetSPEVersion │------------------------
'--------------------------------└───────────────┘------------------------
'-------------------------------------------------------------------------
{{
Returns:
Returns the SPE Version installed on the module in Hex
}}
_Ack := Fxn(0,Cmd_sys_GetVersion,0)
result := Get_WORD_Response

pub SetBaud(baud)                                    
'-------------------------------------------------------------------------
'--------------------------------┌─────────┐------------------------------
'--------------------------------│ SetBaud │------------------------------
'--------------------------------└─────────┘------------------------------
'-------------------------------------------------------------------------
{{
Description:
specifies the baud rate index value

Returns:
None
}}
_Ack := Fxn(1,_SetBaud,@baud)         
                                                            
pub WritePalette(C0L0R,value)                           
'-------------------------------------------------------------------------
'--------------------------------┌──────────────┐-------------------------
'--------------------------------│ WritePalette │-------------------------
'--------------------------------└──────────────┘-------------------------
'-------------------------------------------------------------------------

''Sets one of 256 colors in the scratch pad color palette                       Note: the image function uses this palette

C0L0RPalette[(C0L0R & $FF)+1] := value & $FFFF 
                                                   
pub ReadPalette(C0L0R)                                  
'-------------------------------------------------------------------------
'--------------------------------┌─────────────┐--------------------------
'--------------------------------│ ReadPalette │--------------------------
'--------------------------------└─────────────┘--------------------------
'-------------------------------------------------------------------------

''Reads one of 256 colors in the scratch pad color palette

result := C0L0RPalette[(C0L0R & $FF)+1] 


pub RunScreenSaver(time)                                
'-------------------------------------------------------------------------
'--------------------------------┌────────────────┐-----------------------
'--------------------------------│ RunScreenSaver │-----------------------
'--------------------------------└────────────────┘-----------------------
'-------------------------------------------------------------------------

''Run Screen Saver for N milliseconds, and then disable Screen Saver

ScreenSaverTimeout(1) 
waitcnt(((clkfreq/1000)*time)+cnt)
ScreenSaverTimeout(0) 

 
pub SystemTimer                                         
'-------------------------------------------------------------------------
'--------------------------------┌─────────────┐--------------------------
'--------------------------------│ SystemTimer │--------------------------
'--------------------------------└─────────────┘--------------------------
'-------------------------------------------------------------------------

''Get 32-Bit uOLED System Timer value

result := WordPeek(113)<<16 + WordPeek(112) 
                                                        
pub XScreenResolution                                   
'-------------------------------------------------------------------------
'--------------------------------┌───────────────────┐--------------------
'--------------------------------│ XScreenResolution │--------------------
'--------------------------------└───────────────────┘--------------------
'-------------------------------------------------------------------------

''X Screen Resolution

result := BytePeek(132)              

pub YScreenResolution                                   
'-------------------------------------------------------------------------
'--------------------------------┌───────────────────┐--------------------
'--------------------------------│ YScreenResolution │--------------------
'--------------------------------└───────────────────┘--------------------
'-------------------------------------------------------------------------

''Y Screen Resolution

result := BytePeek(133)              

'-----------------------------------------------------------------------------------------------------------------
'-----------------------------------------------------------------------------------------------------------------
'-----------------------------------------------------------------------------------------------------------------
'-----------------------------------------------------------------------------------------------------------------

pub RGB(Red,Green,Blue)                                 
'-------------------------------------------------------------------------
'--------------------------------┌─────┐----------------------------------
'--------------------------------│ RGB │----------------------------------
'--------------------------------└─────┘----------------------------------
'-------------------------------------------------------------------------

''Creates composite LONG value from RGB values

   color := ((Red >> 3) << 11) | ((Green >> 2) << 5) | (Blue >> 3)
   result := color
   
   '' Input Format: 8-Bit Red / 8-Bit Green / 8-Bit Blue   24 Bit color
   ''Output Format: 5-Bit Red / 6-Bit Green / 5-Bit Blue   16 Bit color

pub customcolor(colordata)                              
'-------------------------------------------------------------------------
'--------------------------------┌─────────────┐--------------------------
'--------------------------------│ customcolor │--------------------------
'--------------------------------└─────────────┘--------------------------
'-------------------------------------------------------------------------

''This is for choosing you own colors. The input must be a (5-6-5) 16 bit representation of the color
                                                        
    color := colordata                                  '' See also the ... RGB command                                                           
                                                        
pub BaudIndex(Baud)                                     
'-------------------------------------------------------------------------
'--------------------------------┌───────────┐----------------------------
'--------------------------------│ BaudIndex │----------------------------
'--------------------------------└───────────┘----------------------------
'-------------------------------------------------------------------------

''Calculate Baud Index

result :=  (3000000 / Baud)-1   
   
pub placestring(column, row, data, size)
'-------------------------------------------------------------------------
'--------------------------------┌─────────────┐--------------------------
'--------------------------------│ placestring │--------------------------
'--------------------------------└─────────────┘--------------------------
'-------------------------------------------------------------------------
{{
Description:
This will place a string of text on the display. It will start at the column and row specified in the first two 
parameters... specified in the first two parameters..."data" is the parameter used for passing along the array of 
characters. "size" is the number of bytes of data that are to be sent

Note: 'color' is a global variable set with choosecolor, customcolor, or RGB

Returns:
None
}}

MoveCursor(row,column)          'Move Cursor first
TextForegroundColor(color)      'Set Color
PutString(data,size)            'Display String

pub erasechar(c,r)                                      
'-------------------------------------------------------------------------
'--------------------------------┌───────────┐----------------------------
'--------------------------------│ erasechar │----------------------------
'--------------------------------└───────────┘----------------------------
'-------------------------------------------------------------------------
{{
Description:
This command will erase a single character(located by c and r) by converting it back to it's background color.

Returns:
None
}}
     placestring(c, r, string(" "), 0)

pub char(Chardata, c, r)                                
'-------------------------------------------------------------------------
'--------------------------------┌──────┐---------------------------------
'--------------------------------│ char │---------------------------------
'--------------------------------└──────┘---------------------------------
'-------------------------------------------------------------------------
{{
Description:
This command will simply place a ASCII character onto the display at the appropriate column and row

Returns:
None
}} 
    strAddress := string(" ")
    byte[strAddress]:=Chardata 
    placestring(c, r, strAddress, 0)     

pub bmpchar(x,y,charID, Data)|index,bitdata             
'-------------------------------------------------------------------------
'--------------------------------┌─────────┐------------------------------
'--------------------------------│ bmpchar │------------------------------
'--------------------------------└─────────┘------------------------------
'-------------------------------------------------------------------------

''Uses BLIT(BLock Image Transfer) to send a custom 8x8 bitmap character image to the screen

SendData(_BlitComtoDisplay)
SendData(x)
SendData(y)
SendData(8)                                             ''Data = Address of an 8x8 bit array
SendData(8)
index := charID * 8                                     ''charID is the character index 
repeat 8
  bitdata := byte[data][index++]
  repeat 8
    if (bitdata & 128)== 128
       SendData(color)
    else
       SendData(0)
    bitdata := bitdata << 1   
_Ack := ser.CharIn

pub choosecolor(colorpointer)
'-------------------------------------------------------------------------
'--------------------------------┌─────────────┐--------------------------
'--------------------------------│ choosecolor │--------------------------
'--------------------------------└─────────────┘--------------------------
'-------------------------------------------------------------------------
''This function will set a common variable(Color) to represent one of the pre-defined colors. You can also make your
''own using the "customcolor" or "RGB" method. This function accepts a single ASCII character. Use the following chart
''to determine color

case colorpointer
  "B" : color := %00000_000000_00011 'DarkBlue
  "b" : color := %00000_000000_11111 'LightBlue 
  "G" : color := %00000_000011_00000 'DarkGreen
  "g" : color := %00000_011111_00000 'LightGreen
  "R" : color := %00010_000000_00000 'DarkRed
  "r" : color := %11111_000000_00000 'LightRed
  "Y" : color := %00010_000100_00000 'DarkYellow
  "y" : color := %11111_111110_00000 'LightYellow
  "P" : color := %00010_000000_00010 'DarkPurple
  "p" : color := %00111_000000_00111 'LightPurple
  "O" : color := %10011_001111_00000 'Orange
  "W" : color := %11111_111111_11111 'BrightWhite
  "H" : color := %11111_000111_01011 'HotPink
  "D" : color := %00000_000000_00000 'dark(black)

pub Gauge(x,y,r,mode,C0L0R,level,GaugeNumber)|data1,data2,index                 
'-------------------------------------------------------------------------
'--------------------------------┌───────┐--------------------------------
'--------------------------------│ Gauge │--------------------------------
'--------------------------------└───────┘--------------------------------
'-------------------------------------------------------------------------

''Displays a circular 180 Deg indicator Gauge located at x,y .. r sets the gauge radius Mode adjusts the screen orientation, see
''the 'ScreenMode' for more information 'color' sets the color you want the Gauge to be drawn. 'level' is the position of
''the gauge 0-255. GaugeNumber 1-4 references the active gauge.  It is used to prevent unnecessary redraw when the value of
''the gauge doesn't need to be changed.
    GaugeNumber := (GaugeNumber -1)& %11
    level := (((level & $FF) * 179)/255)                                        
    ScreenMode(mode)                                                        
    MoveOrigin(x,y)                                                         
    if GaugeValue[GaugeNumber]& $100 <> $100                                     
       repeat index from 360 to 180 step 18                                     
         data1 := CalculateOrbit(index,r)                                   
         data2 := CalculateOrbit(index,r+5)                                 
         DrawLine(data1.word[1],data1.word[0],data2.word[1],data2.word[0],C0L0R)  
    if GaugeValue[GaugeNumber]& $FF<>level                                      
       data1 := CalculateOrbit(360-GaugeValue[GaugeNumber]& $FF,r-1)
       DrawLine(x,y,data1.word[1],data1.word[0],0)       
       GaugeValue[GaugeNumber] := 1<<8 + level
    data1 := CalculateOrbit(360-level,r-1)
    DrawLine(x,y,data1.word[1],data1.word[0],C0L0R)
    MoveOrigin(0,0)
    ScreenMode(0)

pub BARgraph(x,y,mode,size,segments,ColorON,ColorOFF,level,BARnumber)|index,offset,C0L0R,thresh
'-------------------------------------------------------------------------
'--------------------------------┌──────────┐-----------------------------
'--------------------------------│ BARgraph │-----------------------------
'--------------------------------└──────────┘-----------------------------
'-------------------------------------------------------------------------

''Displays a linear BAR graph meter with the top left corner being at location x,y Mode adjusts the screen orientation,
''see the 'ScreenMode' for more information 'size' sets the pixel width of each LED segment. The height of each segment is 
''scaled to 1/4th of the width. 'segemnts' determine the total number of segments in the graph. ColorON - the "ON" color ; 
''likewise for ColorOFF. 'level' is the position of the gauge 0-255. BARnumber 1-4 references the active graph. It is used
''to prevent unnecessary redraw when the value of the graph doesn't need to be changed.
    BARnumber := (BARnumber -1)& %11 
    level := level & $FF
    thresh := (segments * (255-level))/255                                      
    offset := 0                                                                 
    ScreenMode(mode)                                                        
    if BarValue[BARnumber] <> thresh                                            
       BarValue[BARnumber] := thresh                                            
       repeat index from 1 to segments                                          
         if thresh => index                                                     
            C0L0R := ColorOFF                                                   
         else                                                                   
            C0L0R := ColorON                                                    
         DrawFilledRectangle(x,y+offset,x+size,size>>2+offset,C0L0R)         
         offset += size>>1-1                                                      
    ScreenMode(0)
                                                                                
pri ByteRegisterCheck(location)|flag       ''Memory protection to avoid accidental writes into system memory
flag := 0
case location                   ''Note: Memory that is ok to write to, the flag is set to a "1"                   
  138     :  flag:=1
  140..147:  flag:=1
  153..154:  flag:=1
  156..156:  flag:=1
result := flag

pri WordRegisterCheck(location)|flag       ''Memory protection to avoid accidental writes into system memory
flag := 0
case location                   ''Note: Memory that is ok to write to, the flag is set to a "1"
  83      :  flag:=1
  86..91  :  flag:=1            
  104..105:  flag:=1
  112..118:  flag:=1
  121     :  flag:=1
  129..383:  flag:=1
result := flag

pub Char5x7(x,y,address)|index                          
'-------------------------------------------------------------------------
'--------------------------------┌─────────┐------------------------------
'--------------------------------│ Char5x7 │------------------------------
'--------------------------------└─────────┘------------------------------
'-------------------------------------------------------------------------

''Display 5x7 Null terminated String at location specified by x,y

index := 0 
repeat strsize(address)
  displaybmpchar(byte[address][index], x+index++*6, y)

pub displaybmpchar(_char, x, y)                          
'-------------------------------------------------------------------------
'--------------------------------┌────────────────┐-----------------------
'--------------------------------│ displaybmpchar │-----------------------
'--------------------------------└────────────────┘-----------------------
'-------------------------------------------------------------------------

''Display 5x7 Character at location specified by x,y

if _char >64 and _char<92
   bmpchar(x,y,_char-65, @bitmap)
if _char >96 and _char<123
   bmpchar(x,y,_char-97, @bitmap)
if _char >47 and _char<59
   bmpchar(x,y,(_char-48)+26, @bitmap)     

pub Ack                                                                         ''Request latest Ack result
    result := _Ack
pub NextAck                                                                     ''Adapted mainly for Debugging
    _Ack := ser.CharIn
    result := _Ack    

pub dec(data, c, r)
'-------------------------------------------------------------------------
'--------------------------------┌─────┐----------------------------------
'--------------------------------│ dec │----------------------------------
'--------------------------------└─────┘----------------------------------
'-------------------------------------------------------------------------

''Simply displays a byte, word or long as a series of ASCII characters representing their number in decimal "r" and "c"
''are the starting column and row                                                            
                                                        
placestring(c, r, decstr(data), 0)

pub binary(data, digits, c,r)
'-------------------------------------------------------------------------
'--------------------------------┌────────┐-------------------------------
'--------------------------------│ binary │-------------------------------
'--------------------------------└────────┘-------------------------------
'-------------------------------------------------------------------------

''This is used to display binary data onto the screen. "Digits" is the number of digits in the sequence "r" and
'' "c" are the starting column and row
                                                                                                             
placestring(c, r, binstr(data, digits), 0)

pub hex(data, digits,c,r)
'-------------------------------------------------------------------------
'--------------------------------┌─────┐----------------------------------
'--------------------------------│ hex │----------------------------------
'--------------------------------└─────┘----------------------------------
'-------------------------------------------------------------------------

''Simply displays a Hex number on to the screen, "Digits" is the number of digits in the sequence "r" and "c" are the
''starting column and row
                                              
placestring(c, r, hexstr(data, digits), 0)
                                                      
pri Fxn(argCount,Command,ArgAddress)|index
SendData(Command)
index := 0
repeat argCount
   SendData(long[ArgAddress][index++])                  ''Main Function to communicate with various methods 
result := ser.CharIn                                    ''associated with the uOLED display

pri SendData(Data)                                      ''Send Word variable to the uOLED display 
ser.char(Data.byte[1])                                           
ser.char(Data.byte[0])
'waitcnt(clkfreq/3500 + cnt)

pri Get_WORD_Response                                   ''Read Word variable response from the uOLED display
result := ser.CharIn<< 8 + ser.CharIn                   ''return WORD result

PUB decstr(value) | div, z_pad,idx   

' Converts value to signed-decimal string equivalent
' -- characters written to current position of idx
' -- returns pointer to strAddress

  ClearStr
  idx := 0

  if (value < 0)                                        ' negative value? 
    -value                                              '   yes, make positive
    byte[strAddress][idx++] := "-"                                  '   and print sign indicator

  div := 1_000_000_000                                  ' initialize divisor
  z_pad~                                                ' clear zero-pad flag

  repeat 10
    if (value => div)                                   ' printable character?
      byte[strAddress][idx++] := (value / div + "0")    '   yes, print ASCII digit
      value //= div                                     '   update value
      z_pad~~                                           '   set zflag
    elseif z_pad or (div == 1)                          ' printing or last column?
      byte[strAddress][idx++] := "0"
    div /= 10 

  return strAddress

PUB binstr(value, digits)|idx

' Converts value to digits-wide binary string equivalent
' -- characters written to current position of idx
' -- returns pointer to strAddress

  ClearStr
  idx := 0

  digits := 1 #> digits <# 32                           ' qualify digits 
  value <<= 32 - digits                                 ' prep MSB
  repeat digits
    byte[strAddress][idx++] := (value <-= 1) & 1 + "0"  ' move digits (ASCII) to string

return strAddress

PUB hexstr(value, digits)|idx

' Converts value to digits-wide hexadecimal string equivalent
' -- characters written to current position of idx
' -- returns pointer to strAddress
  ClearStr
  idx := 0
  
  digits := 1 #> digits <# 8                            ' qualify digits
  value <<= (8 - digits) << 2                           ' prep most significant digit
  repeat digits
    byte[strAddress][idx++] := lookupz((value <-= 4) & $F : "0".."9", "A".."F")

  return strAddress

pri ClearStr
  strAddress := string("                    ")
  bytefill(strAddress,0,strsize(strAddress))    


DAT

'----------------------------------------------------------
'                bitmap for 5x7 Character set
'----------------------------------------------------------
bitmap  byte  $70, $88, $88, $F8, $88, $88, $88, $00    ''A
        byte  $F0, $88, $88, $F0, $88, $88, $F0, $00    ''B
        byte  $70, $88, $80, $80, $80, $88, $70, $00    ''C
        byte  $F0, $88, $88, $88, $88, $88, $F0, $00    ''D
        byte  $F8, $80, $80, $F0, $80, $80, $F8, $00    ''E
        byte  $F8, $80, $80, $F0, $80, $80, $80, $00    ''F
        byte  $70, $88, $80, $80, $98, $88, $68, $00    ''G
        byte  $88, $88, $88, $F8, $88, $88, $88, $00    ''H
        byte  $F8, $20, $20, $20, $20, $20, $F8, $00    ''I
        byte  $70, $20, $20, $20, $20, $20, $C0, $00    ''J
        byte  $88, $90, $A0, $C0, $A0, $90, $88, $00    ''K
        byte  $80, $80, $80, $80, $80, $80, $F8, $00    ''L
        byte  $88, $D8, $A8, $88, $88, $88, $88, $00    ''M
        byte  $88, $88, $C8, $A8, $98, $88, $88, $00    ''N
        byte  $70, $88, $88, $88, $88, $88, $70, $00    ''O
        byte  $F0, $88, $88, $F0, $80, $80, $80, $00    ''P
        byte  $70, $88, $88, $88, $A8, $90, $68, $00    ''Q
        byte  $F0, $88, $88, $F0, $90, $88, $88, $00    ''R
        byte  $70, $88, $80, $70, $08, $88, $70, $00    ''S
        byte  $F8, $20, $20, $20, $20, $20, $20, $00    ''T
        byte  $88, $88, $88, $88, $88, $88, $70, $00    ''U
        byte  $88, $88, $88, $88, $88, $50, $20, $00    ''V
        byte  $88, $88, $88, $88, $A8, $D8, $88, $00    ''W
        byte  $88, $88, $50, $20, $50, $88, $88, $00    ''X
        byte  $88, $88, $50, $20, $20, $20, $20, $00    ''Y
        byte  $F8, $08, $10, $20, $40, $80, $F8, $00    ''Z
        byte  $70, $88, $98, $A8, $C8, $88, $70, $00    ''0
        byte  $20, $60, $20, $20, $20, $20, $70, $00    ''1
        byte  $70, $88, $10, $20, $40, $80, $F8, $00    ''2
        byte  $F8, $10, $20, $70, $08, $88, $70, $00    ''3
        byte  $30, $50, $90, $F8, $10, $10, $10, $00    ''4
        byte  $F8, $80, $80, $F0, $08, $88, $70, $00    ''5
        byte  $70, $80, $80, $70, $88, $88, $70, $00    ''6
        byte  $F8, $08, $10, $20, $40, $40, $40, $00    ''7
        byte  $70, $88, $88, $70, $88, $80, $70, $00    ''8
        byte  $70, $88, $88, $70, $08, $00, $70, $00    ''9
         
dat
{{

┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                 │                                                            
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation   │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,   │
│modify, merge, publish, distribute, sub license, and/or sell copies of the Software, and to permit persons to whom the       │
│Software is furnished to do so, subject to the following conditions:                                                         │         
│                                                                                                                             │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the         │
│Software.                                                                                                                    │
│                                                                                                                             │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE         │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR        │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,  │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                        │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}        
 
 
