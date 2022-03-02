classdef PanelComFunctionalTest < matlab.unittest.TestCase

    %% functional test of the G4 Host.exe
    %
    % A good way to run all tests here is via
    % > results = runtests({'PanelComFunctionalTest'}, 'Tag', 'MainHost')
    % or, if only the Panel_com aspects need testing, 
    % > results = runtests({'PanelComFunctionalTest'}, 'Tag', 'PanelCom')
    % This should run a few tests automatically and record the results.
    % To export the results, you can use:
    % >  writetable(results.table, 'test_results.csv')
    
     methods(TestMethodSetup)
        function startNewHost(testCase)
            [~,~] = system('taskkill /IM "G4 Host.exe"');
            connectHost;
        end
     end
    
    methods(TestMethodTeardown)
        function stopHost(testCase)
            pause(0.5);  % Make sure there is no timing issue
            disconnectHost;
            [~,~] = system('taskkill /IM "G4 Host.exe"');
        end
    end
     
     
    methods(Test, TestTags = {'MainHost'})
        function leavesMainHostWithLoggingOn(testCase)
            % leavesMainHostWithLoggingOn check if quick disconnect breaks 
            %   previous command
            %
            % The test is somewhat shaky: the last command is a "Stop Log".
            % So after reconnecting to the same Main Host, I try to run
            % another "Start Log". If that fails then we assume the Main
            % Host is still logging.
            
            global ctlr;
            pnet(ctlr.tcpConn, 'read', 'noblock'); % empty buffer
            pnet(ctlr.tcpConn, 'write', char([1, 65]));            
            testCase.verifyReturn(0, 65, ...
                'The "Start Log" TCP command does not return correct response');

            pnet(ctlr.tcpConn, 'write', char([1, 64]));            
            testCase.verifyReturn(0, 64, ...
                'The "Stop Log" TCP command does not return correct response');
            
            pause(0.1);            
            Panel_com('change_root_directory', 'C:\matlabroot\G4');
            Panel_com('start_log');
            Panel_com('start_display', 0.5);
            pause(1);
            Panel_com('stop_display');
            pause(0.1);
            allOn = Panel_com('all_on');
            pause(0.1);
            allOff = Panel_com('all_off');
            hasLogStopped = Panel_com('stop_log');
            % Adding a pause(1) here solves the problem
            disconnectHost;
            
            connectHost;
            global ctlr;
            pnet(ctlr.tcpConn, 'read', 'noblock');
            pnet(ctlr.tcpConn, 'write', char([1, 65]));
            testCase.verifyReturn(0, 65, ...
                'The "Start Log" TCP command does not provide the expected response.');
            Panel_com('stop_log');
        end
        
        
        function setPatternAndPositionFunctionMemoryFail(testCase)
            % This runs through now, but should fail once the G4 Host is
            % fixed.
            [status, response] = system('tasklist | find /I "G4 Host.exe"');
            testCase.verifyEqual(status, 0, "G4 Host is not running, but should.");
            testCase.verifyEqual(str2double(response(65:74)), 150000, 'AbsTol', 30000, ...
                "Memory usage should be around 100M");
            Panel_com('set_pattern_and_position_function', [0 0]);            
            pause(10);
            [status, response] = system('tasklist | find /I "G4 Host.exe"');
            testCase.verifyEqual(status, 0, "G4 Host is not running, but should still be there.");
            testCase.verifyGreaterThan(str2double(response(65:74)), 500000, ...
                sprintf("Memory usage will have gone up quite a bit to %d (although it shouldn't).", str2double(response(65:74))));
        end
        
    end
       
    methods(Test, TestTags = {'MainHost', 'PanelCom'})
        function stopDisplay(testCase)
            % stopDisplay test Panel_com 'stop_display' command
            Panel_com('stop_display');
            testCase.verifyReturn(0, 48, ...
                'The "Stop Display" TCP command does not provide the expected response.');
        end
        
        function allOff(testCase)
            % allOff tests Panel_com 'all_off' command
            Panel_com('all_off');
            testCase.verifyReturn(0, 0, ...
                'The "All Off" TCP command does not provide the expected response.');
        end
        
        function ctrReset(testCase)
            Panel_com('ctr_reset');
            testCase.verifyReturnString("Invalid Command", ...
                strcat('The "Controller_reset" TCP command is not supposed to be ', ...
                'implemented, should return an "invalid command" but do not do that.'));
        end
        
        function getVersion(testCase)
            Panel_com('get_version');
            testCase.verifyReturn(0, 70, ...
                'The "Get Version" TCP command does not provide the expected response.');
        end
        
        function resetCounter(testCase)
            Panel_com('reset_counter');
            testCase.verifyReturn(0, 66, ...
                'The "Reset Counter" TCP command does not provide the expected response.');            
        end
        
        function requestTreadmillData(testCase)
            Panel_com('request_treadmill_data');
            testCase.verifyReturnEmpty(...
                'The response for the "Request Treadmill Data" TCP command is not empty as expected.');
        end
        
        function updateGuiInfo(testCase)
            Panel_com('update_gui_info');
            testCase.verifyReturnEmpty(...
                'The response for the "Update GUI Info" TCP command is not empty as expected.');
        end
        
        function startStopLog(testCase)
            Panel_com('start_log');
            testCase.verifyReturn(0, 65,...
                'The "Start Log" TCP command does not provide the expected response.');
            
            %% Make sure timing isn't getting in the way.
            pause(1);

            Panel_com('stop_log');
            testCase.verifyReturn(0, 64,...
                'The "Stop Log" TCP command does not provide the expected response.');
            
            %% Make sure timing isn't getting in the way.
            pause(1);
        end
        
        function resetDisplay(testCase)
            Panel_com('reset_display');
            testCase.verifyReturn(0, 1,...
                'The "Reset Display" TCP command does not provide the expected response.');
        end
        
        function setControlModeOutsideRange(testCase)
            noErr = false;
            % The test includes the boundaries -1 and 8 as well as 40
            % random numbers between -5000 and 5000
            for cm = [-1 8 randi([8 5000], 1, 20) randi([-5000 -1], 1, 20)]
                try
                    Panel_com('set_control_mode', cm);
                    noErr = true;
                catch actualME
                    testCase.verifyNotEmpty(actualME.message);
                end
                pause(0.1);
            end
            testCase.verifyFalse(noErr, ...
                'Setting a control mode outside the accepted range should trigger an error, but it did not');
        end
        
        function setControlMode(testCase)
            for cm = [0:7]
                Panel_com('set_control_mode', cm);
                testCase.verifyReturn(0, 16,...
                    'Setting control mode via Panel_com did not have the expected response');
            end
        end
        
        function sendReset(testCase)
            Panel_com('reset', 0);
            testCase.verifyReturnString("Invalid Command", ...
                strcat("The Panel_com command 'reset' maps onto a TCP command ", ...
                "that is an 'Invalid Command' but wasn't triggered now."));
        end
        
        function setActiveAOChannels(testCase)
            for aoc = [0:15]
                channelSelect = char(sprintf("%04s", dec2bin(aoc)));
                Panel_com('set_active_ao_channels', channelSelect);
                testCase.verifyReturn(0, 17,...
                    sprintf("Setting AO Channel via Panel_com did not have the expected response for %s.", channelSelect));
            end
        end
        
        function setActiveAOChannelsFail(testCase)
            noErr = false;
            for aoc = ['00' '11111' '0123' '011' 5 2 0101]
                try
                    Panel_com('set_active_ao_channels', aoc);
                    noErr = true;
                catch actualME
                    testCase.verifyNotEmpty(actualME.message);
                end
                pause(0.1);                
            end
             testCase.verifyFalse(noErr, ...
                'Setting an active AO Channel via Panel_com outside the accepted range should trigger an error, but it did not');
        end
        
        function setActiveAIChannels(testCase)
            assumeFail(testCase)
            % This test basically never works. There is often at least one
            % or two responses that are either 255, 0, or 1.
            for aic = [0:15]
                channelSelect = char(sprintf("%04s", dec2bin(aic)))
                testCase.emptyBuffer();                
                Panel_com('stream_channels', aic);
                testCase.verifyReturn(0, 19,...
                    sprintf("Setting AI Channel via Panel_com 'stream_channels' did not have the expected response for %s.", channelSelect));
            end
        end
        
        function setActiveAIChannelsFail(testCase)
            for aic = [16 0101 255  randi([16 255], 1, 20) ]
                Panel_com('stream_channels', aic);
                testCase.verifyReturn(1, 19, ...
                    sprintf("Setting an active AI Channel via Panel_com outside the accepted range did not have the expected response for %d.", aic));
                pause(0.1);
            end
        end
        
        function setPatternID(testCase)
            assumeFail(testCase); % All fail. Setting root dir, starting log, or mode 1 doesn't solve the problem
            Panel_com('set_pattern_id', 1);
            testCase.verifyReturn(0, 3, ...
                "Setting a pattern ID via Panel_com did not have the expected response");            
        end
        
        function setPatternFuncID(testCase)
            assumeFail(testCase); % All are out of range, not sure why?
            for fid = [0 1 2 randi([3 65533], 1, 20) 65534 65535]
                Panel_com('set_pattern_func_id', fid);
                testCase.verifyReturn(1, 21, ...
                    "Setting a pattern function ID via Panel_com did not have the expected response.");
            end
        end
        
        function startDisplay(testCase)
            % There is something odd about the timing
            % TODO: actually measure time between start_display and
            % "Sequence complete" message. Below 2sec there might be an
            % issue?
            Panel_com('set_control_mode', 1);
            testCase.emptyBuffer();
            Panel_com('start_display', 3);
            testCase.verifyReturn(0, 33, ...
                    "Starting display via Panel_com did not have the expected response.");
            testCase.verifyReturnEmpty(...
                "Buffer should be empty while waiting for completion");
            pause(3.5);
            testCase.verifyReturn(0, 33, ...
                    "Waiting for completion of Start Display via Panel_com did not have the expected response.");
        end
        
        function setFrameRate(testCase)
            for fps = [0 1 randi([2 498], 1, 20) 499 500]
                Panel_com('set_frame_rate', fps);
                testCase.verifyReturn(0, 18, ...
                    sprintf("Setting Frame rate via Panel_com did not have the expected response for %d.", fps));
            end
        end
        
        function setFrameRateOutOfRange(testCase)
            for fps = randi([501 32768], 1, 20)
                Panel_com('set_frame_rate', fps);
                testCase.verifyReturn(1, 18, ...
                    sprintf("Setting Frame rate via Panel_com outside the range with %d should return an error, but did not.", fps));
            end
        end
        
        function setFrameRateNegative(testCase)
            noErr = false;
            for fps = [-1 -2 -5 -100 -500]
                try
                    Panel_com('set_frame_rate', fps);
                    noErr = true;
                catch actualME
                    testCase.verifyNotEmpty(actualME.message);
                end
                pause(0.1);                
            end
             testCase.verifyFalse(noErr, ...
                'Setting the frame rate via Panel_com outside the accepted range should trigger an error, but it did not');
        end
        
        function setPositionX(testCase)            
            for xpos = [1 2 randi([3 65533], 1, 20) 65534 65535 65536]
                Panel_com('set_position_x', xpos);
                testCase.verifyReturnEmpty(...
                    sprintf("Setting the Position X to %d, but got an unexpected response", xpos));
            end
        end
        
        function setPositionY(testCase)            
            for ypos = [1 2 randi([3 65533], 1, 20) 65534 65535 65536]
                Panel_com('set_position_y', ypos);
                testCase.verifyReturnEmpty(...
                    sprintf("Setting the Position Y to %d, but got an unexpected response", ypos));
            end
        end
        
        function setAOFunctionID(testCase)
            assumeFail(testCase); % Not sure why this always returns an error...
            Panel_com('set_ao_function_id', [1, 1]);
            testCase.verifyReturn(0, 49,...
                sprintf("Setting AO function ID for channel %d to %d", 1, 1));
        end
        
        function setAO(testCase)
            Panel_com('set_ao', [1, -5]);
            testCase.verifyReturnString("Invalid Command",...
                "In Panel_com 'set_ao' maps onto two non-existing TCP-commands (0x04 0x10 and 0x04 0x11).");
            Panel_com('set_ao', [2, 5]);
            testCase.verifyReturnString("Invalid Command",...
                "In Panel_com 'set_ao' maps onto two non-existing TCP-commands (0x04 0x10 and 0x04 0x11).");
        end
        
        function setGainBias(testCase)
            for bias = randi([-32768 32768], 1, 20)
                Panel_com('set_gain_bias', [bias, -bias]);
                testCase.verifyReturnEmpty(...
                    sprintf("Panel_com '4_bias' command does not have a return value but we falsly received one for bias %s.", bias));
            end
        end
        
        function sendStreamFrame(testCase)
            Panel_com('set_control_mode', 0);
            frm = zeros(1,4764, 'uint8');
            Panel_com('stream_frame', {length(frm) 0 0 frm});
            testCase.verifyReturnEmpty(...
                "Panel_com 'stream_frame' is not supposed to return anything, but it does.");
        end
        
        function changeRootDirectory(testCase)
            targetDir = tempname;
            Panel_com('change_root_directory', targetDir);
            testCase.verifyReturn(0,67,...
                "'change_root_directory' of Panel_com sent an unexpected response.");
            testCase.verifyEqual(exist(targetDir + "\Functions", 'dir'), 7, ...
                sprintf("Root directory was not created properly at %s", targetDir));
            rmdir(targetDir, 's');
        end
        
        function sendCombinedCommand(testCase)
            Panel_com('combined_command', ...
                [1,...          % Mode
                0, 0,...        % pattern ID, Function ID
                0, 0, 0, 0,...  % AO1..4 
                100,...         % fps
                3]);            % duration
            testCase.verifyReturnEmpty(...
                "The combined command of Panel_com does not expect any response, but there was one.");
        end

    end
    
    methods (Access = private)
        function verifyReturn(testCase, expectedCmd, expectedValue, errorMessage)
            global ctlr;
            pause(0.1);
            rtn_stop = pnet(ctlr.tcpConn, 'read', 'noblock');
            testCase.verifyNotEmpty(rtn_stop, ...
                strcat('The TCP command does not return a response.\n', ...
                'Additional error message for debugging: ', ...
                errorMessage));
            if ~isempty(expectedCmd)
                testCase.verifyEqual(uint8(rtn_stop(2)), uint8(expectedCmd), ...
                    errorMessage);     
            end
            if ~isempty(expectedValue)
                testCase.verifyEqual(uint8(rtn_stop(3)), uint8(expectedValue), ...
                    errorMessage);
            end
        end
        
        function verifyReturnString(testCase, expectedString, errorMessage)
            global ctlr;
            pause(0.1);
            rtn_string = pnet(ctlr.tcpConn, 'read', 'noblock');
            testCase.verifyEqual(...
                convertCharsToStrings(rtn_string(4:end)), ...
                expectedString, ...
                errorMessage);
        end
        
        function verifyReturnEmpty(testCase, errorMessage)
            global ctlr;
            pause(0.1);
            rtn_empty = pnet(ctlr.tcpConn, 'read', 'noblock');
            testCase.verifyEmpty(rtn_empty, errorMessage);
        end
        
        function emptyBuffer(testCase)
             global ctlr;
             [~] = pnet(ctlr.tcpConn, 'read', 'noblock');
        end
    end
end

