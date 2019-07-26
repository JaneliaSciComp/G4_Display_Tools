[filePath, fileName, ~] = fileparts(mfilename('fullpath'));
aoPath = filePath;
aoName = 'ao_function_sync_test.afn';

%generate the analog output data
anaSig = zeros(17000,1);

anaSig(4501:4749) = 5;
anaSig(12252:12500) = -5;

assert(isvector(anaSig), 'input should be a vector')
assert(max(anaSig) <= 10 && min(anaSig) >= -10, 'input exceeds -10 to 10V range')

%convert the analog voltage value to a int16 between (-32768, 32767)
value = ADConvert(anaSig);

%save header in the first block
block_size = 512; % all data must be in units of block size
Header_block = zeros(1, block_size);
    
Header_block(1:4) = dec2char(length(anaSig)*2, 4);     %each function datum is stored in two bytes
Header_block(5) = length(aoName);
Header_block(6: 6 + length(aoName) -1) = aoName;

%concatenate the header data with function data
aoData = signed_16Bit_to_char(value);     
Data_to_write = [Header_block aoData];

%write to the fun image file
fid = fopen(fullfile(aoPath, aoName), 'w');
fwrite(fid, Data_to_write(:),'uchar');
fclose(fid);