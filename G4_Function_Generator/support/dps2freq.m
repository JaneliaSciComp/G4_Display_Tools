function out = dps2freq(in,step_size,high,low,type,reverse)
%FUNCTION out = dps2freq(in,step_size,high,low,type,reverse)
%
%converts degrees per second (dps) to frequency
%inputs:
%in: dps (by default)
%step_size: amount of motion (in degrees) between frames of the pattern)
%high: highest frame in the position function
%low: lowest frame in the position function
%type: type of position function
%reverse: (optional) logical, 1 = converts freq (in) to dps (out)

%default
frame_range = high-low+1;

switch type
    case 'static'
        %default
    case 'sawtooth'
        %default
    case 'triangle'
        frame_range = (frame_range-1)*2; %ramp up just like sawtooth, then ramp down without first/last frame
    case 'sine'
        frame_range = (frame_range-1)*2; %(avg speed for sine wave)
    case 'cosine'
        frame_range = (frame_range-1)*2;
    case 'square'
        frame_range = (frame_range-1)*2;
    case 'loom'
        %default
    otherwise
        error('type not recognized')
end

deg_range = frame_range*step_size;
if nargin<6 || logical(reverse)==0
    out = in/deg_range;
else
    out = in*deg_range;
end

