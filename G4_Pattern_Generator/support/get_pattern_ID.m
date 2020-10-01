function ID = get_pattern_ID(save_dir)
%FUNCTION ID = get_pattern_ID(save_dir)
%
%finds the first available pattern ID number in the specified save directory

cd(save_dir);
patfiles = ls('*.pat');
if isempty(patfiles)
    ID = 1;
else
    takenIDs = [];
    for i = 1:size(patfiles,1)
        num_inds = regexp(patfiles(i,:),'\d');
        assert(length(num_inds)==4,['file ' patfiles(i,:) ' appears to have incorrect ID (should be 4 digits)']);
        takenIDs = [takenIDs str2double(patfiles(i,num_inds))];
    end
    takenIDs = sort(takenIDs);
    ID = find((1:size(patfiles,1))-takenIDs<0,1);
    if isempty(ID)
        ID = max(takenIDs)+1;
    end
end

end