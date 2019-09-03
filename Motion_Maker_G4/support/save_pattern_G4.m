function save_pattern_G4(Pats, param, save_dir, filename, Pats2)
% FUNCTION save_pattern_G4(Pats, param, save_loc, filename)
% 
% Saves the Pats variable to both .mat and .pat files, the former of which
% can be easily read back into Matlab and the latter a binary file which is
% used to display the pattern on the G4 LED arena.
%
% inputs:
% Pats: array of brightness values for each pixel in the arena
% param: full parameters of the input pattern to be stored in .mat file
% save_loc: directory to store the pattern files
% filename: desired name of the .mat pattern file
% Pats2: (optional, only used for checkerboard layouts) array of brightness 
%        values for each pixel in the arena for 2nd half of checkerboard -
%        if left blank, Pats will be duplicated for both halves of 
%        checkerboard

%rearrgange pattern if using checkerboard layout
if isfield(param,'checker_layout')
    if param.checker_layout==1
        if nargin<5
            Pats2 = Pats;
        end
        Pats = checkerboard_pattern(Pats, Pats2);
    end
else
    param.checker_layout = 0;
end

pattern.Pats = Pats;
pattern.x_num = length(Pats(1,1,:,1));
pattern.y_num = length(Pats(1,1,1,:));
pattern.gs_val = param.gs_val; 
pattern.stretch = param.stretch;
pattern.param = param; %store full pattern parameters

%get the vector data for each pattern through function make_pattern_vector_g4
if exist('make_pattern_vector_g4','file')
    pattern.data = make_pattern_vector_g4(pattern);
else
    disp('could not save binary .pat file; missing script from PControl');
end

%create save directory if it doesn't exist
if ~exist(save_dir,'dir')
    mkdir(save_dir)
end

%create file name strings
matFileName = fullfile(save_dir, [num2str(param.ID,'%04d') '_' filename '_G4.mat']);
if exist(matFileName,'file')
    error('pattern .mat file already exists in save folder with that name')
end
patFileName = fullfile(save_dir, ['pat' num2str(param.ID,'%04d') '.pat']);
if exist(patFileName,'file')
    error('pattern .pat file already exists in save folder with that name')
end
    
%save pattern .mat file
save(matFileName, 'pattern');

%save the corresponding binary pat file
if exist('make_pattern_vector_g4','file')
    fileID = fopen(patFileName,'w');
    fwrite(fileID, pattern.data);
    fclose(fileID);
end

end