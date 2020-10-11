local toolName = "TNS|Change ISRM mode|TNE"

---- #########################################################################
---- #                                                                       #
---- # Copyright (C) OpenTX                                                  #
-----#                                                                       #
---- # License GPLv2: http://www.gnu.org/licenses/gpl-2.0.html               #
---- #                                                                       #
---- # This program is free software; you can redistribute it and/or modify  #
---- # it under the terms of the GNU General Public License version 2 as     #
---- # published by the Free Software Foundation.                            #
---- #                                                                       #
---- # This program is distributed in the hope that it will be useful        #
---- # but WITHOUT ANY WARRANTY; without even the implied warranty of        #
---- # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
---- # GNU General Public License for more details.                          #
---- #                                                                       #
---- #########################################################################

local mode = -1

local function redrawPage()
  
  lcd.clear()
  
  if LCD_W == 480 then
    lcd.drawFilledRectangle(0, 0, LCD_W, 30, TITLE_BGCOLOR)
    lcd.drawText(1,5, "ISRM MODE Changer", MENU_TITLE_COLOR)
 
    if mode == 0 then
      lcd.drawFilledRectangle((LCD_W / 2) - 85, (LCD_H / 2) - 40, 80, 80, TITLE_BGCOLOR)
    else
      lcd.drawRectangle((LCD_W / 2) - 85, (LCD_H / 2) - 40, 80, 80, 0)
    end
    lcd.setColor(CUSTOM_COLOR, lcd.RGB(0,0,0))
    lcd.drawText((LCD_W/2) - 44, (LCD_H / 2) - 10, "LBT / EU", CENTER + CUSTOM_COLOR)

    if mode == 1 then
      lcd.drawFilledRectangle((LCD_W / 2) + 5, (LCD_H / 2) - 40, 80, 80, TITLE_BGCOLOR);
    else
      lcd.drawRectangle((LCD_W / 2) + 5, (LCD_H / 2) - 40, 80, 80, 0);
    end
    lcd.drawText((LCD_W/2) + 43, (LCD_H / 2) - 10 , "FCC", CENTER + CUSTOM_COLOR)

    if mode == -1 then
      lcd.drawText(LCD_W/2, LCD_H - 20, "Reading mode...", CENTER)
    else
      lcd.drawText(LCD_W/2, LCD_H - 20, "Check your country law!", CENTER)
    end  
  
  else
    lcd.drawScreenTitle("ISRM MODE Changer", 0, 0)

    lcd.drawText(5 + 28, 30, "LBT / EU", CENTER)
    if mode == 0 then
      lcd.drawFilledRectangle(5, 14, 56, LCD_H - 25, 0)
    else
      lcd.drawRectangle(5, 14, 56, LCD_H - 25, 0)
    end

    lcd.drawText(67 + 28, 30, "FCC", CENTER)
    if mode == 1 then
      lcd.drawFilledRectangle(67, 14, 56, LCD_H - 25, 0);
    else
      lcd.drawRectangle(67, 14, 56, LCD_H - 25, 0);
    end

    if mode == -1 then
      lcd.drawText(LCD_W/2, LCD_H - 8, "Reading mode...", CENTER)
    else
      lcd.drawText(LCD_W/2, LCD_H - 8, "Check your country law!", CENTER)
    end    
    
  end  

end

local function modeRead()
  return accessTelemetryPush(0, 0, 0x17, 0x30, 0x0C40, 0xA0AA5555)
end

local function modeWrite(value)
  if 0 == value then
    command = 0xA0AA5555
  else
    command = 0xA1AA5555
  end
  return accessTelemetryPush(0, 0, 0x17, 0x31, 0x0C40, command)
end


local function telemetryPop()
  physicalId, primId, dataId, value = sportTelemetryPop()
  if primId == 0x32 and dataId >= 0X0C40 and dataId <= 0X0C4F then
    mode = math.floor(value / 0x1000000) - 0xA0
  end
end

local function runPage(event)
  if event == EVT_EXIT_BREAK then
    return 2
  elseif event == EVT_PLUS_FIRST or event == EVT_ROT_RIGHT or event == EVT_PLUS_REPT or event == EVT_RIGHT_FIRST or event == EVT_MINUS_FIRST or event == EVT_ROT_LEFT or event == EVT_MINUS_REPT or event == EVT_LEFT_FIRST then
    local newmode
    if mode == 0 then
      newmode = 1
    else
      newmode = 0
    end
    mode = -1
    modeWrite(newmode)
  else
    if mode == -1 then
      modeRead()
    end
    telemetryPop()
  end
  redrawPage()
  return 0
end

-- Init
local function init()
end

-- Run
local function run(event)
  if event == nil then
    error("Cannot run as a model script!")
    return 2
  end

  return runPage(event)
end

return { init=init, run=run }
