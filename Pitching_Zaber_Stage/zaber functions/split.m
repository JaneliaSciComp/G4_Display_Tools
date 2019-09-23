function parts = split(string)

    inds = strfind(string,' ');
    num_inds = length(inds);
    
    if num_inds==0
        parts{1} = string;
    else
        parts = cell(1,num_inds);
        parts{1} = string(1:inds(1)-1);
        inds = [inds length(string)+1];
        for i = 1:num_inds
            parts{i+1} = string(inds(i)+1:inds(i+1)-1);
        end
    end
end