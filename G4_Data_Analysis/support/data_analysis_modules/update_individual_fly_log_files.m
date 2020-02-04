function update_individual_fly_log_files(exp_folder, save_path, analyses_run, files_excluded)
    
    date = (datestr(now, 'dd/mm/yy-HH:MM'));
    if isempty(files_excluded)
        files = [];
        reasons = [];
    else
        
        for i = 1:length(files_excluded)
            files(i) = files_excluded{i}(1);
            reasons(i) = files_excluded{i}(2);
        end
    end
    for i = 1:length(exp_folder(:,1))
        for q = 1:length(exp_folder(1,:))
        
           fly_path = exp_folder{i,q};
           if ~isempty(fly_path)
               [path, fly_name] = fileparts(fly_path);
               log_filename = [fly_name,'_DA_history.txt'];
               log_filepath = fullfile(fly_path, log_filename);

               if ~isfile(log_filepath)
                   create_new_txt_file(log_filepath);
               end

               fid = fopen(log_filepath, 'a');

               if ~isempty(find(strcmp(files, fly_path),1))
                   index = strcmp(files, fly_path);
                   fprintf(fid, '%s\n%s\n\n%s\n', "Date:", date, "Analyses Attempted:");
                   for j = 1:length(analyses_run)
                       fprintf(fid, '%s\n', analyses_run{j});
                   end

                   fprintf(fid, '\n%s\n%s\n\n%s\n%s\n\n', "Fly not included because:", reasons(index), ...
                       "Analysis results located at:", save_path);

               else

                    fprintf(fid, '%s\n%s\n\n%s\n', "Date:", date, "Analyses Performed:");
                    for j = 1:length(analyses_run)
                        fprintf(fid, '%s\n', analyses_run{j});
                    end

                    fprintf(fid, '\n%s\n%s\n\n', "Analysis results located at:", save_path);

               end

                fclose(fid);
           end
        end
    end
    %Loop through exp_folder
    %Check the files_excluded list for each item - if it is in
    %files_excluded, then say so in log file
    %Otherwise put analysis type and where it was saved.

end