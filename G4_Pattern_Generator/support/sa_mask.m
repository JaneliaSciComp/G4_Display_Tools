function mask = sa_mask(x, y, z, sa_mask_params, aa_samples)
% FUNCTION mask = sa_mask(x, y, z, sa_mask_params, aa_samples)
%
% Given a 2-D matrix of points in cartesian coordinates (x, y, z), this 
% function generates a mask for all points that lie either outside or 
% inside of a solid angle from the spherical coordinates specified
% 
% inputs:
% x/y/z: cartesian coordinates for every pixel in arena
% sa_mask_params: [center-longitude, center-lattitude, solid-angle, out/in]
%               4th vector (out/in) is optional; setting to 1 masks the 
%               inside of the solid angle specified rather than the outside
% aa_samples: %# of samples taken to calculate the brightness of each pixel
%
% outputs:
% mask: 2-D matrix of 0-1 values(not logical; can have decimal values to 
%               create smooth mask edges if aa_samples>1)


coord = sa_mask_params(1:2);
coord(2) = coord(2)+pi/2; %convert from lattitude to spherical
solid_angle = sa_mask_params(3);

%rotate mask center to south pole
[x, y, z] = rotate_coordinates(x, y, z, [-coord 0]);
[~, theta, ~] = cart2sphere(x, y, z);

%take multiple samples for each pixel
samples = samples_by_diff(theta, aa_samples);

%mask solid angle
mask = samples<solid_angle;
mask = mean(mask,3);

if length(sa_mask_params)==4 && sa_mask_params(4)
    mask = 1-mask; %mask inside of solid angle rather than outside
end

end

