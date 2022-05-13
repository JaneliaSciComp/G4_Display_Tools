---
title: Software
parent: Assembly
grand_parent: Generation 4
nav_order: 2
---

# G4 Software Setup

The software required to run Generation 4 of the Modular LED Display three main parts. The first component is the G4 Host application that directly communicates with the NI IO card. Secondly, a MATLAB programming environment is requried to run user interfaces and software developed for the G4 displays. And finally, these user interfaces and software tools need to be installed.

## Download and install G4 Host {#download-main-host}

We provide the G4 *Main Host*{:.gui-txt} application as a compiled binary and free of cost, although we are not at liberty to share the LABVIEW sources. Please [get in contact]({{site.baseurl}}/Contact) if you notice an error or if you have special requrirements. The current version requires a two-step process to install: version v1.0.0.230 that is packaged with an installer and an additional patch that upgrades the software to version v1.0.0.235.

The G4 Main Host v1.0.0.230 that is packaged with the installer pulls in required libaries such as the NI R RIO Driver v16.0, NI-Serial v15.0, NI-VISA v16.0, NI System Configuration v16.0 and NI-488.2 v14.0. If you want to use more recent versions that include NI bug fixes and performance improvements, the we suggest installing these NI packages prior to running the G4 Main Host installer since it is more difficult to update afterwards. For us, the link for the [RIO driver](https://www.ni.com/en-us/support/downloads/drivers/download.ni-r-series-multifunction-rio.html)[^1] was difficult to find, but the other software packages are readily available via the search function on the NI homepage <https://ni.com>.

The compiled G4 *Main Host*{:.gui-txt} application in version v1.0.0.230 is available for [download](https://github.com/floesche/LED-Display_G4_Display-Tools/releases/tag/host-v230) ([mirror](https://www.dropbox.com/s/mywy2a3gb6vxhec/HHMI%20G4%20Host%28Ver1-0-0-230%29%20with%20installer.zip?dl=0)). The compressed archive contains an installer that also includes a LabVIEW runtime environment. Once you have installed the application and even if you had previously installed the NI packages separately, we recommend pulling the latest updates through the NI update manager that was installed in the process. You can verify the installation by checking if the G4 *Main Host*{:.gui-txt} software exists in a folder at `C:\Program Fiels(x86)\HHMI G4`.

In a second step you will need to patch the G4 *Main Host*{:.gui-txt} application to the most recent version. In the lab we have been using [v1.0.0.235](https://github.com/floesche/LED-Display_G4_Display-Tools/releases/tag/host-v235) ([mirror](https://www.dropbox.com/s/cuhs907arnx4kfq/G4%20Host(Ver1-0-0-235).zip)) for some time, but we are [currently publishing updates](https://github.com/floesche/LED-Display_G4_Display-Tools/releases) that fix bugs but are less tested. Download the archive of your choosing and unzip the file to a temporary directory. Then replace the G4 *Main Host*{:.gui-txt} files in `C:\Program Files(x86)\HHMI G4` with your recently downloaded version.

## Download and install MATLAB {#download-matlab}

Download and install the [latest version of MATLAB](https://www.mathworks.com/products/matlab.html). Required toolboxes are [instrument control](https://www.mathworks.com/help/instrument/index.html) and [statistics and machine learning](https://www.mathworks.com/help/stats/index.html). A recommended toolbox is [parallel computing](https://www.mathworks.com/help/parallel-computing/index.html). You will need a license to run MATLAB and many research institutions have campus licenses available.

## Download Display Tools {#download-display-tools}

![On the GitHub repository website, click on "Code" and either use the HTTPS or SSH URL in your git client or choose to "Download ZIP" file](assets/p-d_c-s_t_download-or-clone.png){:standalone .ifr data-img-class="pop"}

To download the G4 Display Tools, navigate to the [G4_Display_Tools GitHub Repository](https://github.com/JaneliaSciComp/G4_Display_Tools). There are two different ways to download the Display Tools: either through git or by downloading a recent archive in your web browser. Download the sofware to a directory of your choice (e.g. `%HOMEPATH%\srcs\G4_Display_Tools`) using either method. If you know about git and know how to download the files you can skip to the next heading.

__Small detour__: using git allows easy updates of the Display Tools in the future but requires additional software on your computer, namely a git client. Instead, using the _download ZIP_ option gives quick access to the most recent version of the G4 Display Tools, but updates are a bit more difficult and potentially dangerous.
{:.info}

[Git](https://git-scm.com/) is a software to control different versions of files within a single directory. Git and other so called version control systems are efficient in recognizing even small changes in a path that contains many (hundreds, thousands, …) files. Organized in these so-called repositories, git makes it easy to keep track of the different combinations of changes over time. We share our G4 Display Tools git repository on the website GitHub. This means whenever we fix bugs and update the software, you can just _pull_ the latest release with a simple command (or button click). 

If you don't want to [read more about git](https://git-scm.com/book) now, [GitHub Desktop](https://desktop.github.com/) is an easily accessible GUI to get started: Just download and install the [GitHub Desktop](https://desktop.github.com/). Once started, go to *File*{:.gui-btn} → *Clone Repository*{:.gui-btn}, and click on the *URL*{:.gui-txt}. There you can paste the G4 Display Tools HTTPS URL <https://github.com/JaneliaSciComp/G4_Display_Tools.git> and configure your local path where you want to store the software (e.g. `C:\Users\YOURNAME\srcs\` - this will download a copy to `%HOMEPATH%\srcs\G4_Display_Tools`). If you want to update the software at a later point, you can do this by clicking *Repository*{:.gui-btn} → *Pull*{:.gui-btn}.

Instead, if you download the ZIP file from the GitHub repository website, this is a one-time solution. If you want to update the software at a later point, you will need to delete the existing directory and replace it with a [freshly downloaded version from GitHub](https://github.com/JaneliaSciComp/G4_Display_Tools). There is a danger that this might delete some of your own files, a problem unlikely to happen when using git instead.

## Set up Display Tools in MATLAB {#add-to-path}

For full functionality, you must add the folder with your downloaded G4 Display Tools to the MATLAB path.

On the MATLAB home tab, click *set path*{:.gui-btn}, then *add with subfolders*{:.gui-btn}. Next, browse to the location where you downloaded G4_Display_Tools, save and close the *Set Path*{:.gui-txt} window.

Alternatively, in the *Current Folder*{:.gui-txt} pane in MATLAB, browse to the location where you saved G4_Display_Tools, right click this folder, and select *Add to Path: Selected folders and subfolders*{:.gui-btn}.

## Verify that old software is not interfering {#verify-old}

If you have previously used a version of Modular LED Displays, please ensure that `C:\matlabroot\PControl_G4_V01\TDMSReaderv2p5` is NOT on your MATLAB path. This folder contains files from previous versions of this software that may conflict with the current files. You can check this via the MATLAB command `contains(path, "TDMSReaderv2p5")` – a return value of `1` means the folder needs to be removed from your path.

## Configure the arena size for the display controller {#configure-controller}

Open the Display controller configuration file in located in `C:\Program Files (x86)\HHMI G4\Support Files\HHMI Panels Configuration.ini` in a text editor such as notepad. Make sure that the `number of rows` field has the correct number of rows based on the size of LED arena you have built (e.g. for an arena that has 12 LED panel columns with each column 4 panels tall, the number of rows is 4.) The `number of columns` field should be the number of columns that the arena can support – not how many columns have been populated with LED panels – which is 12 for standard LED arenas.

## Configure the arena size for the PControl software {#configure-pcontrol}

In MATLAB, open `G4_Display_Tools\PControl_Matlab\userSettings.m` and set the `NumofRows` and `NumofColumns` fields to the same values set for the display controller. If the arena will be mounted upside-down (i.e. if the arena will be mounted with the bottom board on the top and vice versa), set `flipUpDown = 1` and `flipLeftRight = 1`. Otherwise if the arena will be mounted right-side up, set both to `0`.

## Configure the arena size for the Pattern Generator software {#configure-pattern-generator}

In MATLAB, run `configure_arena` (located in `G4_Display_Tools\G4_Pattern_Generator\support\configure_arena.m`). Make sure the # of rows/columns of panels is correct. If you are using G4 panels consisting of 16x16 LEDs, set the panel size to be 16. If you are using a G4 arena consisting of 12 LED columns that would fully enclose the cylindrical arena (e.g. the 12" arena), set the arena circumference to 12. If you are using a differently-sized arena, such as the open-form 12/18 cylindrical arena (where 18 panel columns would be needed to fully enclose the cylinder), set the circumference to 18. If the center of the arena (located between columns 6 and 7) is not oriented directly "forward" from the center of the cylinder, use the `arena rotations` to account for that, otherwise some motion types will not be oriented correctly.

## Verify software is working {#verify}

After the hardware and software setup is complete, try to start the application `Panel_Host` that you previous installed in `C:\Program Files(x86)\HHMI G4`. Instead of running the `g4host.exe` directly, calling the command `PControl_G4` in MATLAB should open two two windows: the *Panel_Host*{:.gui-txt} LabVIEW window and a MATLAB GUI.

Switch to the *Panel_Host*{:.gui-txt} window and try to send an *all on*{:.gui-btn} command through the interface. If this is the first time you send a command, the Windows firewall might ask you to *allow network access to the `g4host.exe`*{:.gui-txt}. To use the G4 system, you will need to grant that right. If the arena is connected and powered on, all panels should light up -- if not, have a look at the [troubleshooting guide]({{site.baseurl}}/docs/g4_troubleshooting.html) or [get in contact]({{site.baseurl}}/Contact). Turn them back off by sending the *all off*{:.gui-btn} command through the GUI.

The second test will verify that the connection between MATLAB and the *Panel_Host*{:.gui-txt} software is working. Switch back to the MATLAB PControl_G4 GUI and click on the *arena*{:.gui-txt} tab and then *all on*{:.gui-btn}. If all LEDs on the arena turn on, then the system has been set up successfully -- and you can turn it off the same way as before. Otherwise and most likely you will need to [trouble shoot your system]({{site.baseurl}}/docs/g4_troubleshooting.html) or [get in contact]({{site.baseurl}}/Contact).

---

[^1]: In November 2021, the NI R RIO Driver and most other software packages are available in version 21.3 (previously in July 2020: v20.0).
