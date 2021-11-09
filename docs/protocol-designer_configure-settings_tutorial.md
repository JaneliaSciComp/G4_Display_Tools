---
title:  Tutorial - Configure Settings
parent: G4 Protocol Designer
grand_parent: Generation 4
nav_order: 2
---

# Prerequisites

[Generation 4 Setup](software_setup.md)
You must have cloned the G4 Display Tools repository as described in the [Designer Manual](protocol-designer.md)

# Getting Started

Many features of the [G4 Designer](protocol-designer.md) and [Conductor](experiment-conductor.md) require that certain settings be configured correctly. Even though some features will work without them, your experience with the [G4 Display Tools](data-handling_getting-started.md) will be smoother if you configure your settings first. You will rarely need to change them after setting them up once. Follow this tutorial to ensure your settings are correct before proceeding to use the Designer or Conductor.

# Configuration file

Before you can even open the G4 Designer, you must update one thing - the path to your G4 Configuration file.

Open the file `G4_Display_Tools/G4_Protocol_Designer/G4_Protocol_Designer_Settings.m` in MATLAB. The first line of this file should read "Configuration File Path: /Users/taylorl/Desktop/HHMI Panels Configuration.ini" or something similar. This path must be accurate to open the Designer. If it is not, replace the current path with the correct path to your HHMI Panels Configuration.ini file.

Note: There should be exactly one space between the ':' and the first character of your path. Additionally there should be no trailing spaces at the end of your path. Please ensure these two things are true before saving and closing the file.

This is the only change you should make to this file. Please save and close the file when you are done.

# Open the G4 Designer

Make sure that G4_Display_Tools and all its subfolders and files are on your MATLAB path. Then type 'G4_Experiment_Designer' into your MATLAB command window and hit 'Enter.' Alternatively, you could browse to the file `G4_Display_Tools/G4_Protocol_Designer/G4_Experiment_Designer.m`, open it in MATLAB, and hit *Run*{:.gui-btn}.

A window like the one below will open. If it does not, or if you get a MATLAB error, see the [G4 Designer Manual](protocol-designer.md) for more help on errors and debugging.

![Empty Protocol Designer Window](assets/protocol-designer_empty.png){:.pop}

Click *File*{:.gui-txt} → *Settings*{:.gui-txt} in the upper left hand corner of the window. A second window should pop up that looks like this:

![Protocol Designer Settings](assets/protocol-designer_settings.png){:.pop}

# The settings

Let's go through each field in the settings window and what it means.

- *Configuration file location*{:.gui-txt}. This field should contain the correct path to your configuration file, which you just updated. The rest of the fields may or may not be correct, depending on how your system is set up, so let's go through them.

- *Default Run Protocol*{:.gui-txt}. A "run protocol" refers to an .m file which defines the structure of how an experiment is run on the screens. Refer to the [Run Protocol Tutorial](experiment-conductor_run-protocol.md) for more details. While we provide several examples, the default at `G4_Display_Tools/G4_Protocol_Designer/run_protocols/G4_default_run_protocol.m` should be sufficient for most use cases.

- *Default Plotting Protocol*{:.gui-txt}. This field only matters if you will be using the G4 data analysis tools to run automatic data analysis when an experiment is over. If you're unsure what this is, please see [G4 Data Analysis](data-handling_analysis.md) for more details. If you have create a data analysis settings file, which determines how your automatic data analysis will be run, put the path to that settings file here. This may change from experiment to experiment, feel free to update it when you need to. However, this only controls the default settings file - you will always have the chance when you run an experiment to select a different settings file for your data analysis, so you do not ever need to change it here if you don't want to.
  
- *Default Processing Protocol*{:.gui-txt}. Like the plotting protocol, this field only matters if you will be using the G4 data processing tools to automatically process your data into datasets after an experiment. If you're unsure what this is, please see [G4 Data Analysis](data-handling_analysis.md) for more details. If you have created a settings file for your data processing which you want to run at the end of each experiment, put the path to that settings file here. Like the previous field, this only defines the default. You can still choose a different settings file at the time that you run an experiment.

- *Default Flight Test Protocol*{:.gui-txt}. This refers to an experiment protocol (a .g4p file) which would be used as a test run for your flight experiments. It's common that before you run a full experiment, you might want to run a quick test with just a few patterns to make sure your fly is responding as you expect and everything looks normal. We have provided a simple test protocol like this, located in `G4_Display_Tools/G4_Protocol_Designer/test_protocols/test_protocol1/test_protocol1.g4p`. This test protocol folder has all the patterns and files you would need to run this protocol, but it was designed with our lab's experiments in mind. You may find it more useful to design your own short protocol and designate it as your test for flight experiments. If that's the case, the path to the .g4p file you create should go here.

- *Default Camera Walk Test Protocol*{:.gui-txt}. This is exactly the same as the previous field, but should instead be the path to a .g4p file which is designed to be the test protocol for camera walking experiments on a ball, instead of flight experiments.

- *Default Chip Walk Test Protocol*{:.gui-txt}. This is the same as the previous two fields, but should contain a test protocol for chip walking experiments instead of flight.

- *Default Run Protocol for Test*{:.gui-txt}. If you have a test protocol in any one of the previous three fields, you'll need to designate a run protocol to run it. This run protocol serves exactly the same purpose as the *Default Run Protocol*{:.gui-txt} several fields ago, but applies to your test protocol instead of your actual experiment protocol. It is very likely that this will be the same as your experiment's default run protocol. This should be a path to an .m file. We provide a default for you at `G4_Display_Tools/G4_Protocol_Designer/run_protocols/G4_default_run_protocol.m`.
  
- *Default Processing file for Test*{:.gui-txt}. This field is exactly the same as the *Default Processing Protocol*{:.gui-txt} but for your test protocols instead of your main experiment. If you want any test protocol you run to have its data processed and/or plotted automatically, you'll have to create data processing and analysis settings files. This could likely be the same processing file that you use for your experiment above.

- *Default Plotting file for Test*{:.gui-txt}. This is the same as the previous default plotting file, but for your test protocol instead of your main experiment. It may likely be the same as your experiment's default plotting file.

- *Color of disabled cells:*{:.gui-txt}. This takes a color in the form of a hexadecimal code. It defaults to #bdbdbd which is a grey color. You can change this if you'd like to change the background color of table cells in the G4 Designer when they are disabled. For example, in certain modes, a condition does not take a position function. If this is the case, the table cell for position functions will become gray and be filled with some text determined in the next field. You can change the fill color here if you like.

- *Text inside disabled cells*{:.gui-txt}. The text that will fill disabled table cells in the G4 Designer. By default, they will turn gray and be filled with dashes, *--------*{:.gui-txt}. You can change this to any string if you prefer, such as *disabled*{:.gui-txt} or *////////*{:.gui-txt}.

The bottom section contains a panel called Metadata Google Sheets Properties. We will not cover these fields in this tutorial. Please see our [Setting up your Google Sheets tutorial](protocol-designer_metadata_tutorial.md) for an explanation regarding these settings.

# What if I don't have some of these?

That's okay! The only settings which are required are the *Configuration file location*{:.gui-txt}, the *Default run protocol*{:.gui-txt}, and the color and text inside disabled cells. For any Google Sheets settings that are required, have a look at the [Google Sheets tutorial](protocol-designer_metadata_tutorial.md). The rest can be left blank or at their default values, even if those paths don't exist on your computer.

Note: When you click *Apply Changes*{:.gui-btn} the software will check each value for validity. If a field is empty or contains a path that doesn't exist, you will get a pop up warning you about it. That's okay, if you don't care about that field, just click *OK*{:.gui-btn} through the warning boxes. The settings will still be saved. The warnings are for your information only.

Once your settings are how you want them, just click *Apply Changes*{:.gui-btn} and you are done!
