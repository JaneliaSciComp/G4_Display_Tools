function outlist = findlogoutliers()
    %% little hack to find log functions with timing outliers
    
    % debug:
    % alllog = findfiles('*11-11-29-50_Frame_Time.tdms', 'C:\matlabroot\G4\Log Files');
    alllog = findfiles('*Frame_Time.tdms', 'C:\matlabroot\G4\Log Files');
    % alllog = findfiles('*Frame_Time.tdms', 'E:\BehavioralRig');
    outlist = {};
    for i = 1:length(alllog)
        cfilename = alllog{i, :};
        cfile = TDMS_readTDMSFile(cfilename);
        maxdiff = max(cfile.data{1,3}(:, 2:end) - cfile.data{1,3}(:, 1:end-1));
        if  maxdiff > 2005
            disp(cfilename);
            ollen = size(outlist,1);
            outlist{ollen+1, 1} = maxdiff;
            outlist{ollen+1, 2} = cfilename;
        end
    end
end