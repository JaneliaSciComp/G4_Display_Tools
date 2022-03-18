classdef PanelsControllerFunctionalTest < matlab.unittest.TestCase
    
    properties
        panelsController
    end

    methods(TestMethodSetup)
        function startNewHost(testCase)
            testCase.panelsController = PanelsController();
            testCase.panelsController.open(true);
        end
     end
    
    methods(TestMethodTeardown)
        function stopHost(testCase)
            testCase.panelsController.close(true);
        end
    end
    
    methods(Test, TestTags = {'MainHost', 'PanelsController'})
        function stopDisplay(testCase)
            for i = 1:100
                testCase.verifyTrue(testCase.panelsController.stopDisplay(), ...
                    sprintf("PanelsController.stopDisplay didn't successfully complete for iteration %d.", i));
            end
        end
        
        function sendAllOn(testCase)
            for i = 1:100
                testCase.verifyTrue(testCase.panelsController.allOn(), ...
                    sprintf("PanelsController.allOn wasn't successfully completed in iteration %d.", i));
            end
        end
        
        function sendAllOff(testCase)
            for i = 1:100
                testCase.verifyTrue(testCase.panelsController.allOff(), ...
                    sprintf("PanelController.allOff wasn't successfully completed in iteration %d", i));
            end
        end
        
        function sendAllOnAndOff(testCase)
            for i = 1:15
                testCase.verifyTrue(testCase.panelsController.allOn(), ...
                    sprintf("PanelsController.allOn wasn't successfully completed in iteration %d.", i));
                testCase.verifyTrue(testCase.panelsController.allOff(), ...
                    sprintf("PanelController.allOff wasn't successfully completed in iteration %d", i));
                testCase.verifyTrue(testCase.panelsController.allOn(), ...
                    sprintf("PanelsController.allOn wasn't successfully completed in iteration %d.", i));
                testCase.verifyTrue(testCase.panelsController.allOff(), ...
                    sprintf("PanelController.allOff wasn't successfully completed in iteration %d", i));
            end
        end
        
        function sendAllOnAndOffWithDelay(testCase)
            delayOnOff = 0.004;
            delayOffOn = 0;
            boff = tic;
            for i = 1:1000000
                while toc(boff) < delayOffOn
                end
                bon = tic;
                testCase.verifyTrue(testCase.panelsController.allOn(), ...
                    sprintf("PanelsController.allOn wasn't successfully completed in iteration %d, round 1.", i));
                while toc(bon) < delayOnOff
                end
                boff = tic;
                testCase.verifyTrue(testCase.panelsController.allOff(), ...
                    sprintf("PanelController.allOff wasn't successfully completed in iteration %d, round 1.", i));
                while toc(boff) < delayOffOn % Copy&Paste earlier code to reduce the delay introduced by for-loop.
                end
                bon = tic;
                testCase.verifyTrue(testCase.panelsController.allOn(), ...
                    sprintf("PanelsController.allOn wasn't successfully completed in iteration %d, round 2.", i));
                while toc(bon) < delayOnOff
                end
                boff = tic;
                testCase.verifyTrue(testCase.panelsController.allOff(), ...
                    sprintf("PanelController.allOff wasn't successfully completed in iteration %d, round 2", i));
            end
        end
        
        function sendRootDirectory(testCase)
            testCase.verifyTrue(testCase.panelsController.setRootDirectory("C:\matlabroot\G4"), ...
                "PanelsController.setRootDirectory wasn't successfully completed.");
            testCase.verifyFalse(testCase.panelsController.setRootDirectory(tempname, false), ...
                "PanelsController.setRootDirectory didn't fail for a non-existing directory.");
            newDir = tempname;
            testCase.verifyTrue(testCase.panelsController.setRootDirectory(newDir, true), ...
                "PanelsController.setRootDirectory wasn't successfully completed for a non-existing directory.");
            testCase.verifyTrue(rmdir(newDir, 's'), "temporary directory wasn't removed successfully");
        end
        
        function sendActiveAO(testCase)
            for i = [0:15]
                onOff = str2num(char(num2cell(dec2bin(i))))';
                onOff = padarray(onOff, [0 4-length(onOff)], 0, 'pre');
                testCase.verifyTrue(testCase.panelsController.setActiveAOChannels(onOff), ...
                    sprintf("PanelsController.setActiveAOChannels wasn't successfully completed for %d", i));
            end
        end
        
        function sendActiveAI(testCase)
            for i = [0:15]
                onOff = str2num(char(num2cell(dec2bin(i))))';
                onOff = padarray(onOff, [0 4-length(onOff)], 0, 'pre');
                testCase.verifyTrue(testCase.panelsController.setActiveAIChannels(onOff), ...
                    sprintf("PanelsController.setActiveAIChannels wasn't successfully completed for %d", i));
            end
        end
        
        function testLoggingRepeatedOn(testCase)
             for i = [0:15]
                 testCase.verifyTrue(testCase.panelsController.startLog(), ...
                    sprintf("Starting the log didn't work in iteration %d", i));
             end
             testCase.panelsController.stopLog();
        end
        
        function testLoggingRepeatedOff(testCase)
              testCase.panelsController.startLog();
              for i = [0:15]
                 testCase.verifyTrue(testCase.panelsController.stopLog(), ...
                    sprintf("Stopping the log didn't work in iteration %d", i));
             end
        end
        
        function testLogging(testCase)
            for i = [0:15]
                testCase.verifyTrue(testCase.panelsController.startLog(), ...
                    sprintf("Starting the log didn't work in iteration %d", i));
                testCase.verifyTrue(testCase.panelsController.stopLog(), ...
                    sprintf("Stopping the log didn't work in iteration %d", i));
            end
        end

        function testControlMode(testCase)
            for i = randi([0,7], 1,10)
                testCase.verifyTrue(testCase.panelsController.setControlMode(i), ...
                    sprintf("Setting the control mode to %d didn't work", i));
            end
        end
        
        function testControlModeFail(testCase)
            testCase.verifyError(@()testCase.panelsController.setControlMode(2.7), 'MATLAB:validators:mustBeInteger', ...
                "Trying to set a non-integer value for control mode didn't fail as expected.");
            testCase.verifyError(@()testCase.panelsController.setControlMode(-1), 'MATLAB:validators:mustBeGreaterThanOrEqual', ...
                "Setting a negative control mode didn't fail as expected.");
            testCase.verifyError(@()testCase.panelsController.setControlMode(8), 'MATLAB:validators:mustBeLessThanOrEqual', ...
                "Setting a control mode > 7 didn't fail as expected.");
        end
        
        function testSetPatternID(testCase)
            testCase.panelsController.setRootDirectory("C:\matlabroot\G4");
            testCase.verifyTrue(testCase.panelsController.setPatternID(1), ...
                "Setting pattern 1 didn't work (make sure pattern 1 exists in root directory).");
        end
        
        function setPositionX(testCase)
            testCase.panelsController.setRootDirectory("C:\matlabroot\G4");
            testCase.panelsController.setControlMode(3);
            for i = randi([0 65535], 1, 50)
                testCase.verifyWarningFree(@() testCase.panelsController.setPositionX(i), ...
                    sprintf("Couldn't set position X to %d", i));
            end
        end
        
        function setPositionY(testCase)
            testCase.panelsController.setRootDirectory("C:\matlabroot\G4");
            testCase.panelsController.setControlMode(3);
            for i = randi([0 65535], 1, 50)
                testCase.verifyWarningFree(...
                    @() testCase.panelsController.setPositionY(i), ...
                    sprintf("Couldn't set position Y to %d", i));
            end
        end
        
        function sendPositionIDAndFunctionID(testCase)
            testCase.panelsController.setRootDirectory("C:\matlabroot\G4");
            testCase.panelsController.setControlMode(3);
            for ii = randi([0 65535], 2, 50)
                testCase.verifyWarningFree(...
                    @() testCase.panelsController.setPositionAndFunctionID(ii(1), ii(2)),...
                    sprintf("Could not set PositionID %d and FunctionID %d", ii(1), ii(2)));
            end
        end
        
        function sendGain(testCase)
            for ii = randi([-32768 32767], 2, 50)
                testCase.verifyWarningFree(...
                    @() testCase.panelsController.setGain(ii(1), ii(2)),...
                    sprintf("Could not set Gain %d and Bias %d", ii(1), ii(2)));
            end
        end
        
        function sendFrameRate(testCase)
            for i = [-500:500]% randi([-32768 32767], 1, 50)
                testCase.verifyTrue(...
                    testCase.panelsController.setFrameRate(i),...
                    sprintf("Could not send FPS %d", i));
            end
        end

    end
     
end