%specify the folder and name to save the pattern file
[filePath, fileName, ~] = fileparts(mfilename('fullpath'));
pattFilePath = filePath;
pattName = 'Pattern_single_bar_4x12';

%make a single bar pattern for G4 system
numRow = 4;
numCol = 12;

%meta data
pattern.x_num = 192; 	
pattern.y_num = 1; 		
pattern.num_panels = numRow*numCol; 	
pattern.gs_val = 4; 	%gs_val is either 1 or 4

%One stretch value for one frame, so the size of stretch matrix should match with the number of frame. 
pattern.stretch = zeros(pattern.x_num, pattern.y_num); 

%frameN is the number of row in dot 
%frameM is the number of column in dot
frameN = 16*numRow;
frameM = 16*numCol;

%generate the pattern data
Pats = zeros(frameN, frameM, pattern.x_num, pattern.y_num);
Pats(:, :, 1, 1) = [15*ones(64,1) zeros(64,191)]; % one stripe

for j = 2:192
    Pats(:,:,j,1) = ShiftMatrix(Pats(:,:,j-1,1),1,'r','y');
end

pattern.Pats = Pats;

%get the vector data for each pattern through function make_pattern_vector_g4
pattern.data = make_pattern_vector_g4(pattern);

%save the mat file
matFileName = fullfile(pattFilePath, [pattName, '.mat']);
save(matFileName, 'pattern');

%save the corresponding binary pat file

patFileName = fullfile(pattFilePath, [pattName, '.pat']);
fileID = fopen(patFileName,'w');
fwrite(fileID, pattern.data);
fclose(fileID);