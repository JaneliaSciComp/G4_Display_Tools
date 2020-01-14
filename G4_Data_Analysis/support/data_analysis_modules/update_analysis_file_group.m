function update_analysis_file_group(group_name, results_path, save_path, analyses_run, files_excluded, OL_dt, CL_dt, TC_dt, geno)

    filename = string([group_name,'_DA_history.txt']);
    date = (datestr(now, 'dd/mm/yy-HH:MM'));
    
    %Create a log file if one does not exist
    if ~isfile(fullfile(results_path, filename))
        
       % headers = ["Date", "Analysis Performed", "Files Excluded", "Results location"];
        create_new_txt_file(fullfile(results_path, filename));
        
    end
    
    %Split up the files that were excluded and their reasons for ease
    for i = 1:length(files_excluded)
        files(i) = files_excluded{i}(1);
        reasons(i) = files_excluded{i}(2);
    end
    
    %Open log file
    fid = fopen(fullfile(results_path,filename), 'a');
    
    %Print the date and analyes performed header
    fprintf(fid, '\n%s\n%s\n\n%s\n', "Date:", date, "Analysis Performed:");
    
    %Loop through the analyses performed and print each one
    for k = 1:length(analyses_run)
        fprintf(fid, '%s\n', analyses_run{k});
    end
    
    %If TS plots were run, print the datatypes used
    if ~isempty(find(strcmp(analyses_run, "Timeseries Plots"),1))
        fprintf(fid, '\n%s\n', "Open Loop Datatypes:");
        for m = 1:length(OL_dt)
            fprintf(fid, '%s\n', OL_dt{m});
        end
    end
    
    %If closed loop histograms were run, print the datatypes used
    if ~isempty(find(strcmp(analyses_run, "CL histograms"),1))
        fprintf(fid, '\n%s\n', "Closed Loop Datatypes:");
        for n = 1:length(CL_dt)
            fprintf(fid, '\n%s\n', CL_dt{n});
        end
    end
    
    %If tuning curvers were run, print the datatypes used
    if ~isempty(find(strcmp(analyses_run, "Tuning Curves"),1))
        fprintf(fid, '\n%s\n', "Tuning Curve Datatypes:");
        for z = 1:length(TC_dt)
            fprintf(fid, '\n%s\n', TC_dt{z});
        end
    end
    
    %if genotypes were analyzed, print which genotypes. 
    if ~isempty(geno)
        fprintf(fid, '\n%s\n', "Genotypes Analyzed:");
        for s = 1:length(geno)
            fprintf(fid, '%s\n', geno{s});
        end
    end
    
    %Give location of analysis results,which flies if any were left
    %out, and why
    
    fprintf(fid, '\n%s\n%s\n\n%s\t\t\t\t\t\t\t\t\t\t%s\n', "Results saved at:", save_path, "Files excluded:", "Reason:");
    for j = 1:length(files_excluded)
        fprintf(fid, '%s\t\t%s\n', files(j), reasons(j));
    end
    
    fclose(fid);


end