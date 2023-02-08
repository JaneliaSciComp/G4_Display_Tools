
%start Host, set to streaming mode
connectHost;
global ctlr
Panel_com('set_control_mode',0) %sets control mode to streaming mode

%set AI channels for TCP streaming
AI = 3; %for active channels 1 and 2
Panel_com('change_root_directory', 'C:\matlabroot\G4');
Panel_com('start_log');
send_tcp( char([2 hex2dec('13') AI]));

%pre-render 1-bit greyscale frames
AllONvector = make_framevector_gs16(15*ones(64,192),127);
AllOFFvector = make_framevector_gs16(zeros(64,192),0);
vector_length = length(AllOFFvector);

%stream dark pattern to start
%Panel_com('stream_frame',{vector_length,0,0,AllOFFvector});
Panel_com('stream_frame',{vector_length,0,0,AllONvector});
Panel_com('stop_log');
pause(1);


%% run experiment (100 repetions)
Panel_com('start_log');
num_samples=0; %trigger signal is a 1 Hz pulse with 20% duty cycle
while num_samples<100;
    message = pnet(ctlr.tcpConn, 'read','noblock');
    if ~isempty(message)
        LO = dec2bin(uint8(message(3)),8);
        HI = dec2bin(uint8(message(4)),8);
        val = typecast(uint16(bin2dec([HI LO])),'int16');
        if val>30000 && val < 34000 %if 5V trigger is detected
            Panel_com('stream_frame',{vector_length,0,0,AllONvector});
            pause(0.5); %pause greater than trigger window
            Panel_com('stream_frame',{vector_length,0,0,AllOFFvector});
            num_samples=num_samples+1;
            message = pnet(ctlr.tcpConn, 'read','noblock'); %clear cache
        end
    end
end
Panel_com('stop_log');


