[filePath, fileName, ~] = fileparts(mfilename('fullpath'));
aoPath = filePath;
aoName = 'ao_function_+10_-10.afn';

%generate the analog output data
temSig = ones(1000,1);
anaSig = zeros(21000,1);

for i = 1:21
    voltage = i -11;
    anaSig((i-1)*1000+1:(i*1000)) = temSig*voltage;
end

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