function [opp_cond] = get_opposing_condition(cond, cond_pairs)
    
    %cond_pairs is a cell array of two digit arrays like so:
    
%     cond_pairs{1} = [1 6];
%     cond_pairs{2} = [2 5];
%     cond_pairs{3} = [3 8];
% .   etc

% This function takes in a condition and finds its match my searching
% through cond_pairs for the first pair to contain that condition. 

% It assumes that no condition will be in multiple pairs, so each condition
% should be present exactly once. If the condition is not found in the list
% of pairs, this function returns the condition that was passed in and
% displays a message to the user. 
    pair = 1;
    
    if isempty(cond_pairs)
        opp_cond = cond + 1;
        return;
    end
    
    while pair <= length(cond_pairs) && cond_pairs{pair}(1) ~= cond && cond_pairs{pair}(2) ~= cond 
        
            pair = pair + 1;
        
    end
    
    if pair > length(cond_pairs)
        disp("Condition " + string(cond) + " not found in the list of condition pairs.");
        opp_cond = cond;
        return;
    end
    
    if cond_pairs{pair}(1) == cond
        opp_cond = cond_pairs{pair}(2);
    else
        opp_cond = cond_pairs{pair}(1);
    end
    

    

end