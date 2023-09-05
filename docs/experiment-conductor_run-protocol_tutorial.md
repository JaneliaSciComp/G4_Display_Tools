---
title:  Tutorial - Design your own run protocol
parent: G4 Experiment Conductor
grand_parent: Generation 4
nav_order: 1
---

# Prerequisites

- [G4 Setup](software_setup.md)
- have designed at least one pattern using the [Pattern Maker](pattern-generator.md)
- have designed at least one position function using the [Function Generator](function-generator.md)
- Have some basic knowledge of programming in MATLAB

# Introduction

You may have seen references to a __run protocol__ throughout the documentation. This is an `.m` file which sends [the experiment you design](protocol-designer.md) to the panels. It provides a structure and defines details regarding how the experiment is run like, for example, whether to run inter-trials before the first condition. There are three run protocols included with the G4 Display Tools at `G4_Display_Tools/G4_Protocol_Designer/run_protocols`: `G4_default_run_protocol.m`, `G4_default_run_protocol_streaming.m`, and `G4_run_protocol_combinedCommand.m`. The last of these is not ready for use, as it still has uncorrected bugs. The first in the list runs an experiment without streaming back any fly data. The second will return data throughout the experiment to help you monitor your fly. It will also re-schedule any conditions that failed due to your fly not flying at the end of the experiment. You can read about these features in more detail in the [Conductor documentation](experiment-conductor.md).

What you might not know is that you can also write your own run protocol. The potential benefits of doing this will become clear throughout this tutorial, though for most use cases, you won't need one other than the defaults. In this tutorial, we will use `G4_default_run_protocol.m` as our example, so streaming features are not covered here.

- Please note that the run protocol `G4_run_protocol_combinedCommand.m` should not currently be used. It utilizes a new Panel_com command which still has unresolved bugs.

By definition, this tutorial will also show you how to send specific commands to the panels using none of the provided GUIs. This might be useful if you want to display a single pattern on the panels or try running a condition without using the [G4 Designer](protocol-designer.md).

# The Panel_com Wrapper

In the folder `G4_Display_Tools/PControl_Matlab/controller` you'll find a set of `.m` files. Some of these function names may be familiar from the [setup section]({{site.baseurl}}/docs/g4_assembly.html#install-software) in this documentation.

You should not edit any of the files in `G4_Display_Tools/PControl_Matlab/controller`. Changes to any of these files could prevent the G4 system from working properly so please open the files carefully.
{:.error}

Open the file called `Panel_com.m` in MATLAB, which contains a function with a large `switch` statement and many `case` conditions. The TCP connection provided by the [G4 Host LabView Software](software_setup.md) running on the Multi I/O card is wrapped in this function. This means, `Panel_com.m` accepts human readable commands and converts it into the correct TCP code before sending them to the panels. This way, you never have to get into the other files in this folder, and you never have to worry about creating hexadecimal strings or other code the panels will recognize.

While the file `Panel_com.m` contains the most comprehensive reference list of commands, we also have [documentation on the available commands](pcontrol.md). If you refer to the source file make sure __not to edit any code in `Panel_com.m`__. The file contains several `case` statements, each of which represents a command the panels can interpret. For example, the first few commands in this file are [`stop_display`](pcontrol.md#stop_display), [`all_off`](pcontrol.md#all_off), [`all_on`](pcontrol.md#all_on), etc.

Remember in the [software setup](software_setup.md#verify), to verify everything was working correctly, you clicked a button called _All On_{:.gui-txt} in the _Panel Host_{:.gui-txt} GUI? When you clicked it, it used the `all_on` command you see in `Panel_com.m` to send that command to the panels. You can do this same test without the GUI:

In your MATLAB command window, type `connectHost` and hit enter. Assuming your setup is working, the Panel Host GUI should open after a few seconds. Ignore the application and instead, in the MATLAB command window, type `Panel_com('all_on')` and hit _enter_{:.kbd}. You should see all the LEDs in your arena come on, just like they did when you [tested this](software_setup.md#verify) through the Panel Host application. Now type `Panel_com('all_off')` in the MATLAB command window and hit _enter_{:.kbd}. This should turn the LEDs back off.

As you can see, you send commands to the panels generally by typing `Panel_com(command name[, arguments…])` into the MATLAB command window, with the list of argument being optional. If you look in `Panel_com.m` at line 28, you will see that when you submit the `all_on` command, a particular hexadecimal string `FF` is converted to its byte value 255 and sent to the panels via TCP:

```matlab
    % FIXME: old code example. Not working anymore
    case 'all_on'      % set all panels to 0;
        reply = send_tcp( char([1 hex2dec('FF')]));
        % … handling of the return value
```

The benefit of the `Panel_com` wrapper is that you do not have to write this hexadecimal string -- the wrapper does it for you. If the G4 Panel Host implements a new command on the IO card, then this should lead to a new command within the `Panel_com`. In theory, a single `Panel_com` command can also map to several G4 Panel Host commands, as the [`set_ao`](pcontrol.md#set_ao) command demonstrates. In addition to the translation from human-readable commands to TCP/IP byte commands, `Panel_com`  commands also do additional checking. It is therefore strongly encouraged to rely on the `Panel_com` wrapper for your run protocols instead of sending your own TCP/IP commands.

## Running a condition via command window

Now that you know how to send commands to the panels using the MATLAB command window, it becomes clear that you could run a complete experimental condition this way if you knew which commands to use. I'll walk you through this process now. It will be much easier to understand the role of the run protocol once you have run a condition via MATLAB command window.

### Set up experiment folder

You will need an experiment folder containing a pattern and function to follow along. You should have one if you've already completed the [tutorial on how to design a condition](protocol-designer_create-condition_tutorial.md). If you have not done this or cannot find the experiment folder -- [don't panic](https://en.wikipedia.org/wiki/Phrases_from_The_Hitchhiker%27s_Guide_to_the_Galaxy#Don't_Panic), here is a quick reminder how to create a mock experiment folder. Create a new folder with a descriptive name of your choice wherever you can find it. Inside this folder should be two folders -- one called `Patterns` and one called `Functions`. Each of these folders should contain at least one pattern and one function. You can create them by using the [Pattern Generator](pattern-generator.md) and the [Function Generator](function-generator.md). Both files associated with the pattern (`*.pat`) or function (`*.mat`) should be within the respective folder. This next section will not work if you don't have a pattern and a function inside the file structure to send to the panels.

### Connect to the Panel Host

Send a `connectHost` command via the MATLAB command window. This requires the G4 Panel Host application to run and the command connects to the G4 Panel Host -- which is required before sending any other commands via `Panel_com`.

Type the following commands into your MATLAB command window. It is better to send them one at a time rather than to send them all at once. This is because if one of the commands takes some extra time as short as 50ms to run, it can cause the following commands to get queued up and cause unpredictable side effects. Inside our example run protocols we place strategic pauses and checks to avoid the panels commands queueing up, as this can cause the panels to glitch.

### Set root directory

```matlab
Panel_com('change_root_directory', <path to your experiment folder here as a string>)
```

This command tells the panels where it should be looking for whatever files you send it from now on. This is why your functions and patterns must be contained in the same experiment folder. You should pass in the absolute path to your experiment folder as a string. An example from my computer could be:

```matlab
Panel_com('change_root_directory', '/Users/taylorl/Desktop/test_protocol') % on a Mac or:
Panel_com('change_root_directory', 'C:\Users\taylorl\Desktop\test_protocol') % on Windows
```

### Start data logging

```matlab
Panel_com('start_log')
```

You may have noticed on the Panel Host there is a virtual LED labeled _Log running_{:.gui-txt} which is green when a condition or experiment is running and which is dark when it is not. You should always start the log running before running an experiment and only stop the log running when the entire experiment is over. In the [data analysis section](data-handling.md), you'll see that your raw data is contained in the log file. Data is only collected when the log is running. It's good habit to always run the log, even if you are just testing something.

### Set the Display mode

```matlab
Panel_com('set_control_mode',1)
```

This command sets your [display mode](protocol-designer_display-modes.md) and is always required. Remember the panels are capable of running seven different modes. This tutorial uses the first mode as it is simple and often used. In this mode the position function defines the order in which the patterns are displayed. For example, a y-value of 10 for the position function will tell the panels to show the 10th frame of the pattern.

### Set Pattern

```matlab
Panel_com('set_pattern_id',1)
```

This command tells the panels which pattern to use. This command is required for all display modes. Notice that the argument is a number, not a file path. This relies on the the experimental folder set up in a defined way, in this case that there is a file `Patterns/Pattern_0001.pat` inside your root folder. All the software we provide knows and follows this file structure, so if you followed the documentation for the [Pattern Generator](pattern-generator.md) the file will be at the correct location.

It is good practice to name your patterns with their ID number in the name so that they will be ordered correctly in the folder and you don't have to remember the ID for every pattern. For example, when we make a set of patterns for an experiment, they each have a unique ID of 1 through the number of patterns we are making. Their filenames, then, are `Pattern_0001`, `Pattern_0002`, etc with the number in the filename matching the ID number. This way, it is easy to remember which ID number you should be sending to the panels in order to get the pattern that you want.

The arena uses the `.pat` file, which is not human-readable, but if you do not know the ID of your pattern, you can open the `.mat` file associated with that pattern in MATLAB. The structure it contains has an ID field with the ID number.

### Set Function

```matlab
Panel_com('set_pattern_func_id',1)
```

This command works similar to the previous command, but with regard to the position functions instead of patterns. The same naming convention is suggested. This command is not necessary in some display modes, but it is necessary for [mode 1](protocol-designer_display-modes.md#mode-1).

### Start the Display

```matlab
Panel_com('start_display', 3)
```

This command tells the panels to start showing the previously sent information, specifically the mode, pattern, and function. Before you send this command, you must at least set the mode and the pattern id. Other commands are required, or not, depending on which mode you are using. The 3, in this command, is a duration. This tells the panels to display this pattern and function combination for 3 seconds. After that amount of time, it will automatically stop displaying the pattern.

Once your pattern has run and the panels have gone dark again, submit the final command:

### Stop data logging

```matlab
Panel_com('stop_log')
```

It's very important to send the `stop_log` command. Were you to run a real condition this way and forget to stop the log, it would continue running and could disrupt other functions of the Panel Host, not to mention giving you lots of useless extra data and filling up your storage.

### Disconnect from the G4 Panel Host

```matlab
% FIXME: deprecated
disconnectHost
```

When you are done working with the panels, it is important to stop the connection.

# What does this all mean

Keep in mind you never have to use any of these commands. All of this is handled for you by either the Panel Host or the [G4 Experiment Conductor](experiment-conductor.md), and if you are happy with the default run protocol, you should never have to worry about these commands.

But now that you have seen how these commands work, it might be more clear what the run protocol file does. The run protocol is the file which actually utilizes these commands to send the patterns, functions, and other parameters saved in your experiment to the panels. You could create your own run protocol if you wanted to change how or when any given condition in your experiment is displayed on the panels.

So let's look at the default run protocol and see what it controls and what it doesn't. Please note that this tutorial does not use the default streaming protocol. However, if you wanted to create your own run protocol that does collect data as the experiment runs for display on the Conductor, you would want to base your run protocol off of the default streaming run protocol.

__Warning__: Please do not alter the default run protocol file. If you would like to create your own run protocol, you may start a new `.m` file, or make a copy of the default run protocol and alter that.
{:.warning}

# The Default Run Protocol

Open `G4_Display_Tools/G4_Protocol_Designer/run_protocols/G4_default_run_protocol.m` in MATLAB.

The run protocol is a MATLAB function which, unlike most of the G4 Display Tools code, can be replaced with your own function if you so choose. Any run protocol, whether it is our default one or custom made, must accept two variables as inputs, and return one variable as an output. The first input `runcon` is a structure containing all of the experiment parameters you are running. The second input `p` will be the handle to the [G4 Experiment Conductor's](experiment-conductor.md) GUI object to update update the progress bar and other GUI elements. The return variable `success` is a status variable which the Conductor will use to determine if the experiment was successful or if it was interrupted. Scroll down to line 50 in the file to see what these inputs and outputs look like:

```matlab
function [success] = G4_default_run_protocol(runcon, p)  % input should always be 1 or 2 items
```

__Note__: The code shown in this documentation was copied in November 2021 and might not represent the current state of the protocol. For improved readability on the website, some reformatting was applied. If in doubt, refer to the the code in the MATLAB file itself.
{:.info}

__Reminder__: It is strongly suggested that, if you want to make a custom run protocol, you make a copy of our default protocol and edit it however you choose, rather than writing a new file from scratch. That's because much of the code from our default protocol must be included for the default protocol to work.
{:.warning}

For example, lines 53-60 in the `G4_default_run_protocol.m` are necessary code to give the run protocol access to the application items like the progress bar and labels. Lines 63-142 take the structure that was passed in and pull out all the experiment parameters it needs to run. You will not want to cut any of this out, as any given experiment may need all of these parameters.

<details closed markdown="block">
<summary>
Click to expand default run protocol around lines 53…167
</summary>

```matlab
global ctrl;

% fig = runcon.fig;
if ~isempty(runcon.view)
    progress_bar = runcon.view.progress_bar;
    progress_axes = runcon.view.progress_axes;
    axes_label = runcon.view.axes_label;
end

%% Set up parameters 
%pretrial params-----------------------------------------------------
if isempty(p.pretrial{1}) %no need to set up pretrial params
    pre_start = 0;
else %set up pretrial params here
    pre_start = 1;
    pre_mode = p.pretrial{1};
    pre_pat = p.pretrial_pat_index;
    pre_pos = p.pretrial_pos_index;
    pre_ao_ind = p.pretrial_ao_indices;
    if isempty(p.pretrial{8})
        pre_frame_ind = 1;
    elseif strcmp(p.pretrial{8},'r')
        pre_frame_ind = 0; %use this later to randomize
    else
        pre_frame_ind = str2num(p.pretrial{8});
    end
    pre_frame_rate = p.pretrial{9};
    pre_gain = p.pretrial{10};
    pre_offset = p.pretrial{11};
    pre_dur = p.pretrial{12};
end

%intertrial params---------------------------------------------------
if isempty(p.intertrial{1})
    inter_type = 0;%indicates whether or not there is an intertrial
else
    inter_type = 1;
    inter_mode = p.intertrial{1};
    inter_pat = p.intertrial_pat_index;
    inter_pos = p.intertrial_pos_index;
    inter_ao_ind = p.intertrial_ao_indices;
    if isempty(p.intertrial{8})
        inter_frame_ind = 1;
    elseif strcmp(p.intertrial{8},'r')
        inter_frame_ind = 0; %use this later to randomize
    else
        inter_frame_ind = str2num(p.intertrial{8});
    end
    inter_frame_rate = p.intertrial{9};
    inter_gain = p.intertrial{10};
    inter_offset = p.intertrial{11};
    inter_dur = p.intertrial{12};
end

%posttrial params------------------------------------------------------
if isempty(p.posttrial{1})
    post_type = 0;%indicates whether or not there is a posttrial
else
    post_type = 1;
    post_mode = p.posttrial{1};
    post_pat = p.posttrial_pat_index;
    post_pos = p.posttrial_pos_index;
    post_ao_ind = p.posttrial_ao_indices;
    if isempty(p.posttrial{8})
        post_frame_ind = 1;
    elseif strcmp(p.posttrial{8},'r')
        post_frame_ind = 0; %use this later to randomize
    else
        post_frame_ind = str2num(p.posttrial{8});
    end
    post_frame_rate = p.posttrial{9};
    post_gain = p.posttrial{10};
    post_offset = p.posttrial{11};
    post_dur = p.posttrial{12};
end

%define static block trial params (will define the ones that change every
%loop later)--------------------------------------------------------------
block_trials = p.block_trials; 
block_ao_indices = p.block_ao_indices;
reps = p.repetitions;
num_cond = length(block_trials(:,1)); %number of conditions

%% Start host and switch to correct directory
if ~isempty(ctrl)
    if ctrl.isOpen() == 1
       ctrl.close()
    end
end
% FIXME: deprecated
connectHost;
pause(10);
Panel_com('change_root_directory', p.experiment_folder);

%% set active ao channels
% FIXME: this is outdated code
if ~isempty(p.active_ao_channels)
    aobits = 0;
   for bit = p.active_ao_channels
       aobits = bitset(aobits,bit+1); %plus 1 bc aochans are 0-3
   end
   Panel_com('set_active_ao_channels', dec2bin(aobits,4));
end
```

</details>

Around line 170 is where the code starts that you're more likely to be interested in. Start at line 170 and scroll down with me as I explain the code's various steps.

## Confirm to run the experiment

The following code from the default run protocol prompts the user to confirm they want to run the experiment and gives them an option to cancel it. (l169-182)

<details closed markdown="block">
<summary>
Click to expand default run protocol around lines 169…182
</summary>

```matlab
%% confirm start experiment
if ~isempty(runcon.view)
    start = questdlg('Start Experiment?','Confirm Start','Start','Cancel','Start');
else
    start = 'Start';
end
switch start
    case 'Cancel'
        %FIXME: deprecated
        disconnectHost;
        success = 0;
        return;
    case 'Start' 
```

</details>

## Determine number of trials

Then the run protocol looks at the experiment and determines how many trials will be run in total.

<details closed markdown="block">
<summary>
Click to expand default run protocol around lines 187…200
</summary>

```matlab
total_num_steps = 0; 
if pre_start == 1
    total_num_steps = total_num_steps + 1;
end
if inter_type == 1
    total_num_steps = total_num_steps + (reps*num_cond) - 1;
    %Minus 1 because there is no intertrial before the first
    %block trial OR after the last block trial.
end
if post_type == 1
    total_num_steps = total_num_steps + 1;
end
total_num_steps = total_num_steps + (reps*num_cond);
```

</details>

Note that, for the default run protocol no inter-trial is played before the first block trial or after the last block trial. It assumes the pre-trial and post-trial are only played once.

Details like this could change the experiment slightly, so if you wanted to do this differently, you would need to change this code. (l187-200)

## Calculate experiment duration

Then it calculates how long the experiment will take and updates the progress bar's text. (l205-231)

<details closed markdown="block">
<summary>
Click to expand default run protocol around lines 205…231
</summary>

```matlab
total_time = 0; 
if inter_type == 1
    for i = 1:num_cond
        total_time = total_time + p.block_trials{i,12} + inter_dur;
    end
    total_time = (total_time * reps) - inter_dur; 
    % bc no inter-trial before first rep OR after last rep of the block.
else %meaning no inter-trial
    for i = 1:num_cond
        total_time = total_time + p.block_trials{i,12};
    end
    total_time = total_time * reps;
end
if pre_start == 1
    total_time = total_time + pre_dur;
end
if post_type == 1
    total_time = total_time + post_dur;
end

% Update the progress bar's label to reflect the expected
% duration.
axes_label.String = "Estimated experiment duration: " + num2str(total_time/60) + " minutes.";

% Will increment this every time a trial is completed to track how far along 
% in the experiment we are
num_trial_of_total = 0;
```

</details>

## Start the log

Around line 234 we start using [`Panel_com`](pcontrol.md) commands. This is why you must be familiar with them if you want to write your own run protocol. The default run protocol uses this order of operations:

First, start the data logging with `start_log` (l234…236).

<details closed markdown="block">
<summary>
Click to expand default run protocol around lines 235…236
</summary>

```matlab
Panel_com('start_log');
pause(1);
```

</details>

## Set up the pre-trial

If there is a pre-trial, set the mode (`set_control_mode`), pattern (`set_pattern_id`), x position (`set_position_x`), function (`set_pattern_func_id`), gain and bias (`set_gain_bias`), frame rate (`set_frame_rate`), and ao functions (`set_ao_function_id`).

Note that not all of these are used for every pre-trial. Each mode requires a subset of these, but your run protocol needs to always define them so it will work with any mode.

You can see in the top half of this file how these values are taken from the `runcon` experiment structure passed in, which is why you likely want to leave the first 160 lines or so as they are. (l240-288)

<details closed markdown="block">
<summary>
Click to expand default run protocol around lines 240…288
</summary>

```matlab
if pre_start == 1
    %First update the progress bar to show pretrial is running----
    runcon.update_progress('pre');
    num_trial_of_total = num_trial_of_total + 1;
   %Set the panel values appropriately----------------
    Panel_com('set_control_mode',pre_mode);
    if pre_mode == 3 %For some reason, mode 3 specifically screws up the run,...
                     %  making subsequent trials glitch. 
        pause(.1);   %A pause is unnecessary with other modes but seems necessary...
                     %  with mode 3. Will investigate further.
    end
    
    Panel_com('set_pattern_id', pre_pat);
    if pre_mode == 3
        pause(.1);
    end
       
    %randomize frame index if indicated
    if pre_frame_ind == 0
        pre_frame_ind = randperm(p.num_pretrial_frames, 1);
    end
    
    Panel_com('set_position_x',pre_frame_ind);
    if pre_mode == 3
        pause(.1);
    end
    
    if pre_pos ~= 0
        Panel_com('set_pattern_func_id', pre_pos);   
    end

    if ~isempty(pre_gain) %this assumes you'll never have gain without offset
        Panel_com('set_gain_bias', [pre_gain, pre_offset]);
    end

    if pre_mode == 2
        Panel_com('set_frame_rate', pre_frame_rate);
    end

    for i = 1:length(pre_ao_ind)
        if pre_ao_ind(i) ~= 0 %if it is zero, there was no ao function for this channel
            Panel_com('set_ao_function_id',...
              [p.active_ao_channels(i), pre_ao_ind(i)]);
                %[channel number, index of ao func]
        end
    end
```

</details>

## Update the Experiment Conductor GUI

Once the parameters are all set, line 291 runs a function that belongs to the [G4 Experiment Conductor](experiment-conductor.md). This function updates the data being displayed on the G4 Experiment Conductor window regarding which trial is being displayed. You can use this function in your own run protocols, but you must call it exactly as it is called here and pass in the correct variables. In our case, `runcon` is the handle to the G4 Experiment Conductor which was passed in at the beginning of the file, but you could name this anything you want in your own run protocol.

<details closed markdown="block">
<summary>
Click to expand default run protocol around lines 291…294.
</summary>

```matlab
runcon.update_current_trial_parameters(pre_mode, pre_pat, pre_pos, p.active_ao_channels, ...
   pre_ao_ind, pre_frame_ind, pre_frame_rate, pre_gain, pre_offset, pre_dur);
pause(0.01);
```

</details>

## Repetition of pre-trials

An `if` statement at line 297 checks to see if the duration for the pre-trial is set to 0. This is another feature we have in the default run protocol that you may or may not care about. If you set the duration of the pre-trial to 0, this means the pre-trial will run indefinitely until you hit a button to tell it to move on. This is often useful if you don't want to move on with the experiment until your fly has fixated correctly and you don't know exactly how long that will take. Notice, that it will not actually run indefinitely. If the pretrial duration is 0, we pass 2000 seconds to the `Panel_com` as the duration. The length duration you can pass to the panels with your `start_display` command is actually limited. (297-304)

<details closed markdown="block">
<summary>
Click to expand default run protocol around lines 297…304.
</summary>

```matlab
if pre_dur ~= 0
   Panel_com('start_display', pre_dur+2);
   pause(pre_dur + .01);
else
    Panel_com('start_display', 2000);
    w = waitforbuttonpress; %If pretrial duration is set to zero, this
    %causes it to loop until you press a button.
end
```

</details>

Notice that after a `start_display` command is sent to `Panel_com`, we then put a `pause` directly after it which lasts for the duration of the trial plus one hundredth of a second. If you do not do this, your run protocol code will continue running while the trial you just displayed is still displaying on the panels. This is bad because it will start trying to set the parameters for the next trial while the previous one is still running, which will cause the panels to back up and get glitchy. If you write your own protocol, you must remember to include these pauses.

## Interactions with G4 Experiment Conductor

Another two functions from our [G4 Experiment Conductor](experiment-conductor.md) are called at lines 307 and 318. The first, called `check_if_aborted`, must be included in any of your run protocols if you want the _Abort_{:.gui-btn} button the G4 Experiment Conductor to work. In our run protocol, it checks if the _Abort_{:.gui-btn} button has been clicked at the end of every trial.

At line 318, the elapsed time displayed on the Conductor is updated. This also is done at the end of every trial.

<details closed markdown="block">
<summary>
Click to expand default run protocol around lines 307…318.
</summary>

```matlab
if runcon.check_if_aborted()
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
```

</details>

## Run the conditions

Lines 323-478 contain the main loop which runs your set of block trials. "Conditions" refer to each condition in the block as created in the Designer. Repetitions refers to the number of times the entire block is repeated. Each instance of the loop runs one condition and one inter-trial, except the last iteration which does not run an inter-trial.

<details closed markdown="block">
<summary>
Click to expand default run protocol around lines 323…478.
</summary>

```matlab
for r = 1:reps
    for c = 1:num_cond
       %define which condition we're using
       cond = p.exp_order(r,c);
       
       %Update the progress bar--------------------------
       num_trial_of_total = num_trial_of_total + 1;
       runcon.update_progress('block', r, reps, c, num_cond, cond, num_trial_of_total);
       
       %define parameters for this trial----------------
       trial_mode = block_trials{cond,1};
       pat_id = p.block_pat_indices(cond);
       pos_id = p.block_pos_indices(cond);
       if length(block_ao_indices) >= cond
           trial_ao_indices = block_ao_indices(cond,:);
       else
           trial_ao_indices = [];
       end
       %Set frame index
       if isempty(block_trials{cond,8})
           frame_ind = 1;
       elseif strcmp(block_trials{cond,8},'r')
           frame_ind = 0; %use this later to randomize
       else
          frame_ind = str2num(block_trials{cond,8});
       end
        
       frame_rate = block_trials{cond, 9};
       gain = block_trials{cond, 10};
       offset = block_trials{cond, 11};
       dur = block_trials{cond, 12};
        
       %Update panel_com-----------------------------
       Panel_com('set_control_mode', trial_mode)
       
       Panel_com('set_pattern_id', pat_id)
       
       if ~isempty(block_trials{cond,10})
           Panel_com('set_gain_bias', [gain, offset]);
       end
       if pos_id ~= 0
           Panel_com('set_pattern_func_id', pos_id)
       end
       if trial_mode == 2
           Panel_com('set_frame_rate',frame_rate);
       end
       
       if frame_ind == 0
           frame_ind = randperm(p.num_block_frames(c),1);
       end
       Panel_com('set_position_x', frame_ind);
       
       for i = 1:length(p.active_ao_channels)
           Panel_com('set_ao_function_id',[p.active_ao_channels(i), trial_ao_indices(i)]);
       end
       
       %Update status panel to show current parameters
      runcon.update_current_trial_parameters(trial_mode, pat_id, pos_id, p.active_ao_channels, ...
         trial_ao_indices, frame_ind, frame_rate, gain, offset, dur);
       pause(0.01)
       
       %Run block trial--------------------------------------
       Panel_com('start_display', dur+2); %duration expected in 100ms units
       pause(dur + .01)
       isAborted = runcon.check_if_aborted();
       if isAborted == 1
           Panel_com('stop_display');
           Panel_com('stop_log');
           pause(1);
           % FIXME: deprecated
           disconnectHost;
           success = 0;
           return;
       end
       runcon.update_elapsed_time(round(toc,2));
       
       %Tells loop to skip the intertrial if this is the last iteration of the last rep
       if r == reps && c == num_cond
           continue 
       end
       
       %Run inter-trial assuming there is one-------------------------
       if inter_type == 1
           %Update progress bar to indicate start of inter-trial
           num_trial_of_total = num_trial_of_total + 1;
           runcon.update_progress('inter', r, reps, c, num_cond, num_trial_of_total)
           progress_axes.Title.String = "Rep " + r + " of " + reps +...
               ", Trial " + c + " of " + num_cond + ". Inter-trial running...";
           progress_bar.YData = num_trial_of_total/total_num_steps;
           drawnow;

           %Run intertrial-------------------------
           Panel_com('set_control_mode',inter_mode);
           Panel_com('set_pattern_id', inter_pat);
          
           %randomize frame index if indicated
           if inter_frame_ind == 0
               inter_frame_ind = randperm(p.num_intertrial_frames, 1);
           end
           Panel_com('set_position_x',inter_frame_ind);
           
           if inter_pos ~= 0
               Panel_com('set_pattern_func_id', inter_pos);
           end
            if ~isempty(inter_gain) %this assumes you'll never have gain without offset
                Panel_com('set_gain_bias', [inter_gain, inter_offset]);
            end
            if inter_mode == 2
                Panel_com('set_frame_rate', inter_frame_rate);
            end
            for i = 1:length(inter_ao_ind)
                %if it is zero, there was no ao function for this channel
                if inter_ao_ind(i) ~= 0 
                    Panel_com('set_ao_function_id',...
                      [p.active_ao_channels(i), inter_ao_ind(i)]);
                      %[channel number, index of ao func]
                end
            end
            
           % Update status panel to show current parameters
           runcon.update_current_trial_parameters(inter_mode,...
              inter_pat, inter_pos, ...
              p.active_ao_channels, ...
              inter_ao_ind, inter_frame_ind, ...
              inter_frame_rate, inter_gain, ...
              inter_offset, inter_dur);
           
            pause(0.01);
            Panel_com('start_display', inter_dur+2);
            pause(inter_dur + .01);
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
