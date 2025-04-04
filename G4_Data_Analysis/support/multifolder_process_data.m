%make sure process_data settings are correct before you run this
%% file paths (user-inputs)
%experiment folder path; exp_folder is the top folder that contains data of the individual flies
exp_folder = fullfile("C:\");
new_dir = uigetdir('C:\Users\kappagantular\Desktop\smallfield_V2_comparison\Results','Select folder containing genotype data');
if new_dir ~= 0
    exp_folder = new_dir;
end

%setting mat file path
set_folder= 'C:\Users\kappagantular\Desktop\smallfield_V2_comparison\processing_settings_badtrials.mat';

%% run process_data script for all the individual flies
%get list of folders (should be for individual flies)
ind_folder=dir(fullfile(exp_folder,'**/*.mat'));
fields = {'name','date', 'bytes', 'isdir', 'datenum'};
check = strcat(reshape(unique(struct2cell(rmfield(ind_folder, fields))),[],1),filesep);

%run process_data
for i = 1:length(check)
   disp("Fly " + i)
   test = string(fullfile(check(i)));
   process_data(test,set_folder)
end

