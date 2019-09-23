[plot_path, plot_name, plot_ext] = fileparts(run_con.model.plotting_file);
                plotting_command = plot_name + "(metadata.fly_results_folder, metadata.trial_options)";
                plot_file = strcat(plot_name, plot_ext);

fly_results_folder = 'C:\matlabroot\G4\Experiments\small_field_looms_V2_09-20-19_13-24-31\Results\emptysplit_1';
trial_options = [1 1 1];


[proc_path, proc_name, proc_ext] = fileparts(run_con.model.processing_file);
                processing_command = proc_name + "(fly_results_folder, trial_options)";

                eval(processing_command);
metadata = struct;
metadata.experimenter = run_con.model.experimenter;
metadata.experiment_name = run_con.doc.experiment_name;
metadata.experiment_protocol = run_con.model.run_protocol_file;

%Turn experiment type (1,2, or 3) to matching word
%("Flight", etc)
if run_con.model.experiment_type == 1
    metadata.experiment_type = "Flight";
elseif run_con.model.experiment_type == 2
    metadata.experiment_type = "Camera Walk";
elseif run_con.model.experiment_type == 3
    metadata.experiment_type = "Chip Walk";
end
metadata.fly_name = run_con.model.fly_name;
metadata.genotype = run_con.model.fly_genotype;
metadata.timestamp = run_con.date_and_time_box.String;
metadata.plotting_protocol = run_con.model.plotting_file;
metadata.processing_protocol = run_con.model.processing_file;
if run_con.model.do_plotting == 1
    metadata.do_plotting = "Yes";
elseif run_con.model.do_plotting == 0
    metadata.do_plotting = "No";
end
if run_con.model.do_processing == 1
    metadata.do_processing = "Yes";
elseif run_con.model.do_processing == 0
    metadata.do_processing = "No";
end

metadata.plotting_command = plotting_command;
metadata.fly_results_folder = fly_results_folder;
metadata.trial_options = trial_options;



%assigns the metadata struct to metadata in the base
%workspace so publish can use it.



assignin('base','metadata',metadata);
assignin('base','fly_results_folder',fly_results_folder);
assignin('base','trial_options',trial_options);


%publishes the output (but not code) "create_pdf_script" to
%a pdf file.
options.codeToEvaluate = sprintf('%s(%s,%s,%s)',plot_name,'fly_results_folder','trial_options','metadata');
options.format = 'pdf';
options.outputDir = sprintf('%s',fly_results_folder);
options.showCode = false;
publish(plot_file,options);

plot_filename = strcat(plot_name,'.pdf');
new_plot_filename = strcat(run_con.model.fly_name,'.pdf');
pdf_path = fullfile(fly_results_folder,plot_filename);
new_pdf_path = fullfile(fly_results_folder,new_plot_filename);
movefile(pdf_path, new_pdf_path);