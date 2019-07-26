%create a TCP/IP connection with the Host
if (connectHost==0) 
    return; 
end

Panel_com('all_off');
Panel_com('change_root_directory', 'D:\G4_PanelController\Experiment');
Panel_com('set_control_mode', 2);
Panel_com('set_pattern_id', 2);
%pause 0.1 second to load the pattern
pause(0.1);
Panel_com('set_frame_rate', 20);
Panel_com('start_display', 300);

%disconnect Host
disconnectHost;
