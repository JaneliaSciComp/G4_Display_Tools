function update_analysis_file_single(fly_name, filepath)

    %This function creates a small text file containing information about
    %data analyses that have been run on a single fly, located in that
    %fly's folder. 
    
    filename = [fly_name,'_DA_history.txt'];
    
    if ~isfile(fullfile(filepath, filename))
        headers = ["Date", "Analyses Performed", "File Location"];
        create_new_txt_file(fullfile(filepath, filename), headers);
        %create file
        
    end


end