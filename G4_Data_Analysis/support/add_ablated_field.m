function add_ablated_field(flyPath, ablated)
    
    commentOptions = {'n', 'b', 'l', 'r'};
    if ~isfile(fullfile(flyPath, 'metadata.mat'))
        disp("Could not find metadata file. Check the fly path provided.")
        return;
    end
    
    if ~strcmp(ablated, commentOptions{1}) && ~strcmp(ablated, commentOptions{2}) && ~strcmp(ablated, commentOptions{3}) && ~strcmp(ablated, commentOptions{4})
        prompt = "Your new ablated value does not match the options 'n', 'b', 'l', or 'r'. Do you wish to continue? (y or n)";
        cont = input(prompt,'s');
    else
        cont = 'y';
    end
    
    if strcmp(cont, 'n')
        return;
    end
    
    load(fullfile(flyPath, 'metadata.mat'));
    metadata.ablated = ablated;
    save(fullfile(flyPath, 'metadata.mat'), 'metadata');

end