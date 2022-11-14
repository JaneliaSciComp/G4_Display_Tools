%create a TCP/IP connection with the Host
%% Open new Panels controller instance
    ctlr = PanelsController();
    ctlr.mode = 0;
    ctlr.open(true);

if ~ctlr.isOpen 
    return; 
end
    
%test mode 0
frameN = 16*3;
frameM = 16*12;

ctlr.setControlMode(0);

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
ctlr.allOff();

%disconnect with Host
disconnectHost;
