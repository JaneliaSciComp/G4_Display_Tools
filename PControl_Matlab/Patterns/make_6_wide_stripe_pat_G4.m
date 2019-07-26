%specify the folder and name to save the pattern file
[filePath, fileName, ~] = fileparts(mfilename('fullpath'));
pattFilePath = filePath;
pattName = 'Pattern_6_wide_stripe_4x12';

numRow = 4;
numCol = 12;

%meta data
pattern.x_num = 192; 	
pattern.y_num = 4; 		
pattern.num_panels = numRow*numCol; 	
pattern.gs_val = 1; 	%gs_val is either 1 or 4

%One stretch value for one frame, so the size of stretch matrix should match with the number of frame. 
pattern.stretch = zeros(pattern.x_num, pattern.y_num); 

%frameN is the number of dot on each row 
%frameM is the number of dot on each column
frameN = 16*numRow;
frameM = 16*numCol;

%generate the pattern data
Pats = zeros(frameN, frameM, pattern.x_num, pattern.y_num);
Pats(:, :, 1, 1) = [ones(64,186) zeros(64,6)]; % one stripe
% two stripes, 90 degs apart
Pats(:, :, 1, 2) = [ones(64,6) zeros(64,6) ones(64,162) zeros(64,6) ones(64,12)]; 
% 3 stripes
Pats(:, :, 1, 3) = repmat([ones(64, 58) zeros(64,6)], 1, 3);
% 8 stripes
Pats(:, :, 1, 4) = repmat([ones(64, 18) zeros(64,6)], 1, 8);

for j = 2:192
    Pats(:,:,j,1) = ShiftMatrix(Pats(:,:,j-1,1),1,'r','y');
    Pats(:,:,j,2) = ShiftMatrix(Pats(:,:,j-1,2),1,'r','y');
    Pats(:,:,j,3) = ShiftMatrix(Pats(:,:,j-1,3),1,'r','y');
    Pats(:,:,j,4) = ShiftMatrix(Pats(:,:,j-1,4),1,'r','y');
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