function aligned_data = align_timeseries(set_times, unaligned_times, unaligned_data, upscaling, downscaling)
% FUNCTION aligned_data = align_timeseries(set_times, unaligned_times, unaligned_data, upscaling, downscaling)
%
% Inputs:
% set_times: timestamps of a constant rate which the unaligned times/data will be aligned to
% unaligned_times: timestamps corresponding to timeseries data
% unaligned_data: timeseries data
% upscaling: options for filling NaN gaps in unaligned data: "propagate", "interpolate", or "leave NaN"
% downscaling: options for downscaling data: "mean", "median", or "mode"
    
upscale_limit = 2; %maximum size of NaN gap that will be filled by upscaling method

%pre-allocate space for aligned_data matrix (rows accommodate downscaling)
set_period = median(diff(set_times));
unaligned_period = median(diff(unaligned_times));

%align data to nearest time indices in set_times (col_inds)
%multiple datapoints occupying the same col_ind are given different row_inds
col_inds = round(((unaligned_times-min(set_times))/set_period)+1);
if any(col_inds<1)||any(col_inds>length(set_times))
    error('timestamps extend outside of set time boundaries')
end

row_inds = diff([0 col_inds]);
row_inds(row_inds>1) = 1;
while any(row_inds==0)
    next_idx = ~row_inds; 
    row_inds = row_inds + next_idx.*([1 row_inds(1:end-1)+1]);
end
aligned_data = nan([max(row_inds) length(set_times)]);
array_size = size(aligned_data);
aligned_data(sub2ind(array_size,row_inds,col_inds)) = unaligned_data;

%% downscale data if data rate is higher than set rate
switch lower(downscaling)
    case 'mean'
        aligned_data = nanmean(aligned_data,1);
        
    case 'median'
        aligned_data = round(nanmedian(aligned_data,1));
        
    case 'mode'
        aligned_data = mode(aligned_data,1);
        
    otherwise
        error('For downscaling, choose either "mean", "median", or mode')
end


%% upscale data if data rate is lower than set rate
%ignore any missing data at the start/end (upscaling fills missing gaps only)
nanidx = isnan(aligned_data);
first_val = find(nanidx==0,1);
last_val = find(nanidx==0,1,'last');
nanidx([1:first_val last_val:end]) = 0;
if any(nanidx)
    switch lower(upscaling)
        case 'propagate' %fill gaps (within the limit) with nearest previous datapoint
            for i = 1:upscale_limit
                aligned_data(logical([0 nanidx(2:end)])) = aligned_data(logical([nanidx(2:end) 0]));
                nanidx = isnan(aligned_data);
            end

        case 'interpolate' %linear interpolation between 2 nearest datapoints
            error('interpolate option not yet added')

        case 'leave nan'

        otherwise
            error('For Upscaling, choose "propagate", "interpolate", or "leave NaN"')
    end
end