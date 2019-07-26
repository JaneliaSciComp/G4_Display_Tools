[filePath, fileName, ~] = fileparts(mfilename('fullpath'));
funcPath = filePath;
funcName = 'sine_01Hz_100_function.pfn';

% make a 100 position peak to peak 0.1 Hz position sine wave
func = round(16*make_sine_wave_function(20, 50, 0.1));

%save header in the first block
block_size = 512; % all data must be in units of block size
Header_block = zeros(1, block_size);
    
Header_block(1:4) = dec2char(length(func)*2, 4);     %each function datum is stored in two bytes in the currentFunc card
Header_block(5) = length(funcName);
Header_block(6: 6 + length(funcName) -1) = funcName;

%concatenate the header data with function data
functionData = signed_16Bit_to_char(func);     
Data_to_write = [Header_block functionData];

%write to the fun image file
fid = fopen(fullfile(funcPath, funcName), 'w');
fwrite(fid, Data_to_write(:),'uchar');
fclose(fid);