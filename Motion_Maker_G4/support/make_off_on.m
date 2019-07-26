function [Pats, num_frames] = make_off_on(param)
% FUNCTION [Pats, frames] = make_off_on(param)
% 
% Creates a pattern of uniform brightness, starting with the lowest desired
% brightness and increasing to the highest desired brightness.
% 
% inputs:
% param.rows: number of rows in arena
% param.cols: number of columns in arena
% param.levels: brightness level of [starting_brightness, ending_brightness]
% 
% outputs:
% Pats: array of brightness values for each pixel in the arena
% num_frames: # of frames in the Pats variable (3rd dimension in Pats)

%calculate # of frames needed
num_frames = abs(param.levels(1)-param.levels(2))+1;
l = zeros(1,1,num_frames);

%calculate brightness values for every frame
if param.levels(1)>param.levels(2)
    l(1,1,:) = param.levels(2):param.levels(1);
else
    l(1,1,:) = param.levels(1):param.levels(2);
end

%replicate brightness value for every pixel
Pats = repmat(l,[param.rows, param.cols, 1]);

end