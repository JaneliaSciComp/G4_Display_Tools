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

You may have seen references to a __run protocol__ throughout the documentation. This is an `.m` file which sends [the experiment you design](protocol-designer.md) to the panels. It provides a structure and defines, for example, whether to run inter-trials before the first trial. There are three run protocols included with the G4 Display Tools at `G4_Display_Tools/G4_Protocol_Designer/run_protocols`: `G4_default_run_protocol.m`, `G4_default_run_protocol_streaming.m`, and `G4_run_protocol_combinedCommand.m` -- but you can also write your own run protocol. The potential benefits of doing this will become clear throughout this tutorial, though for many use cases, you won't need one other than the default `G4_default_run_protocol.m`.

By definition, this tutorial will also show you how to send specific commands to the panels using none of the provided GUIs. This might be useful if you want to display a single pattern on the panels or try running a condition without using the [G4 Designer](protocol-designer.md).

# The Panel_com Wrapper

In the folder `G4_Display_Tools/PControl_Matlab/controller` you'll find a set of `.m` files. Some of these function names may be familiar from the [setup section]({{site.baseurl}}/docs/g4_assembly.html#install-software) in this documentation.

You should not edit any of the files in `G4_Display_Tools/PControl_Matlab/controller`. Changes to any of these files could prevent the G4 system from working properly so please open the files carefully.
{:.error}

Open the file called `Panel_com.m` in MATLAB, which contains a function with a large `switch` statement and many `case` conditions. The TCP connection provided by the [G4 Host LabView Software](software_setup.md) running on the Multi I/O card is wrapped in this function. This means, `Panel_com.m` accepts human readable commands and converts it into the correct TCP code before sending them to the panels. This way, you never have to get into the other files in this folder, and you never have to worry about creating hexadecimal strings or other code the panels will recognize.

While the file `Panel_com.m` contains the most comprehensive reference list of commands, we also have [documentation on the available commands](pcontrol.md). If you refer to the source file make sure __not to edit any code in `Panel_com.m`__. The file contains several `case` statements, each of which represents a command the panels can interpret. For example, the first few commands in this file are [`stop_display`](pcontrol.md#stop_display), [`all_off`](pcontrol.md#all_off), [`all_on`](pcontrol.md#all_on), etc.

Remember in the [software setup](software_setup.md#verify), to verify everything was working correctly, you clicked a button called *All On*{:.gui-txt} in the *Panel Host*{:.gui-txt} GUI? When you clicked it, it used the `all_on` command you see in `Panel_com.m` to send that command to the panels. You can do this same test without the GUI:

In your MATLAB command window, type `connectHost` and hit enter. Assuming your setup is working, the Panel Host GUI should open after a few seconds. Ignore the application and instead, in the MATLAB command window, type `Panel_com('all_on')` and hit enter. You should see all the LEDs in your arena come on, just like they did when you tested this through the Panel Host application. Now type `Panel_com('all_off')` in the MATLAB command window and hit enter. This should turn the lights back off.

As you can see, you send commands to the panels generally by typing `Panel_com(command name, arguments)` into the MATLAB command window. If you look in `Panel_com.m` at line 28, you will see that when you submit the 'all_on' command, a particular hexadecimal string is sent to the panels via TCP. The benefit of this wrapper is that you do not have to write this hexadecimal string -- the wrapper does it for you. The downside is that you cannot create new commands for the panels on the fly. You can only use the pre-defined commands that are listed in Panel_com.

## Running a condition via command window

Now that you know you can send commands to the panels via MATLAB command window, it becomes clear that you could run an entire condition this way if you knew which commands to use. I'll take you through the steps to do this now. Once you have run a condition via MATLAB command window, it will be much easier to understand the function of the run protocol.

To do this, you will need an experiment folder, or at least a mock experiment folder, containing a pattern and function. If you've already done the tutorial on how to [design a condition](protocol-designer_create-condition_tutorial.md), you should have one, wherever you saved the file in that tutorial. If you've not done this yet, that's okay. Create a test folder on your desktop or somewhere else easily accessible (you can delete it later). Inside this folder should be two folders - one called Patterns and one called Functions. And each of these folders should contain at least one pattern and one function, created using the [Pattern Generator](pattern-generator.md) and the [Function Generator](function-generator.md). Both files associated with the pattern or function, `.mat` and `.pat` files, should be present. This next section will not work if you don't have a pattern and a function to send to the panels.

If you did not send the connectHost command to the panels earlier, do it now. Panel Host must be connected before sending any other commands via Panel_com.

Type the following commands into your MATLAB command window. It is better to send them one at a time rather than to send them all at once. This is because if one of the commands takes an extra 50 ms to run, it can cause the following commands to get backed up. In the run protocol, you will see that we place strategic pauses and checking to avoid the panels commands getting backed up, as this can cause the panels to glitch.

### `Panel_com('change_root_directory', path to your experiment folder here as a string)`

This command tells the panels where it should be looking for whatever files you send it from now on. This is why your functions and patterns must be contained in the same experiment folder. You should pass in the absolute path to your experiment folder as a string. An example from my computer would be:

`Panel_com('change_root_directory', '/Users/taylorl/Desktop/test_protocol')`

### `Panel_com('start_log')`

You may have noticed on the Panel Host there is a virtual LED labeled *Log running*{:.gui-txt} which is green when a condition or experiment is running and which is dark when it is not. You should always start the log running before running an experiment and only stop the log running when the entire experiment is over. In the data analysis section, you'll see that your raw data is contained in the Log. If the log is not running, you will miss data from that time. It's good habit to always run the log, even if you are just testing something.

### `Panel_com('set_control_mode',1)`

This command sets your experiment mode. Remember the panels are capable of running 7 different modes. We are running the first mode in this tutorial as it is simple and often used. It simply runs through the pattern library based on the position function provided it. (i.e., when the y-value of the position function is 10, the panels are displaying the 10th frame in the pattern).

### `Panel_com('set_pattern_id',1)`

This command tells the panels which pattern you want to use. Notice that you do not pass it a filepath, but a number. This is why your experiment folder must be set up the way it is. The software knows automatically to look in the 'Patterns' folder inside your experiment folder. It then find the pattern with an ID of (in this case) 1. You set the pattern's ID in the [Pattern Generator](pattern-generator.md) when you designed the pattern.

It is good practice to name your patterns with their ID number in the name so that they will be ordered correctly in the folder and you don't have to remember the ID for every pattern. For example, when we make a set of patterns for an experiment, they each have a unique ID of 1 through the number of patterns we are making. Their filenames, then, are `Pattern_0001`, `Pattern_0002`, etc with the number in the filename matching the ID number. This way, it is easy to remember which ID number you should be sending to the panels in order to get the pattern that you want.

The arena uses the `.pat` file, which is not human-readable, but if you do not know the ID of your pattern, you can open the `.mat` file associated with that pattern in MATLAB. The structure it contains has an ID field with the ID number.

### `Panel_com('set_pattern_func_id',1)`

This command works exactly the same as the previous command, but with regard to the position functions instead of patterns. The same naming convention is suggested. This command is not necessary in some modes, but it is necessary for mode 1.

### `Panel_com('start_display', 3)`

You can probably guess that this command tells the panels to start displaying the information you have previously send it. Before you send this command, you must at least set the mode and the pattern id. Other commands are required, or not, depending on which mode you are using. The 3, in this command, is a duration. This tells the panels to display this pattern and function combination for 3 seconds. after that amount of time, it will automatically stop displaying the pattern.

Once your pattern has run and the panels have gone dark again, submit the final command:

### `Panel_com('stop_log')`

It's very important to remember the stop_log command. Were you to run a real condition this way and forget to stop the log, it would continue running and could disrupt other functions of the Panel Host, not to mention giving you lots of useless extra data.

Now you can enter the command `disconnectHost` in your MATLAB command window. When you are done with the panels for a while, it is important to remember to do this.

# What does this all mean

Keep in mind you never have to use any of these commands. All of this is handled for you by either the Panel Host or the G4 Experiment Conductor, and if you are happy with the default run protocol, you should never have to worry about these commands.

But now that you have seen how these commands work, it might be more clear what the run protocol file does. The run protocol is the file which actually utilizes these commands to send the patterns, functions, and other parameters saved in your experiment to the panels. You could create your own run protocol if you wanted to change how or when any given condition in your experiment is displayed on the panels.

So let's look at the default run protocol and see what it controls and what it doesn't.

__Warning__: Please do not alter the default run protocol file. If you would like to create your own run protocol, you may start a new `.m` file, or make a copy of the default run protocol and alter that.
{:.warning}

# The Default Run Protocol

Open `G4_Display_Tools/G4_Protocol_Designer/run_protocols/G4_default_run_protocol.m` in MATLAB.

The run protocol is a MATLAB function which, unlike most of the G4 Display Tools code, can be replaced with your own function if you so choose. Any run protocol, whether it is our default one or custom made, must accept two variables as inputs, and return one variable as an output. The first input is a structure containing all of the experiment parameters you are running. The second input will be the handle to the G4 Conductor's user interface, assuming you are using the Conductor. This allows the run protocol to update your progress bar and other application items. The output variable is a success variable which the Conductor will use to determine if the experiment was successful or if it was interrupted. Scroll down to line 50 in the file to see what these inputs and outputs look like.

It is strongly suggested that, if you want to make a custom run protocol, you make a copy of our default protocol and edit it however you choose, rather than writing a new file from scratch. That's because much of the code from our default protocol must be included for the default protocol to work.

For example, lines 53-60 are necessary code to give the run protocol access to the application items like the progress bar and labels. Lines 63-142 take the structure that was passed in and pull out all the experiment parameters it needs to run. You will not want to cut any of this out, as any given experiment may need all of these parameters.

Around line 170 is where the code starts that you're more likely to be interested in. Start at line 170 and scroll down with me as I explain the code's various steps.

- First the code prompts the user to confirm they want to run the experiment and gives them an option to cancel it. (169-182)
- Then the run protocol looks at the experiment and determines how many trials will be run in total. Note that, in our case, we assume no inter-trial is played before the first block trial or after the last block trial. It assumes the pre-trial and post-trial are only played once. Details like this could change the experiment slightly, so if you wanted to do this differently, you would need to change this code. (187-200)
- Then it calculates how long the experiment will take and updates the progress bar's text. (205-231)\\
At line 234 we start using Panel_com commands. This is why you must be familiar with them if you want to write your own run protocol. As the protocol exists now, this is the order of operations:
- Start the log (lines 235-236)
- If there is a pre-trial, set the mode, pattern, x position, function, gain and bias, frame rate, and ao functions. Note that not all of these are used for every pre-trial. Each mode requires a subset of these, but your run protocol needs to always define them so it will work with any mode. You can see in the top half of this file how these values are taken from the experiment structure passed in, which is why you likely want to leave the first 160 lines or so as they are. (24-288)
- Once the parameters are all set, line 291 runs a function that belongs to the G4 conductor. This function updates the data being displayed on the [Conductor](experiment-conductor.md) window regarding which trial is being displayed. You can use this function in your own run protocols, but you must call it exactly as it is called here and pass in the correct variables. In our case, `runcon` is the handle to the G4 Conductor which was passed in at the beginning of the file, but you could name this anything you want in your own run protocol.
- An if statement at line 297 checks to see if the duration for the pre-trial is set to 0. This is another feature we have in our run protocol that you may or may not care about. If you set the duration of the pre-trial to 0, this means the pre-trial will run indefinitely until you hit a button to tell it to move on. This is often useful if you don't want to move on with the experiment until your fly has fixated correctly and you don't know exactly how long that will take. Notice, that it will not actually run indefinitely. If the pretrial duration is 0, we pass 2000 seconds to the panel_com as the duration. The length duration you can pass to the panels with your `start_display` command is actually limited. (297-304)
- Notice that after a `start_display` command is sent to Panel_come, we then put a `pause` directly after it which lasts for the duration of the trial plus one hundredth of a second. If you do not do this, your run protocol code will continue running while the trial you just displayed is still displaying on the panels. This is bad because it will start trying to set the parameters for the next trial while the previous one is still running, which will cause the panels to back up and get glitchy. If you write your own protocol, you must remember to include these pauses.
- Another two functions from our G4 Conductor are called at lines 307 and 318. The first, called check_if_aborted, must be included in any of your run protocols if you want the *Abort*{:.gui-btn} button the Conductor to work. In our run protocol, it checks if the *Abort*{:.gui-btn} button has been clicked at the end of every trial. At line 318, the elapsed time displayed on the Conductor is updated. This also is done at the end of every trial.
- Lines 323-478 contain the main loop which runs your set of block trials. "Conditions" refer to each condition in the block as created in the Designer. Repetitions refers to the number of times the entire block is repeated. Each instance of the loop runs one condition and one inter-trial, except the last iteration which does not run an inter-trial.
- Lines 481-536 run the post-trial if there is one. Notice at line 543, instead of using the `stop_log` command, our run protocol uses `send_tcp` directly. This is because a common problem has been that the `stop_log` command does not go through due to some back-up with the panels, and then the Conductor can not do its job of moving the data files to where they need to go, because the log is still running. We've done this so that if the stop log command fails, we can allow the user to stop the log manually before moving on.

# Run Protocol Requirements

So now that you've seen how our run protocol is structured, you can probably tell where, if anywhere, you might want to make changes. But whatever changes you make, remember that these things MUST be done in the run protocol:

- It must take in two variables, and assign its parameters from those variables as happens in the first 160 lines or so of this file.
- You must include a pause after `connectHost`, `start_log`, `start_display`, `stop_display`, `stop_log`, and `disconnectHost` commands. The pause after `start_display` must equal or be slightly longer than the duration of the trial. The rest should just be a small pause as these commands sometimes take a few hundred milliseconds to carry out. We use 1 second as default.
- If you want the conductor to be updated, you must use its built in functions the same way they are used in this file. Some require variables be passed in. These functions include:
  - `update_elapsed_time` - updates the elapsed time shown on the Conductor. Takes in one argument, a number.
  - `update_progress` - updates text above the progress bar. Takes in several variables, see line 417 for an example. Note the lines following this function (lines 417-421) must all be run to display this update on the Conductor.
  - `update_current_trial_parameters` - The conductor shows the parameters (pattern id, function id, mode, etc) of any given trial as it runs. This updates the conductor to show the current trial. You must pass in all the parameters for that condtion. (See line 456 for an example)
  - `check_if_aborted` - checks if the *Abort*{:.gui-btn} button has been clicked, returns 0 for no, 1 for yes.
- You must remember to `stop_display`, `stop_log`, and `disconnectHost` at the end of the file.
