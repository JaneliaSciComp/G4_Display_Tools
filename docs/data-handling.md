---
title:  G4 Automated Data Handling
parent: Generation 4
nav_order: 14
has_children: true
has_toc: false
---

# Prerequisites

Please make sure you have gone through the [G4 Experiment Designer](protocol-designer.md) documentation and are comfortable designing an experiment. Whether you have covered the [G4 Experiment Conductor](experiment-conductor.md) is optional.

# Overview

Automated data handling is optional. When using the Conductor to run an experiment, if you do not want anything automatically done to your data, simply uncheck the _Processing_{:.gui-btn} and _Plotting_{:.gui-btn} checkboxes. However, we do recommend that you at least use the data processing tool, as it will convert your data from a single string of data into datasets which have been separated by condition, making it easy to see what data belongs to what trial. You should note that a small pre-processing function will run automatically even if both of these boxes are unchecked, and that is a function that converts the .TDMS file created by the arena into a matlab struct so the data can at least be accessed in matlab.

Data handling is split into two parts: data processing and data analysis. Each has its own collection of settings that need to be adjusted and saved before they can be run. Processing and single-fly analysis is done in exactly the same way for all flies run through a particular protocol. As such, the settings for each can be saved as a .mat file in the Experiment folder. Once they have been saved, the software will use those settings every time that experiment is run. Note that you can have the settings saved in your experiment folder but choose to not use them for any given run of the protocol -- simply uncheck the _Processing_{:.gui-btn} and _Plotting_{:.gui-btn} boxes in the [Conductor](experiment-conductor.md). Ideally, the user will set up and save the settings for their data processing and analysis when the user designs their experiment. We recommend going through these data handling steps directly after creating an experiment in the Designer. However, data processing and analysis can be done anytime, even after the experiment is finished running.

You must run data processing first, and data processing is required before data analysis can be run.

Please see the following for detailed instructions.

1. [G4 Data Processing](data-handling_processing.md)
2. [G4 Data Analysis](data-handling_analysis.md)
