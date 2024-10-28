---
title:  G4 Data Processing Step by Step
parent: G4 Automated Data Handling
grand_parent: Generation 4
nav_order: 1
---

# Overview

After each experiment on the arena, the data that was collected will be processed according to the settings you created (see [processing setup](data-handling_processing.md)). What follows is a step by step description of what the processing does - how it splits up the raw data, aligns data and checks the quality, breaks it up into datasets, and all assumptions that are made along the way. If you see anomalies in your data and need to confirm the data processing is doing what you expect it to, this is the place to look. 

If you'd like to follow along in the code, open the file `G4_Display_Tools\G4_Data_Analysis\new_data_processing\process_data.m`. 

# Data Processing Step by Step

