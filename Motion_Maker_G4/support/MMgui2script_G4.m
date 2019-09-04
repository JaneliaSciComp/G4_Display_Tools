function MMgui2script_G4(param)
% function gui2script_G4(param)
%
% creates a matlab script file that will create and save the pattern
% specified by the current pattern parameters in the 
% Motion_Pattern_Maker_gui
%
% Script given the temporary name 'temp_script_G4.m' and saved in the 
% directory 'C:\matlabroot\Motion_Maker_G4_scripts\'
%
% inputs:
% param: all pattern parameters

script_dir = 'C:\matlabroot\G4\Scripts\';
if ~exist(script_dir, 'dir')
    mkdir(script_dir);
end
if exist([script_dir 'temp_pattern_script_G4.m'],'file')
    recycle('on');
    delete([script_dir 'temp_pattern_script_G4.m']);
    recycle('off');
end
FID = fopen([script_dir 'temp_pattern_script_G4.m'],'a');

fprintf(FID,'%s\n','% Script version of Motion_Maker_G4 with current GUI parameters');
fprintf(FID,'%s\n','% (script saved in C:\matlabroot\G4\Scripts\)');
fprintf(FID,'%s\n','%');
fprintf(FID,'%s\n','% Save this script with a new filename to keep it from being overwritten');
fprintf(FID,'%s\n','');
fprintf(FID,'%s\n','%% user-defined pattern parameters');
fprintf(FID,'%s\n','% all angles/distances/sizes are in units of radians rather than degrees');
fprintf(FID,'%s\n','% some parameters are only needed in certain cirumstances {specified by curly brace}');
fprintf(FID,'%s\n',['param.pattern_type = ''' param.pattern_type '''; %square grating, sine grating, edge, starfield, or Off/On']);
fprintf(FID,'%s\n',['param.motion_type = ''' param.motion_type '''; %rotation, translation, or expansion-contraction']);
fprintf(FID,'%s\n',['param.pattern_fov = ''' param.pattern_fov '''; %full-field or local']);
fprintf(FID,'%s\n',['param.arena_pitch = ' num2str(param.arena_pitch, '%.4g') '; %angle of arena pitch (0 = straight ahead, positive values = pitched up)']);
fprintf(FID,'%s\n',['param.gs_val = ' num2str(param.gs_val) '; %bits of intensity value (1 or 4)']);
fprintf(FID,'%s\n',['param.levels = [' num2str(param.levels, '%d') ']; %brightness level of [1st bar (in grating) or advancing edge, 2nd bar or receding edge, background (mask)]']);
fprintf(FID,'%s\n',['param.pole_coord = [' num2str(param.pole_coord, ' %.4g') ']; %location of pattern pole [longitude, lattitude] {for pattern_fov=full-field}']);
fprintf(FID,'%s\n',['param.motion_angle = ' num2str(param.motion_angle, '%.4g') '; %angle of rotation (0=rightward motion, positive values rotate the direction clockwise) {fov=local}']);
fprintf(FID,'%s\n',['param.spat_freq = ' num2str(param.spat_freq, '%.4g') '; %spatial angle (in radians) before pattern repeats {for gratings and edge}']);
fprintf(FID,'%s\n',['param.step_size = ' num2str(param.step_size, '%.4g') '; %amount of motion per frame (in radians) {for type~=off/on}']);
fprintf(FID,'%s\n',['param.duty_cycle = ' num2str(param.duty_cycle) '; %percent of spat_freq taken up by first bar {for square gratings}']);
fprintf(FID,'%s\n',['param.num_dots = ' num2str(param.num_dots) '; %number of dots in star-field {for type=starfield}']);
fprintf(FID,'%s\n',['param.dot_radius = ' num2str(param.dot_radius, '%.4g') '; %radius of dots (in radians) {for starfield}']);
fprintf(FID,'%s\n',['param.dot_size = ''' param.dot_size '''; %static or distance-relative {for starfield}']);
fprintf(FID,'%s\n',['param.dot_occ = ''' param.dot_occ '''; %how occluding dots are drawn (closest, sum, or mean) {for starfield}']);
fprintf(FID,'%s\n',['param.dot_re_random = ' num2str(1) '; %whether to re-randomize dot starting locations (1=randomize, 0=reuse previous) {for startfield}']);
fprintf(FID,'%s\n',['param.dot_level = ' num2str(param.dot_level) '; %0 = dot brightness set to 1st level; 1 and 2 = random brightness (0-1st; 0 or 1st) {for starfield}']);
fprintf(FID,'%s\n',['param.snap_dots = ' num2str(param.snap_dots) '; %1 if apparent dot locations should be rounded to the nearest pixel {for starfield}']);
fprintf(FID,'%s\n',['param.sa_mask = [' num2str(param.sa_mask, ' %.3g') ']; %location, size, and direction of solid angle mask [longitude, lattitude, solid_angle, out/in]']);
fprintf(FID,'%s\n',['param.long_lat_mask = [' num2str(param.long_lat_mask, ' %.3g') ']; %coordinates of lattitude/longitude mask [min-long, max-long, min-lat, max-lattitude, out/in]']);
fprintf(FID,'%s\n',['param.aa_samples = ' num2str(param.aa_samples) '; %# of samples taken to calculate the brightness of each pixel (1 or 15 suggested)']);
fprintf(FID,'%s\n',['param.aa_poles = ' num2str(param.aa_poles) '; %1=anti-aliases the poles of rotation/translation grating/edge stimuli by matching them to the duty cycle']);
fprintf(FID,'%s\n',['param.back_frame = ' num2str(param.back_frame) '; %1=adds a frame (frame 1) uniformly at background (mask) level']);
fprintf(FID,'%s\n',['param.flip_right = ' num2str(param.flip_right) '; %1=left-right flips the right half of the pattern']);
fprintf(FID,'%s\n',['param.phase_shift = ' num2str(param.phase_shift) '; %shifts the starting frame of pattern (in radians)']);
fprintf(FID,'%s\n',['param.checker_layout = ' num2str(param.checker_layout) '; %0 = standard LED panel layout; 1 = checkerboard (e.g. 2-color) panel layout']);
fprintf(FID,'%s\n','');
fprintf(FID,'%s\n','');
fprintf(FID,'%s\n','%% generate pattern');
fprintf(FID,'%s\n','[Pats, param.true_step_size, param.rot180] = Motion_Maker_G4(param);');
fprintf(FID,'%s\n','param.stretch = zeros(size(Pats,3),1); %stretch increases (within limits) the per-frame brightness -- zeros add no brightness');
fprintf(FID,'%s\n','');
fprintf(FID,'%s\n','');
fprintf(FID,'%s\n','%% save pattern');
fprintf(FID,'%s\n','save_dir = ''C:\matlabroot\G4\Patterns\'';');
fprintf(FID,'%s\n','patName = ''Pattern'';');
fprintf(FID,'%s\n','param.ID = get_pattern_ID(save_dir);');
fprintf(FID,'%s\n','save_pattern_G4(Pats, param, save_dir, patName);');
fprintf(FID,'%s\n','');

fclose(FID);
edit C:\matlabroot\G4\Scripts\temp_pattern_script_G4.m;

end