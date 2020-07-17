function ordered_files = order_pdfs(plot_type_order, norm_order, path)
    
    all = dir(path);
    isub = [all(:).isdir];
    for i = 1:length(isub)
        if isub(i) == 1
            isub(i) = 0;
        else
            isub(i) = 1;
        end
    end
    filenames = {all(isub).name};
    for file = length(filenames):-1:1
        if strcmp(filenames{file}(1), '.')
            filenames(file) = [];
        end
    end
    
    ordered_files = {};
    for type = 1:length(plot_type_order)
        norm_num_ordered = {};
        unnorm_num_ordered = {};
        norm_ordered = {};
        unnorm_ordered = {};
        names_of_type = {};
        norm_string = 'Normalized';
        inds = find(contains(filenames, plot_type_order{type}));
        if isempty(inds)
            continue;
        end
        
        
        if strcmp(plot_type_order{type}, 'Comparison')
            
            for compi = 1:length(inds)
                names_of_type{compi} = filenames{inds(compi)};
            end
            
            ranges = {};
            for ty = 1:length(names_of_type)
                und = strfind(names_of_type{ty}, '_');
                last_und = und(end);
                dot = strfind(names_of_type{ty},'.');
                ranges{ty} = names_of_type{ty}(last_und+1:dot-1);
                dash = strfind(ranges{ty}, '-');
                first_nums{ty} = str2num(ranges{ty}(1:dash-1));
     
            end
            first_nums = cell2mat(first_nums);
            [~,p] = sort(first_nums, 'ascend');
            r = 1:length(first_nums);
            r(p) = r;
            
            ordered_comps = {};
            for comp = 1:length(names_of_type)
                ordered_comps{r(comp)} = names_of_type{comp};
            end
            
            ordered_files = [ordered_files, ordered_comps];
            
            % run function to order comparison plots
            continue;
        end
        
        
        for i = 1:length(inds)
            names_of_type{i} = filenames{inds(i)};
        end
        
        if ~isempty(find(contains(names_of_type, norm_string)))
            norm_inds = find(contains(names_of_type, norm_string));
            for ni = length(norm_inds):-1:1
                norm_ordered{ni} = names_of_type{norm_inds(ni)};
                names_of_type(norm_inds(ni)) = [];
            end
            %order norm_ordered numerically
            num_figs = 1;
            
            while ~isempty(norm_ordered)
                for no = length(norm_ordered):-1:1
                    if strcmp(norm_ordered{no}(end-4),string(num_figs))
                        norm_num_ordered{end+1} = norm_ordered{no};
                        norm_ordered(no) = [];
                    end
                end
                num_figs = num_figs + 1;
            end
        end

                
        if ~isempty(names_of_type)
            for ui = length(names_of_type):-1:1
                unnorm_ordered{ui} = names_of_type{ui};
                names_of_type(ui) = [];
            end
        else
            unnorm_ordered = {};
        end
        num_figs = 1;
        while ~isempty(unnorm_ordered)
            for ul = length(unnorm_ordered):-1:1
                if strcmp(unnorm_ordered{ul}(end-4),string(num_figs))
                    unnorm_num_ordered{end+1} = unnorm_ordered{ul};
                    unnorm_ordered(ul) = [];
                end
            end
            num_figs = num_figs + 1;
        end
    
        if strcmp(norm_order{1}, 'normalized')
            ordered_files = [ordered_files, norm_num_ordered, unnorm_num_ordered];
        else
            ordered_files = [ordered_files, unnorm_num_ordered, norm_num_ordered];
        end
        
              
    end

    
end