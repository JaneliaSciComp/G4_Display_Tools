---
title:  Tutorial - Design your own run protocol
parent: G4 Experiment Conductor
grand_parent: Generation 4
nav_order: 2
---

# This tutorial is only for advanced users. Multiple run protocols are provided for the user to choose between. It's only recommended to design your own if you are thoroughly familiar with all tools involved and have a particular need.

# Prerequisites

- [G4 Setup](software_setup.md)
- have designed at least one pattern using the [Pattern Maker](pattern-generator.md)
- have designed at least one position function using the [Function Generator](function-generator.md)
- Basic MATLAB skills

# Introduction

You may have seen references to a __run protocol__ throughout the documentation. This is an `.m` file which sends [the experiment you design](protocol-designer.md) to the panels. It provides a structure and defines details regarding how the experiment is run like, for example, whether to run inter-trials before the first condition. There are eight run protocols included with the G4 Display Tools at `G4_Display_Tools/G4_Protocol_Designer/run_protocols`. In almost all cases, you should choose between one of these. When you run an experiment using the Conductor, a drop down list containing these eight run protocols is provided and you must choose one for your experiment. If you have a need to design your own, you will also need to update the Conductor to display your new run protocol in this drop down list. We will cover how to do that in this tutorial. This extra step helps re-iterate that this should only be done when truly necessary. 

There are three optional features in these run protocols. There is a run protocol for every possible combination of the three features, resulting in eight protocols total. The filenames indicate which features are present in each protocol. The three features with a brief summary are listed below. To read about the features in more detail, see the [Conductor documentation](experiment-conductor.md).

- The __streaming feature__. In these protocols, data being collected is displayed in real time in plots to the side of the screen,  so you can tell if the data you're collecting looks correct. In addition, trials which are marked as bad, due to something like the fly not flying during it, can be automatically rescheduled to run again at the end of the protocol in an attempt to get more robust data from any given experiment. 

- The __Block Logging__ feature. This tells the host to create a different log for each repetition of the experiment in order to keep the size of any given log file down. The log files can be combined into one data file at the end, or not. Without this feature, the data for the entire experiment is continuously logged into one file. 

- The __Combined Command__ feature. By default, parameters are sent to the screens individually, one by one, in sequence. However, there is a panel command which sends all parameters to the screen at once, hopefully reducing the opportunity for errors or hangups. These protocols utilize this command instead. In previous years, the data collected with this command had some issues. We believe these have been corrected, but this is pending confirmation, so as of April 2024, we do not recommend using these protocols. 

The default run protocol does not use any of these features. Each other protocol lists which features it utilizes in its file name. The protocols all function the same way aside from these features. 

If you need to run an experiment differently than the current run protocols, or need a feature we do not provide, you can write your own and add it to the list of options. Before we go into the details of how to do this, let's go over exactly how the current run protocols operate so you can decide if this is something you need to do.

By definition, this tutorial will also show you how to send specific commands to the panels manually. This might be useful if you want to display a single pattern on the panels or try running conditions without using the [G4 Designer](protocol-designer.md).

## How the current run protocols run an experiment, step by step

When you press "Run" on the Conductor to run your experiment, this is what happens when using any of the provided run protocols.

1. The protocol checks whether the GUI is present, to know whether graphics need to be updated or not.
2. Parameters are collected from your experiment and compiled into variables easy to pass along to the controller. 
3. It opens the Host.
4. The root directory and active AO channels, if any, are set.
5. At this point a dialog box pops up asking the user if they'd like to start the experiment or cancel.
6. Assuming they  start the experiment, some calculations are then done to get the estimated experiment duration and keep track of the remaining time throughout the experiment.
7. The log is started. If it fails to start twice, the experiment aborts.
8. If there is a pre-trial, the protocol updates the GUI progress, sends the pre-trial parameters to the screens, and then starts the display. 
9. After each condition completes throughout the experiment, the protocol checks if the user has pressed the "Abort" or "Pause" button. If the experiment has been aborted, it stops the display, stops the log, and closes the Host in that order. If the pause button has been pushed, it stops the log and then runs a pause function which waits for the pause button to be pressed again.
10. The elapsed time and remaining time are updated.
11. A loop begins to run each condition and inter-trial (if present) in the experiment. This is nested in an outer loop which does this for each repetition. In pseudo-code it looks like this:

		pre-trial runs (if present)
		for each repetition
			for each condition
				run condition
				if intertrial
					if it's the last conditon and last rep, skip inter-trial
					run inter-trial
		post-trial runs (if present)
					
This means that no inter-trial runs between the pre-trial and first condition. An inter-trial does run in between the last trial of one repetition and the first trial of the next repetition. And an inter-trial does not run after the last condition of the last repetition. 

12. Inside the loop that runs each condition, this is the order of operations:

	Determine the condition to play next if randomized
	Send parameters to the controller
	Start the display
	Update the progress bar and GUI text while condition runs
	If streaming is enabled, update the graphs with the previous condition's collected data while current condition runs.
	After the condition ends, collect streamed data if streaming is enabled. 
	Update loop parameters.
	If its time to move to the next repetition, the log will be stopped and re-started if block logging is enabled. 
	If it is the last repetition and last condition, the inter-trial is skipped.
	Update the elapsed and expected time.

13. After all repetitions have been run, it then runs any rescheduled conditions if this feature is enabled. Information for all bad trials (repetition and condition number) are collected. An inter-trial, if present, is run before the first rescheduled condition. The rescheduled conditions are run in the exact same manner as they were in the main experiment.  If you have set the protocol to attempt these bad conditions more than once, then after they've all been attempted, any that were bad a second time are attempted again, up to the number of attempts set by the user. 

14. After all conditions have been run, the post-trial is run in the same manner as the pre-trial, if present. If block logging is enabled, the pre-trial and post-trial data are saved in their own log. The log is started directly before the display, and stopped directly after the display, to minimize junk data before or after the condition.

This is the general flow of the experiment. If something about the order of operations here would be harmful to your experiment, you may need to write your own run protocol. So let's talk about how to do that.

# Communicating with the arena

## How to send a command to the screens

At `G4_Display_Tools\PControl_Matlab\controller` you'll find a file called `PanelsController.m`. This file should __not__ be edited. However, you'll need to be familiar with it, as it contains all the functions used to send information to the arena. 

At this point, you must have the G4 Panel Host application installed and ready to run in order to follow this tutorial. To create an instance of the controller, open matlab and in the command window and type the following:

```matlab
ctlr = PanelsController();
ctlr.open(true);
```
This will open the host and give you access to all the functions in `PanelsController.m`.  Now type

```matlab
ctlr.allOn()
```
The screens should light up. Next enter the following command.

```matlab
ctlr.allOff()
```
The screens should turn back off. This is the general idea of how information is sent to the arena.

## Running a condition via command window

Now that you know how to send a command to the panels using the MATLAB command window, it becomes clear that you could run a complete experimental condition this way if you knew which commands to use. I'll walk you through this process now. 

### Set up experiment folder

You will need an experiment folder containing a pattern and function to follow along. You should have one if you've already completed the [tutorial on how to design a condition](protocol-designer_create-condition_tutorial.md). If you have not done this or cannot find the experiment folder -- [don't panic](https://en.wikipedia.org/wiki/Phrases_from_The_Hitchhiker%27s_Guide_to_the_Galaxy#Don't_Panic), here is a quick reminder how to create a mock experiment folder. Create a new folder with a descriptive name of your choice wherever you can find it. Inside this folder should be two folders -- one called `Patterns` and one called `Functions`. Each of these folders should contain at least one pattern and one function. You can create them by using the [Pattern Generator](pattern-generator.md) and the [Function Generator](function-generator.md). Both files associated with the pattern (`*.pat`) or function (`*.mat`) should be within the respective folder. This next section will not work if you don't have a pattern and a function inside the file structure to send to the panels.

### Set the Root Directory

If you have closed the PanelsController instance that we created before, re-enter the folowing code. Otherwise, skip this step. 

```matlab
ctlr = PanelsController();
ctlr.open(true);
```

Next, save a variable called expFolder as the path to your experiment folder, and pass it into the controller command setRootDirectory. For example:

```matlab
expFolder = 'mypath\experiment_folder';
ctlr.setRootDirectory(expFolder);
```

### Start data logging

```matlab
log_started = ctlr.startLog();
```

You may have noticed on the Panel Host there is a virtual LED labeled _Log running_{:.gui-txt} which is green when a condition or experiment is running and which is dark when it is not. You should start the log before anything begins running and only stop the log when you are finished collecting data. You can stop the log, and then restart it, in order to create a new data file and save further data in that new file. In the [data analysis section](data-handling.md), you'll see that your raw data is contained in the log file. Data is only collected when the log is running. It's good habit to always run the log, even if you are just testing something.

### Set the parameters for your condition

All parameters for a condition are sent to the PanelsController at the same time. It then sends each item individually to the screens, unless you are using the combined command, in which case it sends all parameters simultaneously to the screens. All parameters must exist, even if they are empty and not being used, and they should be saved in a cell array in the order the controller expects. We are going to run a simple condition in mode 1 using a pattern and a position function. 

```matlab
mode = 1; 
pat = 1; #The pattern ID
posFunc = 1; #The position function ID
frameInd = 1; #The frame index to display in constant mode
frameRate = []; #The frame rate to use in streaming mode
gain = []; #The gain to use in certain modes
offset = []; #The offset used in certain modes
AOchans = []; #Which Analog Output Channels are active
AOind = []; #The function IDs of any Analog Output functions being used

params = {mode, pat, gain, offset, posFunc, frameRate, frameInd, AOchans, AOind};

ctlr.setControllerParameters(params);
```

Remember that different parameters are required for different modes. We are using mode 1 which requires a pattern and a position function. AO functions are optional. You can review what is needed for what mode [here](protocol-designer_display-modes.md). Regardless of which mode you use, all parameters must be defined and passed to the controller. 

Notice that the arguments for pattern and position function are numbers, not a file path. This relies on the the experimental folder set up in a defined way, in this case that there is a file `Patterns/Pattern_0001.pat` inside your root folder. All the software we provide knows and follows this file structure, so if you followed the documentation for the [Pattern Generator](pattern-generator.md) the file will be at the correct location.

It is good practice to name your patterns with their ID number in the name so that they will be ordered correctly in the folder and you don't have to remember the ID for every pattern. For example, when we make a set of patterns for an experiment, they each have a unique ID of 1 through the number of patterns we are making. Their filenames, then, are `Pattern_0001`, `Pattern_0002`, etc with the number in the filename matching the ID number. This way, it is easy to remember which ID number you should be sending to the panels in order to get the pattern that you want.

The arena uses the `.pat` or `.pfn` file, which is not human-readable, but if you do not know the ID of your pattern or function, you can open the `.mat` file associated with that pattern in MATLAB. The structure it contains has an ID field with the ID number.

### Start the Display

```matlab
dur = 5; #This is the duration you want the condition to run for in seconds
ctlr.startDisplay(dur*10);
```

This command tells the panels to start showing the previously sent information; in this case, display the pattern and function provided in mode 1. This command requires a duration be passed into it, so it knows how long to display the condition for. Ideally, the duration is the length of your position function, or a multiple of it if you want it to repeat. We only use 5 seconds as an example. Notice the duration is multipled by 10. The controller expects duration in deciseconds, not seconds. We generally enter the duration in seconds, so as to be more readable to the user, and convert to deciseconds only when sending it to the controller. You could, however, save the duration variable as 50 and remove the multiplication.

Once your pattern has run and the panels have gone dark again, submit the final command:

### Stop data logging

```matlab
ctlr.stopLog('showTimeoutMessage', true);
```

It's very important to send the `stopLog` command. Were you to run a real condition this way and forget to stop the log, it would continue running and could disrupt other functions of the Panel Host, not to mention giving you lots of useless extra data and filling up your storage. 'showTimeoutMessage' is an optional input. There are times when the log has collected a very large amount of data, that it might take a while for the stopLog command to complete. Enabling this option will tell it to provide you with a message if the stopLog command times out. You can then stop it manually through the Host GUI by selecting Stop Log from the drop down menu of commands and hitting the Send button.

### Disconnect from the G4 Panel Host

```matlab
ctlr.close();
```
When you are done working with the panels, it is important to stop the connection and close out the controller.

# What does this all mean

Keep in mind you never have to use any of these commands. All of this is handled for you by either the Panel Host or the [G4 Experiment Conductor](experiment-conductor.md), and if you are happy with the default run protocol, you should never have to worry about these commands.

But now that you have seen how these commands work, it might be more clear what the run protocol file does. The run protocol is the file which actually utilizes these commands to send the patterns, functions, and other parameters saved in your experiment to the panels. You could create your own run protocol if you wanted to change how or when any given condition in your experiment is displayed on the panels. Keep in mind, the run protocol is inherently more complicated than the code above because it also needs to pass information back to the Conductor to keep the user updated. Additional features, like the streaming feature, add code as well. You'll need to include this code in your custom run protocol for it to work with the Conductor software. 

So let's look at the default run protocol and see what it looks like. Please note that this tutorial uses the simplest protocol. However, if you wanted to create your own run protocol that includes the streaming, block logging, or combined command features, you can.  You'd want to base it off of the provided run protocol that has the features you want to use in your own.

__Warning__: Please do not alter the provided run protocol file. If you would like to create your own run protocol, you may start a new `.m` file, or make a copy of the provided run protocol and alter that.
{:.warning}

# The Default Run Protocol

Open `G4_Display_Tools/G4_Protocol_Designer/run_protocols/G4_default_run_protocol.m` in MATLAB.

The run protocol is a MATLAB function which, unlike most of the G4 Display Tools code, can be replaced with your own function if you so choose. Any run protocol, whether it is a provided one or custom made, must accept two variables as inputs, and return one variable as an output. The first input `runcon` will be the handle to the [G4 Experiment Conductor's](experiment-conductor.md) GUI object to update the progress bar and other GUI elements. The second input `p` is a structure containing all of the experiment parameters you are running. The return variable `success` is a status variable which the Conductor will use to determine if the experiment was successful or if it was interrupted. Scroll down to line 54 in the file to see what these inputs and outputs look like:

```matlab
function [success] = G4_default_run_protocol(runcon, p)  % input should always be 1 or 2 items
```

__Note__: The code shown in this documentation was copied in April 2024 and might not represent the current state of the protocol. For improved readability on the website, some reformatting was applied. If in doubt, refer to the the code in the MATLAB file itself.
{:.info}

__Reminder__: It is strongly suggested that, if you want to make a custom run protocol, you make a copy of our provided protocol and edit it however you choose, rather than writing a new file from scratch. That's because much of the code from our default protocol must be included for the protocol to work.
{:.warning}

For example, lines 56-60 in the `G4_default_run_protocol.m` are necessary code to give the run protocol access to the application items like the progress bar and labels. You also have access to a number of pre-made functions, saved in the Modules folder, which you can use in your custom protocol. By using the provided protocol, you can see and copy how these functions are used, like at line 63, where the function assign_parameters pulls the parameters out of the passed in structure and formats them for easier use. 

## Set up parameters and confirm experiment start

<details closed markdown="block">
<summary>
Click to expand default run protocol lines 54...99
</summary>

```matlab
function [success] = G4_default_run_protocol(runcon, p)%input should always be 1 or 2 items

    if ~isempty(runcon.view)
        progress_bar = runcon.view.progress_bar;
        progress_axes = runcon.view.progress_axes;
        axes_label = runcon.view.axes_label;
    end

    %% Set up parameters
    params = assign_parameters(p);
    if params.inter_type == 1
        ctlr_parameters_intertrial = {params.inter_mode, params.inter_pat, params.inter_gain, ...
            params.inter_offset, params.inter_pos, params.inter_frame_rate, params.inter_frame_ind, ...
            params.active_ao_channels, params.inter_ao_ind};
    else
        ctlr_parameters_intertrial = {};
    end

    %% Open new Panels controller instance
    ctlr = PanelsController();
    ctlr.open(true);

    %% Set root directory to the experiment folder
    ctlr.setRootDirectory(p.experiment_folder);

    %% set active ao channels
    ctlr.setActiveAOChannels(params.active_ao_channels);

    %% confirm start experiment
    if ~isempty(runcon.view)
        start = questdlg('Start Experiment?','Confirm Start','Start','Cancel','Start');
    else
        start = 'Start';
    end

    switch start

        case 'Cancel'
            if isa(ctlr, 'PanelsController')
                ctlr.close();
            end
            clear global;
            success = 0;
            return;

        case 'Start' %The rest of the code to run the experiment goes under this case
```

</details>

This first section of code is less likely to be altered for your custom protocol, but let's go through it briefly just in case. First we check if the GUI exists. You can run an experiment directly from command line with no need for the GUI, so this ensures the same run protocol can be used whether the GUI is present or not. If it is present, it stores the handles to the progress bar, the progress axes, and the axes label into easily used variables.

Next we use the function assign_parameters to pull the parameters out of the provided structure and make them more easily readable. This may seem redundant, but for example, the provided structure's intertrial parameters are saved in a cell array. The mode is intertrial{1}. The frame rate is intertrial{9}. It's not necessarily easy to remember which parameter is which element in the array. In addition, there are a few parameters that need to be calculated from the provided information, like the total number of conditions. We return a struct called params where every parameter is saved in an easily readable variable name for use later on. 

Remember parameters are sent to the controller in a cell array. So after using the assign_parameters function, we combine all the intertrial parameters into a cell array that will be passed to controller when it is time to run the intertrial.  We don't do the pretrial or posttrial here because these are only run once. Therefore, we do it right before they run, assuming they are present. The intertrial, if present, runs many times, so it saves time to format its parameters at the beginning.

Next we open the controller, set the root directory, and set any active AO channels. After that, assumign the GUI is present, we provide a dialog box to the user confirming they want to start the experiment. They have the chance  to cancel here. A switch statement is used and the rest of the code to run the experiment is contained under the "start" case. 

It's recommended you leave this code as it is unless there's a reason  you'd like to change how the parameters are stored. 

## Determine number of trials and experiment duration

Then the run protocol looks at the experiment and determines how many trials will be run in total and how long the experiment should take.  We also update the progress bar's label to refelct the experiment length, and establish a counter to track how far along in the experiment we are as it goes on.

<details closed markdown="block">
<summary>
Click to expand default run protocol around lines 187…200
</summary>

```matlab
%% Determine the total number of trials in order to define in what increments
%the progress bar will progress.-------------------------------------------
total_num_steps = get_total_num_trials(params);

%% Determine how long the experiment will take and update the title of the            %progress bar to reflect it------------------------------------------------
total_time = get_total_experiment_length(params);

%Update the progress bar's label to reflect the expected
%duration.
axes_label.String = "Estimated experiment duration: " + num2str(total_time/60) + " minutes.";

%Will increment this every time a trial is completed to track how far along
%in the experiment we are
num_trial_of_total = 0;

```

</details>

Note that we call separate functions, saved in Modules, called `get_total_num_trials` and `get_total_experiment_length` to do these calculations. These functions assume that no inter-trial is played before the first block trial or after the last block trial of the last repetition. They assume the pre-trial and post-trial are only played once. Were these details to change, the code in thes side functions would also need to be edited.

## Start the log

Line 117-122 checks to see if the pause button has been pressed. If it has, it runs the pause method from the Conductor.  Then we start the data log. If the log fails to start for some reason, we abort the experiment. At line 127 we run `runcon.abort_experiment()`. Usually, this method is run when the user presses the _Abort_{:.gui-btn} button. Running this method in the code is how you press _Abort_{:.gui-btn} programmatically. The following if statement and everything in it is what the protocol uses throughout to check and respond to to the button press.

<details closed markdown="block">
<summary>
Click to expand default run protocol around lines 235…236
</summary>

```matlab
%% Make sure the pause button hasn't been pressed
is_paused = runcon.check_if_paused();
if is_paused
    disp("Experiment is paused. Please press pause button again to continue.");
    runcon.pause();
end

%% Start log, if fails twice, abort------------------------------------
log_started = ctlr.startLog();
if ~log_started
    runcon.abort_experiment();
end
if runcon.check_if_aborted()
    if isa(ctlr, 'PanelsController')
        ctlr.close();
    end
    clear global;
    success = 0;
    return;
end
```

</details>

## Set up and run the pre-trial

The next block of code (lines 138-191) runs the pre-trial if it exists. Click to expand the code below and follow along, or follow along in the file. First we use `tic` to get the start time of the experiment. This variable, `startTime` is what we will use to track how much time has elapsed througout the experiment.  This is set regardless of whether there is a pre-trial. 

Then we have an if statement which will only execute if there is a pre-trial to run. First we use the Conductor's method `update_progress` to update the progress bar. We pass in 'pre' to tell it that we're about to run the pre-trial. We also iterate `num_trial_of_total` which, remember, is how we keep track of how many trials in to the experiment we are. Next we set the controller parameters. Combine them into the cell array as required by the controller, and then pass them along. After the controller is updated, we update the display on the Conductor to reflect the correct condition parameters. This conductor method, `update_current_trial_parameters` requires all inputs shown, in that order. We give a short pause to allow the graphics time to update. Next we run the pre-trial.

An `if` statement at line 159 checks to see if the duration for the pre-trial is set to 0. This is another feature we have in the default run protocol that you may or may not care about. If you set the duration of the pre-trial to 0, this means the pre-trial will run indefinitely until you hit a button to tell it to move on. This is often useful if you don't want to move on with the experiment until your fly has fixated correctly and you don't know exactly how long that will take. Notice, that it will not actually run indefinitely. If the pretrial duration is 0, we pass 200 seconds in as the duration. The length duration you can pass to the panels with your `startDisplay` command is actually limited. Also note that we pass a second parameter into startDisplay. This sets the waitForEnd parameter to 'false'. This tells the startDisplay command that instead of waiting until the trial is over, we should continue running subsequent code immediately, while the condition is running. This way, the `waitforbuttonpress` command will execute right away and the user can press a button when they are ready for the experiment to continue.

The code following this will be used after every condition. We check to see if the abort button has been pressed, we check to see if the pause button has been pressed, and then we run the Conductor method `update_elapsed_time`. We pass into this the amount of time that has passed so far, rounded to 2 digist. We get this with the toc command, and pass in our startTime variable, which gives us the time elapsed since we created startTime. You must include this code as well if you want the GUI to work as expected. 

<details closed markdown="block">
<summary>
Click to expand default run protocol around lines 240…288
</summary>

```matlab
%% run pretrial if it exists----------------------------------------
startTime = tic;
if params.pre_start == 1
    %First update the progress bar to show pretrial is running----
    runcon.update_progress('pre');
    num_trial_of_total = num_trial_of_total + 1;

    %Set the panel values appropriately----------------
    ctlr_parameters_pretrial = {params.pre_mode, params.pre_pat, params.pre_gain, ...
        params.pre_offset, params.pre_pos, params.pre_frame_rate, params.pre_frame_ind, ...
        params.active_ao_channels, params.pre_ao_ind};
    ctlr.setControllerParameters(ctlr_parameters_pretrial);

    %Update status panel to show current parameters
    runcon.update_current_trial_parameters(params.pre_mode, params.pre_pat, ...
        params.pre_pos, p.active_ao_channels, params.pre_ao_ind, ...
        params.pre_frame_ind, params.pre_frame_rate, params.pre_gain, ...
        params.pre_offset, params.pre_dur);
    pause(0.01);

    %Run pretrial on screen
    if params.pre_dur ~= 0
        ctlr.startDisplay(params.pre_dur*10); %Panelcom usually did the *10 for us. Controller expects time in deciseconds
    else
        ctlr.startDisplay(2000, false); %second input, waitForEnd, equals false so code will continue executing
        w = waitforbuttonpress; %If pretrial duration is set to zero, this
        %causes it to loop until you press a button.
    end
end

% Turn off AO functions if there are any
% for i = 1:length(p.active_ao_channels)
%     self.setAOFunctionID(p.active_ao_channels(i), 0);
% end

if runcon.check_if_aborted()
   ctlr.stopDisplay();
   ctlr.stopLog('showTimeoutMessage', true);
   if isa(ctlr, 'PanelsController')
       ctlr.close();
   end
   clear global;
   success = 0;
   return;
end

is_paused = runcon.check_if_paused();
if is_paused
    ctlr.stopLog();
    disp("Experiment is paused. Please press pause button again to continue.");
    runcon.pause()
    ctlr.startLog();
end
runcon.update_elapsed_time(round(toc(startTime),2));
```

</details>

## Run the conditions

Lines 194-296 contain the main loop which runs your set of block trials. "Conditions" refer to each condition in the block as created in the Designer. Repetitions refers to the number of times the entire block is repeated. Each instance of the loop runs one condition and one inter-trial, except the last iteration which does not run an inter-trial. I'll go through the code in detail and you can follow along below or in the file.

This code is contained in two nested for loops. The outer loop goes through each repetition, and the inner loop cycles through each condition in a repetition. 

The first line uses `p.exp_order`, which is an array containing the order in which conditions are run, to find out which condition we are about to run and stores the number in the variable `cond`. This is necessary in case conditions are randomized. 

Next we update the progress bar as we did before the pre-trial, and iterate the number trial we are on.

Unlike the pre-trial, the parameters will change with each iteration of our loop, so next we define the parameters for this particular condition. We use the function, found in Modules, called `assign_block_trial_parameters` and it takes three inputs - `params`, `p`, and `cond`. It returns a struct called `tparams` containing this condition's parameters. These are then put into a cell array as expected by the controller, and passed to the controller. The Conductor's display is then updated with the current parameters. 

Next we use the startDisplay command to run the condition, and then, as usual, check to see if the experiment has been aborted or paused, and update the elapsed time. 

The next lines tell the loop to continue, or skip the rest of the loop, if it is the last trial of the last repetition. This way, there is no inter-trial between the last condition and the post-trial. If you wanted an inter-trial here, you could remove this if statement.

The next line is a new if statement which runs an inter-trial assuming the experiment contains an inter-trial. The inter-trial progresses much the same as the block condition did. One difference can be found at line 262, after the progress bar update. One feature of the intertrial is that the user can set the frame index to 0. If it is set to 0, this means the frame index will be randomized each time the inter-trial is run. So we have an if statement which chooses a random frame from the intertrial's pattern and setting the index frame parameter accordingly. 

After that, the controller and display parameters are update as usual  and the startDisplay command is sent. We then, again, check for abort or pause button presses and update the elapsed time.  

<details closed markdown="block">
<summary>
Click to expand default run protocol around lines 194...296.
</summary>

```matlab
%% Loop to run the block/inter trials --------------------------------------
for r = 1:params.reps
    for c = 1:params.num_cond
        %define which condition we're using
        cond = p.exp_order(r,c);

        %Update the progress bar--------------------------
        num_trial_of_total = num_trial_of_total + 1;
        runcon.update_progress('block', r, params.reps, c, params.num_cond, cond, num_trial_of_total);

        %define parameters for this trial----------------
        tparams = assign_block_trial_parameters(params, p, cond);

        %Update controller-----------------------------
        ctlr_parameters = {tparams.trial_mode, tparams.pat_id, tparams.gain, ...
            tparams.offset, tparams.pos_id, tparams.frame_rate, tparams.frame_ind...
            params.active_ao_channels, tparams.trial_ao_indices};

        ctlr.setControllerParameters(ctlr_parameters);

        pause(0.01)

        %Update status panel to show current parameters
        runcon.update_current_trial_parameters(tparams.trial_mode, ...
            tparams.pat_id, tparams.pos_id, p.active_ao_channels, ...
            tparams.trial_ao_indices, tparams.frame_ind, tparams.frame_rate, ...
            tparams.gain, tparams.offset, tparams.dur);

        %Run block trial--------------------------------------
        ctlr.startDisplay(tparams.dur*10); %duration expected in 100ms units

        isAborted = runcon.check_if_aborted();
        if isAborted == 1
            ctlr.stopDisplay();
            ctlr.stopLog('showTimeoutMessage', true);
            if isa(ctlr, 'PanelsController')
                ctlr.close();
            end
            clear global;
            success = 0;
            return;

        end

        is_paused = runcon.check_if_paused();
        if is_paused
            ctlr.stopLog();
            disp("Experiment is paused. Please press pause button again to continue.");
            runcon.pause()
            ctlr.startLog();
        end

        runcon.update_elapsed_time(round(toc(startTime),2));

        %Tells loop to skip the intertrial if this is the last iteration of the last rep
        if r == params.reps && c == params.num_cond
            continue
        end

        %Run inter-trial assuming there is one-------------------------
        if params.inter_type == 1
            %Update progress bar to indicate start of inter-trial
            num_trial_of_total = num_trial_of_total + 1;
            runcon.update_progress('inter', r, params.reps, c, params.num_cond, num_trial_of_total)
            if params.inter_frame_ind == 0
                inter_frame_ind = randperm(p.num_intertrial_frames,1);
                ctlr_parameters_intertrial{7} = inter_frame_ind;
            end

            ctlr.setControllerParameters(ctlr_parameters_intertrial);

            %Update status panel to show current parameters
            runcon.update_current_trial_parameters(params.inter_mode, ...
                params.inter_pat, params.inter_pos, p.active_ao_channels, ...
                params.inter_ao_ind, params.inter_frame_ind, params.inter_frame_rate,...
                params.inter_gain, params.inter_offset, params.inter_dur);

            pause(0.01);

            %Run intertrial-------------------------
            ctlr.startDisplay(params.inter_dur*10);

            if runcon.check_if_aborted() == 1
                ctlr.stopDisplay();
                ctlr.stopLog('showTimeoutMessage', true);
                if isa(ctlr, 'PanelsController')
                    ctlr.close();
                end
                clear global;
                success = 0;
                return;
            end
            runcon.update_elapsed_time(round(toc(startTime),2));
        end
    end
end
```

</details>

## Run Post-Trial

Lines 481-536 run the post-trial if there is one.

<details closed markdown="block">
<summary>
Click to expand default run protocol around lines 481…554.
</summary>

```matlab

% FIXME: old code example, not working anymore.
if post_type == 1
    
    %Update progress bar--------------------------
    num_trial_of_total = num_trial_of_total + 1;
    runcon.update_progress('post', num_trial_of_total);
     Panel_com('set_control_mode', post_mode);
     
     Panel_com('set_pattern_id', post_pat);
     
     if ~isempty(post_gain)
         Panel_com('set_gain_bias', [post_gain, post_offset]);
     end
     if post_pos ~= 0
         Panel_com('set_pattern_func_id', post_pos);
         
     end
     if post_mode == 2
         Panel_com('set_frame_rate', post_frame_rate);
     end
     if post_frame_ind == 0
         post_frame_ind = randperm(p.num_posttrial_frames, 1);
     end
         
     Panel_com('set_position_x',post_frame_ind);
     
     for i = 1:length(post_ao_ind)
         if post_ao_ind(i) ~= 0 %if it is zero, there was no ao function for this channel
             Panel_com('set_ao_function_id',...
               [p.active_ao_channels(i), post_ao_ind(i)]);
               %[channel number, index of ao func]
             
         end
     end
     
     %Update status panel to show current parameters
     runcon.update_current_trial_parameters(post_mode, ...
        post_pat, post_pos, ...
        p.active_ao_channels, ...
        post_ao_ind, post_frame_ind, ...
        post_frame_rate, ...
        post_gain, post_offset, post_dur);
    
     Panel_com('start_display',post_dur+2);
     pause(post_dur);
     
     if runcon.check_if_aborted() == 1
        Panel_com('stop_display');
        pause(.1);
        Panel_com('stop_log');
        pause(1);
        % FIXME: deprecated
        disconnectHost;
        success = 0;
        return;
     
     end
     runcon.update_elapsed_time(round(toc,2));
     
end
Panel_com('stop_display');

pause(1);
%Panel_com('stop_log');
stop_log_response = send_tcp( char([1 hex2dec('40')]), 1);
if stop_log_response.success == 1
    waitfor(errordlg("Stop Log command failed, please stop log manually then hit a key"));
    waitforbuttonpress;
end
pause(1);     
% FIXME: deprecated     
disconnectHost;

pause(1);
success = 1;
```

</details>

Notice that in the line starting with `stop_log_response`, instead of using the `stop_log` command, the default run protocol uses `send_tcp` directly. This is because a common problem has been that the `stop_log` command does not go through due to some back-up with the panels, and then the Conductor can not do its job of moving the data files to where they need to go, because the log is still running. We've done this so that if the stop log command fails, we can allow the user to stop the log manually before moving on.

# Run Protocol Requirements

So now that you've seen how our run protocol is structured, you can probably tell where, if anywhere, you might want to make changes. But whatever changes you make, remember that these things MUST be done in the run protocol:

- It must take in two variables, and assign its parameters from those variables as happens in the first 160 lines or so of this file.
- You must include a pause after `connectHost`, `start_log`, `start_display`, `stop_display`, `stop_log`, and `disconnectHost` commands. The pause after `start_display` must equal or be slightly longer than the duration of the trial. The rest should just be a small pause as these commands sometimes take a few hundred milliseconds to carry out. We use 1 second as default.
- If you want the conductor to be updated, you must use its built in functions the same way they are used in this file. Some require variables be passed in. These functions include:
  - `update_elapsed_time` - updates the elapsed time shown on the Conductor. Takes in one argument, a number.
  - `update_progress` - updates text above the progress bar. Takes in several variables, see line 417 for an example. Note the lines following this function (lines 417-421) must all be run to display this update on the Conductor.
  - `update_current_trial_parameters` - The conductor shows the parameters (pattern id, function id, mode, etc) of any given trial as it runs. This updates the conductor to show the current trial. You must pass in all the parameters for that condtion. (See line 456 for an example)
  - `check_if_aborted` - checks if the _Abort_{:.gui-btn} button has been clicked, returns 0 for no, 1 for yes.
- You must remember to `stop_display`, `stop_log`, and `disconnectHost` at the end of the file.
