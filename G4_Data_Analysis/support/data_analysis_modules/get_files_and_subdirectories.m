function [files, subFolders] = get_files_and_subdirectories(path)
    
    allfiles = dir(path);
    
    %remove hidden directories like '.','..', and '.DS_store'
    allNames = {allfiles(:).name};
    hidden_ind = startsWith(allNames,'.');
    allfiles(hidden_ind) = [];
    
    % Save all names of subfolders in subFolders
    isub = [allfiles(:).isdir];
    subFolders = {allfiles(isub).name};
    
    % Get names of all files (non-directories) and save in files.

    files = {allfiles(~isub).name};


end