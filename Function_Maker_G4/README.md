# Function_Maker_G4

A MATLAB tool for visualizing and creating both position functions and analog output functions for use with the 4th generation Reiser LED panel arena. Position functions specify which pattern frame is displayed at every refresh of the LED arena, and analog output functions control the voltage set at an analog output of the G4 controller at a rate of 1 kHz. Functions are created in multiple sections (the GUI supports up to 5 sections but the script version is unlimited) where each section specifies the parameters of a portion of the function (section 1: 5 Hz sine wave for 1 second; section 2: 1 Hz square wave for 5 seconds, etc.)

Requires PControl matlab scripts downloaded as well in order to save functions in the correct format to be read by the panel controller.