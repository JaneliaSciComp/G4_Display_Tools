%specify the folder and name to save the pattern file
[filePath, fileName, ~] = fileparts(mfilename('fullpath'));
pattFilePath = filePath;
pattName = 'Pattern_checkBox_4x12';

numRow = 4;
numCol = 12;

%meta data
pattern.x_num = 16; 	
pattern.y_num = 16; 		
pattern.num_panels = numRow*numCol; 	
pattern.gs_val = 4; 	%gs_val is either 1 or 4

%One stretch value for one frame, so the size of stretch matrix should match with the number of frame. 
pattern.stretch = zeros(pattern.x_num, pattern.y_num); 

%frameN is the number of dot on each row 
%frameM is the number of dot on each column
frameN = 16*numRow;
frameM = 16*numCol;

%generate the pattern data
Pats = zeros(frameN, frameM, pattern.x_num, pattern.y_num);

frame = zeros(frameN,frameM);
InitPat = [repmat([zeros(4,4), 15*ones(4,4)], 1,24);repmat([15*ones(4,4), zeros(4,4)], 1,24)];
InitPat = repmat(InitPat, 8,1);
Pats(:,:,1,1) = InitPat;

for j = 2:16
    Pats(:,:,1,j) = ShiftMatrix(Pats(:,:,1,j-1), 1, 'r', 'y'); 
end

for j = 1:16
    for i = 2:16
        Pats(:,:,i,j) = ShiftMatrix(Pats(:,:,i-1,j), 1, 'd', 'y'); 
    end
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