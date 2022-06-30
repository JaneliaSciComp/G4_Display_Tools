---
title:  The Display Modes
parent: G4 Protocol Designer
grand_parent: Generation 4
permalink: /G4/Display-Modes
nav_order: 1
---

# The Display Modes

In the [G4 Experiment Designer](protocol-designer.md), in order to determine how the stimuli in any particular condition is played on the screens, you will have to enter a trial mode. The key at the bottom left corner of the Experiment Designer gives a brief description of each mode, but see below for a more in-depth understanding of each one.

There are two main types of trial modes: closed-loop and open-loop. Closed-loop trials feature real-time feedback to the display based on signals acquired from the analog input, which is often used to update the display based on behavior from the animal. Open-loop trials display patterns in a more consistent way and are not modified by any external feedback (the animal's behavior won’t influence the stimuli on the screens). Modes 1 to 3 are open-loop and modes 4 to 7 are closed-loop. Additionally, some modes in the designer will require position functions, which can be made using the [Function Generator](function-generator.md). The seven trial modes are described below:

## Display Mode 1 {#mode-1}

__Mode 1__ uses a __position function__ to be provided by the user. The position function is a simple vector of frame indices that determines which frame number of a pattern will be displayed at each refresh cycle of the display. When used with 1-bit patterns which are refreshed at a rate of 1 kHz, each frame number in the position function will be held for 1 ms. For 4-bit patterns the panels refresh at 500 Hz and each frame is held for 2 ms.

For this mode 1, the designer will by default set the duration of the trial equal to the duration defined by the position function, but this can be changed if required. If the duration is decreased, the display will be stopped before the position function has finished, and if the duration is increased, the position function will restart after it has finished.

## Display Mode 2 {#mode-2}

__Mode 2__ will play through the pattern in order from the first frame to the last at a __constant frame rate__ (frames per second) which you will set in the designer. After reaching the final frame of the pattern, it will begin again at the first frame.

## Display Mode 3 {#mode-3}

__Mode 3__ will show a single __static frame__ from your pattern on the screen. The user will have to indicate which frame to display on the screen by setting the Frame Index. Note that in this mode, there is no motion, only a still image on the screen.

## Display Mode 4 {#mode-4}

__Mode 4__ will play a __closed-loop trial at a frame rate__ based on signals acquired from the analog input channel `ADC0`. Positive voltages set a positive frame rate for the pattern to be played through, resulting in a similar function as [Mode 2](#mode-2), while negative voltages result in patterns played in reverse through the negative frame rate.

How the voltage scales to the frame rate can be modified using the gain, which works as a multiplier of the relationship between voltage and frame rate; larger values for gain cause the pattern to be played through faster at the same voltage value, and negative gain values reverse the direction that frames are played through. Additionally, the neutral value of the input signal, which is the voltage that results in a frame rate of 0, can be changed by the _Offset_{:.gui-txt}. Thus, the relationship between voltage and frame rate is defined by the following equation: `Frame Rate = Gain * (Voltage + Offset)`.

## Display Mode 5 {#mode-5}

__Mode 5__ combines closed-loop input on top of the pattern's movement set by a position function. Therefore, in addition to setting a position function to apply to the pattern, the gain and offset can also be set to determine how the analog input can modify the pattern from the baseline set by the position function.

## Display Mode 6 {#mode-6}

__Mode 6__: Closed-loop rate function Y – not implemented

## Display Mode 7 {#mode-7}

__Mode 7__: In this mode, an input signal, scaled by the Gain, sets which frame of the pattern is being displayed at any given time. In other words, where other closed-loop modes (4-6) use the analog input channel to define the `Frame Rate` that the pattern's frames are cycled through, mode 7 uses the analog input to set the `Frame Index`.
