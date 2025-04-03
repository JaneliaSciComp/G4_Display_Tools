% Create single bar patterns for testing the new G4-1 arenas.  

% Set arena specs
arena_specs.pixels_per_panel = 16;
arena_specs.n_rows = 2;
arena_specs.n_cols = 12;
arena_specs.h_display = arena_specs.n_rows*16;
arena_specs.w_display = arena_specs.n_cols*16;
arena_specs.arena_pitch = 0;

% Set pattern specs
pattern_specs.bar_color = 2;
pattern_specs.bkg_color = 5;
pattern_specs.bar_width = 6;
pattern_specs.bar_angle = 30;
pattern_specs.gs_val = 4;

% Choose whether the pattern should move around arena circumference
% or should just be two static, mirror-image frames:
% wrap = move pattern around the arena by "wrap_step" pixels per frame. 
% flip = two frame pattern with flipped pattern in frame 2.
pattern_specs.wrap_or_flip = "flip"; 
pattern_specs.wrap_step = 1;

save_folder = 'C:\GitHub\G4_Display_Tools\G4_Display_Tools\G4_Example_Experiment_Scripts\test_patterns';

% Create an instance of the SingleBarPattern class
patternGenerator = SingleBarPattern(arena_specs, pattern_specs, save_folder);

% Generate and save the pattern
patternGenerator.generatePattern();


