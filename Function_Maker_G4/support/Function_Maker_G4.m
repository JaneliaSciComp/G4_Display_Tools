function func = Function_Maker_G4(param)
% FUNCTION func = Function_Maker_G4(param)
% 
% Creates a position function (used to control which pattern frame is 
% displayed at every refresh of the LED arena) or an analog output function 
% (controls the voltage set at an analog output of the G4 controller at a 
% rate of 1 kHz) based on the input parameters. The function is created in
% multiple sections, with each section being described by specific
% parameters (e.g. 20 Hz sine wave lasting for 1 second, followed by a 1 Hz
% square wave lasting for 5 seconds.) The index of each parameter array 
% specifies which section it applies to.
% 
% inputs:
% param.type: 'pfn' or 'afn (for position function and analog output function, respectively)
% param.frames: number of frames in the pattern this function will be used with {for position functions only}
% param.gs_val: brightness bits in the pattern this function will be used with {for position functions only}
% param.section: array of section types (static, sawtooth, traingle, sine, cosine, square, or loom)
% param.dur: array of duration (in seconds) of each section of the function
% param.val: array of the static value of the function (either frame or voltage) {for static sections only}
% param.high: array of the high-end of the function {for non-static sections}
% param.low: array of the low-end of the function {for non-static sections}
% param.freq: array of the frequency of the function {for non-static sections}
% param.flip: array of binary values specifying if the sections should be inverted {for non-static sections}
% param.size_speed_ratio: half size to approach speed ratio, in milliseconds {for looming}

func = [];

%determine function type
switch param.type
    case 'afn'
        fps = 1000; %afn rate is always 1 kHz
    case 'pfn'
        fps = 1000/sqrt(param.gs_val); %pfn rate depends on gs_val
        skipped_frames = []; %for position functions, array of skipped frames
        param.high(param.high==0) = param.frames; %for position function, 0's are replaced with maximum frame value
end

%generate function one section at a time
for i=1:length(param.section)
    if strcmp(param.section{i},'static')==0 
        assert(param.high(i)>param.low(i),'function high value must be larger than low value')
    end
    
    
    range = param.high(i)-param.low(i);
    min = param.low(i);
    s = round(param.dur(i)*1000)/1000; %duration in seconds (rounded to nearest ms)
    timepts = 1/(2*fps):1/fps:s-1/(2*fps);
    f = param.freq(i)*2*pi;
    
    switch param.section{i}
        case 'static'
            tmp = repmat(param.val(i),1,length(timepts));
        case 'sawtooth'
            if strcmp(param.type,'pfn')==1 %for fair rounding
                range = param.high(i)-param.low(i)+0.9999;
                min = param.low(i)-0.49995;
            end
            tmp = min+range*((sawtooth(timepts*f)+1)/2);
            range = param.high(i)-param.low(i); %reset range and min
            min = param.low(i);
        case 'triangle'
            tmp = min+range*((sawtooth(timepts*f,0.5)+1)/2);
        case 'sine'
            tmp = min+range*((sin(timepts*f)+1)/2);
        case 'cosine'
            tmp = min+range*((cos(timepts*f)+1)/2);
        case 'square'
            tmp = min+range*((square(timepts*f)+1)/2);
        case 'loom'
            tmp = min-(range/1.5708)*atan(param.size_speed_ratio(i)./(1000*(timepts-s)));
        otherwise
            clear tmp
    end
    
    %to flip cycling direction
    if param.flip(i)==1 
        tmp = 2*min + range - tmp;
    end
    
    %check if any frames have been skipped (for position functions only)
    if strcmp(param.type,'pfn')==1 && strcmpi(param.section{i},'static')==0 && strcmpi(param.section{i},'square')==0
        tmp = round(tmp);
        frames = param.low(i):param.high(i);
        for j=1:length(frames)
            if any(tmp==frames(j))==0
                skipped_frames = [skipped_frames frames(j)];
            end
        end
        if isempty(skipped_frames)==0
            disp('warning: some frames have been skipped in position function')
            %disp(['skipped_frames: ' num2str(skipped_frames)])
        end
    end
    
    func = [func tmp];
end

if strcmp(param.type,'afn')==1 && max(abs(func))>10
    error('analog output value cannot exceed 10 volts')
end

if strcmp(param.type,'pfn')==1
    func = round(func); %pattern frames are specified by integers
end
        
end