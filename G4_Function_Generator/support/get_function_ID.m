function ID = get_function_ID(function_type,save_dir)
%FUNCTION ID = get_function_ID(function_type,save_dir)
%
%finds the first available function ID number in the specified save directory
%inputs: function_type = 'afn' or 'pfn'
%save_dir: e.g. 'C:/matlabroot/G4/Functions/'

if strcmpi(function_type,'afn')
    ID_inds = 3:6; %first 2 are 'ao', next 4 is ID
elseif strcmpi(function_type,'pfn')
    ID_inds = 4:7; %first 3 are 'fun', next 4 is ID
else
    error('function type must be either afn or pfn')
end

cd(save_dir);
files = ls(['*.' function_type]);
if isempty(files)
    ID = 1;
else
    takenIDs = sort(str2num(files(:,ID_inds)))';
    ID = find((1:size(files,1))-takenIDs<0,1);
    if isempty(ID)
        ID = max(takenIDs)+1;
    end
end

end