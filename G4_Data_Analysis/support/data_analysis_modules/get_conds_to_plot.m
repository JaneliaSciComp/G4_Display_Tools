function [conds_vec] = get_conds_to_plot(plot_type, varargin)
    
    
    switch plot_type
        
        case 'cl_hist'
            conditionModes = varargin{1};
            conds_vec = find(conditionModes==4); 


        case 'ts_plot'
            plot_settings = varargin{1};
            conditionModes = varargin{2};

            
            conds_vec = find(conditionModes~=4); 
            
            %this assumes right now that opposing direction conditions
            %are next to each other (1&2, 3&4, etc). Add function later
            %based on different options.
            if ~isempty(conds_vec)
                if plot_settings.plot_both_directions
                    if isempty(plot_settings.opposing_condition_pairs)
                        for i = length(conds_vec):-1:1
                            if rem(conds_vec(i),2) == 0
                                conds_vec(i) = [];
                            end
                        end
                    else
                        conds_vec = [];
                        for pair = 1:length(plot_settings.opposing_condition_pairs)
                            
                            conds_vec(pair) = plot_settings.opposing_condition_pairs{pair}(1);
                        end
                    end
                end
            end
           

        case 'pos_plot'
            plot_settings = varargin{1};
            pos_conditions = varargin{2};
            
            conds_vec = pos_conditions;
            
            if ~isempty(conds_vec)
                if plot_settings.plot_opposing_directions == 1
                    for i = length(conds_vec):-1:1
                        if rem(conds_vec(i),2) == 0
                            conds_vec(i) = [];
                        end
                    end
                end
            end

        case 'mp_plot'
            
            pos_conditions = varargin{1};
            conds_vec = pos_conditions;
            if ~isempty(conds_vec)
                for i = length(conds_vec):-1:1
                    if rem(conds_vec(i),2) == 0
                        conds_vec(i) = [];
                    end
                end

            end    
    end
  
            
            
            


end