function [figNames] = extend_figure_names(figNames, conds)
    
%if there are more more figures being generated than there are names for,
%this repeats the figure names in order. For example, if you have figure
%names for each timeseries datatype, but each datatype requires three
%figures to get all the plots out, this will make sure all figures of a
%particular datatype get the same figure name. 

    orig_figNames = figNames;

    while length(conds) > length(figNames)
        figNames = [figNames, orig_figNames];
    end
    

end