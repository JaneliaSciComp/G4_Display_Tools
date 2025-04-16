function [g4ppath] = get_g4p_file(path)

% To be used when the path passed in is to a folder other than the
% protocol.

    [files, ~] = get_files_and_subdirectories(path);
    %check results path and make sure it has a .g4p file in it. 
    
    file_index = find(contains(files, '.g4p'));

    %If there is no g4p file, prompt the user to browse to the protocol
    %folder
    if isempty(file_index)
        new_dir = uigetdir(path, "Please select your protocol folder");
        if new_dir ~= 0
            path = new_dir
        end
        [files, ~] = get_files_and_subdirectories(path);
        file_index = find(contains(files, '.g4p'));
    end
    
    if isempty(file_index)
        disp("There is no .g4p file in this protocol folder");
        g4ppath = [];
    else
        g4ppath = fullfile(path, files{file_index});
    end

    


end