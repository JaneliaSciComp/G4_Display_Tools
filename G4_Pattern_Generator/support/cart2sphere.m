function [phi, theta, rho] = cart2sphere(x, y, z)
% FUNCTION [phi, theta, rho] = cart2sphere(x, y, z)
%
% Converts arrays of points in Cartesian coordinates (x, y, z) to spherical 
% coordinates (phi, theta, rho)

if any(size(x)~=size(y))||any(size(x)~=size(z))
    error('all inputs must be of equal size');
end

rho = sqrt(x.^2+y.^2+z.^2);
phi = atan2(x,y);
theta = acos(-z./rho);

end