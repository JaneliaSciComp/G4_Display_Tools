---
title:  G4 Experiment Conductor
parent: Generation 4
nav_order: 13
has_children: true
has_toc: false
---

1. TOC
{:toc}

# Overview

The G4 Conductor is the application you will use to run an experimental protocol on the LED screen arena.

To open this application directly from the [G4 Designer](protocol-designer.md), click the *Run Trials*{:.gui-btn} on the left side of the Designer window. The experimental protocol that was open in the Designer will automatically be opened in the Conductor, assuming you have saved the experimental protocol.

If the Designer is not open, there is no need to open it. You can open the file `G4_Display_Tools\G4_Protocol_Designer\G4_Experiment_Conductor.m` in MATLAB and hit *Run*{:.gui-btn} to open the Conductor directly.

The window that opens should look something like this:

![Experiment Conductor](assets/conductor-empty.png)

The top left section contains settings for your experiment. The Metadata section at the top-middle is where you can fill in some basic experiment metadata. The center displays a progress bar, or will once an experiment begins running. Once you begin running an experiment, data relating to the current trial will display along the bottom. The right side panel, titled Data Monitoring, will display some basic data as it is collected, assuming your protocol has streaming enabled, meaning the sample rates for the analog input channels are not set to 0 (this can be checked in the Designer).

__Note__: You must have set up a metadata Google Sheets and connected it to the G4 software through the G4 Designer Settings. If you have not done this, the Conductor will not open properly.
{:.warning}

__Note__: The Conductor opens and utilizes the configuration .ini file. If your account does not have permission to access this file, you may get errors. Please make sure your account has permission to open and edit the .ini file before using the Designer and Conductor. (If you successfully used the Designer to create an experiment, then you have the necessary permissions) 

Please see the [tutorial on how to set this up](protocol-designer_metadata_tutorial.md).

# Fill out the metadata

Notice in the above picture, the metadata is already filled out for the most part. That's because possible values for these metadata fields are stored in a Google Sheets created for this purpose. Most of the metadata fields have a drop down list which draws its options from this Google Sheets. This prevents people from introducing typos or stating the same metadata in different ways, making it difficult to search experiments by metadata values. If the value you need for a metadata field is not present in the drop down list, you can click the *Open Metadata Google Sheets*{:.gui-btn} button at the bottom. This will open the appropriate Google Sheets. You can find the tab that corresponds with the metadata field and add the value you need to the sheet. Any fields that do not have a drop down list or autofill, please fill in appropriately.

__Note__: You can add comments to the comments metadata field anytime during the experiment, and when the experiment ends it will pause and give you another chance to add any final comments.
{:.info}

If you are on a Windows operating system, and when you click Open Metadata Google Sheets nothing happens or you get an error that says, `'cmd.exe' is not recognized`, try running this command in the MATLAB command window once before clicking the button again: `setenv('PATH', [getenv('PATH') ';C:\Windows\system32'])`.

# Experiment settings

Next, take a look at the top left panel and fill out your experiment settings appropriately.

## Experiment type

Select the correct experiment type. Experiment type refers to your arena set up - whether you have a fly tethered and flying, or whether you have a fly walking on a ball.

This is important because, in the Designer settings, you have a default test protocol for each experiment type. When you click the *Run Test Protocol*{:.gui-btn} button, the file associated with that experiment type in your settings will run automatically. More on the test protocol later.

## Processing and Plotting

Select whether you would like the application to perform automatic data processing and/or plotting when the experiment is done.

For this to work, you should have created a data processing settings file and a data analysis settings file earlier in the experiment design process. If processing is checked, the associated filepath should be to your processing settings file, and the same for your plotting (analysis).

If you want your data processed and analyzed automatically but have not set up these settings files, please see [Data analysis](data-handling_analysis.md). If you do not wish to use this feature right now, simply uncheck the processing and plotting boxes.

## Processing and Plotting paths

You must set the paths to three files – the processing and plotting files (if you've selected to use them) and the run protocol file (covered in the next section). The default paths in the settings file will be placed here automatically, so if you don't wish to change from the defaults, you don't have to do anything. However, you can change these without altering the defaults. Hit the *browse*{:.gui-btn} button at the end of each text box to change the file being used in this particular experiment.

These paths should point to the settings files you generated for data processing and plotting earlier in the process. If you did not set up any settings for data processing or plotting, then uncheck the plotting and processing checkboxess. 

- Please note that you cannot change the experiment name in the conductor. The designer, if it is open, and the conductor share the same underlying experiment. If you change the experiment in the designer, it will change in the conductor, but if you have opened the conductor independently, it will not. For this reason, changing the experiment name in the conductor could lead to confusion as to which is experiment is actually loaded. If you must make any changes, close the conductor and go back to the designer.

## Run Protocol Path

The run protocol does not refer to the .g4p file, but to a different .m file which controls how exactly the .g4p file is run on the arena. For more details on how exactly the run protocol works, see [this tutorial](experiment-conductor_run-protocol_tutorial.md). There are two default run protocols to choose from: `G4_default_run_protocol.m` and `G4_default_run_protocol_streaming.m`, both located in `G4_Display_Tools/G4_Protocol_Designer/run_protocols`. A third run protocol, called `G4_run_protocol_combinedCommand.m` is also present, but as of now should not be used, as it still has bugs to be worked out. 

Which of the two default protocols you use depends on whether you'd like to use the recently added streaming feature. To use it, the experiment must have non-zero sample rates set for the Analog Input Channels. You set these values in the Designer when creating your experiment. 

The streaming feature does two things. First, it collects data from your fly at the end of each trial and plots it on the graphs shown in the Data Monitoring Panel (more on these in the Data Monitoring section below). This allows you to monitor how centered your fly is and how well it is flying. Second, it catches any conditions where the fly was not flying enough, marks them as bad, and attempts to re-run them at the end of the experiment. This way, if the fly successfully runs through the condition on the re-run, you still get data for that condition. The data processing will automatically use the re-run's data instead of the bad data from the first attempt. 

If you'd like to utilize these features in your experiment, all you have to do is set the run protocol to `G4_default_run_protocol_streaming.m`. If you do not want these features, set the run protocol to `G4_default_run_protocol.m`. If you are comfortable with programming in matlab, you can also see [this tutorial](experiment-conductor_run-protocol_tutorial.md) showing how to create your own run protocol.

Notice the next line in the Conductor asking how many times bad conditions should be re-attempted at the end of the experiment. By default this is set to 1. If you're using the streaming protocol, and a bad condition is re-attempted at the end of the experiment and still fails, it will not be attempted again. You can set this to a higher number, meaning if the first re-attempt fails, the condition will be tried again, up to the number of re-attempts you have set. Keep in mind that if your fly stops flying a lot, your experiment may end up being much longer than originally anticipated if you are re-running multiple trials many times at the end of the experiment. And a fly that stops flying a lot will very likely refuse to fly much at all by the end of a long experiment. Note, however, that you can also set this number to 0. If you set it to 0, you will get the benefit of seeing the fly's data throughout the experiment on the plots provided, but bad conditions will NOT be re-attempted at the end of the experiment. 

## Run a test protocol (optional)

The *Run Test Protocol*{:.gui-btn} button will run the protocol listed in the settings file as the test protocol for that type. This will allow you to see a test run on the screens and make sure it looks right. If you need to adjust these settings, you cannot presently do it from the conductor. Close the conductor, adjust the settings through *File*{:.gui-btn} → *Settings*{:.gui-btn} on the Designer, then return the conductor when finished.

# The progress bar

You'll notice in the image above, the progress bar is simply a long empty box. When you open an experiment, vertical lines will appear denoting the end of each repetition in the protocol. The more repetitions your experiment has, the more vertical lines there will be. When you start running an experiment, text will appear above the progress bar, telling which trial in which repetition is running at any given time. A horizontal bar will move from left to right, giving you a visual representation of how far along you are in the experiment. If data streaming is enabled, any time a trial is marked as bad because the fly was not flying, a red vertical line will appear on the progress bar indicating where in the experiment it happened. If your fly gets tired and stops flying a lot, you'll see this visually by the clustering of red vertical lines. If data streaming is not enabled, you'll get no indication of how the trials are going. 

# Trial Data

Below the progress bar will be the parameters for the trial currently running on the screen. You'll notice that the *Pattern*{:.gui-txt}, *position function*{:.gui-txt}, and *AO functions*{:.gui-txt} give numbers, not file names. This is the value being sent to the screens. If `Pattern_0008` is the fourth pattern in the patterns field of `currentExp.mat`, then the number provided under *Pattern*{:.gui-txt} will be 4. The `currentExp.mat` file stores all the experiment parameters and sends them to the screen in a way the screens can understand.

Also beneath this will be the total time the experiment is expected to take.

# Data Monitoring

In the Data Monitoring Panel you'll find three plots as well as some labels. *Last trial avg WBF:*{:.gui-txt} will display, at the end of each trial, your fly's average wing beat frequency for that trial. Note that the items in the Data Monitoring panel will only update if you are using the run protocol called `G4_default_run_protocol_streaming.m`.

There are three axes visible in this panel.

## Intertrials Histogram

Assuming your experiment includes an intertrial, this axis will plot a histogram of the fly's intertrial data. The histogram will be updated at the end of every intertrial, taking into account all intertrials up to that point. After a few intertrials, the histogram should settle into a pattern which will help the user understand at a glance how well-centered their fly is. 

## Conditions Histogram

This histogram may or may not be useful depending on the experiment. It does the same as the intertrials histogram, but instead uses condition data. Every time a condition completes, this histogram will update, using all data collected from conditions so far. 

## Wing Beat Frequency per Trial

This axis will update after every trial aside from the pre- and post-trials if they are present. A dot will appear showing the average wing beat frequency for that trial. Intertrials will be marked in red, regular conditions in black. A horizontal line is also plotted, indicating the minimum acceptable wing beat frequency a fly should have before a condition is marked as "bad." This limit will be taken from your data processing settings, if you have created them. If you have not, it will default to 1.5 hz.

A trial is also marked as bad if the average is above the minimum but the fly spends too large a percentage of the trial flying below the minimum wbf. These settings are also in your processing settings file if you have created one. See [Data analysis](data-handling_analysis.md) for information on how to set up this file. If you do not doing automatic data processing, then by default a trial will be marked as bad if the fly spends 25% or more of the trial flying below the minimum wing beat frequency. 

When a trial is marked as bad, a red line will appear on the progress bar to give you a visual indication of where in the experiment it happened. This way it will be visually obvious if your fly is not flying well and you're losing a lot data because of it. 

# Running the experiment

When you are ready to go, hit the *Run Experiment*{:.gui-btn} button. It will take a few seconds to connect to the G4 Host, but when everything is ready, a dialog box will pop up asking you to *Start*{:.gui-btn} or *Cancel*{:.gui-btn}. If you entered a duration of zero for your pre-trial, don't forget you will need to hit a button to make the experiment go past the pre-trial.

## Abort an experiment

If something goes wrong and you need to abort an experiment in the middle, hit the *Abort Experiment*{:.gui-btn} button. This will finish the currently running trial, then stop the experiment. It will automatically clear out any lingering log files, so once you get the dialog box saying the experiment was aborted successfully, you can hit *Run*{:.gui-btn} to restart the experiment.

## Open a subsequent experiment

If you are done with the experiment currently loaded in the conductor and wish to run another, no need to close the application. Just go to *File*{:.gui-btn} – *open*{:.gui-btn} and open the new experiment. It will automatically replace the old one.

## Using the conductor without the designer

The conductor can also be opened on its own, without going through the experiment designer. To open the conductor directly, run the `G4_Experiment_Conductor.m` file in `G4_Display_Tools\G4_Protocol_Designer`. If you open the conductor this way, then you will need to go to *File*{:.gui-btn} – *Open*{:.gui-btn} to open the .g4p file you want to run. Other than that, it operates exactly the same as described above.

# Post-experiment data analysis

## Data analysis

If you elected to run them, data processing and analysis scripts will run when the experiment is complete. This will create a folder in your experiment folder named by the current date. This date folder will contain a folder for each fly that has been run through that particular experimental protocol on that particular date. In each fly folder will be TDMS log files, a processed data file, as well as some .mat files containing your metadata and experiment information. If you chose to do automatic data plotting, those plots and a pdf report will be saved wherever your analysis settings indicate.

# How to change the run protocol for experiments

## The run protocol

The run protocol does not refer to the .g4p file, but refers to the way in which the experiment parameters in the .g4p file are relayed to the screens. For example, in the default run protocol, no inter-trial is run before the first block trial or after the last, though an inter-trial is run between repetitions of the block trials. If you wanted to change this, you could make the change and save as a new run protocol. Please only do this if you are comfortable writing MATLAB scripts to run experiments on the LED arena, and never delete the two default run protocols.

If you create your own run protocol, please do not forget that you must change the path in the conductor to your new file.

The default run protocol file is heavily commented to help you understand what each piece of code does, but if you are confused about something, you can always contact [Lisa (Taylor) Ferguson](mailto:taylorl@janelia.hhmi.org).
