function ID = get_pattern_ID(save_dir)
%FUNCTION ID = get_pattern_ID(save_dir)
%
%finds the first available pattern ID number in the specified save directory

cd(save_dir);
patfiles = ls('*.pat');
if isempty(patfiles)
    ID = 1;
else
    takenIDs = sort(str2num(patfiles(:,1:4)))';
    ID = find((1:size(patfiles,1))-takenIDs<0,1);
    if isempty(ID)
        ID = max(takenIDs)+1;
    end
end

end