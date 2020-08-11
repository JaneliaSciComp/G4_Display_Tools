---
title: Display Tools
parent: Generation 4
nav_order: 2
has_children: true
---

# Overview of G4 Display Tools

This document briefly describes the various software tools developed for this system. They require the [Hardware](docs/G4_Hardware_Setup.md) and [Software](docs/G4_Software_Setup.md) to be [working correctly](docs/G4_Verify.md). 

These tools can be used to generate visual stimuli, run experiments, and analyze the acquired results. Some of the software tools described later in this document do not require a physical LED arena set up and attached to the computer in order to be used; for example, the Motion Maker scripts can be used to generate and visualize patterns without any G4 hardware attached, and the Data Analysis scripts only require the TDMS log files generated during an experiment in order to analyze and plot data. Other tools, such as PControl and the Protocol Designer scripts, will only be fully functional when connected to a G4 Display system.

# Motion_Maker_G4

This set of scripts and GUIs can be used to design patterns (primarily for displaying motion, rather than pictures of objects) on the G4 display. Patterns are generated using the Motion_Maker_G4.m script based on input parameters that describe the desired motion. These scripts output two types of pattern files: The first type is a .mat file which contains the created pattern matrix and all the pattern parameters so that it can be easily read back into MATLAB. The second type is a .pat file containing a binary vector of the pattern that can be quickly accessed by the Display Controller. Only the .pat file is necessary to be displayed on a G4 arena, though the .mat file is needed to be easily loaded back into MATLAB for viewing, debugging, or for creating experiments with the G4_Protocol_Designer (described later). See G4_Display_Tools\Motion_Maker_G4\About Motion Maker.docx for more details.

# Function_Maker_G4

This set of scripts and GUIs allow for the design and creation of analog output functions and position functions, to be used in conjunction with displaying patterns on a G4 display. Position functions control what frame of the selected pattern is displayed for every refresh cycle (when the display system is operating in position function mode), operating at a rate of either 500 or 1000 Hz (1-bit or 4-bit patterns, respectively). Analog output functions control the voltage of the analog output channels of the G4 system (accessed easily with the optional breakout box) in a way that is synchronized to the display refresh cycle, operating at 1000 Hz regardless of the pattern refresh rate. Similar to Motion_Maker_G4, functions are created using the Function_Maker_G4.m script based on input parameters that describe the desired function. These scripts output two types of files: The first type is a .mat file which contains the created function array and all the function parameters so that it can be easily read back into MATLAB. The second type is either a .afn (for analog output functions) or .pfn (for position functions) file containing a binary vector of the function that can be quickly accessed by the Display Controller.

# PControl_G4

Developed by Jinyang Liu, PControl_G4 allows for communication between the G4 display system and MATLAB by establishing a TCP connection between the two. A communication channel can be opened using the connectHost function, and messages can be translated and sent to the display using Panel_com. Commands for displaying patterns and using functions in various modes can be sent, provided that an ‘experiment folder’ has been created and specified. Experiment folders can be made by manually selecting pre-made pattern and function files using the design_exp GUI. Running `PControl_G4` automatically connects to the G4 display and opens a window where an experiment folder can be specified and various commands can be sent, including commands for displaying the patterns included in the experiment folder. Finally, examples of custom-written patterns and functions are also included in this set of scripts.

# G4_Protocol_Designer

Developed by Lisa Taylor, these scripts and GUIs allow for designing, visualizing, and running experimental protocols using patterns and functions that have already been created. An experimental structure can be created and visualized using the G4_Experiment_Designer GUI, where pre-made pattern and function files can be selected and organized. Experimental protocols can be validated within the GUI and saved as .g4p files. The G4_Experiment_Conductor GUI can run experimental protocols and display information on the current experiment progress in real-time. See G4_Display_Tools\G4_Protocol_Designer\User Instructions.docx for more details on how to use these scripts.

# G4_Example_Experiment_Scripts

These scripts – using many of the functions described in the previous tools – demonstrate an entirely script-based solution for creating patterns, functions, and experiment folders, as well as creating and running experiments with the G4 system.

# G4_Data_Analysis

These scripts can be used to read data logged and acquired by the G4 display system into MATLAB. Each experiment (marked by `start log` and `stop log` commands) outputs a folder of log files in .TDMS format, which can be read and converted into a MATLAB struct using the `G4_TDMS_folder2struct` function. These log files contain data and timestamps corresponding to the frames displayed during that experiment as well as the commands received over TCP. Any active analog output and analog input channels are also logged by both voltage and corresponding timestamp. Additional scripts are included for further processing, analyzing, and plotting data from two example categories of experiments – a tethered fly walking on an air-suspended ball, and a tethered flying fly monitored with a wingbeat analyzer. An example of a full data analysis pipeline is shown in the `test_G4_Data_Analysis.m` script.