function reply = send_tcp(string_to_send, varargin)
%send_serial is a function for sending and receving serial port info from matlab. 
%
%send_serial(string_to_send, waitingAck)
%        string_to_send is the command to be sent 
%        waitingAck is a flag for the function to wait for a acknowledgement or not
%        waitingAck default value is 0 when only user inputs only one
%        argument for send_serial. 
%        If waitingAck = 0, the function doesn't wait for data from the
%        receiver after sending the command.
%        If waitingAck = 1; the function wait for 0.1 second and then check
%        whether the data from the receiver are ready. If the data are
%        ready, the data are displayed.
%        If waitingAck = 2; the function wait until the data from the receiver 
%        are ready. If the data are ready, the data are displayed.

global ctlr

%Step 1: Currently we can use only read command, not write command, to check whether the connection is open
%or not 
message = pnet(ctlr.tcpConn, 'read','noblock');


%Step 2: check whether the connection is open 
%success is the number of the elements has been sent successfully
if  ctlr.isOpen() == 0
    ctlr = PanelsController();        
    ctlr.mode = 1;
    ctlr.open();
    %check whether the TCP connection was openned successfully     
    if ctlr.tcpConn == -1 
        if ctlr.mode == 1
            errordlg('Tcp/ip connection is broken. Please check whether the host app is running.', 'Broken TCP/IP connection!');
        else
            cprintf('err', 'Tcp/ip connection is broken. Please check whether the host app is running.')
        end   
        reply.numByte = 0;
        reply.success = -1;
        reply.commandCode = 0;
        reply.responseData = '';
        return
    end
    
    %change the default folder
    userSettings;
    Panel_com('change_root_directory',default_exp_path);
end

% step 3: send commands and receive feedback if it is GUI mode
success = ctlr.write(string_to_send);

% step 4: if mode == 1, which means GUI mode. Check the feedback
% information from the host.
if ctlr.mode ==1
    nVarargs = length(varargin);
    if nVarargs > 0
        waitAck = varargin{1};
        if waitAck
            pause(0.1);
            try
                message = pnet(ctlr.tcpConn, 'read','noblock');
                
            catch ME
                if ctlr.tcpConn == -1 || success == 1
                    ctlr = PanelsController();
                    ctlr.open();
                    %% update the status and update GUI accordingly
                    %% add codes here after Andy added update GUI command
                    
                    ctlr.write(string_to_send);
                    %     init_serial;
                    %     fwrite(serialPort, string_to_send, 'uchar');
                end
            end
            if ~isempty(message)
                reply.numByte = double(message(1));
                reply.success = double(message(2));
                reply.commandCode = double(message(3));
                reply.responseData = message(4:end);
                update_status_display(reply.responseData);
                return
            end
        end
    end
end
    
reply.numByte = 0;
reply.success = success;
reply.commandCode = 0;
reply.responseData = '';




    



