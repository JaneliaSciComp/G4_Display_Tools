function [Pats, num_frames, true_step_size] = make_grating_edge(param, arena_x, arena_y, arena_z)
% FUNCTION [Pats, frames, true_step_size] = make_grating_edge(param, arena_x, arena_y, arena_z)
% 
% Creates moving pattern of gratings or advancing edges.
% 
% inputs: (all angles/distances/sizes in units of radians)
% arena_x/y/z: cartesian coordinates of pixels in arena
% param.rows: # of rows of pixels in arena
% param.cols: # of columns of pixels in arena
% param.motion_type: 'rotation', 'translation', or 'expansion-contraction'
% param.pattern_fov: 'local' or 'full-field'
% param.arena_pitch: pitch of arena 
% param.levels: brightness level of [1st bar (in grating) or advancing edge, 2nd bar or receding edge, background (mask)]
% param.step_size: amount of motion per frame
% param.spat_freq: angle before the pattern repeats
% param.duty_cycle: percent of square wave at the high value/ also sets the value of translation poles
% param.pole_coord: location of pattern pole [longitude, lattitude]
% param.sa_mask: [mask-center-longitude, mask-center-lattitude]
% param.motion_angle: direction of motion (0=left->right; positive values rotate the direction clockwise)
% param.sa_mask: [mask-center-longitude, mask-center-lattitude]
% param.aa_samples: # of samples taken to calculate a single pixel's brightness
% param.aa_poles: anti-aliases the poles of rotation/translation grating/edge stimuli by matching them to the duty cycle
% param.phase_shift: amount to shift the starting phase of the grating/edge pattern
%
% outputs:
% Pats: array of brightness values for each pixel in the arena
% num_frames: # of frames in the Pats variable (3rd dimension in Pats)
% true_step_size: recalculated value of step size (in order to divide evenly into spat_freq)


%determine how the arena coordinates should be rotated to produce the
%desired pattern (i.e. the desired orientation with respect to the pole)
if strncmpi(param.pattern_fov,'f',1) %orient pattern for desired pole coordinates
    rotations = [-param.pole_coord(1) -param.pole_coord(2)-pi/2 0];
else %orient poles so motion is maximal at the  mask center
    if strncmpi(param.motion_type,'r',1)
        rotations = [-param.sa_mask(1:2) -param.motion_angle];
    else %for translation, roll more so that motion=rightward by default
        rotations = [-param.sa_mask(1:2) -param.motion_angle-pi/2];
    end
end
[pat_x, pat_y, pat_z] = rotate_coordinates(arena_x, arena_y, arena_z, rotations);
[pat_phi, pat_theta, ~] = cart2sphere(pat_x, pat_y, pat_z);


%determine coordinate through which the pattern will change
if strncmpi(param.motion_type,'r',1)
    coord = pat_phi ;%for rotation, motion is through the phi coordinate
elseif strncmpi(param.motion_type,'e',1)
    coord = pat_theta; %for expansion-contraction, motion through theta
else
    coord = tan(pat_theta-pi/2); %for translation, motion through apparent distance
end


%take numerous samples for each pixel's field-of-view
% coord = samples_by_diff(coord, param.aa_samples); 
coord = samples_by_p_rad(coord, param.aa_samples); 

%calculate number of frames needed to create pattern (must be at least 1)
num_frames = max([1 round(param.spat_freq/param.step_size)]); 
true_step_size = param.spat_freq/num_frames; %step_size corrected to evenly divide into spat_freq)


if strncmpi(param.pattern_type,'e',1) %for edges
    num_frames = num_frames+1; %add frame to include both fully-on and fully-off
    Pats = zeros(param.rows, param.cols, num_frames);
    duty_cycle = 0:100/(num_frames-1):100; %duty cycle from 0 to 100 to create advancing edge
    for i=1:num_frames %draw pattern
        Pats(:,:,i) = squeeze((mean(square((coord+param.phase_shift)*2*pi/param.spat_freq,duty_cycle(i)),3)+1)/2);
    end
    
    %repeat duty cycle for every frame/pixel (used for anti-aliasing at end of script)
    duty_cycle = repmat(duty_cycle,[param.rows,1,param.cols]);
    duty_cycle = permute(duty_cycle,[1 3 2]);
    
    
else %for gratings
    duty_cycle = param.duty_cycle;
    coord = repmat(coord,[1 1 1 num_frames]);
    frame_adj = nan(1,1,1,num_frames);
    
    %calculate adjusted pixel coordinates for every frame
    frame_adj(1,1,1,:) = 0:true_step_size:true_step_size*(num_frames-1);
    frame_adj = repmat(frame_adj,[param.rows, param.cols, param.aa_samples, 1]);
    coord = coord - frame_adj;

    if strncmpi(param.pattern_type,'sq',2) %draw square wave gratings
        Pats = squeeze((mean(square((coord+param.phase_shift)*2*pi/param.spat_freq,duty_cycle),3)+1)/2); 
    else %draw sine wave gratings
        Pats = squeeze((mean(sin((coord+param.phase_shift)*2*pi/param.spat_freq),3)+1)/2);
    end
end


%correct for aliasing at poles (when spatial frequency is too small to accurately sample)
if strncmpi(param.motion_type,'e',1)==0 && param.aa_poles==1    
    t2 = param.p_rad; %sampling angle;
    d2 = param.spat_freq/2; %minimum angle for sampling (nyquist limit)
    
    if strncmpi(param.motion_type,'r',1)
        ns_angle = t2/d2;
    else
        %calculate maximum distance that can be accurately sampled (quadratic formula)
        d1 = -d2/2 + sqrt(d2^2/4 + d2/tan(t2) - 1);
        %calculate corresponding angle from pole
        ns_angle = pi/2 - atan(d1) - t2/2;
    end
    
    %mask both poles with value set by duty cycle
    samples = samples_by_diff(pat_theta, param.aa_samples);
    mask = samples<ns_angle | samples>pi-ns_angle;
    mask = mean(mask,3);
    mask = repmat(mask,[1, 1, num_frames]);
    Pats = Pats.*(1-mask) + (duty_cycle/100).*mask;
end

%map pattern (of 0-1) values to desired brightness range
Pats = Pats*(param.levels(1)-param.levels(2)) + param.levels(2);

end