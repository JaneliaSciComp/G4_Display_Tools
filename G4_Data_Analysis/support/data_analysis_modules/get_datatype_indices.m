function [Frame_ind, OL_inds, CL_inds, TC_inds] = get_datatype_indices(channelNames, ...
    OL_datatypes, CL_datatypes, TC_datatypes) 

    Frame_ind = find(strcmpi(channelNames.timeseries,'Frame Position'));
    for i = 1:length(OL_datatypes)
        ind = find(strcmpi(channelNames.timeseries,OL_datatypes{i}));
        assert(~isempty(ind),['could not find ' OL_datatypes{i} ' datatype'])
        OL_inds(i) = ind;
    end
    for i = 1:length(CL_datatypes)
        ind = find(strcmpi(channelNames.histograms,CL_datatypes{i}));
        assert(~isempty(ind),['could not find ' CL_datatypes{i} ' datatype'])
        CL_inds(i) = ind;
    end
    for i = 1:length(TC_datatypes)
        ind = find(strcmpi(channelNames.timeseries,TC_datatypes{i}));
        assert(~isempty(ind),['could not find ' TC_datatypes{i} ' datatype'])
        TC_inds(i) = ind;
    end
    
end