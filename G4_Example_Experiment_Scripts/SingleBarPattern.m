classdef SingleBarPattern
    properties
        arena_specs
        pattern_specs
        save_folder
    end
    
    methods
        function obj = SingleBarPattern(arena_specs, pattern_specs, save_folder)
            obj.arena_specs = arena_specs;
            obj.pattern_specs = pattern_specs;
            obj.save_folder = save_folder;
        end
        
        function generatePattern(obj)
            patName = strcat(num2str(obj.pattern_specs.bar_width),'pix_bar_', ...
                 obj.pattern_specs.wrap_or_flip, '_', ...
                 string(obj.pattern_specs.bar_angle),'deg_', ...
                 num2str(obj.pattern_specs.bar_color),'bar_', ...
                 num2str(obj.pattern_specs.bkg_color), 'bkg_', ...
                 'gs_val', num2str(obj.pattern_specs.gs_val)...
                 );
            
            frame = obj.createBarFrame();
            
            if obj.pattern_specs.wrap_or_flip == "wrap"
                Pats = obj.generatePatsArena(frame);
            elseif obj.pattern_specs.wrap_or_flip == "flip"
                Pats = obj.generatePatsFlip(frame);
            end
            
            param.stretch = zeros(obj.arena_specs.w_display, 1);
            param.gs_val = obj.pattern_specs.gs_val;
            param.arena_pitch = obj.arena_specs.arena_pitch;
            param.ID = get_pattern_ID(obj.save_folder);
            
            save_pattern_G4(Pats, param, obj.save_folder, patName);
        end
        
        function frame = createBarFrame(obj)
            frame = ones(obj.arena_specs.h_display, obj.arena_specs.w_display) * obj.pattern_specs.bkg_color;
            slope = tand(obj.pattern_specs.bar_angle);
            centerRow = ceil(obj.arena_specs.h_display / 10);
            centerCol = ceil(obj.arena_specs.w_display / 10);
            y1 = 1;
            x1 = centerRow - (centerCol / slope);
            
            for row = 1:obj.arena_specs.h_display
                for col = 1:obj.arena_specs.w_display
                    expectedCol = round(slope * (row - x1) + y1);
                    if abs(col - expectedCol) <= obj.pattern_specs.bar_width / 2
                        frame(row, col) = obj.pattern_specs.bar_color;
                    end
                end
            end
        end
        
        function Pats = generatePatsArena(obj, frame)
            n_pixels_circum = obj.arena_specs.pixels_per_panel * obj.arena_specs.n_cols;
            n_frames_pattern = n_pixels_circum / obj.pattern_specs.wrap_step;
            Pats = zeros(obj.arena_specs.h_display, obj.arena_specs.w_display, n_frames_pattern);
            Pats(:, :, 1) = frame;
            
            for j = 2:n_frames_pattern
                Pats(:, :, j) = ShiftMatrix(Pats(:, :, j-1), obj.pattern_specs.wrap_step, 'r', 'y');
            end
        end
        
        function Pats = generatePatsFlip(obj, frame)
            Pats = zeros(obj.arena_specs.h_display, obj.arena_specs.w_display, 2);
            Pats(:, :, 1) = frame;
            Pats(:, :, 2) = flip(frame);
        end
    end
end
