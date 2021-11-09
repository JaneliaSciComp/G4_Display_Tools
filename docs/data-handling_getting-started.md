---
title: Data Handling Overview
parent: Getting Started
nav: 5
---

# Handling data from a G4 experiment

So you've run an experiment on the G4 system but you didn't set up any automatic data processing or analysis. Here's what to expect.

When an experiment finishes, your experiment folder will contain a new folder, named by the date, i.e. `09_25_20`.  All flies run through this particular protocol on this date will end up inside this folder. Each fly's results will be contained in a folder named by the fly name. So your experiment folder organization will look something like this:

```sh
[Experiment name]
├── Patterns
├── Functions
├── [.g4p file]
└── [date folder]
    ├── fly1
    ├── fly2
    └── fly3
        ├── [timestamped folder with raw data]
        ├── G4_TDMS_Logs_[timestamp].mat
        ├── exp_order.mat
        └──metadata.mat
```

In the fly's folder, there will be a folder named with a timestamp. Inside are a set of `*.tdms` files. [TDMS (Technical Data Management Solution)](https://www.ni.com/en-us/support/documentation/supplemental/06/the-ni-tdms-file-format.html) is a file type created by National Instruments and it generally takes some kind of special software to view them. Therefore, we have provided a function called `G4_TDMS_folder2struct.m` which will run automatically at the end of an experiment. This produces a `.mat` file called `G4_TDMS_Logs_[timestamp].mat`. It contains the raw data from the `.tdms` files, but in a format easy to open and navigate in MATLAB. This `.mat` file contains a structure called Log. The structure looks like this:

```sh
Log
├── ADC
│   ├── Time
│   ├── Volts
│   └── Channels
├── AO
│   ├── Time
│   ├── Volts
│   └── Channels
├── Frames
│   ├── Time
│   └── Position
└── Commands
    ├── Time
    ├── Name
    └── Data
```

The ADC field holds a time vector for each channel which simply acts as a clock, with the time recorded every 10 milliseconds. It also holds a Volts vector for each channel which gives the actual fly position data, and then a channels array which gives you the names of each recorded channel. This is your raw fly data that you're likely interested in.

The AO field holds the same data as the ADC field, but for analog output channels. Often, these may not be in use and the data may be empty.

The Frames field holds two vectors, time and position. The time vector is the same as the one in ADC. The position vector refers to the position of the pattern on the screen. This data is useful in debugging. If you have reason to suspect a screen malfunction, you can use this data to see exactly what the pattern on the screen was doing at any given time.

Finally, the Commands field contains three arrays, Time, Name, and Data. This keeps track of what commands were sent to the screens and when. They should be the same size and align, so the first element of each gives you the time the first command was sent, the name of the command, and any inputs that were passed along with the command. This also can be useful for debugging.

At the end of an experiment, you should also find a `metadata.mat` file and `exp_order.mat` file in your fly's folder. These just preserve important information like your metadata and the order in which trials were run if they were randomized, so that you can go back and reference them if you ever need.

It takes a little bit of work to parse these raw vectors in the Log `struct` into meaningful datasets, so we have done this for you. This process is what I refer to as "data processing." While at this point, you have a `.mat` file and could write any code you like to parse this data, we have created a data processing tool to make this easier.

## How to set up automatic data processing

Please see the [G4 Data Analysis section](data-handling_analysis.md) for an introduction to the data processing tools and detailed tutorials on how to use it. Here I will give you a general idea of what's required.

You will access a file we have provided called create_processing_settings.m. This file contains many different parameters, which is covered in detail in the [G4 Data Analysis section](data-handling_analysis.md). Essentially, you will provide information such as file name and save locations, information pertaining to the structure of your experiment, information pertaining to channels you used and datatypes you'd like to analyze, and provide parameters for normalization and error checking. When you have your settings the way you want them, you can run the file and it will create a .mat file wherever you specified. This .mat file contains your processing settings, and I will refer to it from now on as your "processing settings file." It is suggested that you save it in your experiment folder, so that if you come back to that experiment months or years later, you can see exactly how its data was processed.

If you want the G4 Conductor to run this processing automatically, all you need to do is check the *Processing*{:.gui-txt} box and then provide the path to the processing settings file you created. However, if you did not process the data automatically, you can always run this processing on your own later. To do this, you would run the command `process_data('path to fly folder', 'path to settings file')` in your MATLAB command window.

This processing tool uses the tdms log .mat file to align the raw data and divide it into its appropriate trials, repetitions, and datatypes. It will create a new .mat file with many variables in it, but the basic data will be processed into a cell array of size {number datatypes × number trials per repetition × number of repetitions × data points per trial}. Several other datasets will be produced from this basic dataset depending on your settings.

## After the data is processed into datasets, what do you do with it?

The ways in which you might want to analyze your data could vary widely depending on your experiment, but we have provided an automated way of performing some basic analyses that are relevant in our lab. If you plan to do any of the following analyses on your data, consider using our data analysis tools. Like the processing, this can be run automatically after an experiment is finished as long as you configure your settings ahead of time. You can also use these tools to analyze many flies, or many groups of flies, at once and compare them.

The analyses included in this tools are:

- Histograms of the fly position data
- Fly position plotting as timeseries
- Tuning curves comparing a changing aspect between trials (like if you have four trials that are the same other than the frequency at which the pattern is displayed)
- Histograms of closed-loop data
- Position series plots (Similar to timeseries but adjusted so the fly's position data is plotted against the position of the pattern instead of time. Only relevant for certain types of stimulus)
- A comparison plot which creates numerous of the above plots side by side for each trial for easy comparison.

If you'd like to set this up to run automatically, please see the detailed instructions in [G4 Data Analysis](data-handling_analysis.md). Here's a general run down.

The first thing you will do, much like the data processing set, is open the file DA_plot_settings.m.  You will notice that this settings file is far longer than the processing settings file. It will take a while to get used to the plethora of options here, so I highly recommend following the [data analysis documentation](data-handling_analysis.md) the first time you set this up. There is currently an application with a user interface in development to replace this file, to make it easier for you to configure your data analysis settings, and it will be included with future releases.

This settings file will allow you to do everything from setting the colors, fonts, and other aesthetic plot options, determining the layout of subplots on your figures, providing labels and alternate axis scales, and much more. You can also set a save location for a data analysis report, which will be provided at the end of the analysis.

Once your settings file is as you want it, you will run the function create_settings_file in your MATLAB command window. It takes two inputs - the name that you want to give your settings file, and the path where you want to save it. So the command looks like this: `create_settings_file('name of file', 'path to file')`.

It's important to note that your experiment folder must follow a certain structure for this to work. If you have changed the organization of your experiment folder from the way it was produced by the G4 Protocol Designer, then you should become familiar with the organization requirements. The data analysis settings allows you to provide information which will let the software automatically pull data for flies you are interested in. For example, you can tell it that you want all flies of genotype1 and run by one experimenter in one group, and all flies of that same genotype but run by a different experimenter in a second group. Then your data analysis would be comparing flies of the same genotype run by two different experimenters. However, this sorting behavior requires that your experiment structure be set up in this general structure:

```sh
[Protocol Folder]
├── [date folder]
├── [date folder]
└── [date folder]
    ├── [fly1 folder]
    ├── [fly2 folder]
    └── [fly3 folder
```

The protocol folder refers to the folder which contains your .g4p file as well as an pattern or function folders. Inside the protocol folder should be some subfolders which organize your flies in some way. In our case, we create a folder for each date. That folder then contains the results of all flies run on that date. But these could be by genotype or any other organizational scheme. The important thing is that each individual fly folder, which contains that fly's results, are two levels below the protocol folder, as shown here.

To have the Conductor then run this data analysis automatically, simply check the "Plotting" checkbox and provide a path to the settings file you've just created. If you want to run it yourself, later, you will run a command from the MATLAB command window that looks like this:

```matlab
da = create_data_analysis_tool('path to settings file', -flags)
da.run_analysis
```

The flags that you pass in tell the data analysis tool which analysis types to run. The settings file contains settings for ALL analysis types, but if you are only interested in timeseries plots for the time being, you would run `create_data_analysis_tool('settings path', '-group', '-tsplot')` and it would only spit out timeseries plots. This way, you aren't be inundated with plots you may not need at the moment. Possible flags include:

- `'-hist'` for a histogram of the fly data
- `'-clhist'` for a histogram of closed-loop data
- `'-tsplot'` for timeseries plots
- `'-tcplot'` for tuning curves
- `'-posplot'` for position series plots
- `'-compplot'` for comparison plots
- `'-single'` if you are only analyzing a single fly's data
- `'-group'` if you are analyzing a group of files or multiple groups of flies

You MUST provide the `'-single'` or `'-group'` flag along with at least one other. Capitalization does not affect the flags, but you must include the dash and single quotes.

This will produce a .pdf file for each figure created, as well as a .pdf report containing all the figures at the path you specified in your settings.

And that's it! Now that you have a general idea of how the system works and the process for creating, running, and processing an experiment, head on down to the Generation 4 menu item to get set up.
