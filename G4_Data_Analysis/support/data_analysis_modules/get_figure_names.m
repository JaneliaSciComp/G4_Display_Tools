function [figNames] = get_figure_names(plot_type, figNames, varargin)
    
%If figure names were not provided, generate default ones. If figure names
%were provided, but not enough of them (for example, if a figure name was
%provided for each timeseries datatype, but each datatype will need more
%than one figure to show all plots) this will extend the figure names to
%cover all figures. Ie, it will make sure all figures of each datatype get
%the same figure name. 

    switch plot_type
        case {'ts', 'tc', 'cl_hist'}
            
            datatypes = varargin{1};
            conds = varargin{2};
            if isempty(figNames)
                figNames = string(datatypes);
            end

        case 'hist'
            conds = [];
            if isempty(figNames)
                figNames = ["Histogram"];
            end

        case 'pos'

            conds = varargin{1};
            if isempty(figNames)
                figNames = ["Mean Position Series"];
            end

        case 'mp'

            conds = varargin{1};
            if isempty(figNames)
                figNames = ["M", "P"];
            end

    end
        
   
    orig_figNames = figNames;

    while length(conds) > length(figNames)
        figNames = [figNames, orig_figNames];
    end
    

end