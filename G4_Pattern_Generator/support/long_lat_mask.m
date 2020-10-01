function mask = long_lat_mask(phi, theta, long_lat_params, aa_samples)
% FUNCTION mask = long_lat_mask(phi, theta, long_lat_params, aa_samples)
%
% Given a 2-D matrix of points in spherical coordinates (phi, theta), this 
% function generates a mask for all points that lie either outside or 
% inside the lattitude/longitude lines specified
% 
% inputs:
% phi: 2-D array of angles of rotation around the z-axis (longitude)
% theta: 2-D array of angles around the x-axis (lattitude)
% long_lat_params: [min-longitude, max-longitude, min-lattitude, 
%                   max-lattitude, out/in]
%                   5th vector (out/in) is optional; setting to 1 masks
%                   the inside of the lattitude/longitude lines specified
%                   rather than the outside
% aa_samples: %# of samples taken to calculate the brightness of each pixel
%
% outputs:
% mask: 2-D matrix of 0-1 values(not logical; can have decimal values to 
%               create smooth mask edges if aa_samples>1)

longs = long_lat_params(1:2);
lats = long_lat_params(3:4) + pi/2; %convert from lattitude to spherical
mask_lo = ones(size(phi));
mask_la = ones(size(phi));

%create lattitude mask
if abs(diff(lats))<pi
    samples = samples_by_diff(theta, aa_samples);
    mask_la = samples>min(lats) & samples<max(lats);
    mask_la = mean(mask_la,3);
end

%create longitude mask
if abs(diff(longs))<2*pi
    samples = samples_by_diff(phi, aa_samples);
    mask_lo = samples>min(longs) & samples<max(longs);
    mask_lo = mean(mask_lo,3);
end

%combine masks
mask = mask_la.*mask_lo;

%mask inside of lattitude/longitude lines rather than outside (if desired)
if length(long_lat_params)==5 && long_lat_params(5)
    mask = 1-mask;
end

end