
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
            % PanelsController.open Establish a connection to "Main Host"
            %
            % Connect to the webserver started by `G4 Host.exe`. If
            % startHost is true then make stop all running G4 Host
            % processes and start a new one and wait until it is up and
            % running. Disconnect via PanelsController.close.
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
            else
                warning('tcp connection already open');
            end
        end


        function close(self, stopHost)
            % PanelsController.close Disconnect from Main Host
            % 
            % Disconnect the connection established in
            % PanelsController.open. If stopHost is true then also stop the
            % `G4 Host.exe`.
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
            % PanelsController.isOpen confirms a working connection
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
            % PanelsController.setHostName update the host name
            if ~self.isOpen
                self.hostName = hostName;
            else
                warning('tcp connection open - unable to change hostName');
            end
        end


        function setPort(self,port)
            % setPort update the host port
            if ~self.isOpen
                self.port = port
            else
                warning('tcp connection open - unable to change port');
            end
        end

        function rtn = stopDisplay(self)
            % PanelsController.stopDisplay send 'stop_display' command
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
            resp = self.expectResponse([0 1], 48, "Display has been stopped", 0.1);
            if ~isempty(resp) && resp(2) == 0
                rtn = true;
            end
        end

        function rtn = allOn(self)
            % allOn Send 'all on' command
            %
            % Triggers the 'all on' TCP command on the G4 Main Host and
            % checks for the response.
            %
            % Returns true if 'all on' was confirmed and false if the
            % operation timed out after 100ms or an unexpected response was
            % received.
            %
            % SEE ALSO allOff
            rtn = false;
            cmdData = uint8([1 255]); % Command 0x01 0xFF
            self.write(cmdData);
            resp = self.expectResponse(0, 255, "All-On Received", 0.1);
            if ~isempty(resp)
                rtn = true;
            end
        end


        function rtn = allOff(self)
            % allOff Send 'all off' command
            %
            % Triggers the 'all off' TCP command on the G4 Main Host and
            % checks for the response.
            %
            % Returns true if 'all off' was confirmed and false if the
            % operation timed out after 300ms or an unexpected response was
            % received. A longer timeout of 300ms was chosen, since the
            % Main Host happened to have slower responses in many cases.
            %
            % SEE ALSO allOn
            rtn = false;
            cmdData = char([1 0]); % Command 0x01 0x00
            self.write(cmdData);
            resp = self.expectResponse(0, 0, "All-Off Received", 0.3);
            if ~isempty(resp)
                rtn = true;
            end
        end
        
        function rtn = setRootDirectory(self, dirName, createDir)
            % setRootDirectory Set Root directory
            %
            % Triggers the 'Change Root Directory' TCP command on the G4
            % Main Host and checks for the correct response.
            %
            % RTN = SETROOTDIRECTORY(SELF, DIRNAME, CREATEDIR)
            %
            % Returns true if 'Change Root Directory' was confirmed and
            % false if the operation timed out after 100ms or an enexpected
            % response was received.
            %
            
            arguments
                self (1,1) PanelsController
                dirName (1,1) string
                createDir (1,1) logical = true
            end
            cmdData = char([67]);   % Command 0x43
            rtn = false;
            if 7~=exist(dirName, 'dir') % doesn't exist
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
        
        function rtn = setActiveAOChannels(self, activeChannels)
            % PanelsController.setActiveAOChannels Set active analoge
            % output channels
            %
            % Triggers the 'Set Active Analog Output Channels' TCP command
            % on the G4 Main Host and checks for the correct response.
            %
            % Returns true if the
            arguments
                self (1,1) PanelsController
                activeChannels (1,4) logical = [false false false false]
            end
            cmdData = char([2 17]);  % Command 0x02 0x11            
            chn = uint8(activeChannels(1)*8+activeChannels(2)*4+activeChannels(3)*2+activeChannels(4));
            self.write([cmdData chn]);
            resp = self.expectResponse(0, 17, "Active Analog Output Channel Value", 0.1);
            if ~isempty(resp)
                rtn = true;
            end
        end


        function setGrayScaleLevel16(self)
            cmdData = char([2,4,16]);
            self.write(cmdData);
        end


        function setGrayScaleLevel2(self)
            cmdData = char([2,4,2]);
            self.write(cmdData)
        end


        function startStreamingMode(self)
            cmdData = char([2, hex2dec('10'), 0]);
            self.write(cmdData);
        end


        function startPatternMode(self)
            cmdData = char([1, hex2dec('21')]);
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
        
        function success = write(self,data)
            %success: 1 means unsuccessful and 0 means successful
            success = 1;
            if self.isOpen
                pnet(self.tcpConn, 'write', data);
                success = 0;
            end
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
            self.iBuf = [self.iBuf pnet(self.tcpConn, 'read', 65536, 'uint8', 'noblock')];            
            if length(self.iBuf) > self.iBufSz
                self.iBuf(1, length(self.iBuf) - self.iBufSz) = [];
            end
        end

        function response = expectResponse(self, rsp, cmd, rspString, timeout)
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


function charArray = dec2char(num, num_chars)
    % this functions makes an array of char values (0-255) from a decimal number
    % this is listed in MSB first order.
    % untested for negative numbers, probably wrong!
    % to decode, for e.g. a 3 char array:
    % ans = charArray(1)*2^16 + charArray(2)*2^8 + charArray(3)*2^0
    
    charArray = zeros(1,num_chars);    
    if (num > (2^(8*num_chars)-1))
        error("not enough characters for a number of size %d (should be between 0...%d)", ...
            num_chars, (2^(8*num_chars)-1) );
    end

    if (num < 0 )
        error('this function does not handle negative numbers correctly' );
    end
    
    num_rem = num;
    
    for j = num_chars:-1:1
        temp = floor((num_rem)/(2^(8*(j-1))));
        num_rem = num_rem - temp*(2^(8*(j-1)));
        charArray(j) = temp;
    end
end


