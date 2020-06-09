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
            
        case 'comp'
            
            conditions = varargin{1};
            conds_per_fig = varargin{2};
            num_figs = ceil(length(conditions)/conds_per_fig);
            if isempty(figNames)
                for f = 1:num_figs
                    start_ind = conds_per_fig*f - (conds_per_fig-1);
                    if f ~= num_figs
                        figNames{f} = ['Comparison_',num2str(conditions(start_ind)),'-',num2str(conditions(start_ind + 3))];
                    else
                        figNames{f} = ['Comparison_',num2str(conditions(start_ind)),'-', num2str(conditions(end))];
                    end
                end
            end
            

    end
    
    if ~strcmp(plot_type,'comp')
        
   
       orig_figNames = figNames;

        while length(conds) > length(figNames)
            figNames = [figNames, orig_figNames];
        end
    end
    

end