---
title: Experiment Creation
parent: Getting Started
nav_order: 3
---

# Setting up an experiment - an overview

At this point, your [hardware should be set up and working](../../../docs/gs_getting-hardware.md), and you should understand how to tether a fly inside the arena. If not, please see [Historic Background](../../../docs/gs_historic-background.md) and [Getting the hardware](../../../docs/gs_getting-hardware.md) pages under [Getting Started](../../../docs/getting-started.md).

So your hardware is set up and you're ready to run an experiment? You'll need the G4 Display Tools.

## What are the G4 Display Tools?

The [G4 Display tools](../../../docs/G4-index.md#Display-Tools) are a suite of software tools that make it easy to run fly behavioral experiments on the Generation 4 (G4) arena. These tools allow you to:

- Create patterns to display on the screens
- Generate functions to control the movement of patterns on the screens
- Organize these into experiments which can be saved for later use
- Run experiments on the screens with the click of a button
- Automatically save and process data
- Perform some types of data analysis automatically

For now, here's an overview of the steps you will take to set up an experiment utilizing these tools. Please see the page for each individual tool, located under [Generation 4](../../../docs/G4-index.md) for further details on its use and tutorials to take you through this step by step.

## Pattern and Function Generators

The first thing you need to do is [create any patterns](pattern-generator.md):
![pattern](assets/Pattern.png)

and/or [functions](About_Function_Generator.md):
![function](assets/function_sawtooth.png)

that will be necessary for the experiment. You don't want to create a pattern and add it to the experiment one at a time - create all your patterns and functions up front. You can do this using the [G4 Pattern Generator](pattern-generator.md) for patterns and [G4 Function Generator](About_Function_Generator.md) for functions.

A couple tips:

- Save all your patterns and functions together. This will make it easier to import them all to the [G4 Designer](G4_Designer_Manual.md) at once, rather than having to import them individually from different locations.
- We suggest naming the patterns and functions by their ID number. In using the Pattern and Function generators, you will give each pattern or function its own unique ID. That ID will need to be passed to the arena later to tell it which pattern or function to use. So naming your patterns `Pattern_0001` for an ID number of 1, for example, will help keep your files organized.
- See the [Pattern Generator](pattern-generator.md) and [Function Generator](About_Function_Generator.md) pages for in-depth instructions on how to use these tools.

## G4 Protocol Designer

Once your patterns and functions have been created, you want to open the [G4 Protocol Designer](G4_Designer_Manual.md). This software will allow you to import the patterns and functions you've created and organize them into trials. It will also allow you to set many other parameters, like the size of your screen, whether you want trials randomized, how many times the protocol should be repeated, and more.

Once you have organized your trials the way you want them, the G4 Designer will also let you save the protocol. This will save a file with extension .g4p (G4 protocol) in your save location. It will also create folders which hold copies of all the patterns and functions used in the protocol. I will refer to the folder in which you have saved this protocol as the *experiment folder*. The experiment folder will contain everything needed to run the experiment. If you open the [G4 Designer](G4_Designer_Manual.md) or [Conductor](G4_Conductor_Manual.md) and want to open an existing protocol, you will go to *File*{:.gui-btn} → *Open*{:.gui-btn} and browse to the .g4p file. Opening the .g4p file will import everything that is needed from the folder. However, you should not move your .g4p out of the experiment folder. Leave the folder organized as is.

For detailed instructions on how to do this, please see the [G4 Protocol Designer User Manual](G4_Designer_Manual.md), the [Protocol Designer Settings tutorial](tut_prot_configure-settings.md), and the [Design a Condition Tutorial](tut_prot_create-condition.md).

At this point, your experiment is set up! All that remains is to tether your fly, open the protocol in the [G4 Conductor](G4_Conductor_Manual.md), and run it!
