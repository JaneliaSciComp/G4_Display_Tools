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
            for i = 1:15
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
            for i = 0:15
                onOff = str2num(char(num2cell(dec2bin(i))))';
                onOff = padarray(onOff, [0 4-length(onOff)], 0, 'pre');
                testCase.verifyTrue(testCase.panelsController.setActiveAOChannels(onOff), ...
                    sprintf("PanelsController.setActiveAOChannels wasn't successfully completed for %d", i));
            end
        end
        
        function sendActiveAI(testCase)
            for i = 0:15
                onOff = str2num(char(num2cell(dec2bin(i))))';
                onOff = padarray(onOff, [0 4-length(onOff)], 0, 'pre');
                testCase.verifyTrue(testCase.panelsController.setActiveAIChannels(onOff), ...
                    sprintf("PanelsController.setActiveAIChannels wasn't successfully completed for %d", i));
            end
        end
        
        function testLoggingRepeatedOn(testCase)
            newDir = tempname;
            testCase.panelsController.setRootDirectory(newDir);
            for i = 0:15
                testCase.verifyTrue(testCase.panelsController.startLog(), ...
                    sprintf("Starting the log didn't work in iteration %d", i));
            end
            testCase.panelsController.stopLog();
            rmdir(newDir, 's');
        end
        
        function testLoggingRepeatedOff(testCase)
            newDir = tempname;
            testCase.panelsController.setRootDirectory(newDir);
            testCase.panelsController.startLog();
            for i = 0:15
                testCase.verifyTrue(testCase.panelsController.stopLog(), ...
                    sprintf("Stopping the log didn't work in iteration %d", i));
            end
            rmdir(newDir, 's');
        end
        
        function testLogging(testCase)
            newDir = tempname;
            testCase.panelsController.setRootDirectory(newDir);
            for i = 0:15
                testCase.verifyTrue(testCase.panelsController.startLog(), ...
                    sprintf("Starting the log didn't work in iteration %d", i));
                testCase.verifyTrue(testCase.panelsController.stopLog(), ...
                    sprintf("Stopping the log didn't work in iteration %d", i));
            end
            rmdir(newDir, 's');
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
        
        function sendPatternFunctionID(testCase)
            testCase.panelsController.setRootDirectory("C:\matlabroot\G4");
            testCase.panelsController.setControlMode(3);
            for i = 1:100
                testCase.verifyTrue(...
                    testCase.panelsController.setPatternFunctionID(1),...
                    sprintf("Could not set FunctionID %d", i));
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
            for i = -500:500 % randi([-32768 32767], 1, 50)
                testCase.verifyTrue(...
                    testCase.panelsController.setFrameRate(i),...
                    sprintf("Could not send FPS %d", i));
            end
        end
        
%         function sendStartDisplayXLSX(testCase)
%             testCase.panelsController.setRootDirectory("C:\matlabroot\G4");
%             testCase.panelsController.setControlMode(2);
%             testCase.panelsController.setPatternID(1);
%             rsps = [];
%             runTime = [];
%             seqTime = [];
%             for i =   [randi([1, 50], 1, 50)]% randi([0, 65534], 1, 20)] % 
%             %for i = [1878 637 1265 1748]
%                 disp(i);
%                 startTime = tic;
%                 rsp = testCase.panelsController.startDisplay(i);
%                 seqComplete = toc(startTime);
%                 rsps = [rsps; rsp];
%                 runTime = [runTime; i];
%                 seqTime = [seqTime; seqComplete];
%             end
%             T = table(rsps, runTime, seqTime);
%             writetable(T, "startDisplayTimes2.xlsx", "Sheet", "2022-03-25")
%         end

        function gapsInLogXLSX(testCase)
            testCase.panelsController.setRootDirectory("C:\matlabroot\G4");
            testCase.panelsController.setControlMode(1);
            rsps = [];
            runTime = [];
            seqTime = [];            
            for ii=1:400
                testCase.panelsController.startLog()        
                testCase.panelsController.setPatternID(ii);
                testCase.panelsController.setPatternFunctionID(ii);
                testCase.panelsController.setPositionX(ii);
                startTime = tic;
                rsp = testCase.panelsController.startDisplay(23);
                seqComplete = toc(startTime);
                rsps = [rsps; rsp];
                runTime = [runTime; 23];
                seqTime = [seqTime; seqComplete];
                testCase.panelsController.stopLog();
            end
            T = table(rsps, runTime, seqTime);
            writetable(T, "gapsInLog.xlsx", "Sheet", "gaps")
        end
        
        function sendStartDisplay(testCase)
            % This is the unit test doing the same as sendStartDisplayXLSX
            testCase.panelsController.setRootDirectory("C:\matlabroot\G4");
            testCase.panelsController.setControlMode(2);
            testCase.panelsController.setPatternID(1);
            for waitDecSec = randi([1, 50], 1, 20)
                startTime = tic;
                rsp = testCase.panelsController.startDisplay(waitDecSec);
                testCase.verifyTrue(rsp, "startDisplay didn't return true as expected");
                seqComplete = toc(startTime);
                testCase.verifyEqual(seqComplete, waitDecSec*1.0/10, "AbsTol", 0.2, ...
                    sprintf("Wait %d deciseconds didn't work, it was %.2f seconds instead", waitDecSec, seqComplete));
            end
        end
        
        function sendStartStop(testCase)
            testCase.panelsController.setRootDirectory("C:\matlabroot\G4");
            testCase.panelsController.setControlMode(1);
            testCase.panelsController.setPatternID(1);
            for i = randi([500, 3000], 1, 100)
                testCase.panelsController.setControlMode(1);
                testCase.verifyTrue(testCase.panelsController.startDisplay(i, false));
                % As suggested in issue #21:
                % https://github.com/JaneliaSciComp/G4_Display_Tools/issues/21
                testCase.panelsController.setControlMode(0);        
            end
        end
        
        function sendAOFunctionID(testCase)
            testCase.panelsController.setRootDirectory("C:\matlabroot\G4");
            for i = 0:15
                onOff = str2num(char(num2cell(dec2bin(i))))';
                onOff = padarray(onOff, [0 4-length(onOff)], 0, 'pre');
                testCase.verifyTrue(testCase.panelsController.setAOFunctionID(onOff, 1));
            end
        end

    end
     
end