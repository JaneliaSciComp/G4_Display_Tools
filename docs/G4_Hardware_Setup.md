---
title: Setup
parent: Generation 4
has_children: true
nav_order: 2
---

# What you need

- Windows desktop PC with a PCIe-7842R PCI card installed 
  - [Card available here](https://www.ni.com/en-us/support/model.pcie-7842.html)
  - [Recent driver](http://www.ni.com/en-us/support/downloads/drivers/download.ni-r-series-multifunction-rio.html)
- [G4 arena boards](../../Arena/index.md) (1 bottom board and 1 top board)
- [Interconnect board with ribbon cable](../../Arena/index.md) (Note: use shorter ribbon cable than pictures below)
- *N* LED panels, consisting of 2 sandwiched PCBs each. *N* can be between 1 and 48 for one arena
  - *N* [Communication PCBs](../../Hardware/README.md)
  - *N* [Driver PCBs](../../Panel/production-v1/README.md)
  - see [G4_Display_Tools/G4 Panel Programming](../G4 Panel Programming/G4_Panel-programmer_instructions.md) how to program
- VHDCI cable(s)
  - 1× SHC68-68-RDIO, 1× SHC68M-68F-RMIO
- NI Breakout board (optional)
- placeholder board (optional)
- Desktop power supply (5V 10A, for example [this one](https://www.adafruit.com/product/658))

![Overview of required hardware](./assets/G4_hardware-overview.jpg)

# Setting up:

![test](./assets/G4_panel.jpg){: .float-right}

- Combine driver and comm PCBs to LED panels with connectors on two edges
- Stack the LED panels into columns of the desired height and insert the columns into the G4 arena board (so that LED panel columns are sandwiched in between top and bottom boards).
  - Not all columns need to be populated, leave them empty to point cameras or other equipment into the arena.
  - if you want to leave columns empty, start populating the ones closest to the power connector first.
  - Not all rows in a column need to be populated. Bridge empty panel spots with a placeholder PCBs or by using wires to connect the pins between distant rows of panels (e.g. between row 1 and 3) as shown in the picture to the right
- Connect the arena to the interconnect board using the ribbon cable, and connect the interconnect board to the PCIe card (slot 1) using the [SHC68-68-RDIO](https://www.ni.com/en-us/shop/accessories/products/digital-cable.html?skuId=30215) cable
- (optional) connect a breakout box to the PCIe card (slot 0) with an [SHC68M-68F-RMIO](https://www.ni.com/en-us/support/model.shc68m-68f-rmio-cable.html) cable
- Connect the power supply to the G4 arena bottom board.
- With the G4 Host application, you should be able to send an "All On" signal

{::comment}this was copied from the original file G4_Getting_Started.docx{:/comment}