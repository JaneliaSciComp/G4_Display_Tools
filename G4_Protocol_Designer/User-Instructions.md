---
title:  G4 Protocol Designer
parent: Display Tools
grand_parent: Generation 4
nav_order: 12
---

1. TOC
{:toc}

# Before you begin

To Install, clone or download the [G4 Display Tools github repository](https://github.com/JaneliaSciComp/G4_Display_Tools). For full functionality, you must add this folder to the MATLAB path with all its subfolders and files. To do this, click *set path*{:.gui-btn} in the MATLAB home tab, and *add with subfolders*{:.gui-btn}. Next, browse to the location where you saved G4_Display_Tools, save and close the *Set Path*{:.gui-txt} window. Alternatively, in the Current Folder pane in MATLAB, browse to the location where you saved G4_Display_Tools, right click this folder, and select *Add to Path: Selected folders and subfolders*{:.gui-btn}. 

You must also add your configuration file to your MATLAB path. It should be saved at `C:\Program Files (x86)\HHMI G4\Support Files\HHMI Panels Configuration.ini`.  If you don’t have this, please see the [Software Setup documentation](../docs/G4_Software_Setup.html).

Lastly, please ensure that `C:\matlabroot\PControl_G4_V01\TDMSReaderv2p5` is NOT on your MATLAB path. This folder contains files from previous versions of this software that may conflict with the current files. You can check this via the MATLAB command `contains(path, "TDMSReaderv2p5")` – a return value of `1` means the folder needs to be removed from your path.

Before you begin, please note that the Pattern, Position function, and AO function .mat files used by this program must be structured correctly for the program to read them. 

- Patterns, at a minimum, must be a struct pattern with fields `pattern.Pats` and `pattern.gs_val`.
- Position Functions, at a minimum, must be a `struct pfnparam` with fields `pfnparam.gs_val`, `pfnparam.func`, and `pfnparam.size`
- Ao Functions must be a `struct afnparam` with fields `afnparam.func`, `afnparam.size`, and `afnparam.ID`

# The Designer: Start-up

If you already have a .g4p file saved and ready to run, you can open The Experiment Conductor directly instead of using the designer.

## Start the protocol designer.  

In MATLAB open the file `G4_Experiment_Designer.m`, located in `G4_Display_Tools\G4_Protocol_Designer` and hit run. This should open the "Fly Experiment Designer" in a Window that looks like this:

![Fly Experiment Designer main window](../docs/assets/screenshot-1.png)

## Check the size of the LED arena you are using. 

LED screen arenas come in three row screens and four row screens. Which patterns you can use are determined by the screen size you are using, so be sure to check what type of arena you’re using. 

Notice the radio button at the center left of the application indicating *3 Row Screen*{:.gui-btn} or *4 Row Screen*{:.gui-btn}. Set this to the correct screen size that corresponds with your [hardware setup](../docs/G4_Hardware_Setup.md) before doing anything else. This setting will become disabled as soon as you import a folder, so if it is incorrect when you import, you will need to restart the application.

## Verify your settings are correct. 

The next step after verifying your screen size is to verify your settings are correct. Click *File*{:.gui-btn} > *Settings*{:.gui-btn} to open up your settings window. It should look like this:

![Fly Experiment Settings window](../docs/assets/screenshot-2.png)


The first field in the settings panel reads *Configuration file location:*{:.gui-txt} If the path to the configuration file is incorrect, please update it by using the associated browse button or by typing the correct path into the field.

## Run, Plotting, and Processing

The next three fields are paths to your default run protocol file, processing file, and plotting file. These files are provided with the Protocol Designer and and are used to run different stages of the experiment. While there is usually no need to edit these files, they allow customization beyond the parameters provided by the Protocol Designer to advanced users.

In either case, if you want to use the default files or use your own, make sure these paths are set correctly. The defaults are `G4_Display_Tools\G4_Protocol_Designer\run_protocols` for the run protocol, `G4_Display_Tools\G4_Data_Analysis\data processing` for the processing file, and `G4_Display_Tools\G4_Protocol_Designer\plotting_files` for the plotting file. The default plotting file `G4_Plot_Data_flyingdetector_pdf.m` will produce a pdf report. If you prefer another type of plotting, have a look at other options in `G4_Display_Tools\G4_Data_Analysis\data plotting`.

## Test Protocols

The next three lines in the settings file provide paths to test protocols for each type of experiment. The test protocols are located in `G4_Display_Tools\G4_Protocol_Designer\test_protocols`. Again, you can set these to custom test protocols if you have them.

## Overlapping graphs

"Overlapping graphs" refers to the pdf report generated at the end of the experiment. The default is `0`, but if you would like your final graphs to plot on top of one another on a single axis, change this value to `1`.

## Disabled cells

When using the protocol designer, cells for unavailable parameters will fill with ‘---------‘ on a grey background, to indicate that you cannot edit these cells. The next two fields in the settings file allow you to customize the color and text which fill disabled cells. 

## Metadata GoogleSheet Properties. 

Notice the separate panel at the bottom of the Settings window called Metadata GoogleSheet Properties. These keys link to an online spreadsheet from which the Conductor dynamically pulls the metadata fields. The different fields labeled with "GID" define tabs in the metadata GoogleSheet. Should the GoogleSheet be reorganized (specifically current ones deleted or new ones created) the new key will need to be obtained for that tab and replaced here. Usually, there should be no reason to change these values.

# The Designer: Import files

To design an experiment, you must first import the files that you will use for the experiment. These files may include patterns, position functions, analog output functions, or the `currentExp.mat` file produced with every experiment. Patterns describe the visual output on the arena at any point in time. You can use the position functions to change this output over time. Analog output functions are used to generate a corresponding output on the BNC. The file `currentExp.mat` finally is a description of the experiment itself.

Go to *File*{:.gui-btn} -> *Import*{:.gui-btn} at the top left of the application. A box will appear giving you three options – Folder, File, or Filtered File. Select *Folder*{:.gui-btn} if you want to recursively import all files either from an experiment folder or a folder with pattern files. Alternatively, you can also import patterns or functions individually, one file at a time. The option *File*{:.gui-btn} allows you to choose a single file. The text you enter after selecting *Filtered File*{:.gui-btn} acts as an additional filter for the file selection dialog. For example, entering horizontal or 0001 in the Filter Import Results will result in a `*horizontal*.mat` or `*0001*.mat` filter respectively. It is therefore like a permanent alternative to typing `*horizontal*.mat` as a filename in the file selector dialog.

After selecting the file or folder you wish to import and depending on the size of your import, a progress bar informs you about the import progress. Once all files have been imported, you will see a summary of imported and skipped files. Once you confirm with *OK*{:.gui-btn} the import is complete. At this point you might notice the change in the *Experiment Name*{:.gui-txt} at the bottom of the screen. If you have imported a Folder, it this box will contain the experiment folder’s name. Nothing else will look much different.

# Designing an experimental protocol

## Design your experiment. 

You can design your experiment using the files imported in the previous step. The easiest starting point is to hit the *Auto-Fill*{:.gui-btn} button. This will create a block trial for every pattern imported, as well as create a pre-trial, inter-trial, and post-trial using the first pattern. Each trial will default to mode 1 and automatically pair a position function and one analog output function to each pattern. Durations default to double the length of the position function. Hitting *Auto-Fill*{:.gui-btn} will produce something like this:

![After Auto-fill](../docs/assets/screenshot-3.png "Main window of the experiment designer after hitting the Auto-Fill button")

Notice that cells holding parameters not used in mode 1 (such as *Frame Rate*{:.gui-txt}, *Gain*{:.gui-txt}, and *Offset*{:.gui-txt}) are disabled. If you try to edit these cells you will get an error. Each mode uses different parameters so if you change the mode of a trial, the cells will automatically adjust, enabling those used in that mode and disabling the rest.

The string in the cells under *Pattern Name*{:.gui-txt}, *Position Function*{:.gui-txt}, and *AO 1*{:.gui-txt} to *AO 4*{:.gui-txt} are the names of the files of that type you have imported. If you click on one of the Pattern cells, two things will happen. You will get a preview of that pattern in the preview pane. This preview starts at frame 1, and you can use the *Play*{:.gui-btn}, *Forward Frame*{:.gui-btn}, and *Back Frame*{:.gui-txt} buttons to look at the different frames of the selected pattern.

The second thing that will happen is that the embedded list to the right of the preview will fill with all the imported files of that type (patterns if you’ve selected a pattern cell, position functions if you’ve selected a position function cell, and an analog output function for the AO cells). The filename of the selected cell is highlighted, but you may choose other items in this list. If you do, a preview of the item you clicked in the list will appear in the preview frame. You may go through this list, previewing items, until you find the one you want. Confirm a change in you currently selected cell with the *Select*{:.gui-btn} button. Clicking an empty cell will also provide this list, and you can choose the item you want and hit select to populate the empty cell.

## Other methods of arranging parameters and trials. 

Notice the buttons to the right of the block trial. They modify the trial or trials currently selected through the checkbox at the end of each line. *Shift up*{:.gui-btn} and *Shift down*{:.gui-btn} will move your selected trial(s) up and down throughout the main block of trials. *Add trial*{:.gui-btn} will add a copy of the selected trials to the bottom of the block. If no trial is selected, the new trial is based on the last item in the block. *Delete Trial*{:.gui-btn} will remove the selected trial(s). Finally, the *Select All**{:.gui-txt} checkbox above the block will select all trials and *Invert Selection*{:.gui-btn} will uncheck all the checked trials, and check all the unchecked ones.

If you select a trial in the block, then go to *File*{:.gui-btn} > *Copy To*{:.gui-btn}, you can copy that trial into the pre-trial, inter-trial, and/or post-trial spaces. *File*{:.gui-btn} > *Set Selected*{:.gui-txt} will let you type in the values you want for each parameter in the selected trial.

## Pre, Inter, and Post trials are not required.

If you do not wish to have a pre-trial in your experiment, simply erase the mode and hit enter. Leaving the mode blank will disable this section. The same can be done for inter-trial and post-trial, but the block trials must have at least one trial.

## Frame Index.

The frame index can be set in any mode, and will dictate where in the pattern library the animation will start. You may also enter *r*{:.gui-txt} instead of a number as the frame index. This tells the screens to start at a random frame within the frame library.

## Infinite loop pre-trial.

If you want the pre-trial to run indefinitely until you are ready to move on with the experiment, enter a duration of 0. This will cause the pre-trial to continue running until you hit a key or click the mouse to indicate the experiment should continue. This can give you time to make sure your fly is fixated correctly.

Here is an example of a completed experiment. Be sure to change the name of your experiment at the bottom!

![Example of a completed experiment](../docs/assets/screenshot-4.png)

## Other parameters outside the tables.

There are a number of parameters outside the trials themselves that need to be set.

- You may choose whether your block trials run in sequential order or random order.
- You may choose how many times your experiment is repeated. For example, if *repetitions*{:.gui-txt} is set to two, the pre-trial will run once, the block will run twice, with an inter-trial between each block trial, and the post-trial will run once. Note that-he inter-trial does NOT run before the first block trial OR after the last block trial.
- You need to set the sample rates for your Analog Input Channels. If you’d like to disable a channel, set the sample rate to 0.
- You must set your screen size BEFORE importing.
- You must also give your experimental protocol a name at the bottom.

# Saving and opening experiments

## Saving an experiment. 

You’ll notice that under the *File*{:.gui-btn} menu, there is no "Save" option, only *Save As*{:.gui-btn}. This is a safety precaution to prevent you from overwriting an older experimental protocol. When you hit *Save As*{:.gui-btn}, the application will immediately append a timestamp to the end of your experiment name and save the experiment structure in a folder of this name in whatever location you browse to. Note that the experiment does not contain any data at this point, here you save the definition on how an experiment is going to be run. Once the save dialog has opened, you can change this name if you wish, but be careful of over-writing something important. You will not be able to get it back.

When you save an experiment, the application will automatically export all the files you need to run said experiment. It will create an experiment folder, inside of which will be a `Patterns` Folder, `Functions` folder, and `Analog Output` folder, in addition to the `currentExp.mat` file and `.g4p` file:

```
├── Patterns
├── Functions
├── Analog Output
├─ currentExp.mat
└─ experiment.g4p
```

Once you have saved an experiment, if you want to design another one, there is no need to close the application. Simply click the *Clear All*{:.gui-btn} button at the top right corner, and it will clear out the currently loaded experiment. Be careful though, if you click *Clear All*{:.gui-btn} before saving the experiment, you will lose that setup!

## Opening an experiment.

When you go to *File*{:.gui-btn} – *Open*{:.gui-btn}, you’ll see one or more options. *.g4p file*{:.gui-btn} is the first. Click this if you want to open an experiment file not listed. When you open an experiment, you should browse to the .g4p file inside the experiment folder and open that. Everything in the folder will automatically be imported.

Below the *.g4p file*{:.gui-btn} option may be listed up to four experiment names. These are the four most recently opened .g4p files, and if you want to open one of them again, just click the name it will open automatically. When you first start using this software, there will be no recently opened files to list here, but they will appear as you use the software.

Keep in mind if you open an experiment, change it, and then resave it, it will not update the original experiment. It will save as a new folder because there will be a new timestamp added to the experiment name.

When you open an experiment, the designer will automatically populate with the appropriate trials and parameters.

# Previewing an Experiment

## Previewing a full trial.

The in-screen preview panel shows you a preview of the pattern or function you are working with, but you can also get a holistic preview of a selected trial. Select the box at the end of the trial you want to see and hit the *Preview*{:.gui-btn} button to the right of the preview pane. You will see a separate window pop up that looks something like this, depending on the trial:

![Experiment Preview](../docs/assets/screenshot-5.png)

You have some options to set once this window is open. Notice the *Real-time Speed*{:.gui-txt} checkbox below the position function, and the *Frame Increment*{:.gui-txt} field below that. If you hit *Play*{:.gui-btn} immediately after the preview window opens, when the *Frame Increment*{:.gui-txt} is set to `1`, the preview will play VERY slowly. This is because these patterns play on the screens at 500 or 1000 frames per second, and a frame increment of 1 means you are showing every single frame on a screen that only refreshes at approximately 20 frames per second.

If you’d like to see the preview in real-time, check the *Real-time Speed*{:.gui-txt} box by the *Pause*{:.gui-btn} button. This will automatically calculate what frame increment is needed to play the trial at its set duration. Notice that while the *Real-time Speed*{:.gui-txt} box is checked, you cannot change the *Frame Increment*{:.gui-txt}.

If you would like to see the preview at some speed in the middle (fast enough that you don’t grow old waiting for it, but slow enough to get a good idea of what is happening), uncheck the *Real-time Speed*{:.gui-txt} box and set the *Frame increment*{:.gui-txt} to any number. It determines how many frames are skipped between each frame shown, so the higher the number, the faster the playback.

A vertical bar traces the current position in the position function preview and AO function previews as the pattern plays. A red vertical bar denotes the duration set in the designer. For example, in the picture above, the position function being used has a maximum x value of 7s, but my duration for this trial is set to 5s. Therefore, the red bar marks the place on the function where play will stop. Ideally, you will look for the red vertical bar to fall at the end of your graph, indicating that the duration set in your designer matches the duration of the functions you’re using.

Notice on the right side there is a check box labeled *Pattern Only Video*{:.gui-txt} and a button beneath it that says *Generate Video*{:.gui-btn}. These options let you create a video of your trial. If you hit *Generate video*{:.gui-btn} without checking pattern only, it will produce an .avi video of the preview window, played at the current frame increment speed. If you check *Pattern Only*{:.gui-txt} then the video produced will only show the pattern playing. Create different speed videos by adjusting the frame increment before clicking Generate Video.

# Dry Run

## To do a dry run of a single trial.

A dry run is the running of a single trial on the LED screen arena. This trial does not activate any analog input channels and does not include any pre- or post- trials. It will run the trial selected on the screens in isolation, so you can verify it appears on the screen as you expect. To do this, select the trial you want to view and hit the *Dry Run*{:.gui-btn} button below the *Preview*{:.gui-btn} button. Please note that this will take a few seconds, as it will need to open and connect to the G4 Host. A dialog box will pop up when the screens are ready, asking you to click *Start*{:.gui-btn} or *Cancel*{:.gui-btn}. The trial will not begin running on the screens until you click *Start*{:.gui-btn}.

# The Experiment Conductor

## Click "Run Trials".

If you are in the experiment designer and you are ready to run your experiment, click the *Run Trials*{:.gui-btn} button at the left of the window. This will produce a separate window, known as the experiment conductor. Note the different parts: at the top left is the experiment settings, the metadata on the right, the progress bar in the center, and the trial data at the bottom.

![Experiment Conductor](../docs/assets/screenshot-6.png)

## First, fill out the metadata.

Notice in the above picture, the metadata is already filled out for the most part. There is a metadata GoogleSheet in the Reiser Lab Google drive which contains tabs for each metadata fields and possible values. This populates the metadata fields seen on the conductor. Most of them have drop down lists from which you can choose any of the values stored in the GoogleSheet. This prevents people from introducing typos or stating the same metadata in different ways, making it difficult to search experiments by metadata values. If the value you need for a metadata field is not present in the drop down list, you can click the *Open Metadata Google Sheet*{:.gui-btn} button at the bottom and add the value you need to the appropriate tab. Any fields that do not have a drop down list or autofill, please fill in appropriately.

If you click Open Metadata Google Sheet and nothing happens or you get an error that says, `'cmd.exe' is not recognized`, try running this command in the MATLAB command line once before clicking the button again: `setenv('PATH', [getenv('PATH') ';C:\Windows\system32'])`.

## Experiment type.

Select the correct experiment type. The *Run Test Protocol*{:.gui-btn} button will run the protocol listed in the settings file as the test protocol for that type. This will allow you to see a test run on the screens and make sure it looks right. If you need to adjust these settings, you cannot presently do it from the conductor. Close the conductor, adjust the settings through *File*{:.gui-btn} -> *Settings*{:.gui-btn} on the Designer, then return the conductor when finished.

## Processing and Plotting.

Select whether you would like the application to perform automatic data processing and/or plotting when the experiment is done. (Note that the software cannot do plotting without first processing the data).

## Processing, Plotting, and Run Protocol paths.

You must set the paths to three files – the processing and plotting files (if you’ve selected to use them) and the run protocol file. The default paths in the settings file will be placed here automatically, so if you don’t wish to change from the defaults, you don’t have to do anything. However, you can change these without altering the defaults. Hit the *browse*{:.gui-btn} button at the end of each text box to change the file being used in this particular experiment.

- Please note that the run protocol file is set up to be edited by users if they wish. There is now only one default run protocol, but you can change it and save others if you’d like. You should always save these in `G4_Display_Tools\G4_Protocol_Designer\run_protocols` with the default. Whatever .m file is in this text box is the one that will be run. Please only do this if you are comfortable writing scripts in MATLAB.
- Please note that you cannot change the experiment name in the conductor. The designer, if it is open, and the conductor share the same underlying experiment. If you change the experiment in the designer, it will change in the conductor, but if you have opened the conductor independently, it will not. For this reason, changing the experiment name in the conductor could lead to confusion as to which is experiment is actually loaded. If you must make any changes, close the conductor and go back to the designer.

## The progress bar.

You’ll notice in the image above, the progress bar is split into two halves. A vertical bar will denote the end of each repetition. The more repetitions your experiment has, the more bars there will be. When you start running an experiment, text will appear above the progress bar, telling which trial in which repetition is running at any given time. 

## Trial Data.

Below the progress bar will be the parameters for the trial currently running on the screen. You’ll notice that the *Pattern*{:.gui-txt}, *position function*{:.gui-txt}, and *AO functions*{:.gui-txt} give numbers, not file names. This is the value being sent to the screens. If `Pattern_0008` is the fourth pattern in the patterns field of `currentExp.mat`, then the number provided under *Pattern*{:.gui-txt} will be 4. The `currentExp.mat` file stores all the experiment parameters and sends them to the screen in a way the screens can understand.

Also beneath this will be the total time the experiment is expected to take.

## Run the experiment.

When you are ready to go, hit the *Run Experiment*{:.gui-btn} button. It will take a few seconds to connect to the G4 Host, but when everything is ready, a dialog box will pop up asking you to *Start*{:.gui-btn} or *Cancel*{:.gui-btn}. If you entered a duration of zero for your pre-trial, don’t forget you will need to hit a button to make the experiment go past the pre-trial.

## Abort an experiment.

If something goes wrong and you need to abort an experiment in the middle, hit the *Abort Experiment*{:.gui-btn} button. This will finish the currently running trial, then stop the experiment. It will automatically clear out any lingering log files, so once you get the dialog box saying the experiment was aborted successfully, you can hit *Run*{:.gui-btn} to restart the experiment. 

## Open a subsequent experiment.

If you are done with the experiment currently loaded in the conductor and wish to run another, no need to close the application. Just go to *File*{:.gui-btn} – *open*{:.gui-btn} and open the new experiment. It will automatically replace the old one.

## Using the conductor without the designer.

The conductor can also be opened on its own, without going through the experiment designer. To open the conductor directly, run the `G4_Experiment_Conductor.m` file in `G4_Display_Tools\G4_Protocol_Designer`. If you open the conductor this way, then you will need to go to *File*{:.gui-btn} – *Open*{:.gui-btn} to open the .g4p file you want to run. Other than that, it operates exactly the same as described above.

# Post-experiment data analysis

## Data analysis. 

If you elected to run them, data analysis scripts will run when the experiment is complete. This will create a `Results` folder in your experiment folder. The Results folder will contain a folder for each fly that has been run through that particular experimental protocol, which is why giving your flies unique names is important! In each fly folder will be TDMS log files, a processed data file, and a PDF report containing the metadata and basic data analysis/plotting. The only plotting files which produce PDF reports are in `G4_Display_Tools\G4_Protocol_Designer\plotting_files`.  If you develop other data analysis files, simply replace the path for the processing or plotting files in the conductor, and those will run after the experiment instead. However, you cannot currently run more than one for each step.

# How to change the run protocol for experiments.

## The run protocol.

The run protocol does not refer to the .g4p file, but refers to the way in which the experiment parameters in the .g4p file are relayed to the screens. For example, in the default run protocol, no inter-trial is run before the first block trial or after the last, though an inter-trial is run between repetitions of the block trials. If you wanted to change this, you could edit the default run protocol (not recommended) or save a new run protocol with this change (recommended). Please only do this if you are comfortable writing MATLAB scripts to run experiments on the LED arena, and never delete the default run protocol. 

If you create your own run protocol, please do not forget that you must change the path in the conductor to your new file. 

The default run protocol file is heavily commented to help you understand what each piece of code goes, but if you are confused about something, you can always contact Lisa Taylor at her contact information at the bottom of this document. 

# Trouble-shooting

## Common errors and how to fix them.

Many common errors will create a dialog box telling you there is a problem, but some of them may be vague if you are new to MATLAB or to this software. Here are some of the most error messages and what to do about them:

### "You must select a trial" or "Only one trial may be selected." 

Some of the functionality in the designer can only be performed on one trial at a time. If you get this error, scroll through all your trials and make sure a second one isn’t selected somewhere. 

### "You cannot edit that field in this mode."

Most modes only allow certain parameters to be changed in that mode. You are trying to edit a parameter not available for the mode. Check the mode value for your trial and make sure it is correct for what you’re trying to do. 

### "The value you've entered is not a multiple of 1000. Please double check your entry." 

This is not actually an error, and will not prevent you from doing anything. However, the Analog Input sample rates usually should be multiples of 1000, so this warning is there in case you miss a zero or otherwise typo a sample rate. 

### "None of the patterns imported match the screen size selected." 

Check the screen size at the center left of the designer. The patterns you’ve tried to import were made for a different size screen than you have selected. 

### "If you have imported from multiple locations, you must save your experiment before you can test it on the screens." 

This is also not an error, but a warning. If you have not saved your experiment yet, then the folder this application thinks of as the "experiment folder" is the last folder you imported from. If you have imported from multiple locations and try to test a trial on the screens, it may not work if it cannot find the pattern or function it needs in the last location you imported from. You can avoid this issue by saving the experiment before you dry run a trial. 

**There are also errors that you might get in MATLAB that don’t produce a dialog box. Some common ones include: **

### "Error using fileread. Could not open file HHMI Panels Configuration.ini." 

If you get this error message regarding the configuration file or any other important file, check that the path to this file is correct in your settings file, and make sure the file is on your MATLAB path. If you get this file regarding the `G4_Protocol_Designer_Settings.m` file, make sure it is located in `G4_Display_Tools\G4_Protocol_Designer`. Do not move it from this location. If you get this error regarding the `recently_opened_g4p_files.m` file, please make sure it is located in `G4_Display_Tools\G4_Protocol_Designer\support_files`. DO NOT edit this file. 

# A few DO NOTs:

**DO NOT** edit any of the files in the `support_files` folder. 

**DO NOT** move any files out of their original locations within the `G4_Display_Tools` folder (though you can save that folder wherever you like, as long as it is added to your MATLAB path)

**DO NOT** allow multiple files of the same name to be on your MATLAB path, as this can cause conflicts.

# Conventions and explanations

In this document visual aids transport specific meanings. Hopefully this is intuitive, but here is a short and incomplete list: Code, paths, and filenames are highlighted by using a different font in gray: `print("This is machine text")`. Elements of the GUI are highlighted by a surrounding box. Clickable buttons and menu items like *File*{:.gui-btn} or *OK*{:.gui-btn} have a shadow, other text like *Column names*{:.gui-txt} or *Values*{:.gui-txt} are highlighted differently.

# Contact

If you need assistance or would like to talk about the G4 Designer software further, you can contact Lisa Taylor, Scientific Computing Associate, at <taylorl@janelia.hhmi.org>.

{::comment}this was copied from the original file `User_Instructions.docx`{:/comment}