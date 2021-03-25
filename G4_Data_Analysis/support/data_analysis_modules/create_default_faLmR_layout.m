function [falmr_conds] = create_default_faLmR_layout(falmr_data, both_dir)
    
    if ~isempty(falmr_data)
        num_pairs = size(falmr_data,1);

        if both_dir == 1
            num_plots = ceil(num_pairs/2);
            pairs = 1:2:num_pairs;
        else
            num_plots = num_pairs;
            pairs = 1:num_plots;
        end


        default_W = [2 2 2 2 3 3 3 3 3 3 3 3 4 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 5]; %width of figure by number of subplots
        default_H = [1 1 2 2 2 2 3 3 3 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 6 6 6 6 6]; %height of figure by number of subplots

        W = default_W(min([num_plots length(default_W)])); %get number of subplot columns (up to default limit)
        H = default_H(min([num_plots length(default_W)])); %get number of subplot rows
        D = ceil(num_plots/length(default_W)); %number of figures
        p = 1;

        for fig = 1:D
            for col = 1:H
                for row = 1:W
                    if p > length(pairs)
                        falmr_conds{fig}(col,row) = 0;
                    else
                        falmr_conds{fig}(col,row) = pairs(p);
                    end
                    p = p + 1;
                        
                end
            end
        end
            
       

    else 
        falmr_conds = [];
        
    end
   
end