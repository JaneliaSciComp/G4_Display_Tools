function Panel_com(command, argument)

%   Sends commands out to the panels
%  ARGUMENTS MUST BE ROW VECTORS
% Acceptable panel commands are:

switch lower(command)
    
    %% one byte commands:

    case 'stop_display'
        %	Stop display: panel_addr, 0x30
        send_tcp( char([1 48]));
        
    case 'all_off'      % set all panels to 0;
        send_tcp( char([1 hex2dec('00')]));
        
    case 'all_on'      % set all panels to 0;
        send_tcp( char([1 hex2dec('FF')]));
        
    case 'ctr_reset' % resets the controller
        send_tcp( char([1 hex2dec('60')]));  
        
    case 'get_version'
        send_tcp(char([1 hex2dec('46')]));
        
    case 'reset_counter'
        send_tcp(char([1 hex2dec('42')]));       
        
    case 'request_treadmill_data'
        send_tcp(char([1 hex2dec('45')]));          
        
    case 'update_gui_info' % Update gain, offset, and position information
        send_tcp(char([1, hex2dec('19')]));
        
    case 'start_log'
        reply = send_tcp( char([1 hex2dec('41')]), 1);
        
    case 'stop_log'
        reply = send_tcp( char([1 hex2dec('40')]), 1);     
        
    case 'reset_display'
        %	Board reset : 0x01, 
        send_tcp( char([1 1]));        
        
        
    %% two byte commands:
    
    case 'set_control_mode'
        if ((~isequal(length(argument),1))||(~isnumeric(argument))||any(argument > 7)||any(argument(1) < 0))
            error('set mode command requires 1 numerical argument between 0 and 7');
        end
        send_tcp( char([2  hex2dec('10') argument]),1);
        

    case 'reset'
        if (~isequal(length(argument),1)||(~isnumeric(argument)))
            error('reset command requires 1 argument that is a number');
        end
        %	Board reset : 0x01, panel_addr
        send_tcp( char([2 1 argument(1)]));
        

    case 'set_active_ao_channels'
%         First 4 bits represent the active channels i.e. 0001 - ch0, 0110 - ch2&3
%         Input should be a binary string
        assert(ischar(argument), 'Input should be a 4bit binary string')
        assert(length(argument) == 4, 'Input should be a 4bit binary string')
        assert(ismember(unique(argument), {'0', '1', '01'}), 'Input was not binary string') 
        relCh = bin2dec(['0000', argument]);
        
        send_tcp( char([2 hex2dec('11') relCh]));


        
    %% three byte commands
    
    case 'set_pattern_id'
        if ((~isequal(length(argument),1))||(~isnumeric(argument))||(argument(1) >255)||(argument(1) <= 0))
            error('Pattern ID command requires 1 numerical argument that is between 1 and 255');
        end
        % panel ID:  0x03, Panel_ID
        send_tcp( char([3 3 dec2char(argument(1),2)]),1);
        

    case 'set_pattern_func_id' 
        % 0 is default function
        if (~isequal(length(argument),1)||(~isnumeric(argument)))
            error('set position function command requires 2 numerical arguments');
        end
        
        send_tcp( char([3 hex2dec('15') dec2char(argument,2)]),1);        
        
    %% three byte commands
    case 'start_display'
        %	Start display with a duration
        %send_tcp( char([3 hex2dec('21') dec2char(argument)]));
        send_tcp( char([3 hex2dec('21') dec2char(argument*10,2)]));
        
    case 'set_frame_rate'
        send_tcp(char([3  hex2dec('12') dec2char(argument(1),2)]));        
                 
        
    case 'set_position_x'
        % 3 bytes to set pattern position: 0x70, then 2 bytes for x index
        if (~isequal(length(argument),1)||(~isnumeric(argument)))
            error('position setting command requires 1 numerical arguments');
        end
        %subtract -1 from each argument
        % beacause in matlab use 1 as start index, and controller uses 0
        send_tcp(char([3 hex2dec('70') dec2char(argument-1,2)]),1);
        
    case 'set_position_y'
        % 3 bytes to set pattern position: 0x70, then 2 bytes for y index
        if (~isequal(length(argument),1)||(~isnumeric(argument)))
            error('position setting command requires 1 numerical arguments');
        end
        %subtract -1 from each argument
        % beacause in matlab use 1 as start index, and controller uses 0
        send_tcp(char([3 hex2dec('71') dec2char(argument-1,2)]),1);        
        
        
%% four byte commands:  

    case 'set_ao_function_id' 
        if ~isequal(length(argument),2)||(~isnumeric(argument))
            error('set_analog_output_function(chan, fileIndex) requires 2 argument');
        end
         
        if (argument(1) > 3)||(argument(1) < 0)
            error('set_analog_output_function(chan, fileIndex): channel number ranges from 0 to 3');
        end
         
        send_tcp(char([4 hex2dec('31') argument(1), dec2char(argument(2),2)])); 
        

    case 'set_ao'
         if ~isequal(length(argument),2)||(~isnumeric(argument))
             error('set_AO(chan, val) requires 2 argument');
         end
         
         if (argument(1) > 4)||(argument(1) < 1)
             error('set_AO(chan, val): channel number ranges from 1 to 4');
         end
         
         if (argument(2) > 32767)||(argument(2) < -32767)
             error('set_AO(chan, val): val ranges from -32767 to 32767 (-10V-+10V)');
         end
         
         if argument(2) > 0
            send_tcp(char([4 hex2dec('10') argument(1) dec2char(argument(2),2)]));
         else
            send_tcp(char([4 hex2dec('11') argument(1) dec2char(abs(argument(2)),2)]));
         end
         

%% five byte commands:
    case 'set_gain_bias'
        % five bytes to set gain and bias values: 0x01, then 2 byte each for gain_x, bias_x
        if (~isequal(length(argument),2)||(~isnumeric(argument)))
            error('gain & bias setting command requires 2 numerical arguments');
        end
        %Note: these are all signed arguments, so we need to convert to 2's complement if necessary
        send_tcp( char([5 hex2dec('01') signed_16Bit_to_char(argument(1)), signed_16Bit_to_char(argument(2))]),1);

        %send_tcp([5 hex2dec('71') signed_byte_to_char(argument)]);
        %compress the 1000 0/1 laser pattern into a 125 bytes data
        %Panel_com('send_laser_pattern',pattern);
        %argument pattern is a binary vector with length from 1 to 1000.
        %for example
        %Panel_com('send_laser_pattern',[ones(1,250),zeros(1,250),ones(1,250),zeros(1,250)]);
        
    case 'set_pattern_and_position_function'
        % five bytes to set pattern and position function id
        if (~isequal(length(argument),2)||(~isnumeric(argument)))
            error('gain & bias setting command requires 2 numerical arguments');
        end
        %Note: these are all signed arguments, so we need to convert to 2's complement if necessary
        send_tcp( char([5 hex2dec('05') dec2char(argument(1),2), dec2char(argument(2),2)]),1);


%% variable byte commands

    case 'stream_frame'
        dataLen = argument{1};
        x_ao = argument{2};
        y_ao = argument{3};
        send_tcp(char([hex2dec('32') signed_16Bit_to_char(dataLen), signed_16Bit_to_char(x_ao), ...
            signed_16Bit_to_char(y_ao), argument{4}]),1);
        
    case 'change_root_directory'
        dirLen = length(argument);
        send_tcp(char([hex2dec('43') dec2char(dirLen,2) argument]),1);
        
    otherwise
        error('invalid command name, please check help')
end