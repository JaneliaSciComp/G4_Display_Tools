classdef G41_Tools < handle

    % The code inside several of these functions was translated into matlab
    % from a corresponding python file by Claude sonnet 4.5. It was then
    % reviewed, edited, reorganized, and tested as needed.  
    properties



    end

    methods (Static)

        %% Pattern Creation Tools

        function generate_pattern_from_array(Pats, save_dir, patName, gs_val, stretch, arena_pitch)
            % GENERATE_PATTERN_FROM_ARRAY Create and save a pattern from array
            %   Main user-facing function to create a .pat file from a pattern array
            %
            %   Args:
            %       Pats: 4D array (PatR, PatC, NumPatsX, NumPatsY) with pixel values
            %       save_dir: Directory path where pattern will be saved
            %       patName: Base name for the pattern file
            %       gs_val: (optional) Grayscale value, 4 or 16. Default: 4
            %       stretch: (optional) 2D array (NumPatsX, NumPatsY). Default: all ones
            %       arena_pitch: (optional) Arena pitch parameter. Default: 0
            %
            %   The pattern array dimensions must be multiples of 16 (panel size).
            %   Pattern ID is automatically assigned based on existing files.
            
            % Handle optional arguments
            if nargin < 4 || isempty(gs_val)
                gs_val = 4;
            end
            
            if nargin < 5 || isempty(stretch)
                stretch = ones(size(Pats, 3), size(Pats, 4), 'uint8');
            end
            
            if nargin < 6 || isempty(arena_pitch)
                arena_pitch = 0;
            end
            
            % Get dimensions
            [PatR, PatC, NumPatsX, NumPatsY] = size(Pats);
            
            % Validate dimensions
            if mod(PatR, 16) ~= 0
                error('Number of rows (%d) must be a multiple of 16. Each panel row is 16 pixels.', PatR);
            end
            
            if mod(PatC, 16) ~= 0
                error('Number of columns (%d) must be a multiple of 16. Each panel column is 16 pixels.', PatC);
            end
            
            % Get next available ID
            ID = G41_Tools.get_pattern_id(save_dir);
            
            % Create parameter structure
            param = struct();
            param.gs_val = gs_val;
            param.arena_pitch = arena_pitch;
            param.ID = ID;
            param.px_rng = 0;
            
            % Save the pattern
            G41_Tools.save_pattern_g4(Pats, param, stretch, save_dir, patName);
        end

        function save_pattern_g4(Pats, param, stretch, save_dir, filename)
            % SAVE_PATTERN_G4 Save a pattern as a .pat binary file
            %   Creates a pattern structure, generates the binary data, and saves it
            %
            %   Args:
            %       Pats: 4D array (PatR, PatC, NumPatsX, NumPatsY)
            %       param: Structure with fields gs_val, arena_pitch, ID, px_rng
            %       stretch: 2D array (NumPatsX, NumPatsY)
            %       save_dir: Directory path to save the file
            %       filename: Base filename (without ID prefix or extension)
            
            % Create pattern structure
            pattern = struct();
            pattern.Pats = Pats;
            pattern.x_num = size(Pats, 3);
            pattern.y_num = size(Pats, 4);
            pattern.gs_val = param.gs_val;
            pattern.stretch = stretch;
            pattern.param = param;
            
            % Generate binary pattern vector for hardware
            pattern.data = G41_Tools.make_pattern_vector_g4(pattern);
            
            % Create save directory if needed
            if ~exist(save_dir, 'dir')
                mkdir(save_dir);
            end
            
            % Format file name
            pattern_id = param.ID;
            pat_basename = sprintf('pat%04d_%s.pat', pattern_id, filename);
            pat_path = fullfile(save_dir, pat_basename);
            
            % Save .pat binary file
            fid = fopen(pat_path, 'wb');
            if fid == -1
                error('Could not open file for writing: %s', pat_path);
            end
            
            fwrite(fid, pattern.data, 'uint8');
            fclose(fid);
            
            fprintf('Saved: %s\n', pat_path);
        end

        function next_id = get_pattern_id(save_dir)
            % GET_PATTERN_ID Finds the next available 4-digit pattern ID
            %   Scans the given directory for .pat files and finds the next
            %   available ID. Matches files named like 'pat####.pat' or 
            %   'pat####_something.pat'.
            %
            %   Args:
            %       save_dir (string): The directory to scan for .pat files
            %
            %   Returns:
            %       next_id (int): The next available ID (starting from 1)
            
            % Create directory if it doesn't exist
            if ~exist(save_dir, 'dir')
                mkdir(save_dir);
            end
            
            taken_ids = [];
            
            % Get all .pat files in directory
            files = dir(fullfile(save_dir, '*.pat'));
            
            for i = 1:length(files)
                filename = files(i).name;
                
                % Match "pat" followed by 4 digits, then either "_" or ".pat"
                % Pattern: pat####_ or pat####.pat
                tokens = regexp(filename, '^pat(\d{4})(?:_|\.pat)', 'tokens', 'ignorecase');
                
                if isempty(tokens)
                    error('File ''%s'' does not match expected pattern ''pat####[_...].pat''', filename);
                end
                
                % Extract the ID from the first match
                id_str = tokens{1}{1};
                taken_ids = [taken_ids, str2double(id_str)];
            end
            
            if isempty(taken_ids)
                next_id = 1;
            else
                next_id = max(taken_ids) + 1;
            end
        end

        function pat_vector = make_pattern_vector_g4(pattern)
            % MAKE_PATTERN_VECTOR_G4 Generate binary pattern vector for G4 hardware
            %   Takes in a pattern structure with fields:
            %   - Pats: 4D array (PatR, PatC, NumPatsX, NumPatsY)
            %   - stretch: 2D array (NumPatsX, NumPatsY)
            %   - gs_val: grayscale value (4 or 16)
            %
            %   Returns:
            %   - pat_vector: 1D uint8 array with header and all encoded frames
            
            Pats = pattern.Pats;  % shape: (PatR, PatC, NumPatsX, NumPatsY)
            stretch = pattern.stretch;
            
            if pattern.gs_val == 4
                gs_val = 16;
            else
                gs_val = 2;
            end
            
            [PatR, PatC, NumPatsX, NumPatsY] = size(Pats);
            RowN = PatR / 16;
            ColN = PatC / 16;
            
            % Construct header with little-endian 16-bit values
            header = [G41_Tools.pack_uint16_le(NumPatsX), ...
                      G41_Tools.pack_uint16_le(NumPatsY), ...
                      uint8(gs_val), uint8(RowN), uint8(ColN)];
            
            pat_vector = header(:);  % Ensure column vector
            
            for j = 1:NumPatsY
                for i = 1:NumPatsX
                    frame = squeeze(Pats(:, :, i, j));
                    stretch_val = stretch(i, j);
                    
                    if gs_val == 16
                        stretch_val = min(stretch_val, 20);
                    elseif gs_val == 2
                        stretch_val = min(stretch_val, 107);
                    else
                        error('Invalid gs_val');
                    end
                    
                    frameOut = G41_Tools.make_framevector_gs16(frame, stretch_val);
                    pat_vector = [pat_vector; uint8(frameOut(:))];
                end
            end
        end

        function convertedPatternData = make_framevector_gs16(framein, stretch)
            % MAKE_FRAMEVECTOR_GS16 Encode a 2D frame into hardware format
            %   This is the inverse of decode_framevector_gs16
            %
            %   Parameters:
            %   - framein: 2D array of shape (dataRow, dataCol) with values 0-15
            %   - stretch: optional int (0 or 1), default is 0
            %
            %   Returns:
            %   - 1D uint8 array encoded for hardware
            
            if nargin < 2
                stretch = 0;
            end
            
            [dataRow, dataCol] = size(framein);
            numSubpanel = 4;
            subpanelMsgLength = 33;
            idGrayScale16 = 1;
            
            panelCol = dataCol / 16;
            panelRow = dataRow / 16;
            
            outputVectorLength = (panelCol * subpanelMsgLength + 1) * panelRow * numSubpanel;
            convertedPatternData = zeros(outputVectorLength, 1, 'uint8');
            stretch = uint8(stretch);
            
            n = 1;  % MATLAB uses 1-based indexing
            for i = 0:(panelRow-1)
                for j = 1:numSubpanel
                    % Row header
                    convertedPatternData(n) = i + 1;
                    n = n + 1;
                    
                    for k = 1:subpanelMsgLength
                        for m = 0:(panelCol-1)
                            if k == 1
                                convertedPatternData(n) = bitor(idGrayScale16, bitshift(stretch, 1));
                                n = n + 1;
                            else
                                % k ranges from 2 to 33, so (k-2) ranges from 0 to 31
                                % This matches Python's k-1 when Python k ranges 1-32
                                panelStartRowBeforeInvert = i * 16 + mod(j-1, 2) * 8 + floor((k-2) / 4);
                                panelStartRow = floor(panelStartRowBeforeInvert / 16) * 16 + 15 - mod(panelStartRowBeforeInvert, 16);
                                panelStartCol = m * 16 + floor(j / 3) * 8 + mod(k-2, 4) * 2;
                                
                                % MATLAB uses 1-based indexing
                                tmp1 = uint8(framein(panelStartRow + 1, panelStartCol + 1));
                                tmp2 = uint8(framein(panelStartRow + 1, panelStartCol + 2));
                                
                                if tmp1 < 0 || tmp1 > 15 || tmp2 < 0 || tmp2 > 15
                                    error('Frame values must be >= 0 and <= 15');
                                end
                                
                                convertedPatternData(n) = bitor(tmp1, bitshift(tmp2, 4));
                                n = n + 1;
                            end
                        end
                    end
                end
            end
        end

        function bytes = pack_uint16_le(val)
            % PACK_UINT16_LE Pack unsigned 16-bit int as little-endian bytes
            %   Takes in a uint16 value and returns a 1x2 uint8 array
            %   representing the little-endian byte representation
            
            bytes = typecast(uint16(val), 'uint8');
            
            % Ensure it's in row vector format
            if size(bytes, 1) > size(bytes, 2)
                bytes = bytes';
            end
        end

        %% Experiment Creation Tools

        function create_experiment_folder_g41(yaml_file_path, experiment_folder_path)
        % CREATE_EXPERIMENT_FOLDER_G41 Create experiment folder with renumbered patterns from YAML
        %       *This function was translated from a functionally identical python
        %       function by Claude AI, model Sonnet 4.5, and then adjusted for
        %       accuracy. Updated to include pattern dimension validation.
        %
        % This function reads a YAML experiment protocol file, validates that all
        % patterns match the arena dimensions, collects all patterns in order, assigns 
        % sequential IDs, renames them, and saves everything in the experiment folder.
        %
        % INPUTS:
        %   yaml_file_path         - Path to the YAML experiment protocol file (string or char)
        %   experiment_folder_path - Path where experiment folder should be created (string or char)
        %
        % YAML LIBRARY REQUIREMENT:
        %   This function requires the 'yaml' package by Martin Koch
        %   Available on File Exchange: https://www.mathworks.com/matlabcentral/fileexchange/106765-yaml
        %   Install via MATLAB Add-On Explorer or download from File Exchange
        %
        % EXAMPLES:
        %   % Create experiment folder from YAML file
        %   create_experiment_folder_g41('experiment.yaml', './my_experiment');
        %   
        %   % Using full paths
        %   create_experiment_folder_g41('/path/to/experiment.yaml', '/path/to/experiment_folder');
        %
        % The function will:
        %   1. Read the YAML file
        %   2. Extract arena dimensions from the YAML
        %   3. Collect all pattern paths (checking 'include' flags)
        %   4. Validate that all patterns match the arena dimensions
        %   5. Remove duplicates while preserving order
        %   6. Copy patterns to experiment folder with sequential IDs
        %   7. Update pattern paths in the YAML file copy
        %   8. Save the updated YAML in the experiment folder
        
            % Convert to char if string
            if isstring(yaml_file_path)
                yaml_file_path = char(yaml_file_path);
            end
            if isstring(experiment_folder_path)
                experiment_folder_path = char(experiment_folder_path);
            end
            
            % Validate YAML file exists
            if ~isfile(yaml_file_path)
                error('YAML file not found: %s', yaml_file_path);
            end
            
            % Load YAML file
            fprintf('Reading YAML file: %s\n', yaml_file_path);
            experiment_data = yaml.loadFile(yaml_file_path);
            
            % Extract arena dimensions
            if ~isfield(experiment_data, 'arena_info')
                error('YAML file missing ''arena_info'' section');
            end
            
            arena_info = experiment_data.arena_info;
            
            if ~isfield(arena_info, 'num_rows') || ~isfield(arena_info, 'num_cols')
                error('''arena_info'' must contain ''num_rows'' and ''num_cols''');
            end
            
            expected_rows = arena_info.num_rows;
            expected_cols = arena_info.num_cols;
            
            % Create experiment folder if it doesn't exist
            if ~isfolder(experiment_folder_path)
                mkdir(experiment_folder_path);
                fprintf('Created experiment folder: %s\n', experiment_folder_path);
            else
                fprintf('Experiment folder exists: %s\n', experiment_folder_path);
            end
            
            % Collect pattern paths in order
            pattern_paths = G41_Tools.collect_pattern_paths(experiment_data);
            
            % Remove duplicates while preserving order
            [unique_patterns, ~, ~] = unique(pattern_paths, 'stable');
            fprintf('\nFound %d total patterns and %d unique patterns\n', ...
                    length(pattern_paths), length(unique_patterns));
            
            % Validate all patterns match arena dimensions
            G41_Tools.validate_all_patterns(unique_patterns, expected_rows, expected_cols);
            fprintf('✓ All patterns validated successfully\n');
            
            % Copy and rename patterns
            old_paths = cell(length(unique_patterns), 1);
            new_names = cell(length(unique_patterns), 1);
            
            for idx = 1:length(unique_patterns)
                old_pattern_path = unique_patterns{idx};
                
                % Get old filename
                [~, old_name, old_ext] = fileparts(old_pattern_path);
                old_filename = [old_name, old_ext];
                
                % Generate new filename
                new_filename = G41_Tools.generate_new_filename(old_filename, idx);
                new_file_path = fullfile(experiment_folder_path, new_filename);
                
                % Copy the file
                copyfile(old_pattern_path, new_file_path);
                fprintf('Copied: %s -> %s\n', old_filename, new_filename);
                
                % Store mapping
                old_paths{idx} = old_pattern_path;
                new_names{idx} = new_filename;
            end
            
            % Create pattern mapping structure
            mappings = cell(length(old_paths), 1);
            for idx = 1:length(old_paths)
                mappings{idx} = struct('original', old_paths{idx}, 'renamed', new_names{idx});
            end
            
            pattern_mapping.description = 'Mapping of original pattern paths to renamed pattern files';
            pattern_mapping.mappings = mappings;
            
            % Add pattern mapping to experiment data
            experiment_data.pattern_mapping = pattern_mapping;
            
            % Update pattern paths in the YAML data
            experiment_data = G41_Tools.update_pattern_paths_in_yaml(experiment_data, old_paths, new_names);
            
            % Save updated YAML to experiment folder
            [~, yaml_name, yaml_ext] = fileparts(yaml_file_path);
            yaml_output_path = fullfile(experiment_folder_path, [yaml_name, yaml_ext]);
            yaml.dumpFile(yaml_output_path, experiment_data, "block");
            fprintf('\nSaved updated YAML file: %s\n', yaml_output_path);
            
            fprintf('\nExperiment folder setup complete!\n');
        end
        
        function pattern_paths = collect_pattern_paths(experiment_data)
        % COLLECT_PATTERN_PATHS Collect all pattern paths from YAML in order
        %
        % INPUTS:
        %   experiment_data - Parsed YAML data structure
        %
        % OUTPUTS:
        %   pattern_paths - Cell array of pattern file paths as char vectors in order
        
            pattern_paths = {};
            
            % Check pretrial
            if isfield(experiment_data, 'pretrial') && ...
               isfield(experiment_data.pretrial, 'include') && ...
               experiment_data.pretrial.include
                if isfield(experiment_data.pretrial, 'command_inputs') && ...
                   isfield(experiment_data.pretrial.command_inputs, 'pattern')
                    pattern_paths{end+1} = char(experiment_data.pretrial.command_inputs.pattern);
                end
            end
            
            % Check block conditions
            if isfield(experiment_data, 'block') && ...
               isfield(experiment_data.block, 'conditions')
                conditions = experiment_data.block.conditions;
                
                for idx = 1:length(conditions)
                    condition = conditions{idx};
                    if isfield(condition, 'command_inputs') && ...
                       isfield(condition.command_inputs, 'pattern')
                        pattern_paths{end+1} = char(condition.command_inputs.pattern);
                    end
                end
            end
            
            % Check intertrial
            if isfield(experiment_data, 'intertrial') && ...
               isfield(experiment_data.intertrial, 'include') && ...
               experiment_data.intertrial.include
                if isfield(experiment_data.intertrial, 'command_inputs') && ...
                   isfield(experiment_data.intertrial.command_inputs, 'pattern')
                    pattern_paths{end+1} = char(experiment_data.intertrial.command_inputs.pattern);
                end
            end
            
            % Check posttrial
            if isfield(experiment_data, 'posttrial') && ...
               isfield(experiment_data.posttrial, 'include') && ...
               experiment_data.posttrial.include
                if isfield(experiment_data.posttrial, 'command_inputs') && ...
                   isfield(experiment_data.posttrial.command_inputs, 'pattern')
                    pattern_paths{end+1} = char(experiment_data.posttrial.command_inputs.pattern);
                end
            end
        end

        function new_filename = generate_new_filename(old_filename, new_id)
        % GENERATE_NEW_FILENAME Generate new pattern filename with updated ID
        %
        % INPUTS:
        %   old_filename - Original pattern filename (e.g., 'pat0005_motion.pat')
        %   new_id       - New ID number to assign (e.g., 1)
        %
        % OUTPUTS:
        %   new_filename - New filename with updated ID (e.g., 'pat0001_motion.pat')
        
            % Remove .pat extension
            if endsWith(old_filename, '.pat')
                name_without_ext = old_filename(1:end-4);
            else
                name_without_ext = old_filename;
            end
            
            % Check if filename matches pattern: pat####_descriptiveName
            pattern = '^pat(\d{4})_(.+)$';
            tokens = regexp(name_without_ext, pattern, 'tokens');
            
            if ~isempty(tokens)
                % Extract descriptive name and replace ID
                descriptive_name = tokens{1}{2};
                new_filename = sprintf('pat%04d_%s.pat', new_id, descriptive_name);
            else
                % No ID number present, add it to the front
                new_filename = sprintf('pat%04d_%s.pat', new_id, name_without_ext);
            end
        end
        
        function experiment_data = update_pattern_paths_in_yaml(experiment_data, old_paths, new_names)
        % UPDATE_PATTERN_PATHS_IN_YAML Replace old pattern paths with new filenames in YAML
        %
        % INPUTS:
        %   experiment_data - Parsed YAML data structure
        %   old_paths       - Cell array of original pattern paths
        %   new_names       - Cell array of new pattern filenames
        %
        % OUTPUTS:
        %   experiment_data - Updated YAML data structure with new pattern paths
        
            % Create lookup map
            path_map = containers.Map(old_paths, new_names);
            
            % Update pretrial
            if isfield(experiment_data, 'pretrial') && ...
               isfield(experiment_data.pretrial, 'include') && ...
               experiment_data.pretrial.include
                if isfield(experiment_data.pretrial, 'command_inputs') && ...
                   isfield(experiment_data.pretrial.command_inputs, 'pattern')
                    old_path = experiment_data.pretrial.command_inputs.pattern;
                    if isKey(path_map, old_path)
                        experiment_data.pretrial.command_inputs.pattern = path_map(old_path);
                    end
                end
            end
            
            % Update block conditions
            if isfield(experiment_data, 'block') && ...
               isfield(experiment_data.block, 'conditions')
                conditions = experiment_data.block.conditions;
                
                for idx = 1:length(conditions)
                    condition = conditions{idx};
                    if isfield(condition, 'command_inputs') && ...
                       isfield(condition.command_inputs, 'pattern')
                        old_path = condition.command_inputs.pattern;
                        if isKey(path_map, old_path)
                            experiment_data.block.conditions{idx}.command_inputs.pattern = path_map(old_path);
                        end
                    end
                end
            end
            
            % Update intertrial
            if isfield(experiment_data, 'intertrial') && ...
               isfield(experiment_data.intertrial, 'include') && ...
               experiment_data.intertrial.include
                if isfield(experiment_data.intertrial, 'command_inputs') && ...
                   isfield(experiment_data.intertrial.command_inputs, 'pattern')
                    old_path = experiment_data.intertrial.command_inputs.pattern;
                    if isKey(path_map, old_path)
                        experiment_data.intertrial.command_inputs.pattern = path_map(old_path);
                    end
                end
            end
            
            % Update posttrial
            if isfield(experiment_data, 'posttrial') && ...
               isfield(experiment_data.posttrial, 'include') && ...
               experiment_data.posttrial.include
                if isfield(experiment_data.posttrial, 'command_inputs') && ...
                   isfield(experiment_data.posttrial.command_inputs, 'pattern')
                    old_path = experiment_data.posttrial.command_inputs.pattern;
                    if isKey(path_map, old_path)
                        experiment_data.posttrial.command_inputs.pattern = path_map(old_path);
                    end
                end
            end
        end
        
        function validate_all_patterns(pattern_paths, expected_rows, expected_cols)
        % VALIDATE_ALL_PATTERNS Validate that all patterns match expected arena dimensions
        %
        % INPUTS:
        %   pattern_paths  - Cell array of pattern file paths
        %   expected_rows  - Expected number of panel rows
        %   expected_cols  - Expected number of panel columns
        %
        % Raises an error if any pattern has mismatched dimensions or if a pattern
        % file is not found.
        
            mismatches = {};
            
            for idx = 1:length(pattern_paths)
                pattern_path = pattern_paths{idx};
                
                try
                    [is_valid, error_msg] = G41_Tools.validate_pattern_dimensions( ...
                                                          pattern_path, expected_rows, expected_cols);
                    if ~is_valid
                        mismatches{end+1} = error_msg; %#ok<AGROW>
                    end
                catch ME
                    % Handle FileNotFound or ReadFailed errors
                    if strcmp(ME.identifier, 'G41_Tools:FileNotFound')
                        [~, name, ext] = fileparts(pattern_path);
                        filename = [name, ext];
                        mismatches{end+1} = sprintf('Pattern file not found: %s', filename); %#ok<AGROW>
                    elseif strcmp(ME.identifier, 'G41_Tools:ReadFailed')
                        mismatches{end+1} = ME.message; %#ok<AGROW>
                    else
                        rethrow(ME);
                    end
                end
            end
            
            if ~isempty(mismatches)
                error_message = sprintf('\nPattern dimension validation failed:\n');
                for idx = 1:length(mismatches)
                    error_message = [error_message, sprintf('  - %s\n', mismatches{idx})]; %#ok<AGROW>
                end
                error('create_experiment_folder_g41:ValidationFailed', '%s', error_message);
            end
        end
           
        %% Pattern Preview Tools

        function img = decode_framevector_gs16(framevec, rows, cols)
            % DECODE_FRAMEVECTOR_GS16 Decode a grayscale (4-bit) frame vector
            %   Takes in framevec (1D uint8 array for a single frame), pixel height 
            %   and width of arena. Returns 2D uint8 image of shape (rows, cols)
            %
            %   This is the inverse of make_framevector_gs16.
            
            numSubpanel = 4;
            subpanelMsgLength = 33;
            
            panelCol = cols / 16;
            panelRow = rows / 16;
            
            img = zeros(rows, cols, 'uint8');
            
            n = 1;  % MATLAB uses 1-based indexing
            for i = 0:(panelRow-1)
                for j = 1:numSubpanel
                    n = n + 1;  % Skip row header
                    for k = 1:subpanelMsgLength
                        for m = 0:(panelCol-1)
                            if k == 1
                                n = n + 1;  % Skip command byte
                            else
                                byte = framevec(n);
                                n = n + 1;
                                tmp1 = bitand(byte, hex2dec('0F'));
                                tmp2 = bitand(bitshift(byte, -4), hex2dec('0F'));
                                
                                % k ranges from 2 to 33, so (k-2) ranges from 0 to 31
                                % This matches the encoder and Python implementation
                                panelStartRowBeforeInvert = i * 16 + mod(j-1, 2) * 8 + floor((k-2) / 4);
                                panelStartRow = floor(panelStartRowBeforeInvert / 16) * 16 + 15 - mod(panelStartRowBeforeInvert, 16);
                                panelStartCol = m * 16 + floor(j / 3) * 8 + mod(k-2, 4) * 2;
                                
                                % MATLAB uses 1-based indexing
                                img(panelStartRow + 1, panelStartCol + 1) = tmp1;
                                img(panelStartRow + 1, panelStartCol + 2) = tmp2;
                            end
                        end
                    end
                end
            end
            
            fprintf('img shape: %d x %d\n', size(img, 1), size(img, 2));
        end

        function img = decode_framevector_binary(framevec, rows, cols)
            % DECODE_FRAMEVECTOR_BINARY Decode a binary (1-bit) frame vector
            %   Similar to gs16 but processes 1 bit per pixel instead of 4 bits.
            %   Takes in framevec (1D uint8 array for a single frame), pixel height 
            %   and width of arena. Returns 2D uint8 image of shape (rows, cols)
            
            numSubpanel = 4;
            subpanelMsgLength = 9;  % Binary uses 9 bytes per message instead of 33
            
            panelCol = cols / 16;
            panelRow = rows / 16;
            
            img = zeros(rows, cols, 'uint8');
            
            n = 1;  % MATLAB uses 1-based indexing
            for i = 0:(panelRow-1)
                for j = 1:numSubpanel
                    n = n + 1;  % Skip row header
                    for k = 1:subpanelMsgLength
                        for m = 0:(panelCol-1)
                            if k == 1
                                n = n + 1;  % Skip command byte
                            else
                                byte = framevec(n);
                                n = n + 1;
                                
                                % For binary, each bit represents one pixel
                                % Process 8 pixels per byte
                                for bit_idx = 0:7
                                    pixel_val = bitand(bitshift(byte, -bit_idx), 1);
                                    
                                    % Calculate pixel position
                                    % k ranges from 2 to 9, so (k-2) ranges from 0 to 7
                                    pixel_offset = (k - 2) * 8 + bit_idx;
                                    panelStartRowBeforeInvert = i * 16 + mod(j-1, 2) * 8 + floor(pixel_offset / 16);
                                    panelStartRow = floor(panelStartRowBeforeInvert / 16) * 16 + 15 - mod(panelStartRowBeforeInvert, 16);
                                    panelStartCol = m * 16 + floor(j / 3) * 8 + mod(pixel_offset, 16);
                                    
                                    % MATLAB uses 1-based indexing, also check bounds
                                    if (panelStartRow + 1) <= rows && (panelStartCol + 1) <= cols
                                        img(panelStartRow + 1, panelStartCol + 1) = pixel_val;
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            fprintf('img shape: %d x %d\n', size(img, 1), size(img, 2));
        end

        function [frames, meta] = load_pat(filepath)
            % LOAD_PAT Load and decode all frames from a .pat file
            %   Takes in the path to a pattern file and loads it and decodes all frames.
            %   Returns:
            %   - frames: 4D array (NumPatsY, NumPatsX, rows, cols)
            %   - meta: Structure with pattern metadata (NumPatsX, NumPatsY, rows, cols, vmax)
            
            [NumPatsX, NumPatsY, gs_val, RowN, ColN, raw] = G41_Tools.read_header_and_raw(filepath);
            fprintf('%d %d %d %d %d %d\n', NumPatsX, NumPatsY, gs_val, RowN, ColN, length(raw));
            
            rows = RowN * 16;
            cols = ColN * 16;
            fprintf('RowN, ColN: %d %d\n', RowN, ColN);
            fprintf('rows, cols: %d %d\n', rows, cols);
            
            num_frames = NumPatsX * NumPatsY;
            fsize = G41_Tools.frame_size_bytes(RowN, ColN, gs_val);
            fprintf('Frame size: %d\n', fsize);
            
            expected = fsize * num_frames;
            if length(raw) < expected
                error('File too short: got %d, expected %d', length(raw), expected);
            end
            
            % Initialize 4D array: (NumPatsY, NumPatsX, rows, cols)
            % This allows us to index as frames(y_idx, x_idx, :, :)
            frames = zeros(NumPatsY, NumPatsX, rows, cols, 'uint8');
            
            frame_idx = 0;
            for y = 1:NumPatsY
                for x = 1:NumPatsX
                    vec = raw((frame_idx * fsize + 1):((frame_idx + 1) * fsize));
                    
                    % Use appropriate decoder based on gs_val
                    if gs_val == 1 || gs_val == 2
                        img = G41_Tools.decode_framevector_binary(vec, rows, cols);
                    elseif gs_val == 4 || gs_val == 16
                        img = G41_Tools.decode_framevector_gs16(vec, rows, cols);
                    else
                        error('Unsupported gs_val: %d', gs_val);
                    end
                    
                    frames(y, x, :, :) = img;
                    frame_idx = frame_idx + 1;
                end
            end
            
            if gs_val == 4 || gs_val == 16
                vmax = 15;
            else
                vmax = 1;
            end
            
            meta = struct('NumPatsX', NumPatsX, 'NumPatsY', NumPatsY, ...
                          'rows', rows, 'cols', cols, 'vmax', vmax);
        end

        function [frames, meta] = preview_pat(filepath, show_plot)
            % PREVIEW_PAT Preview a .pat file with interactive sliders
            %   Takes in path to the pattern and "show_plot" which is true if you 
            %   want a visual to pop up. Set show_plot to false for testing.
            %   Returns [frames, meta] - the loaded pattern data
            %
            %   Usage:
            %       [frames, meta] = G41_Tools.preview_pat('path/to/pattern.pat')  % Shows plot
            %       [frames, meta] = G41_Tools.preview_pat('path/to/pattern.pat', true)
            %       [frames, meta] = G41_Tools.preview_pat('path/to/pattern.pat', false)  % No plot
            
            if nargin < 2
                show_plot = true;
            end
            
            % Load pattern data
            [frames, meta] = G41_Tools.load_pat(filepath);
            
            if show_plot
                % Create preview window using PatternPreview class
                prev = PatternPreview(filepath);
            end
        end

        %% Pattern utilities/validation
        
        function [NumPatsX, NumPatsY, gs_val, RowN, ColN, raw] = read_header_and_raw(path)

                    % READ_HEADER_AND_RAW Read pattern file header and raw data
        %
        % INPUTS:
        %   path - Path to .pat file (char or string)
        %
        % OUTPUTS:
        %   NumPatsX - Number of frames in X direction
        %   NumPatsY - Number of frames in Y direction
        %   gs_val   - Grayscale value (1, 2, 4, or 16)
        %   RowN     - Number of panel rows
        %   ColN     - Number of panel columns
        %   raw      - Raw data as uint8 array
        %
        % EXAMPLE:
        %   [NumPatsX, NumPatsY, gs_val, RowN, ColN, raw] = G41_Tools.read_header_and_raw('pattern.pat');
        
            if isstring(path)
                path = char(path);
            end
            
            % Open file
            fid = fopen(path, 'rb');
            if fid == -1
                error('G41_Tools:FileNotFound', 'Could not open file: %s', path);
            end
            
            try
                % Read header (7 bytes total)
                % Format: 2 uint16 (NumPatsX, NumPatsY) + 3 uint8 (gs_val, RowN, ColN)
                header = fread(fid, 7, 'uint8');
                
                if length(header) < 7
                    fclose(fid);
                    error('G41_Tools:InvalidFile', 'File too short to contain header.');
                end
                
                % Parse header using little-endian format
                NumPatsX = typecast(uint8(header(1:2)), 'uint16');
                NumPatsY = typecast(uint8(header(3:4)), 'uint16');
                gs_val = header(5);
                RowN = header(6);
                ColN = header(7);
                
                % Read remaining data
                raw = fread(fid, inf, 'uint8');
                
                fclose(fid);
            catch ME
                fclose(fid);
                rethrow(ME);
            end

        end

        function  frame_bytes = frame_size_bytes(RowN, ColN, gs_val)
                % FRAME_SIZE_BYTES Calculate frame size in bytes
        %
        % INPUTS:
        %   RowN   - Number of panel rows
        %   ColN   - Number of panel columns
        %   gs_val - Grayscale value (1, 2, 4, or 16)
        %
        % OUTPUTS:
        %   frame_bytes - Frame size in bytes
        %
        % EXAMPLE:
        %   frame_bytes = G41_Tools.frame_size_bytes(4, 12, 4);
        
            numSubpanel = 4;
            
            % subpanelMsgLength depends on bits per pixel
            if gs_val == 1 || gs_val == 2
                subpanelMsgLength = 9;  % Binary (1 bit per pixel)
            elseif gs_val == 4 || gs_val == 16
                subpanelMsgLength = 33;  % Grayscale (4 bits per pixel)
            else
                error('G41_Tools:InvalidGrayscale', ...
                      'Unknown gs_val: %d. Expected 1, 2, 4, or 16.', gs_val);
            end
            
            frame_bytes = (ColN * subpanelMsgLength + 1) * RowN * numSubpanel;
        end
 
        function dims = get_pattern_dimensions(pattern_path)
            % GET_PATTERN_DIMENSIONS Extract pattern dimensions without loading full data
        %
        % INPUTS:
        %   pattern_path - Path to pattern file (char or string)
        %
        % OUTPUTS:
        %   dims - Structure containing:
        %          .num_rows     - Number of panel rows
        %          .num_cols     - Number of panel columns
        %          .pixel_rows   - Total pixel rows (num_rows * 16)
        %          .pixel_cols   - Total pixel columns (num_cols * 16)
        %          .num_frames_x - Number of frames in X direction
        %          .num_frames_y - Number of frames in Y direction
        %          .gs_val       - Grayscale value
        %
        % EXAMPLE:
        %   dims = G41_Tools.get_pattern_dimensions('pattern.pat');
        %   fprintf('Pattern has %d rows and %d columns\n', dims.num_rows, dims.num_cols);
        
            if isstring(pattern_path)
                pattern_path = char(pattern_path);
            end
            
            [NumPatsX, NumPatsY, gs_val, RowN, ColN, ~] = ...
                G41_Tools.read_header_and_raw(pattern_path);
            
            dims = struct();
            dims.num_rows = RowN;
            dims.num_cols = ColN;
            dims.pixel_rows = RowN * 16;
            dims.pixel_cols = ColN * 16;
            dims.num_frames_x = NumPatsX;
            dims.num_frames_y = NumPatsY;
            dims.gs_val = gs_val;

        end

        function [is_valid, error_msg] = validate_pattern_dimensions(pattern_path, expected_rows, expected_cols)

            % VALIDATE_PATTERN_DIMENSIONS Check if pattern matches expected arena dimensions
        %
        % INPUTS:
        %   pattern_path   - Path to pattern file (char or string)
        %   expected_rows  - Expected number of panel rows
        %   expected_cols  - Expected number of panel columns
        %
        % OUTPUTS:
        %   is_valid   - true if dimensions match, false otherwise
        %   error_msg  - Error message if dimensions don't match, empty otherwise
        %
        % EXAMPLE:
        %   [is_valid, error_msg] = G41_Tools.validate_pattern_dimensions('pattern.pat', 4, 12);
        %   if ~is_valid
        %       fprintf('Error: %s\n', error_msg);
        %   end
        
            if isstring(pattern_path)
                pattern_path = char(pattern_path);
            end
            
            % Check if file exists
            if ~isfile(pattern_path)
                error('G41_Tools:FileNotFound', 'Pattern file not found: %s', pattern_path);
            end
            
            % Try to read pattern dimensions
            try
                dims = G41_Tools.get_pattern_dimensions(pattern_path);
            catch ME
                error('G41_Tools:ReadFailed', ...
                      'Failed to read pattern file ''%s'': %s', pattern_path, ME.message);
            end
            
            % Check if dimensions match
            if dims.num_rows ~= expected_rows || dims.num_cols ~= expected_cols
                [~, name, ext] = fileparts(pattern_path);
                filename = [name, ext];
                error_msg = sprintf(...
                    'Pattern ''%s'' has dimensions %dx%d but arena requires %dx%d', ...
                    filename, dims.num_rows, dims.num_cols, expected_rows, expected_cols);
                is_valid = false;
            else
                error_msg = '';
                is_valid = true;
            end

        end

    end


end