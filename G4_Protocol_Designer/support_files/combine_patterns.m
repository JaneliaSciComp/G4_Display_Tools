function new_pat = combine_patterns(pat_file1, pat_file2, pat_to_edit, num_to_replace)
    
    pat1 = load(pat_file1, 'pattern');
    pat2 = load(pat_file2, 'pattern');
    
    pat1_data = pat1.pattern.Pats;
    pat2_data = pat2.pattern.Pats;
    
    if nargin < 4
        num_to_replace = 0;
    end
    if nargin < 3
        pat_to_edit = pat_file1;
    end
    
    if size(pat1_data) ~= size(pat2_data)
        disp("patterns being combined must be the same size");
        return;
    end
    new_pat = zeros(size(pat1_data));
    
    if strcmp(pat_to_edit, pat_file1)
    
        for height = 1:size(pat1_data,1)
            for width = 1:size(pat1_data,2)
                for depth = 1:size(pat1_data,3)

                    if pat1_data(height, width, depth) == num_to_replace
                        new_pat(height, width, depth) = pat2_data(height, width, depth);
                    else
                        new_pat(height, width, depth) = pat1_data(height, width, depth);
                    end

                end
            end
        end
        
    elseif strcmp(pat_to_edit, pat_file2)
        
        for height = 1:size(pat1_data,1)
            for width = 1:size(pat1_data,2)
                for depth = 1:size(pat1_data,3)

                    if pat2_data(height, width, depth) == num_to_replace
                        new_pat(height, width, depth) = pat1_data(height, width, depth);
                    else
                        new_pat(height, width, depth) = pat2_data(height, width, depth);
                    end

                end
            end
        end
        
    else
        
        disp("third input, the pattern to edit, must match one of the pattern files.");
        return;
    end
        
        
    
    
    


end