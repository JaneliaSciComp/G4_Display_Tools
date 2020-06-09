function [P, M, P_flies, M_flies] = generate_M_and_P(mean_pos_series, MP_conds, MP_settings)

    num_figs = length(MP_conds);
    num_cols = size(MP_conds{1},2);
    num_rows = size(MP_conds{1},1);
    num_groups = size(mean_pos_series,1);
    count = 1;
    num_frames = size(mean_pos_series,4);
    num_conds = size(mean_pos_series,3);
    
    P = nan([num_groups, num_conds/2, num_frames]);
    M = nan([num_groups, num_conds/2, num_frames]);
    
    for fig = 1:num_figs
        for row = 1:num_rows
            for col = 1:num_cols
                
                cond = MP_conds{fig}(row,col);
                if cond>0
                    
                    for g = 1:num_groups

    
                        tmp = squeeze(mean_pos_series(g, :,cond,:));
                        tmp2 = squeeze(mean_pos_series(g, :,cond+1,:));
                        if size(mean_pos_series,2) > 1
                            tmp = nanmean(tmp,1);
                            tmp2 = nanmean(tmp2,1);
                        else
                            tmp = permute(tmp,[2 1]);
                            tmp2 = permute(tmp2, [2 1]);
                        end
                        P(g, count, :) = nanmean([tmp; tmp2],1);
                        M(g, count, :) = nanmean([tmp; -tmp2],1);
                        
                        
                    end
                    count = count+1;
                end
            end
        end
    end
    
    if MP_settings.show_individual_flies == 1
        count = 1;
        for fig = 1:num_figs
            for row = 1:num_rows
                for col = 1:num_cols
                    cond = MP_conds{fig}(row,col);
                    if cond > 0
                        for g = 1:num_groups
                            for fly = 1:size(mean_pos_series,2)
                                tmp = squeeze(mean_pos_series(g,fly,cond,:));
                                tmp2 = squeeze(mean_pos_series(g,fly,cond+1,:));
                                if size(tmp,1) > 1
                                    tmp = permute(tmp,[2 1]);
                                    tmp2 = permute(tmp2,[2 1]);
                                end
                                
                                P_flies(g, fly, count, :) = nanmean([tmp; tmp2],1);
                                M_flies(g,  fly, count,  :) = nanmean([tmp; -tmp2],1);
                                

                            end
                        end
                        count = count + 1;
                    end
                end
            end
        end
        
    else
        P_flies = [];
        M_flies = [];
    end
        
        
        
        

end