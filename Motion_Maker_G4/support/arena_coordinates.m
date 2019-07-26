function arena_coordinates(Psize, Pcols, Prows, Pcircle, rot180, model, rotations, translations)
% FUNCTION arena_coordinates(Prows, Pcols, Psize, Pcircle, rot180, model, rotations, translations)
%
% Calculates the cartesian coordinates of every pixel in a cylindrical LED
% arena, according to the input arena dimensions and parameters. Also 
% calculates the distance between pixels in radians (where the arena's 
% circumference is 2*pi.)
%
% inputs:
% Psize: # of pixels per row (or column) of a single LED panel (e.g. 8 or 16)
% Pcols: # of columns of LED panels 
% Prows: # of rows of LED panels
% Pcircle: # of panel columns that would fully enclose the arena
% rot180: if arena is flipped upside-down
% model: 'poly' or 'smooth' cylinder 
% rotations: [yaw pitch roll] rotations of arena (in radians)
% translations: [x y z] translations of arena (for arena circumferance = 2pi)
% 
% saved outputs: (saved to C:\matlabroot\G4\Arena\arena_parameters.mat)
% arena_x/y/z: matrices of cartesian coordinates for all pixels in the arena
% p_rad: distance between pixels (along rows/column directions) in radians
% arena_param: structure containing all input parameters

rows = Prows*Psize; %# of rows of pixels in arena
cols = Pcols*Psize; %# of columns of pixels in arena
Pan_rad = 2*pi/Pcircle; %radians between panel columns
p_rad = Pan_rad/Psize; %radians between pixels

%calculate height (z) of each pixel
arena_z = p_rad*(1-rows)/2:p_rad:p_rad*(rows-1)/2; 
arena_z = repmat(arena_z',1,cols);

%calculate the angle of each panel column's center from straight ahead
cphi = -Pan_rad*(Pcols-1)/2:Pan_rad:Pan_rad*(Pcols-1)/2;

%for a fully-enclosed arena with an even # of col panels, assume the panel
%center is straight ahead (rather than a vertex)
if mod(Pcols,2) && Pcols==Pcircle
    cphi = cphi - Pan_rad/2; %shift panel center to straight ahead
end
cphi = repmat(cphi,[Psize 1]);
cphi = reshape(cphi,[1 cols]);
        
%calculate each pixel's distance relative to its panel center
points = (p_rad-Pan_rad)/2:p_rad:(Pan_rad-p_rad)/2;
points = repmat(points,[1 Pcols]);
        
switch model
    case 'smooth' %model as smooth-surfaced cylinder (radius = 1)
        %calculate angle from straight ahead of each pixel column
        col_phi = cphi + points;
        
        %calculate x,y coordinates from angle
        arena_x = repmat(sin(col_phi), rows, 1);
        arena_y = repmat(cos(col_phi), rows, 1);
        
    case 'poly' %model as polygonal cylinder (circumferance = 2pi)
        apothem = Pan_rad/(2*tan(pi/Pcircle));
        
        %calculate x,y coordinates of each pixel's panel column center
        arena_x = apothem*sin(cphi);
        arena_y = apothem*cos(cphi);
        
        %adjust each pixel's coordinate from center of panel
        arena_x = arena_x + points.*cos(-cphi);
        arena_y = arena_y + points.*sin(-cphi);
        arena_x = repmat(arena_x,[rows 1]);
        arena_y = repmat(arena_y,[rows 1]);
        
    otherwise
        error('arena model not recognized')
end

%make final adjustments to arena
[arena_x, arena_y, arena_z] = rotate_coordinates(arena_x, arena_y, arena_z, rotations);
arena_x = arena_x + translations(1);
arena_y = arena_y + translations(2);
arena_z = arena_z + translations(3);

%save arena coordinates and parameters
if ~exist('C:\matlabroot\G4\Arena\','dir')
    mkdir('C:\matlabroot\G4\Arena\');
end
aparam.Psize = Psize;
aparam.Pcols = Pcols;
aparam.Prows = Prows;
aparam.Pcircle = Pcircle;
aparam.rot180 = rot180;
aparam.model = model;
aparam.rotations = rotations;
aparam.translations = translations;
save('C:\matlabroot\G4\Arena\arena_parameters.mat','arena_x','arena_y','arena_z','p_rad','aparam');

end