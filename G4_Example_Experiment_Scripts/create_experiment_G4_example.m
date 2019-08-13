% Script to create directional tuning map
exp_name = 'Motion1'; %name of experiment folder (will be saved in C:\matlabroot\G4\Experiments\)
                                                                                                                                                                                                                                                                           
%% user-defined pattern parameters
% all angles/distances/sizes are in units of radians rather than degrees
% some parameters are only needed in certain cirumstances {specified by curly brace}
param.pattern_type = 'square grating'; %square grating, sine grating, edge, starfield, or Off/On
param.motion_type = 'rotation'; %rotation, translation, or expansion-contraction
param.pattern_fov = 'full-field'; %full-field or local
param.arena_pitch = 0; %angle of arena pitch (0 = straight ahead, positive values = pitched up)
param.gs_val = 4; %bits of intensity value (1 or 4)
param.levels = [15 0 7]; %brightness level of [1st bar (in grating) or advancing edge, 2nd bar or receding edge, background (mask)]
param.pole_coord = deg2rad([0 -90]); %location of pattern pole [longitude, lattitude] {for pattern_fov=full-field}
param.motion_angle = deg2rad(0); %angle of rotation (0=rightward motion, positive values rotate the direction clockwise) {fov=local}
param.spat_freq = deg2rad(60); %spatial angle (in radians) before pattern repeats {for gratings and edge}
param.step_size = deg2rad(1.875); %amount of motion per frame (in radians) {for type~=off/on}
param.duty_cycle = 50; %percent of spat_freq taken up by first bar {for square gratings}
param.num_dots = 500; %number of dots in star-field {for type=starfield}
param.dot_radius = 0.02182; %radius of dots (in radians) {for starfield}
param.dot_size = 'static'; %static or distance-relative {for starfield}
param.dot_occ = 'closest'; %how occluding dots are drawn (closest, sum, or mean) {for starfield}
param.dot_re_random = 1; %whether to re-randomize dot starting locations (1=randomize, 0=reuse previous) {for starfield}
param.dot_level = 0; %0 = dot brightness set to 1st level; 1 and 2 = random brightness (0-1st; 0 or 1st) {for starfield}
param.snap_dots = 0; %1 if apparent dot locations should be rounded to the nearest pixel {for starfield}
param.sa_mask = deg2rad([0 0 180 0]); %location, size, and direction of solid angle mask [longitude, lattitude, solid_angle, out/in]
param.long_lat_mask = deg2rad([-180 180 -90 90 0]); %coordinates of lattitude/longitude mask [min-long, max-long, min-lat, max-lattitude, out/in]
param.aa_samples = 15; %# of samples taken to calculate the brightness of each pixel (1 or 15 suggested)
param.aa_poles = 1; %1=anti-aliases the poles of rotation/translation grating/edge stimuli by matching them to the duty cycle
param.back_frame = 1; %1=adds a frame (frame 1) uniformly at background (mask) level
param.flip_right = 0; %1=left-right flips the right half of the pattern
param.phase_shift = 0; %shifts the starting frame of pattern


%% user-defined position function parameters
% This example position function will cause the display to start with a
% static grey (background) frame for 1 second, then show 2 seconds of 
% motion, and then another 2 seconds of background frame
pfnparam.type = 'pfn'; %number of frames in pattern
pfnparam.frames = 33; %number of frames in pattern
pfnparam.gs_val = 4; %brightness bits in pattern
pfnparam.section = { 'static' 'sawtooth' 'static' }; %static, sawtooth, traingle, sine, cosine, or square
pfnparam.dur = [ 1 2 1 ]; %section duration (in s)
pfnparam.val = [ 1 nan 1 ]; %function value for static sections
pfnparam.high = [ nan 33 nan ]; %high end of function range {for non-static sections}
pfnparam.low = [ nan 2 nan ]; %low end of function range {for non-static sections}
pfnparam.freq = [ nan 8 nan ]; %frequency of section {for non-static sections}
pfnparam.size_speed_ratio = [ nan nan nan]; %size/speed ratio {for loom sections}
pfnparam.flip = [ 0 0 0 ]; %flip the range of values of function {for non-static sections}


%% user-defined AO function parameters
% This example analog output function will generate a 5V pulse for 100 ms
% at the start of the pattern (at the start of the 1 second of background
% frame), then will return to 0V for the next 4.9 seconds
afnparam.type = 'afn'; %number of frames in pattern
afnparam.section = { 'static' 'static' }; %static, sawtooth, traingle, sine, cosine, or square
afnparam.dur = [ 0.1 3.9 ]; %section duration (in s)
afnparam.val = [ 5 0 ]; %function value for static sections
afnparam.high = [ nan nan ]; %high end of function range {for non-static sections}
afnparam.low = [ nan nan ]; %low end of function range {for non-static sections}
afnparam.freq = [ nan nan ]; %frequency of section {for non-static sections}
afnparam.size_speed_ratio = [ nan nan ]; %size/speed ratio {for loom sections}
afnparam.flip = [ 0 0 ]; %flip the range of values of function {for non-static sections}

param.ID = 0;

%create experiment folders
exp_folder = create_exp_dir_G4(exp_name);


%% list of patterns to be generated
% 1) yaw +
% 2) yaw -
% 3) roll +
% 4) roll -
% 5) pitch +
% 6) pitch -
% 7) lift +
% 8) lift -
% 9) thrust +
% 10) thrust -
% 11) slip +
% 12) slip -
%
% This script generates an associated analog output function and position
% function for every pattern, even if the functions are the same between
% patterns.


%create stimuli for 6 motion types in both directions
for mtype = 1:2
    if mtype==1
        param.motion_type = 'rotation';
    else
        param.motion_type = 'translation';
    end
    pole_longitudes = [0 0 0 180 -90 90];
    pole_lattitudes = [-90 90 0 0 0 0];
    for p = 1:6
        param.pole_coord = deg2rad([pole_longitudes(p) pole_lattitudes(p)]);
    
        param.ID = param.ID + 1;
        %generate and save pattern for this condition ID
        [Pats, param.true_step_size, param.rot180] = Motion_Maker_G4(param);
        param.stretch = zeros(size(Pats,3),1);
        save_pattern_G4(Pats, param, [exp_folder '\Patterns'], ['Pattern_' num2str(param.ID, '%04d') '_G4.mat']);
        %generate and save position function for this condition ID
        func = Function_Maker_G4(afnparam); afnparam.ID = param.ID;
        save_function_G4(func, afnparam, [exp_folder '\Analog Output Functions'], ['FunctionAO_' num2str(param.ID, '%04d') '_G4.mat']);
        %generate and save analog output function for this condition ID
        func = Function_Maker_G4(pfnparam); pfnparam.ID = param.ID;
        save_function_G4(func, pfnparam, [exp_folder '\Functions'], ['Function_' num2str(param.ID, '%04d') '_G4.mat']);
    end
end


%% finalize experiment folder
create_currentExp(exp_folder)
