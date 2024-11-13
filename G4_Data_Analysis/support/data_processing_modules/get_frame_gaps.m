function [expected_frame_moves, frame_moves] = get_frame_gaps(position_functions, ...
    unaligned_cond_data, Frame_ind)

expected_frame_moves = [];
    for posfunc = 1:length(position_functions)
        count = 1;
        for pt = 1:length(position_functions{posfunc})-1            
            if position_functions{posfunc}(pt+1) - position_functions{posfunc}(pt) ~= 0 
                expected_frame_moves(posfunc, count) = pt+1;
                count = count + 1;   
            end
        end
    end
    frame_moves = nan([size(squeeze(unaligned_cond_data(Frame_ind, :,:,:)))]);
    for cond = 1:size(unaligned_cond_data,2)
        for rep = 1:size(unaligned_cond_data,3)
            c = 1;
            for t = 1:size(unaligned_cond_data,4)
                if unaligned_cond_data(Frame_ind, cond, rep, t+1)-unaligned_cond_data(Frame_ind, cond, rep, t)~= 0
                    frame_moves(cond, rep, c) = t+1;
                    c = c+1;
                end
            end
        end
    end

end