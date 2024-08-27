classdef G4DisplayToolsTests < matlab.unittest.TestCase

    properties
        designer
        conductor
    end

    methods(TestMethodSetup)
        function startDesignerAndConductor(testCase)
            testCase.designer = G4_designer_controller();
            testCase.conductor = G4_conductor_controller();
            testCase.conductor.layout()
        end
    end

    methods(TestMethodTeardown)
        function closeDesignerAndConductor(testCase)
            testCase.designer.view.close_application(testCase.designer.view.f, []);
            testCase.conductor.view.close_application(testCase.conductor.view.fig, []);
        end
    end

    methods(Test, TestTags = {'conductor'})
        
        function openGoogleSheet(testCase)
            try
                testCase.conductor.open_google_sheet();
                pass = true;
            catch ME
                pass = false;
            end
            testCase.verifyTrue(pass, 'Google Sheet failed to open');
        end

    end

    methods(Test, TestTags = {'designer'})
        
        function accessConfigFile(testCase)
            
            config_filepath = testCase.designer.doc.settings.Configuration_Filepath;
            config_data = testCase.designer.doc.configData;

            fid = fopen(config_filepath,'wt');

            testCase.verifyGreaterThanOrEqual(fid,0,"User does not have write permissions to config file.");
            fprintf(fid, '%s\n', config_data{:});
            fclose(fid);

        end

        function importFile(testCase)
%% NOTE: This function will create a pop up window if it passes saying the file has been 
%imported successfully. It will pause the tests until you manually click
%'ok' on the window. 
            num_rows = testCase.designer.doc.num_rows;
            testCase.verifyTrue(num_rows==3 || num_rows==4, "Document shows unexpected number of arena rows")
            s = what('G4_Display_Tools');
            tools_path = s.path;
            if num_rows == 3  
                path = fullfile(tools_path, 'G4_Protocol_Designer\test_protocols\test_protocol_3Rows\Patterns');
                file = '0001_Pat_G4.mat';
            else
                path = fullfile(tools_path, 'G4_Protocol_Designer\test_protocols\test_protocol_4Rows\Patterns');
                file = '0001_Pat_G4.mat';
            end
            try
                testCase.designer.doc.import_single_file(file, path);
                pass = true;
            catch
                pass = false;
            end
            testCase.verifyTrue(pass, ['File ' file ' at ' path ' failed to import']);

        end

        function previewPattern(testCase)
            
            num_rows = testCase.designer.doc.num_rows;
            is_table = 1;
            s = what('G4_Display_Tools');
            tools_path = s.path;
            if num_rows == 3  
                file = fullfile(tools_path, 'G4_Protocol_Designer\test_protocols\test_protocol_3Rows\Patterns\0001_Pat_G4.mat');                
            else
                file = fullfile(tools_path, 'G4_Protocol_Designer\test_protocols\test_protocol_4Rows\Patterns\0001_Pat_G4.mat');
            end
            try
                testCase.designer.preview_selection(is_table, file);
                pass = true;
            catch
                pass = false;
            end
            testCase.verifyTrue(pass, 'Pattern did not preview properly.');

        end

        function openG4p(testCase)


        end

        function saveG4p(testCase)


        end
    end

end