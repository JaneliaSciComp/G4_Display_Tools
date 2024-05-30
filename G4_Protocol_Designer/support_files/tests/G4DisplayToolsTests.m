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
            testCase.designer.close_application(testCase.designer.f, []);
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
    end


end