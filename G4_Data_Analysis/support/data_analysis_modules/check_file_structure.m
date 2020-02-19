%Ideal file structure is the following: 

%Top level folder (protocol_filepath) -> Folder for each date -> Each
%fly results folder run on that date named by combination of genotype
%and timestamp. EXAMPLE fly path:

% .../Protocol-1/012120/genotypeA_012120-154321


%This function checks to make sure this structure is in place and returns
%the answer so other functions know how to find things and if they can find
%things. 

%subFolders = list of folders named by date
function [isCorrect] = check_file_structure(filepath, dateFolders)
    
    %If there are no subfolders in the filepath, check for a metadata file.
    %If there is a metadata file this indicates they've passed in a fly
    %folder, not a protocol folder. If not, then this is just an empty or
    %incorrect folderpath. 
    if isempty(dateFolders)
        isCorrect.val = 0;
        [subfiles, ~] = get_files_and_subdirectories(filepath);
        if ~isempty(find(strcmp(subfiles, 'metadata.mat'),1))
            isCorrect.reason = 'fly_folder';
            disp('This looks like a fly folder, not a protocol folder.');
           
        else
            isCorrect.reason = 'empty';
            disp("This folder has no sub-folders or results");

        end
        return;
    end
    
    %Assuming there are subfolders, get the files and folders inside them. 
    %subFolders should be folders named by date.
    %subsubFolders should be fly folders named by genotype_timestamp.
    
    i = 1;
    [subfiles, flyFolders] = get_files_and_subdirectories(fullfile(filepath,dateFolders{1}));
    
    %A given date folder might be empty - doesn't mean there aren't
    %results. So if subsubFolders comes up empty, check them all before
    %determining there are no results. 
    while isempty(flyFolders)
        i = i + 1;
        [subfiles, flyFolders] = get_files_and_subdirectories(fullfile(filepath,dateFolders{i}));
        if i == length(dateFolders) && isempty(flyFolders)
            isCorrect = 0;
            %If they never found any folders in a date folder, it could be
            %that the date folder just has results, and therefore all
            %files. Check for that. 
            if ~isempty(find(strcmp(subfiles, 'metadata.mat'),1))
                isCorrect.reason = 'date folder is fly folder';
            else
                isCorrect.reason = 'all date folders empty';
            end
            return;
        end
    end
    
    %At this point, flyFolders should be a list of fly folders, each of
    %which should have a metadata file. 
    
    [flyfiles, flySubFolders] = get_files_and_subdirectories(fullfile(filepath, dateFolders{i}, flyFolders{1}));

    if ~isempty(find(strcmp(flyfiles,'metadata.mat'),1))
        isCorrect.val = 1;
        isCorrect.reason = '';
        return;
    else
        %If the metadata is not in the fly folder where it should be, check
        %for it in the level above and level below.
        isCorrect.val = 0;
    end
    %check level below
    if ~isempty(flySubFolders)
        path = fullfile(filepath, dateFolders{1}, flyFolders{1}, flySubFolders{1});
        [subsubfiles, ~] = get_files_and_subdirectories(path);
        
        if ~isempty(find(strcmp(subsubfiles,'metadata.mat'),1))
            isCorrect.reason = 'extra folder level';
            return;
            
        else
            
            isCorrect.reason = 'no metadata file in fly folders';

        end
    else
        isCorrect.reason = 'fly results folders are empty';
    end
    

end