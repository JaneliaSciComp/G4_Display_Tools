---
title: Software
parent: Assembly
grand_parent: Generation 4
nav_order: 2
---

# G4 Software Setup

Download and install the latest version of MATLAB. Required toolboxes are [instrument control](https://www.mathworks.com/help/instrument/index.html) and [statistics and machine learning](https://www.mathworks.com/help/stats/index.html). A recommended toolbox is [parallel computing](https://www.mathworks.com/help/parallel-computing/index.html).

Download and install the G4 Host LabVIEW executable. In addition to the HHMI G4 Files, this installs NI R RIO Driver 16.0, NI-Serial 15.0, NI-VISA 16.0, NI System Configuration 16.0 and NI-488.2 14.0. If you want to use more recent drivers and software it is recommended to install these drivers first. The link for the [RIO driver](https://www.ni.com/en-us/support/downloads/drivers/download.ni-r-series-multifunction-rio.html) is difficult to find[^1]. The other software packages are easy to find on <https://ni.com>. Once you installed the old version that comes with the G4 Host application, it's difficult to upgrade.

The G4 Host LabVIEW installer is available for [download](https://www.dropbox.com/s/mywy2a3gb6vxhec/HHMI%20G4%20Host%28Ver1-0-0-230%29%20with%20installer.zip?dl=0). After this installation, make sure to check for updates from the NI update manager. After the installation, you can upgrade to version 1.0.0.235 via this [patch](https://www.dropbox.com/s/cuhs907arnx4kfq/G4%20Host(Ver1-0-0-235).zip) by replacing the files in `C:\Program Files(x86)\HHMI G4`.

Download (or clone) the [G4_Display_Tools GitHub repository](https://github.com/JaneliaSciComp/G4_Display_Tools).

## Add paths for G4_Display_Tools in MATLAB
{:#add-to-path}

For full functionality, you must add this folder to the MATLAB path with all its subfolders and files.

On the MATLAB home tab, click *set path*{:.gui-btn}, then *add with subfolders*{:.gui-btn}. Next, browse to the location where you saved G4_Display_Tools, save and close the *Set Path*{:.gui-txt} window.

Alternatively, in the Current Folder pane in MATLAB, browse to the location where you saved G4_Display_Tools, right click this folder, and select *Add to Path: Selected folders and subfolders*{:.gui-btn}. 

## Verify that old software is not interfering
{:#verify-old}

Lastly, please ensure that `C:\matlabroot\PControl_G4_V01\TDMSReaderv2p5` is NOT on your MATLAB path. This folder contains files from previous versions of this software that may conflict with the current files. You can check this via the MATLAB command `contains(path, "TDMSReaderv2p5")` – a return value of `1` means the folder needs to be removed from your path.

## Configure the arena size for the display controller
{:#configure-controller}

Open the Display controller configuration file in located in `C:\Program Files (x86)\HHMI G4\Support Files\HHMI Panels Configuration.ini` in a text editor such as notepad. Make sure that the `number of rows` field has the correct number of rows based on the size of LED arena you have built (e.g. for an arena that has 12 LED panel columns with each column 4 panels tall, the number of rows is 4.) The `number of columns` field should be the number of columns that the arena can support – not how many columns have been populated with LED panels – which is 12 for standard LED arenas.

##Configure the arena size for the PControl software.
{:#configure-pcontrol}

In MATLAB, open `G4_Display_Tools\PControl_Matlab\userSettings.m` and set the `NumofRows` and `NumofColumns` fields to the same values set for the display controller. If the arena will be mounted upside-down (i.e. if the arena will be mounted with the bottom board on the top and vice versa), set `flipUpDown = 1` and `flipLeftRight = 1`. Otherwise if the arena will be mounted right-side up, set both to `0`.

## Configure the arena size for the Pattern Generator software.
{:#configure-pattern-generator}

In MATLAB, run `configure_arena` (located in `G4_Display_Tools\G4_Pattern_Generator\support\configure_arena.m`). Make sure the # of rows/columns of panels is correct. If you are using G4 panels consisting of 16x16 LEDs, set the panel size to be 16. If you are using a G4 arena consisting of 12 LED columns that would fully enclose the cylindrical arena (e.g. the 12" arena), set the arena circumference to 12. If you are using a differently-sized arena, such as the open-form 12/18 cylindrical arena (where 18 panel columns would be needed to fully enclose the cylinder), set the circumference to 18. If the center of the arena (located between columns 6 and 7) is not oriented directly "forward" from the center of the cylinder, use the `arena rotations` to account for that, otherwise some motion types will not be oriented correctly.

[^1]: In July 2020, the NI R RIO Driver and most other software packages are available in version 20.0.