function save_function_G4(func, param, save_dir, filename)
% FUNCTION save_function_G4(type, func, save_dir, filename)
% 
% Saves the func variable to both .mat and .pfn (or .afn) files, the former 
% of which can be easily read back into Matlab and the latter a file which 
% is read by the controller.
%
% inputs:
% func: array of function values
% param: full parameters of the input function to be stored in .mat file
% save_dir: directory to store the function files
% filename: desired name of the .mat function file


assert(isvector(func), 'input should be a vector')

param.func = func; %save full function in param structure

%determine function type
if strcmp(param.type,'pfn')
    func = func-1; % frame array starts at 0
    prefix = 'fun';
elseif strcmp(param.type,'afn')
    assert(max(func) <= 10 && min(func) >= -10, 'input exceeds -10 to 10V range')
    func = ADConvert(func); %convert the analog voltage value to a int16 between (-32768, 32767)
    prefix = 'ao';
else
    error('function type must either be "afn" or "pfn"')
end

%create file name
funcname = [prefix num2str(param.ID, '%04d')];
    
%save header in the first block
block_size = 512; % all data must be in units of block size
Header_block = zeros(1, block_size);
    
Header_block(1:4) = dec2char(length(func)*2, 4);     %each function datum is stored in two bytes in the currentFunc card
Header_block(5) = length(funcname);
Header_block(6: 6 + length(funcname) -1) = funcname;

%concatenate the header data with function data
Data = signed_16Bit_to_char(func);     
Data_to_write = [Header_block Data];
param.size = length(Data);

%save .mat file
matFileName = fullfile(save_dir, [num2str(param.ID,'%04d') '_' filename '_G4.mat']);
if exist(matFileName,'file')
    error('function .mat file already exists in save folder with that name')
end
if strcmp(param.type,'pfn')==1
    pfnparam = param;
    save(matFileName, 'pfnparam');
else
    afnparam = param;
    save(matFileName, 'afnparam');
end

%save function file
if exist(fullfile(save_dir, [funcname '.' param.type]),'file')
    error('function file already exists with that name')
end
fid = fopen(fullfile(save_dir, [funcname '.' param.type]), 'w');
fwrite(fid, Data_to_write(:),'uchar');
fclose(fid);