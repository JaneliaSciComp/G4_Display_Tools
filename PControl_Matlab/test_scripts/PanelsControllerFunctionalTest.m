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
        
        function testPositionX(testCase)
            testCase.panelsController.setRootDirectory("C:\matlabroot\G4");
            testCase.panelsController.setControlMode(3);
            for i = randi([0 65535], 1, 50)
                testCase.verifyWarningFree(@() testCase.panelsController.setPositionX(i), ...
                    sprintf("Couldn't set position X to %d", i));
            end
        end
        
        function testPositionY(testCase)
            testCase.panelsController.setRootDirectory("C:\matlabroot\G4");
            testCase.panelsController.setControlMode(3);
            for i = randi([0 65535], 1, 50)
                testCase.verifyWarningFree(...
                    @() testCase.panelsController.setPositionY(i), ...
                    sprintf("Couldn't set position Y to %d", i));
            end
        end
        
        function sendPatternAndPositionIDs(testCase)
            testCase.panelsController.setRootDirectory("C:\matlabroot\G4");
            testCase.panelsController.setControlMode(3);
            for ii = randi([0 65535], 2, 50)
                testCase.verifyWarningFree(...
                    @() testCase.panelsController.setPatternAndPositionIDs(ii(1), ii(2)),...
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
            %  Useful to (rarely) trigger the issue described in 
            %  https://github.com/JaneliaSciComp/G4_Display_Tools/issues/48
            %
            %  To do this, run the current test (which will take about
            %  1.5hrs and create about 1500 experiment folders inside the
            %  root directory. Then run the function `findlogoutliers()`,
            %  which will go through the TDMS files and identify frames
            %  that took longer than an expected treshold. If it returns an
            %  empty cell array there are no errors, otherwise it will
            %  return the maximum length of a frame and the directory where
            %  the outlier was found.
            testCase.panelsController.setRootDirectory("C:\matlabroot\G4");
            testCase.panelsController.setControlMode(1);
            durationInDecaSeconds = 23;
            rsps = [];
            runTime = [];
            seqTime = [];            
            for ii=1:1500
                testCase.panelsController.startLog()        
                testCase.panelsController.setPatternID(ii);
                testCase.panelsController.setPatternFunctionID(ii);
                % testCase.panelsController.setPositionX(ii);
                startTime = tic;
                rsp = testCase.panelsController.startDisplay(durationInDecaSeconds);
                seqComplete = toc(startTime);
                testCase.panelsController.stopLog();
                rsps = [rsps; rsp];
                runTime = [runTime; durationInDecaSeconds];
                seqTime = [seqTime; seqComplete];
            end
            T = table(rsps, runTime, seqTime);
            writetable(T, "gapsInLog.xlsx", "Sheet", "gaps")
        end
        
        function testStartDisplay(testCase)
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
                onOff = str2double(char(num2cell(dec2bin(i))))';
                onOff = padarray(onOff, [0 4-length(onOff)], 0, 'pre');
                testCase.verifyTrue(testCase.panelsController.setAOFunctionID(onOff, 1));
            end
        end
        
        function testSyncLog(testCase)
            testCase.panelsController.setRootDirectory("C:\matlabroot\G4");
            testCase.panelsController.startLog();
            testCase.panelsController.setControlMode(1);
            
            % Min and Max
            testCase.verifyTrue(testCase.panelsController.sendSyncLog(0, 0));
            testCase.verifyTrue(testCase.panelsController.sendSyncLog(255, intmax('int64')));
            for i = randi([0 255], 1, 50)
                for j = int64(randi([0 2^32], 1, 20)) .* int64(randi([0 2^32], 1, 20))
                    testCase.panelsController.setPatternFunctionID(i);
                    testCase.verifyTrue(testCase.panelsController.sendSyncLog(i, j));
                    testCase.verifyTrue(testCase.panelsController.sendSyncLog(i, j+1));
                    testCase.verifyTrue(testCase.panelsController.sendSyncLog(i, j+2));
                    testCase.verifyTrue(testCase.panelsController.sendSyncLog(i, j+3));
                end
            end
            testCase.panelsController.stopLog();

        end
        
        function testReset(testCase)
            testCase.verifyTrue(testCase.panelsController.sendDisplayReset());
        end
        
        function testVersion(testCase)
            %% testVersion Check that G4 Host returns meaningful version
            %
            %  At the point of writing the test, the version was 1.0.0.244.
            %  Anything bigger than that is acceptable.
            version = testCase.panelsController.getVersion();
            testCase.verifyLength(version, 4, "The version does not have the expected format");
            testCase.verifyGreaterThanOrEqual(version(1), 1, "The version is not bigger or equal than 1");
            testCase.verifyTrue((version(1)==1 && version(4)>= 244) || version(1)>1, "Version constraints not met");
        end
        
%         % FIXME: Not working 2022-08-22
%         function testTreadmill(testCase)
%             testCase.verifyTrue(testCase.panelsController.getTreadmillData());
%         end

        function testResetCounter(testCase)
            %% testResetCounter Check if reset counter works
            %
            %  see also testMultipleResetCounter, testLoggedResetCounter
            testCase.verifyTrue(testCase.panelsController.resetCounter());            
        end
        
        function testMultipleResetCounter(testCase)
            %% testMultipleResetCounter Check if reset can be sent continously
            %
            %  see also testResetCounter, testLoggedResetCounter
            testCase.panelsController.setRootDirectory("C:\matlabroot\G4");
            testCase.panelsController.startLog();
            for i = 1:100
                testCase.verifyTrue(testCase.panelsController.resetCounter(), ...
                    sprintf("PanelsController.resetCounter didn't successfully complete for iteration %d.", i));
            end
            testCase.panelsController.stopLog();
        end
        
        function testLoggedResetCounter(testCase)
            %% testLoggedResetCounter Send alternating reset and sync logs
            %
            %  see also testResetCounter, testMultipleResetCounter, testSyncLog
            testCase.panelsController.setRootDirectory("C:\matlabroot\G4");
            testCase.panelsController.startLog();
            testCase.panelsController.setControlMode(1);
            for pse = randi([1 25], 1, 10)                
                testCase.panelsController.resetCounter();
                testCase.panelsController.sendSyncLog(pse, int64(posixtime(datetime('now'))*1000*1000));
                pause(pse/10);
            end
            testCase.panelsController.stopLog();
        end
        
        function testSPIDebug(testCase)
            testCase.panelsController.setRootDirectory("C:\matlabroot\G4");
            testCase.verifyTrue(testCase.panelsController.setSPIDebug(true, 0));
            testCase.panelsController.startLog();
            testCase.panelsController.allOn();
            testCase.panelsController.allOff();
            testCase.panelsController.stopLog();
        end
        
        function testColorDepth16(testCase)
            testCase.verifyTrue(testCase.panelsController.setColorDepth("16"));
        end
        
        function testColorDepth2(testCase)
            testCase.verifyTrue(testCase.panelsController.setColorDepth("2"));
        end
        
        function testWeirdColor(testCase)
            testCase.verifyError(@()testCase.panelsController.setColorDepth("0"), 'MATLAB:validators:mustBeMember');
            testCase.verifyError(@()testCase.panelsController.setColorDepth("1"), 'MATLAB:validators:mustBeMember');
            testCase.verifyError(@()testCase.panelsController.setColorDepth("5"), 'MATLAB:validators:mustBeMember');
        end
        
        function ttt(testCase)
            %testCase.panelsController.startStreamingMode();
            % testCase.panelsController.startPatternMode();
        end
        
        function testSetAOExtreme(testCase)
            testCase.verifyTrue(testCase.panelsController.setAO('6', -10));
            testCase.verifyTrue(testCase.panelsController.setAO('6', 0));
            testCase.verifyTrue(testCase.panelsController.setAO('6', 10));
            testCase.verifyTrue(testCase.panelsController.setAO('7', -10));
            testCase.verifyTrue(testCase.panelsController.setAO('7', 0));
            testCase.verifyTrue(testCase.panelsController.setAO('7', 10));
        end
        
        function testSetAORandom(testCase)
            testCase.panelsController.setRootDirectory("C:\matlabroot\G4");
            testCase.panelsController.startLog();
            for rnm = rand(1, 50)*20-10
                disp(rnm);
                testCase.verifyTrue(testCase.panelsController.setAO('6', rnm));
                testCase.verifyTrue(testCase.panelsController.setAO('7', -rnm));
                pause(0.1);
            end
            testCase.panelsController.stopLog();
        end


    end
     
end