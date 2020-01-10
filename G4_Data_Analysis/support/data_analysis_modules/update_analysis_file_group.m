function update_analysis_file_group(group_name, results_path, save_path, analyses_run, files_excluded)

    filename = string([group_name,'_DA_history.txt']);
    date = (datestr(now, 'dd/mm/yy-HH:MM'));
    
    if ~isfile(fullfile(results_path, filename))
        
       % headers = ["Date", "Analysis Performed", "Files Excluded", "Results location"];
        create_new_txt_file(fullfile(results_path, filename));
        
    end
    
    
    for i = 1:length(files_excluded)
        files(i) = files_excluded{i}(1);
        reasons(i) = files_excluded{i}(2);
    end
    
    
    fid = fopen(fullfile(results_path,filename), 'a');
    fprintf(fid, '\n%s\n%s\n\n%s\n', "Date", date, "Analysis Performed");
    for k = 1:length(analyses_run)
        fprintf(fid, '%s\n', analyses_run{k});
    end
    fprintf(fid, '\n%s\n%s\n\n%s\t\t\t\t\t\t\t\t\t\t%s\n', "Results saved at:", results_path, "Files excluded", "Reason");
    for j = 1:length(files_excluded)
        fprintf(fid, '%s\t\t%s\n', files(j), reasons(j));
    end
    fclose(fid);
%     data = {date, analyses_run, files_excluded, save_path};
%     len_array = [];
%     for i = 1:length(data)
%         len_array(i) = length(data{i});
%     end
%     max_len = max(len_array);
%     
%     for j = 1:length(data)
%         if length(data{j}) ~= max_len
%             for k = length(data{j}):max_len-1
%                 data{j}{end+1,1} = '';
%             end
%         end
%     end
%     
    
    % open and append new information on file
        
%     dataTable = table(data{1}, data{2}, data{3}, data{4}, ...
%         'VariableNames', { 'Date', 'AnalysisPerformed', 'FilesExcluded', 'Results' });
%     
%     writetable(dataTable, fullfile(results_path,filename), 'Delimiter', '\t')

end