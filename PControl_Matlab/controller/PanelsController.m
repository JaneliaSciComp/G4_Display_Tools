
classdef PanelsController < handle
    % PanelsController Mapping of `G4 Host.exe` TCP functions to object
    % oriented MATLAB interface

    properties (Constant)
        defaultHostName = 'localhost';
        defaultPort = 62222;
        defaultHostExec = "C:\Program Files (x86)\HHMI G4\G4 Host";
        numSubPanel = 4;
        dimSubPanel = 8;
        subPanelMsgLength16 = 33;
        subPanelMsgLength2 = 9;
        idGrayScale2 = 0;
        idGrayScale16 = 1;
        iBufSz = 2^20;  % Size of the input buffer (iBuf)
    end

    properties
        hostName = PanelsController.defaultHostName;
        port = PanelsController.defaultPort;
        tcpConn = [];
        %add property mode to distinguish between the GUI and Script modes
        %mode = 0 means creating a TCP/IP connection from a script
        %mode = 1 means creating a TCP/IP connection from PControl
        mode = 0;
        %display stretch parameter is a value between 0 and 127
        stretch = 0;
    end

    properties (Dependent)
        isOpen;
    end
    
    properties (Access = private)
        iBuf = uint8([]);  % input buffer
        prevLogStart = uint64(0);
        isLogRunning = false;
    end


    methods 
        
        function self = PanelsController(varargin)
            if numel(varargin) > 0
                self.setHostName(varargin{1});
            end
            if numel(varargin) > 1
                self.setPort(varargin{2});
            end
        end

        function open(self, startHost)
            %% open Establish a connection to "Main Host"
            %
            % Connect to the webserver started by `G4 Host.exe`. If
            % startHost is true then make stop all running G4 Host
            % processes and start a new one and wait until it is up and
            % running. Disconnect via PanelsController.close.
            %
            % see also close
            arguments
                self (1,1) PanelsController
                startHost (1,1) logical = false
            end
            if startHost
                [~,~] = system('taskkill /IM "G4 Host.exe"');
                status = 0;
                while status == 0
                    [status, ~] = system('tasklist | find /I "G4 Host.exe"');
                    pause(0.01);
                end
                system(sprintf('"%s" &', self.defaultHostExec));
                isRunning = false;
                while ~isRunning
                    [status, ~] = system('tasklist | find /I "G4 Host.exe"');
                    pause(0.1);
                    if status==0
                        isRunning = true;
                    end
                end
            end
            if ~self.isOpen
                self.tcpConn = pnet('tcpconnect', self.hostName, self.port);
                while ~self.isOpen
                    disp("WAIT");
                    pause(0.01);
                end
            else
                warning('tcp connection already open');
            end
        end


        function close(self, stopHost)
            %% close Disconnect from Main Host
            % 
            % Disconnect the connection established in
            % PanelsController.open. If stopHost is true then also stop the
            % `G4 Host.exe`.
            %
            % see also open
            arguments
                self (1,1) PanelsController
                stopHost (1,1) logical = false
            end
            if self.isOpen
                pnet(self.tcpConn, 'close');
                self.tcpConn = [];
                if stopHost
                    [~,~] = system('taskkill /IM "G4 Host.exe"');
                    status = 0;
                    while status == 0
                        [status, ~] = system('tasklist | find /I "G4 Host.exe"');
                        pause(0.01);
                    end
                end
            end
        end


        function isOpen = get.isOpen(self)
            %% isOpen Confirms a working connection
            %
            % returns true if the TCP connection to the webserver behind G4
            % Host.exe is active.
            isOpen = true;
            if isempty(self.tcpConn)
                isOpen = false;
            else
                rval = pnet(self.tcpConn, 'status');
                if rval <= 0
                    isOpen = false;
                end
            end
        end

        function setHostName(self,hostName)
            %% setHostName update the host name
            if ~self.isOpen
                self.hostName = hostName;
            else
                warning('tcp connection open - unable to change hostName');
            end
        end


        function setPort(self,port)
            %% setPort Update the host port
            if ~self.isOpen
                self.port = port
            else
                warning('tcp connection open - unable to change port');
            end
        end

        function rtn = stopDisplay(self)
            %% stopDisplay send 'stop_display' command
            %
            % Triggers the 'stop display' TCP command on the G4 Main Host
            % and checks for the response.
            % 
            % Returns true if 'stop display' was confirmed, and false if
            % either an error was reported by the G4 Main Host, an
            % unexpected response was received, or the operation timed out
            % after 100ms.
            rtn = false;
            cmdData = uint8([1 48]); % Command 0x01 0x30
            self.write(cmdData);
            resp = self.expectResponse(0, 48, "Display has been stopped", 0.3);
            if ~isempty(resp)
                rtn = true;
            end
        end

        function rtn = allOn(self)
            %% allOn Send 'all on' command
            %
            % Triggers the 'all on' TCP command on the G4 Main Host and
            % checks for the response.
            %
            % Returns true if 'all on' was confirmed and false if the
            % operation timed out after 100ms or an unexpected response was
            % received.
            %
            % see also allOff
            rtn = false;
            cmdData = uint8([1 255]); % Command 0x01 0xFF
            self.write(cmdData);
            resp = self.expectResponse(0, 255, "All-On Received", 0.1);
            if ~isempty(resp)
                rtn = true;
            end
        end


        function rtn = allOff(self)
            %% allOff Send 'all off' command
            %
            % Triggers the 'all off' TCP command on the G4 Main Host and
            % checks for the response.
            %
            % Returns true if 'all off' was confirmed and false if the
            % operation timed out after 300ms or an unexpected response was
            % received. A longer timeout of 300ms was chosen, since the
            % Main Host happened to have slower responses in many cases.
            %
            % see also allOn
            rtn = false;
            cmdData = char([1 0]); % Command 0x01 0x00
            self.write(cmdData);
            resp = self.expectResponse(0, 0, "All-Off Received", 0.3);
            if ~isempty(resp)
                rtn = true;
            end
        end
        
        function rtn = setRootDirectory(self, dirName, createDir)
            %% setRootDirectory Set Root directory
            %
            % Triggers the 'Change Root Directory' TCP command on the G4
            % Main Host and checks for the correct response.
            %
            % Returns true if 'Change Root Directory' was confirmed and
            % false if the operation timed out after 100ms or an enexpected
            % response was received.
            arguments
                self (1,1) PanelsController
                dirName (1,1) string
                createDir (1,1) logical = true
            end
            cmdData = char([67]);   % Command 0x43
            rtn = false;
            if ~exist(dirName, 'dir') % doesn't exist
                if createDir
                    mkdir(dirName);
                else
                    return;
                end
            end
            rootPath = java.io.File(dirName);
            if rootPath.isAbsolute()
                rootPathName = char(dirName);
            else
                rootPathName = char(rootPath.getCanonicalPath());
            end
            rootPathLength = length(rootPathName);
            self.write([cmdData dec2char(rootPathLength, 2) uint8(rootPathName)]);
            resp = self.expectResponse(0, 67, [], 0.1);
            if ~isempty(resp)
                rtn = true;
            end
        end
        
        function rtn = setActiveAOChannels(self, activeOutputChannels)
            %% setActiveAOChannels Set active analog output channels
            %
            % Triggers the 'Set Active Analog Output Channels' TCP command
            % on the G4 Main Host and checks for the correct response.
            %
            % Returns true if the active channel was set and false if an
            % unexpected response was received or the response timed out
            % after 100ms.
            %
            % see also setActiveAIChannels
            arguments
                self (1,1) PanelsController
                activeOutputChannels (1,4) logical = [false false false false]
            end
            rtn = false;
            cmdData = char([2 17]);  % Command 0x02 0x11            
            chn = uint8(...
                activeOutputChannels(1)*8+activeOutputChannels(2)*4+ ...
                activeOutputChannels(3)*2+activeOutputChannels(4));
            self.write([cmdData chn]);
            resp = self.expectResponse(0, 17, "Active Analog Output Channel Value", 0.1);
            if ~isempty(resp)
                rtn = true;
            end
        end

        function rtn = setActiveAIChannels(self, activeInputChannels)
            %% setActiveAIChannels Set active analog input channels
            %
            % Triggers the 'Set Active Analog Input Channels For TCP
            % Stream' TCP command on the G4 Main Host and checks for the
            % correct response.
            %
            % Return true if the active input channels were set correctly
            % and false if an unexpected response was received or the
            % response timed out after 100ms.
            %
            % see also setActiveAOChannel
            arguments
                self (1,1) PanelsController
                activeInputChannels (1,4) logical = [false false false false]
            end
            rtn = false;
            cmdData = char([2 19]); % Command 0x02 0x13
            chn = uint8(...
                activeInputChannels(1)*8+activeInputChannels(2)*4+ ...
                activeInputChannels(3)*2+activeInputChannels(4));
            self.write([cmdData chn]);
            resp = self.expectResponse(0, 19, "Active Analog Input Channel For TCP Stream Value", 0.1);
            if ~isempty(resp)
                rtn = true;
            end
        end
        
        function rtn = startLog(self)
            %% startLog Start logging on the the Main Host
            %
            % Triggers the 'Start Log' TCP command if the log is not
            % already running. Returns true if logging started or is
            % already running, returns false if an unexpected response was
            % received or timed out after 10 seconds.
            %
            % see also stopLog
            if self.isLogRunning == true
                rtn = true;
                return;
            end
            rtn = false;
            cmdData = char([1 65]); % Command 0x01 0x41
            while toc(self.prevLogStart)<1
                pause(0.01);
            end
            self.prevLogStart = tic;
            self.write(cmdData);
            resp = self.expectResponse(0, 65, [], 10);
            if ~isempty(resp)
                rtn = true;
                self.isLogRunning = true;
            end
        end
        
        function rtn = stopLog(self)
            %% stopLog Stop logging on the the Main Host
            %
            % Triggers the 'Stop Log' TCP command if the log is still 
            % running. Returns true if logging stopped or has already 
            % stopped, returns false if an unexpected response was
            % received or timed out after 30 seconds.
            %
            % see also startLog
            if self.isLogRunning == false
                rtn = true;
                return;
            end
            rtn = false;
            cmdData = char([1 64]); % Command 0x01 0x40
            self.write(cmdData);
            resp = self.expectResponse(0, 64, [], 30);
            if ~isempty(resp)
                rtn = true;
                self.isLogRunning = false;
            end
        end

        function rtn = setControlMode(self, controlMode)
            %% setControlMode Set control mode on Main Host
            %
            % Modes:
            %   0 - Stream
            %   1 - Fixed Rate Position Function
            %   2 - Constant Rate Playback
            %   3 - Stream Pattern Position
            %   4 - Closed Loop:ADC
            %   5 - Closed Loop + Function
            %   6 - Both Mode 1 and 4
            %   7 - ADC Sets Index
            %
            % Triggers the 'Set Control Mode' TCP command. Returns true if
            % control mode is successfully set. Returns false if an
            % unexpected response is received, the Main host reports out of
            % range (should not happen with current constraint checks), or
            % if command times out.
            arguments
                self (1,1) PanelsController
                controlMode (1,1) ...
                    {mustBeInteger, ...
                     mustBeGreaterThanOrEqual(controlMode, 0), ...
                     mustBeLessThanOrEqual(controlMode, 7)}
            end
            rtn = false;
            cmdData = char([2 16]); % Command 0x02 0x10
            self.write([cmdData controlMode]);
            resp = self.expectResponse([0 1], 16, [], 0.1);
            if ~isempty(resp) && uint8(resp(2)) == 0
                rtn = true;
            end
        end
        
        function rtn = setPatternID(self, patternID)
            arguments
                self (1,1) PanelsController
                patternID (1,1) ...
                    {mustBeInteger, ...
                     mustBeGreaterThanOrEqual(patternID, 0), ...
                     mustBeLessThanOrEqual(patternID, 65535)}
            end
            rtn = false;
            cmdData = char([3 3]); % Command 0x03 0x03
            self.write([cmdData dec2char(patternID, 2)]);
            resp = self.expectResponse([0 1], 3, [], 0.1);
            if ~isempty(resp) && uint8(resp(2)) == 0
                rtn = true;
            end
        end
        
        function setPositionX(self, position)
            arguments
                self (1,1) PanelsController
                position (1,1) ...
                    {mustBeInteger,...
                     mustBeGreaterThanOrEqual(position, 0),...
                     mustBeLessThanOrEqual(position, 65535)}
            end
            cmdData = char([3 112]); % Command 0x03 0x70
            self.write([cmdData dec2char(position, 2)]);
        end
        
        function setPositionY(self, position)
            arguments
                self (1,1) PanelsController
                position (1,1) ...
                    {mustBeInteger,...
                     mustBeGreaterThanOrEqual(position, 0),...
                     mustBeLessThanOrEqual(position, 65535)}
            end
            cmdData = char([3 113]); % Command 0x03 0x71
            self.write([cmdData dec2char(position, 2)]);
        end
        
        function setPatternAndPositionIDs(self, positionID, functionID)
            arguments
                self (1,1) PanelsController
                positionID (1,1) ...
                    {mustBeInteger,...
                     mustBeGreaterThanOrEqual(positionID, 0),...
                     mustBeLessThanOrEqual(positionID, 65535)}
                 functionID (1,1) ...
                    {mustBeInteger,...
                     mustBeGreaterThanOrEqual(functionID, 0),...
                     mustBeLessThanOrEqual(functionID, 65535)}
            end
            cmdData = char([5 5]); % Command 0x05 0x05
            self.write([cmdData dec2char(positionID, 2) dec2char(functionID, 2)]);
        end
        
        function rtn = setPatternFunctionID(self, patternID)
            arguments
                self (1,1) PanelsController
                patternID (1,1) ...
                    {mustBeInteger,...
                    mustBeGreaterThanOrEqual(patternID, 0),...
                    mustBeLessThanOrEqual(patternID, 65535)}
            end
            rtn = false;
            cmdData = char([3 21]); % Command 0x03 0x15
            self.write([cmdData dec2char(patternID, 2)]);
            resp = self.expectResponse([0 1], 21, "Pattern Function", 0.1);
            if ~isempty(resp) && uint8(resp(2)) == 0
                rtn = true;
            end
        end
        
        function setGain(self, gain, bias)
            %% Send a `Set-Gain` command to the controller.
            %
            %  
            arguments
                self (1,1) PanelsController
                gain (1,1) {mustBeInteger,...
                     mustBeGreaterThanOrEqual(gain, -32768),...
                     mustBeLessThanOrEqual(gain, 32767)}
                bias (1,1) {mustBeInteger,...
                     mustBeGreaterThanOrEqual(bias, -32768),...
                     mustBeLessThanOrEqual(bias, 32767)}
            end
            cmdData = char([5 1]); % Command 0x05 0x01
            self.write([cmdData signed16BitToChar(gain) signed16BitToChar(bias)]);
        end
        
        function rtn = setFrameRate(self, fps)
            arguments
                self (1,1) PanelsController
                fps (1,1) {mustBeInteger,...
                     mustBeGreaterThanOrEqual(fps, -32768),...
                     mustBeLessThanOrEqual(fps, 32767)}
            end
            rtn = false;
            cmdData = char([3 18]); % Command 0x03 0x12
            self.write([cmdData signed16BitToChar(fps)]);
            resp = self.expectResponse([0 1], 18, [], 0.1);
            if ~isempty(resp) && uint8(resp(2)) == 0
                rtn = true;
            end
        end

        function rtn = startDisplay(self, deciSeconds, waitForEnd)
            arguments
                self (1,1) PanelsController
                deciSeconds (1,1) {mustBeInteger,...
                    mustBeGreaterThan(deciSeconds, 0),...   % the G4 Host doesn't accept 0
                    mustBeLessThanOrEqual(deciSeconds, 65535)}
                waitForEnd (1,1) logical = true
            end
            rtn = false;
            cmdData = char([3 33]); % Command 0x03 0x21
            self.write([cmdData dec2char(deciSeconds, 2)]);
            resp = self.expectResponse([0 1], 33, [], 0.1);
            if waitForEnd == true && ~isempty(resp) && resp(2) == 0
                resp2 = self.expectResponse(0, 33, sprintf("Sequence completed in %d ms", deciSeconds*100), deciSeconds*1.0/10 + 1);
                % disp(sprintf("Waitfor was %d and response was '%s'.",  deciSeconds, resp2));
                if ~isempty(resp2)
                    rtn = true;
                end
            elseif waitForEnd == false && ~isempty(resp) && resp(2) == 0
                rtn = true;
            end
        end
        
        function rtn = setAOFunctionID(self, aoChannels, aoFunctionID)
            %% setAOFunctionID set the function ID for channels.
            arguments
                self (1,1) PanelsController
                aoChannels (1,4) logical
                aoFunctionID (1,1) {mustBeInteger,...
                    mustBeGreaterThanOrEqual(aoFunctionID, 0),...
                    mustBeLessThanOrEqual(aoFunctionID, 65535)}
            end
            rtn = false;
            cmdData = char([4 49]); % 0x04 0x31
            chn = uint8(...
                aoChannels(1)*8+aoChannels(2)*4+ ...
                aoChannels(3)*2+aoChannels(4));
            self.write([cmdData chn, dec2char(aoFunctionID, 2)]);
            resp = self.expectResponse([0 1], 49, [], 0.1);
            if ~isempty(resp) && resp(2) == 0
                rtn = true;
            end
        end
        
        function rtn = setAO(self, aoChannel, voltage)
            %% setAO sets the voltage on AO6 or AO7
            arguments
                self (1,1) PanelsController
                aoChannel (1,1) {mustBeMember(aoChannel, {'6', '7'})}
                voltage (1,1) {mustBeNumeric, mustBeFinite, ...
                    mustBeGreaterThanOrEqual(voltage, -10), ...
                    mustBeLessThanOrEqual(voltage, 10)}
            end
            rtn = false;
            cmdData = char([4 50]); % 0x04 0x32
            
            switch aoChannel
                case '6'
                    chnl = 1;
                case '7'
                    chnl = 2;
            end
            volVar = voltage/10 * intmax('int16');
            volTrans = mod(int32(intmax('uint16')) + int32(volVar), int32(intmax('uint16')))

            self.write([cmdData dec2char(chnl, 1) dec2char(volTrans, 2)]);
            resp = self.expectResponse(0, 50, [], 0.1);
            if ~isempty(resp)
                rtn = true;
            end
        end
        
        function rtn = sendSyncLog(self, msgClass, msg)
            %% sendSyncLog Log information to TDMS file.
            %
            %  Triggers the 'Sync Log' TCP command. Returns true if the two
            %  values 'msgClass' and 'msg' were successfully stored in the 
            %  TDMS log files.
            arguments
                self (1,1) PanelsController
                msgClass (1,1) {mustBeInteger, ...
                    mustBeGreaterThanOrEqual(msgClass, 0), ...
                    mustBeLessThanOrEqual(msgClass, 255)}
                msg (1,1) {mustBeInteger, ...
                    mustBeLessThanOrEqual(msg, 9223372036854775807)}
            end
            rtn = false;
            cmdData = char([10 71]); % 0x0A 0x47
            alltogethernow = [cmdData dec2char(msgClass, 1) fliplr(dec2char(msg, 8))];
            self.write(alltogethernow);
            resp = self.expectResponse(0, 71, [], 0.1);
            if ~isempty(resp)
                rtn = true;
            end
        end
        
        function rtn = sendDisplayReset(self)
            %% sendDisplayReset Reset the displays
            %
            %  Triggers the 'Display Reset' TCP command. Returns true if
            %  the reset command returns the expected TCP response.
            rtn = false;
            cmdData = char([1 1]); % 0x01 0x01
            self.write([cmdData]);
            resp = self.expectResponse(0, 1, "Reset Command Sent to FPGA", 0.1);
            if ~isempty(resp)
                rtn = true;
            end
        end
        
        function version = getVersion(self)
            %% getVersion Retrieve current version of G4 Host
            %
            %  Triggers the 'Get Version' TCP command. T
            version = [0];
            cmdData = char([1 70]); % 0x01 0x46
            self.write([cmdData]);
            resp = self.expectResponse(0, 70, [], 0.1);
            if length(resp) > 4
                version = str2double(split(resp(4:end), ".", 2));
            end
        end
        
        function rtn = getTreadmillData(self)
            rtn = false; 
            cmdData = char([1 69]); % 0x01 0x45
            self.write([cmdData]);
            resp = self.expectResponse(0, 69, [], 0.1); % TODO: This is untested a and broken
            if ~isempty(resp)
                rtn = true;
            end
        end
        
        function rtn = resetCounter(self)
            %% resetCounter
            %
            %  Trigger 'Reset Counter' TCP command.
            rtn = false;
            cmdData = char([1 66]); % 0x01 0x42
            self.write([cmdData]);
            resp = self.expectResponse(0, 66, "Counter has been reset", 0.1);
            if ~isempty(resp)
                rtn = true;
            end
        end
        
        function rtn = setSPIDebug(self, enable, column)
            %% setSPIDebug enable SPI debugging
            %
            %  MOSI commands for specified COLUMN get logged into TDMS
            %  files when ENABLE is true. Send this before logging started.
            %
            %  see also startLog, stopLog
            arguments
                self   (1,1) PanelsController
                enable (1,1) {mustBeNumericOrLogical}
                column (1,1) {mustBeInteger, ...
                    mustBeGreaterThanOrEqual(column, 0), ...
                    mustBeLessThanOrEqual(column, 12)}
            end
            rtn = false;
            if self.isLogRunning
                ME = MException('PanelsController:WrongOrder', ...
                    'Cannot start SPI debugging after logging.');
                throw(ME);
            end
            cmdData = char([3 80]); % 0x03 0x50
            onoff = 0;
            if enable
                onoff = 1;
            end
            self.write([cmdData dec2char(onoff, 1) dec2char(column, 1)]);
            resp = self.expectResponse(0, 80, [], 0.1);
            if ~isempty(resp)
                rtn = true;
            end
        end
        
        function rtn = setColorDepth(self, depth)
            %% setColorDepth Set the panel either to 2 or 16 colors
            arguments
                self (1,1) PanelsController
                depth (1,1) {mustBeMember(depth, {'2', '16'})}
            end
            rtn = false;
            cmdData = char([2 6]); % 0x02 0x06
            depthBit = 0;
            if str2double(depth) == 16
                depthBit = 1;
            end
            self.write([cmdData dec2char(depthBit, 1)]);
            resp = self.expectResponse(0, 6, "Switch grayscale", 2);  % This takes very long
            if ~isempty(resp)
                rtn = true;
            end
        end
        
%         % TODO: not fully working yet.
%         function rtn = streamFrame(self, aox, aoy, frame)
%             rtn = false;
%             cmdData = char([50]); % 0x32
%             frLength = length(frame);
%             fullCmd = [cmdData dec2char(frLength, 2) dec2char(aox, 2) dec2char(aoy, 2) frame];
%             self.write([fullCmd]);
%             resp = self.expectResponse(0, 50, [], 0.1); 
%             if ~isempty(resp)
%                 rtn = true;
%             end
%         end
        
        function rtn = combinedCommand(self, ...
                controlMode, patternID, functionID,...
                ao0FunctionID, ao1FunctionID, ao2FunctionID, ao3FunctionID,...
                fps, deciSeconds,...
                waitForEnd)
            %% combinedCommand Send many updates in a single command
            %
            % Triggers the 'Set control mode, pattern id, pattern function 
            % id, ao function id, frame rate, run-time(ms)' TCP command 
            % on the G4 Main Host and checks for the correct response.
            %
            % Return true if the command was successful and false if either
            % sending the command received a time out after 0.2 sec or, 
            % when waitForEnd is true, the display did not return a 
            % successful "Sequence completed" after the time specified 
            % deciSeconds.
            %
            % TODO: At some point we weren't sure about the timing of this
            % command, so this might still be off.
            %
            % see also startDisplay, setControlMode, setPatternID,
            % setPatternFunctionID, setAOFunctionID, setFrameRate
            arguments
                self (1,1) PanelsController
                controlMode (1,1) ...
                    {mustBeInteger, ...
                     mustBeGreaterThanOrEqual(controlMode, 0), ...
                     mustBeLessThanOrEqual(controlMode, 7)}
                patternID (1,1) ...
                    {mustBeInteger, ...
                     mustBeGreaterThanOrEqual(patternID, 0), ...
                     mustBeLessThanOrEqual(patternID, 65535)}
                functionID (1,1) ...
                    {mustBeInteger,...
                    mustBeGreaterThanOrEqual(functionID, 0),...
                    mustBeLessThanOrEqual(functionID, 65535)}
                ao0FunctionID (1,1) {mustBeInteger,...
                    mustBeGreaterThanOrEqual(ao0FunctionID, 0),...
                    mustBeLessThanOrEqual(ao0FunctionID, 65535)}
                ao1FunctionID (1,1) {mustBeInteger,...
                    mustBeGreaterThanOrEqual(ao1FunctionID, 0),...
                    mustBeLessThanOrEqual(ao1FunctionID, 65535)}
                ao2FunctionID (1,1) {mustBeInteger,...
                    mustBeGreaterThanOrEqual(ao2FunctionID, 0),...
                    mustBeLessThanOrEqual(ao2FunctionID, 65535)}
                ao3FunctionID (1,1) {mustBeInteger,...
                    mustBeGreaterThanOrEqual(ao3FunctionID, 0),...
                    mustBeLessThanOrEqual(ao3FunctionID, 65535)}
                fps (1,1) {mustBeInteger,...
                     mustBeGreaterThanOrEqual(fps, -32768),...
                     mustBeLessThanOrEqual(fps, 32767)}
                deciSeconds (1,1) {mustBeInteger,...
                    mustBeGreaterThan(deciSeconds, 0),...   % the G4 Host doesn't accept 0
                    mustBeLessThanOrEqual(deciSeconds, 65535)}
                waitForEnd (1,1) logical = true
            end
            rtn = false;
            cmdData = uint8([18 07]); % Command 0x12, 0x07
            cmd = cmdData;
            cmd = [cmd controlMode];
            cmd = [cmd dec2char(patternID, 2)];
            cmd = [cmd dec2char(functionID, 2)];
            cmd = [cmd dec2char(ao0FunctionID, 2)];
            cmd = [cmd dec2char(ao1FunctionID, 2)];
            cmd = [cmd dec2char(ao2FunctionID, 2)];
            cmd = [cmd dec2char(ao3FunctionID, 2)];
            cmd = [cmd signed16BitToChar(fps)];
            cmd = [cmd dec2char(deciSeconds, 2)];
            
            self.write(cmd);
            resp = self.expectResponse([0 1], 07, [], 0.2);
            
            if waitForEnd == true && ~isempty(resp) && resp(2) == 0
                resp2 = self.expectResponse(0, 33, sprintf("Sequence completed in %d ms", deciSeconds*100), deciSeconds*1.0/10 + 1);
                % disp(sprintf("Waitfor was %d and response was '%s'.",  deciSeconds, resp2));
                if ~isempty(resp2)
                    rtn = true;
                end
            elseif waitForEnd == false && ~isempty(resp) && resp(2) == 0
                rtn = true;
            end
        end
        
        function success = write(self, data)
            %% write Send data via TCP
            %
            % Note: for historic reasons success is defined as follows:
            % success: 1 means unsuccessful and 0 means successful
            success = 1;
            if self.isOpen
                pnet(self.tcpConn, 'write', data);
                success = 0;
            end
        end

        %% Deprecated?
        
        function startStreamingMode(self)
            cmdData = char([2, hex2dec('10'), 0]);
            self.write(cmdData);
        end

        function streamFrame16(self,frame)
            frameCmd = self.getFrameCmd16(frame);
            self.write(frameCmd);
        end


        function streamFrameCmd16(self,frameCmd)
            self.write(frameCmd);
        end

        function streamFrame2(self,frame)
            frameCmd = self.getFrameCmd2(frame);
            self.write(frameCmd);
        end


        function streamFrameCmd2(self,frameCmd)
            self.write(frameCmd);
        end

        
        function frameCmd = getFrameCmd16(self,frame)

            frame = self.unInvertPanels(frame);

            [numRow, numCol] = size(frame);
            if mod(numRow,16) ~= 0 || mod(numCol,16) ~= 0
                error('rows and columns must be divisible by 16');
            end
            numRowPan = numRow/16;
            numColPan = numCol/16;

            frameMaxValue = max(max(frame));
            frameMinValue = min(min(frame));
            if (frameMinValue <0) || (frameMaxValue > 15)
                error('frame values must be > 0 and < 15');
            end

            row = [];
            for i=1:numRowPan
                for j=1:numColPan
                    for k=1:self.numSubPanel
                        [n1,n2,m1,m2] = subPanelNumToInd(i,j,k);
                        subPanelFrame = frame(n1:n2,m1:m2);
                        subPanelMsg = self.subPanelFrameToMsg16(subPanelFrame);
                        row(i).col(j).subPanel(k).msg = subPanelMsg;
                    end
                end
            end

            frameOut = [];
            for i=1:numRowPan
                for k=1:self.numSubPanel
                    panMsg = [];
                    for n=1:self.subPanelMsgLength16
                        for j=1:numColPan
                            panMsg = [panMsg row(i).col(j).subPanel(k).msg(n)];
                        end
                    end
                    frameOut = [frameOut i panMsg];
                end
            end
     
            frameCmd = [ 50, signed16BitToChar(length(frameOut)), ... 
                signed16BitToChar(0), signed16BitToChar(0), frameOut];

            frameCmd = char(frameCmd);

        end
        
        %use mex function to speed up the Matlab version getFrameCmd16
        function frameCmd = getFrameCmd16Mex(self,frame)
            stretchF = min(self.stretch, 20);
            frameOut = make_framevector_gs16(frame,stretchF);
            frameCmd = [ 50, signed16BitToChar(length(frameOut)), ... 
                signed16BitToChar(0), signed16BitToChar(0), frameOut];

            frameCmd = char(frameCmd);
        end        

        function frameCmd = getFrameCmd2(self,frame)

            frame = self.unInvertPanels(frame);

            [numRow, numCol] = size(frame);
            if mod(numRow,16) ~= 0 || mod(numCol,16) ~= 0
                error('rows and columns must be divisible by 16');
            end
            numRowPan = numRow/16;
            numColPan = numCol/16;

            frameMaxValue = max(max(frame));
            frameMinValue = min(min(frame));
            if (frameMinValue <0) || (frameMaxValue > 2)
                error('frame values must be > 0 and < 2');
            end

            row = [];
            for i=1:numRowPan
                for j=1:numColPan
                    for k=1:self.numSubPanel
                        [n1,n2,m1,m2] = subPanelNumToInd(i,j,k);
                        subPanelFrame = frame(n1:n2,m1:m2);
                        subPanelMsg = self.subPanelFrameToMsg2(subPanelFrame);
                        row(i).col(j).subPanel(k).msg = subPanelMsg;
                    end
                end
            end

            frameOut = [];
            for i=1:numRowPan
                for k=1:self.numSubPanel
                    panMsg = [];
                    for n=1:self.subPanelMsgLength2
                        for j=1:numColPan
                            panMsg = [panMsg row(i).col(j).subPanel(k).msg(n)];
                        end
                    end
                    frameOut = [frameOut i panMsg];
                end
            end
            
            frameCmd = [ 50, signed16BitToChar(length(frameOut)), ... 
                signed16BitToChar(0), signed16BitToChar(0), frameOut];

            frameCmd = char(frameCmd);

        end
        
        %use mex function to speed up the Matlab version getFrameCmd2
        function frameCmd = getFrameCmd2Mex(self,frame)
            stretchF = min(self.stretch, 107);
            frameOut = make_framevector_gs2(frame, stretchF);
            frameCmd = [ 50, signed16BitToChar(length(frameOut)), ... 
                signed16BitToChar(0), signed16BitToChar(0), frameOut];

            frameCmd = char(frameCmd);

        end        
        
        
        
    end

    
    methods (Access=protected)

        function msg = subPanelFrameToMsg16(self,subFrame)
            msg = [self.idGrayScale16+self.stretch*2];
            for i = 1:self.dimSubPanel
                for j = 1:2:self.dimSubPanel
                    value0 = subFrame(i,j);
                    value1 = subFrame(i,j+1);
                    msg = [msg, bitor(value0, bitshift(value1,4))];
                end
            end
        end

        function msg = subPanelFrameToMsg2(self,subFrame)
            msg = [self.idGrayScale2+self.stretch*2];
            for i = 1:self.dimSubPanel
                msgByte = uint8(0);
                for j = 1:self.dimSubPanel
                    value = subFrame(i,j);
                    msgByte = bitor(msgByte,bitshift(value,j-1),'uint8');
                end
                msg = [msg,msgByte];
            end
        end

        function frameNew = unInvertPanels(self,frameOrig)
            frameNew = frameOrig;
            [numRow,numCol] = size(frameNew);
            if mod(numRow,16) ~= 0 
                error('rows must be divisible by 16');
            end
            numRowPan = numRow/16;
            for i = 1:numRowPan
                n1 = 1 + (i-1)*16;
                n2 = n1 + 15;
                frameNew(n1:n2,:) = flipud(frameNew(n1:n2,:));
            end
        end

        function pullResponse(self)
            %% pullResponse Read response from TCP and put it in buffer iBuf
            %
            %  iBuf is a FIFO buffer which only contains as many chars as
            %  defined in iBufSz
            self.iBuf = [self.iBuf pnet(self.tcpConn, 'read', 65536, 'uint8', 'noblock')];            
            if length(self.iBuf) > self.iBufSz
                self.iBuf(1, length(self.iBuf) - self.iBufSz) = [];
            end
        end

        function response = expectResponse(self, rsp, cmd, rspString, timeout)
            %% expectResponse Check TCP response for certain features
            arguments
                self (1,1) PanelsController
                rsp (1,:) uint8 
                cmd (1,1) uint8
                rspString (1,:) string
                timeout (1,1) double = 0.1
            end
            found_response = false;
            timedOut = false;
            ltim = tic;
            while ~found_response && ~timedOut
                response = [];
                pat.start = [];                
                self.pullResponse();
                for rsp_i = rsp
                    pat.start = [pat.start strfind(self.iBuf, [rsp_i cmd])-1];
                end
                if ~isempty(pat.start)
                    pat.end = pat.start + self.iBuf(pat.start);
                    pat.start = pat.start(pat.end <= length(self.iBuf));
                    pat.end = pat.end(pat.end <= length(self.iBuf));
                    for i = 1:length(pat.start)
                        response = char(self.iBuf(pat.start(i):pat.end(i)));
                        if (~isempty(response) && isempty(rspString)) || ...
                           (~isempty(response) && contains(response, rspString))
                            found_response = true;            
                            self.iBuf(pat.start(i):pat.end(i)) = [];
                            break;
                        else
                            response = [];
                        end
                    end
                end
                actTime = toc(ltim);
                if ~found_response && actTime > timeout
                    timedOut = true;
                end
            end
        end

    end 

end % PanelsController


% Utility functions
% -----------------------------------------------------------------------------


function [n1,n2,m1,m2] = subPanelNumToInd(i,j,panelNum)
    switch (panelNum)
        case 1 
            n1 = 1;
            n2 = 8;
            m1 = 1;
            m2 = 8;
        case 2 
            n1 = 9;
            n2 = 16;
            m1 = 1;
            m2 = 8;
        case 3 
            n1 = 1;
            n2 = 8;
            m1 = 9;
            m2 = 16;
        case 4 
            n1 = 9;
            n2 = 16;
            m1 = 9; 
            m2 = 16;
        otherwise 
            error('sub panel number out of range');
    end

    n1 = n1 + (i-1)*16;
    n2 = n2 + (i-1)*16;
    m1 = m1 + (j-1)*16;
    m2 = m2 + (j-1)*16;
end


function char_val = signed16BitToChar(B)
    % This functions makes two char value (0-255) from a signed 16bit valued 
    % number in the range of -32767 ~ 32767
    if ((any(B > 32767)) || (any(B < -32767)))
        error('this number is out of range - need a function to handle multi-byte values' );
    end
    % this does both pos and neg in one line
    temp_val = mod(65536 + B, 65536);
    for cnt =1 : length(temp_val)
        char_val(2*cnt-1:2*cnt) = dec2char(temp_val(cnt),2);
    end
end


