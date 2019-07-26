%create a TCP/IP connection with the Host
if (connectHost==0) 
    return; 
end
    
%test mode 0
frameN = 16*3;
frameM = 16*12;

Panel_com('set_control_mode', 0);

for i = 1:6*16
    fprintf('creating frame %d\n',i);
    frame = zeros(frameN,frameM);
    
    frame(:,96-i+1) = 15;
    
    frameCmd(i).data = make_framevector_gs16(frame);
end

for i=1:numel(frameCmd)
    Panel_com('stream_frame',{length(frameCmd(i).data), 0, 0, frameCmd(i).data});
    pause(0.15)
end

pause(0.5)
Panel_com('All_OFF');

%disconnect with Host
disconnectHost;
