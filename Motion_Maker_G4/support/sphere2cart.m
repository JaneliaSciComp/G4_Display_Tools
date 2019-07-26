function [x, y, z] = sphere2cart(phi, theta, rho)
% FUNCTION [x, y, z] = sphere2cart(phi, theta, rho)
%
% Converts arrays of points in spherical coordinates (phi, theta, rho) to 
% Cartesian coordinates (x, y, z)
%
% if rho is unspecified, defaults to unit sphere (rho=1)

if nargin<3
    rho = ones(size(phi));
end

if any(size(phi)~=size(theta))||any(size(phi)~=size(rho))
    error('all inputs must be of equal size');
end

x = rho.*sin(phi).*sin(theta);
y = rho.*cos(phi).*sin(theta);
z = -rho.*cos(theta);

end