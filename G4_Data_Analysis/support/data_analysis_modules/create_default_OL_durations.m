function [OL_durs] = create_default_OL_durations(OL_conds, timeseries_data, timestamps)
    
    for i = 1:length(OL_conds)
        for j = 1:length(OL_conds{i}(:,1))
            for k = 1:length(OL_conds{i}(1,:))
                
                if isnan(OL_conds{i}(j,k))
                    OL_durs{i}(j,k) = nan;
                    continue;
                end
                nanInd = find(isnan(timeseries_data(1,OL_conds{i}(j,k),:)));
                
                m = 1;
                if nanInd(1) == 1
                    while(nanInd(m+1)-nanInd(m) == 1) && m < length(nanInd) - 1
                        m = m + 1; 
                        
                            
                    end
                    if m < length(nanInd) - 1
                        firstNanInd = m + 1;
                    else
                        firstNanInd = 0;
                    end
                else
                    firstNanInd = 1;
                end
                
                if firstNanInd ~= 0
                   firstNan = nanInd(firstNanInd);
                   time = timestamps(firstNan);
                else
                    time = timestamps(end);
                end

                
                OL_durs{i}(j,k) = time;
                
            
            end
            
        end
    end

end