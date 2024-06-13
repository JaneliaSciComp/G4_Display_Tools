%G4 Protocol Designer Settings
%--------------------------------------------------------------------------

function settings = G4_Protocol_Designer_Settings()

%% config file
settings.Configuration_Filepath = "/Users/lisaferguson/Documents/Programming/Reiser/HHMI Panels Configuration.ini";

%% Google sheet settings
settings.Google_Sheet_Key = "1g4IYtTNq-QAaGgPDIut5P_5y6CNWU0azGazq4zguqw8";
settings.Users_Sheet_GID = "0";
settings.Fly_Age_Sheet_GID = "149111612";
settings.Fly_Sex_Sheet_GID = "37065023";
settings.Fly_Geno_Sheet_GID = "1459345335";
settings.Experiment_Temp_Sheet_GID = "1073536469";
settings.Rearing_Protocol_Sheet_GID = "2007977020";
settings.Light_Cycle_Sheet_GID = "1154672887";

%% Default Files
settings.run_protocol_file = "C:\matlabroot\G4_Display_Tools\G4_Protocol_Designer\run_protocols\G4_default_run_protocol.m";
settings.processing_file = "";
settings.plotting_file = "";

settings.test_run_protocol_file = "C:\matlabroot\G4_Display_Tools\G4_Protocol_Designer\run_protocols\G4_default_run_protocol.m";
settings.test_processing_file = "";
settings.test_plotting_file = "";

settings.test_protocol_file_flight = "C:\matlabroot\G4_Display_Tools\G4_Protocol_Designer\test_protocols\test_protocol_4Rows\test_protocol_4Rows.g4p";
settings.test_protocol_file_camWalk = "";
settings.test_protocol_file_chipWalk = "";

%% Appearance settings
settings.Overlapping_Graphs = 0; %0 for no, 1 for yes
settings.Uneditable_Cell_Color = "#bdbdbd";
settings.Uneditable_Cell_Text = "---------";

end















