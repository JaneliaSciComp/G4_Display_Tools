
classdef PanelsController < handle

    properties (Constant)
        defaultHostName = 'localhost';
        defaultPort = 62222;
        numSubPanel = 4;
        dimSubPanel = 8;
        subPanelMsgLength16 = 33;
        subPanelMsgLength2 = 9;
        idGrayScale2 = 0;
        idGrayScale16 = 1;
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


    methods 
        
        function self = PanelsController(varargin)
            if numel(varargin) > 0
                self.setHostName(varargin{1});
            end
            if numel(varargin) > 1
                self.setPort(varargin{2});
            end
        end


        function open(self)
            if ~self.isOpen
                self.tcpConn = pnet('tcpconnect', self.hostName, self.port);
            else
                warning('tcp connection already open');
            end
        end


        function close(self)
            if self.isOpen
                pnet(self.tcpConn, 'close');
                self.tcpConn = [];
            end
        end


        function isOpen = get.isOpen(self)
            isOpen = true;
            if isempty(self.tcpConn)
                isOpen = false;
            else
                rval = pnet(self.tcpConn,'status');
                if rval <= 0
                    isOpen = false;
                end
            end
        end


        function setHostName(self,hostName)
            if ~self.isOpen
                self.hostName = hostName;
            else
                warning('tcp connection open - unable to change hostName');
            end
        end


        function setPort(self,port)
            if ~self.isOpen
                self.port = port
            else
                warning('tcp connection open - unableto change port');
            end
        end


        function allOn(self)
            cmdData = char([1, hex2dec('FF')]);
            self.write(cmdData);
        end


        function allOff(self)
            cmdData = char([1, hex2dec('00')]);
            self.write(cmdData);
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
    if (num > 2^(8*num_chars))
        error('not enough characters for a number of this size' );
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


