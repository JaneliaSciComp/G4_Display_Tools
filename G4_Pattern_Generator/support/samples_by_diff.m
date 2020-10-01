function samples = samples_by_diff(m, num_samples)
% FUNCTION samples = samples_by_diff(m, num_samples)
%
% This script turns an (m,n) array of values into an (m,n,num_samples) 
% array, duplicating each of the original elements and evenly spacing them 
% across that original element's range (approximately spanning half the 
% distance to its adjacent elements.)
% 
% Method: this function finds the difference between it's closest adjectent 
% column and row elements, individually. It then calculates the hypotenuse
% of those 2 distances (taken as the element's range) Finally, for each 
% element of the 2-D matrix, it creates a number of replicates (15 by 
% default) of that element and evenly spaces them out across the calculated 
% range, centered around the original element's value.
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
    [rows, cols] = size(m);

    %find closest adjacent row element in the matrix
    diff_ud = nan(rows,cols,2);
    diff_ud(1:end-1,:,1) = diff(m);
    diff_ud(2:end,:,2) = diff_ud(1:end-1,:,1);
    diff_ud = min(abs(diff_ud),[],3);

    %find closest adjacent column element in the matrix
    diff_lr = nan(rows,cols,2);
    diff_lr(:,1:end-1,1) = diff(m, [], 2);
    diff_lr(:,2:end,2) = diff_lr(:,1:end-1,1);
    diff_lr = min(abs(diff_lr),[],3);

    %use the hypotenuse of the closest adjacent elements as the approximate 
    %sampling range of each element
    range = hypot(diff_ud,diff_lr);
    %range = diff_ud + diff_lr; %for square fov

    %calculate array of differences from each original element
    points = nan(1,1,num_samples);
    points(1,1,:) = -0.5*(1-1/num_samples):1/num_samples:0.5*(1-1/num_samples);
    points = repmat(points, [rows, cols, 1]);
    range = repmat(range,[1 1 num_samples]);
    range_shift = range.*points; 

    %duplicate and shift matrix elements across their respective ranges
    m = repmat(m,[1 1 num_samples]);
    samples = m + range_shift;
end

end