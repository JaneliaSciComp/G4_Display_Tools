function samples = samples_by_p_rad(m, num_samples)
% FUNCTION samples = samples_by_p_rad(m, num_samples)
%
% This script turns an (m,n) array of values into an (m,n,num_samples) 
% array, duplicating each of the original elements and evenly spacing them 
% across that original element's range (spanning from -p_rad/2 to +p_rad/2,
% where p_rad is the distance between adjacent elements in radians)
% 
% inputs:
% m: 2-D matrix of pixel coordinates
% num_samples: # of samples to be calculated for each element in m (15 if
%               unspecified)
%
% outputs:
% samples: 3-D array of coordinates (samples for range of coordinates of
% each individual pixel are stored across the 3rd dimension)


if nargin<2
    num_samples = 15;
end

if num_samples == 1
    samples = m;
    
else
    load('C:\matlabroot\G4\Arena\arena_parameters.mat','p_rad')
    [rows, cols] = size(m);

    %calculate array of differences from each original element
    points = nan(1,1,num_samples);
    points(1,1,:) = -0.5*(1-1/num_samples):1/num_samples:0.5*(1-1/num_samples);
    points = repmat(points, [rows, cols, 1]);
    range = repmat(p_rad,[rows, cols, num_samples]);
    range_shift = range.*points; 

    %duplicate and shift matrix elements across their respective ranges
    m = repmat(m,[1 1 num_samples]);
    samples = m + range_shift;
end

end