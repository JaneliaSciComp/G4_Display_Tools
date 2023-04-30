classdef log_model < handle
    %LOGMODEL 
    %% This class takes in an existing, populated Log file to get the correct
    % sizes and data types of for all the different variables in the
    % structure, then creates an empty structure to match and returns it. 
    properties
        Log
    end
    
    methods
        function self = log_model(BaseLog)

            self.Log = struct;

% ADC field

        % Get size of ADC variables

            ADCtimeDim = size(BaseLog.ADC.Time,1);

            self.Log.ADC = struct;
            self.Log.ADC.Time = int64.empty(ADCtimeDim,0);
            self.Log.ADC.Volts = double.empty(ADCtimeDim,0);
            self.Log.ADC.Channels = BaseLog.ADC.Channels;

% AO field
            
            AOtimeDim = size(BaseLog.AO.Time,1);
            self.Log.AO = struct;
            self.Log.AO.Time = int64.empty(AOtimeDim,0);
            self.Log.AO.Volts = double.empty(AOtimeDim,0);
            self.Log.AO.Channels = BaseLog.AO.Channels;

% Frames field
            FramestimeDim = size(BaseLog.Frames.Time,1);
            self.Log.Frames = struct; 
            self.Log.Frames.Time = int64.empty(FramestimeDim,0);
            self.Log.Frames.Position =int16.empty(FramestimeDim,0);

% Commands field

            self.Log.Commands = struct;
            self.Log.Commands.Time = int64.empty(1,0);
            self.Log.Commands.Name = {};
            self.Log.Commands.Data = {};

        end
    end
end

