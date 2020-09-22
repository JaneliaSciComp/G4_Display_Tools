---
title:  Panel Programmer
parent: Setup
grand_parent: Generation 4
nav_order: 12
---

**Note**, you will need a custom version of the Arduino IDE with the PanelsG4 board added as a target.

# Preparation

Program the Arduino Uno to be a AVR programmer. If required ­ I included pre­programmed Arduino.

1. Connect Arduino (Make sure programmer shield is off it will prevent programming)
1. Open Arduino IDE.
1. Go to *Tools*{:.gui-txt} ­> *Board*{:.gui-txt} and select *Arduino UNO*{:.gui-txt}.
1. Go to *Tools*{:.gui-txt} ­> *Port*{:.gui-txt} and select correct Port
1. Go to *File*{:.gui-txt} ­> *Examples*{:gui-txt} select *ArduinoISP*{:.gui-txt}
1. *Verify*{:.gui-btn} (check button) and *Upload*{:.gui-btn} (right point arrow button).

# Programming a comm panel.

1. Connect Arduino w/ programmer shield attached.
1. Open Arduino IDE
1. Go to *Tools*{:.gui-txt} ­> *Board*{:.gui-txt} and select *PanelG4*{:.gui-txt}
1. Go to *Tools*{:.gui-txt} ­> *Programmer*{:.gui-txt} and select *Arduino as ISP*{:.gui-txt} (not ArduinoISP!!!)
1. Connect panels programmer to Arduino shield via ribbon cable
1. Note, you do not need external power supply the Arduino will provide power
1. Connect panel to programmer
1. Go to *Tools*{:.gui-txt} ­> *Burn Bootloader*{:.gui-txt}
1. Open the `comm.ino` sketch (latest version is in `hardware_v0p2/comm/`)
1. Go to *Sketch*{:.gui-txt} ­> *Upload Using Programmer*{:.gui-txt} to upload sketch to panel.

# Programming a driver panel

* Open Arduino IDE
* Connect Arduino w/ programmer shield attached.
* Go to *Tools*{:.gui-txt} ­> *Board*{:.gui-txt} and select *PanelG4*{:.gui-txt}
* Go to *Tools*{:.gui-txt} ­> *Programmer*{:.gui-txt} and select *Arduino as ISP*{:.gui-txt} (not ArduinoISP!!!)
* Note, you do not need external power supply the Arduino will provide power
* Connect panel to programmer
* Connect programmer to shield via ribbon cable (note)
* Go to *Tools*{:.gui-txt} ­> *Burn Bootloader*{:.gui-txt}
* Open the `driver.ino` sketch (latest version is in `hardware_v0p2/driver/`)
* Select subdevice using dip switch. Up is selected ­ only one should be up at a time.
* Go to *Sketch*{:.gui-txt} ­> *Upload Using Programmer*{:.gui-txt} to upload sketch to panel.

**Note 1.* To fully program the driver you chip you need to all four atmega328's
which means programming the bootloader and firmware for all four dip switch "on"
positions.

**Note 2.** Always remove ribbon cable before removing and attaching new driver
subpanel as sometimes attaching a panel without doing so will corrupt the
ArduinoISP program on the Uno

{::comment}this was copied from the original file `G4 Panel programmer instructions.pdf`{:/comment}