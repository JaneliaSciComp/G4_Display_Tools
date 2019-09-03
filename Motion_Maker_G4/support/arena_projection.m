function arena_projection(Pats, gs_val, color, plot_type, frame, checker)
% FUNCTION arena_checker_projection(Pats, gs_val, color, plot_type frame)
% 
% Plots a single frame of the input pattern as a scatter plot of dots.
%
% inputs:
% Pats: 2-D or 3-D array of brightness values for each pixel of pattern
% gs_val: # of brightness bits (1 or 4)/whether Pats values are 0-1 or 0-15
% color: [r g b] sets the color of pixels (for 2-color checkboard patterns, 
%        color is [r1 g1 b1; r2 g2 b2]
% plot_type: specifies whether to create a mercator projection or display
%        the pattern as a grid of pixels
% frame: for a 3-D Pats variable, frame sets the 3rd dimension index to
%        specify the 2-D pattern to be displayed
% checker: sets whether the pattern to be plotted is a checkerboard layout


load('C:\matlabroot\G4\Arena\arena_parameters.mat');
[arena_phi, arena_theta, ~] = cart2sphere(arena_x, arena_y, arena_z);

%figure size settings
max_w = 1.15;
max_h = 0.5;
center_h = 0.33;
center_w = 0.5;

%determine drawing parameters based on plot type
switch plot_type
    case 1 %mercator projection
        x = rad2deg(arena_phi);
        y = rad2deg(arena_theta)-90; %convert to lattitude
        dot_size = 140*p_rad;
        axes = [-180 180 -90 90];
    case 2 %grid projection
        rows = length(arena_phi(:,1));
        cols = length(arena_phi(1,:));
        x = repmat(1:cols,rows,1);
        y = repmat((1:rows)',1,cols);
        dot_size = 320*p_rad;
        axes = [0 cols+1 0 rows+1];
end

%rearrange x and y coordinates to match checkerboard pattern matrix
if checker==1
    if aparam.rot180==1
        x = rot90(x,2);
        y = rot90(y,2);
    end
    x = checkerboard_pattern(x,x);
    y = checkerboard_pattern(y,y);
    if aparam.rot180==1
        x = rot90(x,2);
        y = rot90(y,2);
    end
end

%rotate if arena is mounted upside-down
if aparam.rot180==1
    Pats = rot90(Pats,2);
end

%turn values into vectors for easy plotting
num_pixels = numel(x);
x_vec = reshape(x,[num_pixels 1]);
y_vec = reshape(y,[num_pixels 1]);

%convert Pats to vector of values between 0 and 1
Pats_vec = reshape(Pats(:,:,frame)/(2^gs_val - 1),[num_pixels 1]);

%get pixel color(s)
if checker==1
    colors1 = repmat(permute(color(1,:),[1 3 2]),[size(Pats(:,:,frame)) 1]);
    colors2 = repmat(permute(color(2,:),[1 3 2]),[size(Pats(:,:,frame)) 1]);
    colors = checkerboard_pattern(colors1,colors2);
    colors = reshape(colors,[num_pixels,3]).*repmat(Pats_vec,[1 3]);
else
    colors = repmat(color(1,:),[num_pixels,1]).*repmat(Pats_vec,[1 3]);
end

%plot pattern
scatter(x_vec,y_vec,dot_size,colors,'filled')

%scale plot size to match pattern sizegrid on
axis(axes)
ax = gca;
size_ratio = diff(axes(3:4))/diff(axes(1:2));
width = max_w;
height = width*size_ratio;
if height>max_h
    width = width*(max_h/height);
    height = max_h;
end
ax.OuterPosition = [center_w-width/2 center_h-height/2 width height];
grid on

end