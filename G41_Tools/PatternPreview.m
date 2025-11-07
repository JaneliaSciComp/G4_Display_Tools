classdef PatternPreview < handle
    % PATTERNPREVIEW Display pattern files with interactive frame navigation
    %   
    %   Usage:
    %       preview = PatternPreview(filepath);
    %       
    %   Or from G41_Tools:
    %       [frames, meta] = G41_Tools.preview_pat(filepath);
    
    properties
        filepath        % Path to the pattern file
        frames          % 4D array: (NumPatsY, NumPatsX, rows, cols)
        meta            % Structure with pattern metadata
        
        % UI components
        fig             % Figure handle
        ax              % Axes handle
        img_handle      % Image handle
        title_handle    % Title handle
        slider_x        % X dimension slider
        slider_y        % Y dimension slider (4D patterns only)
        
        % State
        is_4d           % Boolean: true if pattern has Y dimension > 1
        current_x       % Current X frame index (0-based for display)
        current_y       % Current Y frame index (0-based for display)
    end
    
    methods
        function obj = PatternPreview(filepath)
            % Constructor: Load pattern and create preview window
            
            obj.filepath = filepath;
            
            % Load pattern data
            [obj.frames, obj.meta] = G41_Tools.load_pat(filepath);
            
            % Initialize state
            obj.current_x = 0;
            obj.current_y = 0;
            obj.is_4d = obj.meta.NumPatsY > 1;
            
            % Create the preview window
            obj.createPreviewWindow();
        end
        
        function createPreviewWindow(obj)
            % Create and setup the preview figure and controls
            
            % Create figure
            obj.fig = figure('Name', 'Pattern Preview', ...
                            'NumberTitle', 'off', ...
                            'CloseRequestFcn', @(src, evt) obj.closeFigure());
            
            % Create axes for image display
            obj.ax = axes('Parent', obj.fig, 'Position', [0.1, 0.3, 0.8, 0.6]);
            
            % Display initial frame
            obj.img_handle = imagesc(squeeze(obj.frames(1, 1, :, :)));
            colormap(gray);
            caxis([0, obj.meta.vmax]);
            axis image;
            set(obj.ax, 'XTick', [], 'YTick', []);
            
            % Create title
            obj.updateTitle();
            
            % Create sliders based on pattern dimensionality
            if obj.is_4d
                obj.create4DSliders();
            else
                obj.create3DSlider();
            end
        end
        
        function create3DSlider(obj)
            % Create single slider for 3D patterns (X dimension only)
            
            NumPatsX = obj.meta.NumPatsX;
            
            % Calculate slider step
            if NumPatsX > 1
                slider_step = [1/(double(NumPatsX)-1), 1/(double(NumPatsX)-1)];
                max_val = NumPatsX - 1;
            else
                slider_step = [1, 1];
                max_val = 1;
            end
            
            % Create X slider
            obj.slider_x = uicontrol('Parent', obj.fig, ...
                                    'Style', 'slider', ...
                                    'Units', 'normalized', ...
                                    'Position', [0.2, 0.12, 0.6, 0.05], ...
                                    'Min', 0, 'Max', max_val, 'Value', 0, ...
                                    'SliderStep', slider_step, ...
                                    'Callback', @obj.updateDisplay);
            
            % Create label
            uicontrol('Parent', obj.fig, ...
                     'Style', 'text', ...
                     'Units', 'normalized', ...
                     'Position', [0.05, 0.12, 0.1, 0.05], ...
                     'String', 'Frame');
        end
        
        function create4DSliders(obj)
            % Create two sliders for 4D patterns (X and Y dimensions)
            
            NumPatsX = obj.meta.NumPatsX;
            NumPatsY = obj.meta.NumPatsY;
            
            % Calculate slider steps
            if NumPatsX > 1
                slider_step_x = [1/(double(NumPatsX)-1), 1/(double(NumPatsX)-1)];
                max_val_x = NumPatsX - 1;
            else
                slider_step_x = [1, 1];
                max_val_x = 1;
            end
            
            if NumPatsY > 1
                slider_step_y = [1/(double(NumPatsY)-1), 1/(double(NumPatsY)-1)];
                max_val_y = NumPatsY - 1;
            else
                slider_step_y = [1, 1];
                max_val_y = 1;
            end
            
            % Create X slider
            obj.slider_x = uicontrol('Parent', obj.fig, ...
                                    'Style', 'slider', ...
                                    'Units', 'normalized', ...
                                    'Position', [0.2, 0.15, 0.6, 0.05], ...
                                    'Min', 0, 'Max', max_val_x, 'Value', 0, ...
                                    'SliderStep', slider_step_x, ...
                                    'Callback', @obj.updateDisplay);
            
            % Create Y slider
            obj.slider_y = uicontrol('Parent', obj.fig, ...
                                    'Style', 'slider', ...
                                    'Units', 'normalized', ...
                                    'Position', [0.2, 0.08, 0.6, 0.05], ...
                                    'Min', 0, 'Max', max_val_y, 'Value', 0, ...
                                    'SliderStep', slider_step_y, ...
                                    'Callback', @obj.updateDisplay);
            
            % Create labels
            uicontrol('Parent', obj.fig, ...
                     'Style', 'text', ...
                     'Units', 'normalized', ...
                     'Position', [0.05, 0.15, 0.1, 0.05], ...
                     'String', 'X Frame');
            
            uicontrol('Parent', obj.fig, ...
                     'Style', 'text', ...
                     'Units', 'normalized', ...
                     'Position', [0.05, 0.08, 0.1, 0.05], ...
                     'String', 'Y Frame');
        end
        
        function updateDisplay(obj, src, event)
            % Update the displayed frame based on current slider positions
            
            % Get current slider values
            obj.current_x = round(get(obj.slider_x, 'Value'));
            
            if obj.is_4d
                obj.current_y = round(get(obj.slider_y, 'Value'));
            else
                obj.current_y = 0;
            end
            
            % Convert to 1-based indexing for MATLAB
            x_idx = obj.current_x + 1;
            y_idx = obj.current_y + 1;
            
            % Update image
            set(obj.img_handle, 'CData', squeeze(obj.frames(y_idx, x_idx, :, :)));
            
            % Update title
            obj.updateTitle();
            
            % Force redraw
            drawnow;
        end
        
        function updateTitle(obj)
            % Update the title to show current frame indices
            
            if obj.is_4d
                title_str = sprintf('%s\nX: %d / %d, Y: %d / %d', ...
                    obj.filepath, obj.current_x, obj.meta.NumPatsX-1, ...
                    obj.current_y, obj.meta.NumPatsY-1);
            else
                title_str = sprintf('%s\nFrame %d / %d', ...
                    obj.filepath, obj.current_x, obj.meta.NumPatsX-1);
            end
            
            if isempty(obj.title_handle) || ~isvalid(obj.title_handle)
                obj.title_handle = title(obj.ax, title_str, 'Interpreter', 'none');
            else
                set(obj.title_handle, 'String', title_str);
            end
        end
        
        function closeFigure(obj)
            % Handle figure close event
            if isvalid(obj.fig)
                delete(obj.fig);
            end
        end
    end
end
