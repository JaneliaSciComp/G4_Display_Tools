---
title:  The Display Modes
parent: G4 Protocol Designer
grand_parent: Generation 4
nav_order: 1
---

In the [G4 Experiment Designer](G4_Designer_Manual.md), in order to determine how the stimuli in any particular condition is played on the screens, you will have to enter a trial mode. The key at the bottom left corner of the Experiment Designer gives a brief description of each mode, but see below to get a more in-depth understanding of each one. 

There are two main types of trial modes, closed-loop and open-loop. Closed-loop trials will feature real-time feedback to the arena screens based on how the fly is flying. Open-loop trials are used when you want to understand the fly’s response to the stimuli (the fly behavior won’t influence the stimuli on the screens). Modes 1 to 3 are open-loop and modes 4 to 7 are closed-loop. Additionally, some modes in the designer will require position functions, which can be made using the [Function Generator](../G4_Function_Generator/About Function Generator.md). The seven modes are described below:

1.	Mode 1 uses a position function you will provide. The position function is a simple line plot in which the x-axis represents time throughout the trial and the y-axis gives the frame number that will be displayed at that time. Each pattern is made up of a number of frames. Note that you can also set an optional parameter, Frame Index (frame indices range from 1 to 192), if you want the stimuli to start at a frame other than 1. For this mode, the designer will by default set the duration of the trial equal to the x limit of the position function, but you can change this if desired.  
2.	Mode 2 will play through the pattern in order from the first frame to the last at a constant rate (frames per second) which you will set in the designer. 
3.	Mode 3 will show a single frame from your pattern on the screen. The user will have to indicate which frame on the screens under Frame Index. Note that in this mode, there is no motion, it is a still image on the screen.
4.	Mode 4 will play a closed-loop trial that will set the frame based on the fly's behavior. You can set the way the pattern reacts through the gain for the trial. A positive gain will cause the pattern to move in the same direction as the fly. A negative gain will cause the pattern to move in the opposite direction of the fly. And the larger the magnitude of the gain, the faster the pattern will move. (Note: This mode is used for stripe-fixation.)
5.	Mode 5 plays a closed-loop trial where the pattern's movement is set by a position function that the user has chosen. You will also have the option to set frame index and gain. In this case, were the fly to not react at all, the trial would run like mode 1, the frame displayed being determined by the position function. But when the fly reacts, it behaves like mode 4. The pattern moves with or against the fly's motion depending on the gain. 
6.	Mode 6: Closed-loop rate function Y – not implemented
7.	Mode 7: In mode 7, an input signal, scaled by the gain, sets which frame of the pattern is being displayed at any given time. The input signal is adjusted based on the fly's behavior. 
