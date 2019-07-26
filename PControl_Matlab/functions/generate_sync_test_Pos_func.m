[filePath, fileName, ~] = fileparts(mfilename('fullpath'));
funcPath = filePath;
funcName = 'sync_test_function_x.pfn';

%generate the function data
func = zeros(17000,1);
for i=1:16
    func(1001+250*(i-1):1001+250*i) = i-1;
    func(5001+250*(i-1):5001+250*i) = i-16;
    func(9001+250*(i-1):9001+250*i) = i-1;
    func(13001+250*(i-1):13001+250*i) = i-16;
end

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