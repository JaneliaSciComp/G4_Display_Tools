function [x, y, z] = rotate_coordinates(x, y, z, rotations, reverse)
% FUNCTION [x, y, z] = rotate_coordinates(x, y, z, rotations, reverse)
%
% Given a set of points in cartesian coordinates, this function will rotate 
% those points around the x, y, and z axes in the given amount specified
% 
% inputs used:
% x/y/z: starting cartesian coordinates of points
% rotations: [yaw pitch roll] - amount of rotation (in radians) of points 
%             around the z-axis, x-axis, and y-axis, respectively
% reverse: 1=rotations will proceed in the opposite order (roll,
%             pitch, yaw)
% 
% outputs:
% x, y, z: cartesian coordinates of points after rotations


%set order of rotations
if nargin==5 && reverse
    loops = 3;
    order = [3 2 1];
else
    loops = 1;
    order = [1 1 1];
end


for i = 1:loops
    
%% yaw rotation
if rotations(1)~=0 && i==order(1)
%convert to polar coordinates (pole=z, polar axis=y-axis)
rho = hypot(x,y);
phi = atan2(x,y);

phi = phi + rotations(1); %rotate around pole

%convert back to cartesian coordinates (z unchanched in yaw shift)
x = rho.*sin(phi);
y = rho.*cos(phi);
end

%% pitch rotation
if rotations(2)~=0 && i==order(2)
%convert to polar coordinates (pole=x, polar axis=y-axis)
rho = hypot(z,y);
phi = atan2(z,y);

phi = phi + rotations(2); %rotate around pole

%convert to cartesian coordinates (x unchanged in pitch shift)
z = rho.*sin(phi);
y = rho.*cos(phi);
end

%% roll rotation
if rotations(3)~=0 && i==order(3)
%convert to polar coordinates (pole=y, polar axis=x-axis)
rho = hypot(z,x);
phi = atan2(z,x);

phi = phi - rotations(3); %rotate around pole (clockwise)

%convert to cartesian coordinates (y unchanged in roll shift)
x = rho.*cos(phi);
z = rho.*sin(phi);
end

end

end