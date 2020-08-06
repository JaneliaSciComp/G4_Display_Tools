---
title: Verify G4 Setup
parent: Setup
grand_parent: Generation 4
nav_order: 4
---

After the hardware and software setup is complete, open MATLAB and run PControl_G4. Make sure that you “allow network access” to the g4host.exe. 

Two windows will open: a LabVIEW window followed by a MATLAB GUI. Once the PControl_G4 MATLAB GUI has opened, click on the “arena” tab and click “all on”. If all pixels turn on, then the system has been set up successfully and you can continue into the next section for an overview of the software tools to begin more advanced operation of the display system.

If the arena does not turn on, try these common troubleshooting steps:
- Check that the connection between the interconnect board and the VHDCI cable is good, as the VHDCI cables can sometimes need a very tight fit to make all the connections.
- If the G4 Host.exe reports **Error: Create Folder in FileIO […] HHMI – Generate File paths.vi…**, make sure that the following directories exist within `C:\Program Files (x86)\HHMI G4\Support Files`: `Analog Output Functions`, `Functions`, `Log Files`, and `Patterns`. Create empty directories if they don’t exist.
- If your system freezes when clicking on **Start Log** try to move the PCI card to a different PCI slot. On two recent machines (Dell Precision 5820) 2 out of 5 slots worked.
- If **Start Log** leads to an error in the status window, give **Full Access** rights to `C:\Program Files (x86)\HHMI G4\Support Files\Log Files` for the **USER** accounts.
- After running `PControl_G4`, check the LabVIEW window to see if the green light labelled **dequeue timeout** is lit. If it is, it may be that the transfer speeds between the PCIe card and the computer’s memory is too slow. If the computer is relatively new/fast, one possible cause of this problem has been noted with newer Dell workstations, which can be fixed by updating the BIOS. Regardless of the computer make/model, it may be worth updating the computer’s BIOS and seeing if that helps, which can be done by finding your PC’s manufacture support webpage and downloading the latest BIOS installer (e.g. for Dells: <https://www.dell.com/support/home/us/en/04>).
- Using a voltmeter, check that the arena board is being supplied with 5 V as expected.
- Some issues in the past have been caused by mistakes in the arena board assembly. The connectors between the arena board and the LED panels have sometimes been placed on the wrong side of the arena board or have had the gendered 15-pin connectors switched between the top and bottom arena boards. To see if this is the case, remove all of the LED panels from the arena board and plug one column back in, but inserted backwards (where the LEDs are facing to the outside of the arena). If an “all on” command turns on the LEDs in this case, then the connectors were placed incorrectly.

{::comment}this was copied from the original file G4_Getting_Started.docx{:/comment}