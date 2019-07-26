function testController

ctlr = PanelsController();
        
%     ctlr.startStreamingMode()
if true
    ctlr.open();
%     ctlr.startPatternMode()
    %pause(0.1);
    ctlr.startStreamingMode()
    pause(0.1);
    
%test gray scale level 16    
    frameN = 16*3;
    frameM = 16*12;
    
    for i = 1:6*16
        fprintf('creating frame %d\n',i);
        frame = zeros(frameN,frameM);
        
        frame(:,96-i+1) = 15;
        
        frameCmd(i).data = ctlr.getFrameCmd16(frame);
    end
    
    for i=1:numel(frameCmd)
        ctlr.streamFrameCmd16(frameCmd(i).data)
        pause(0.15)
    end
    
    pause(0.5)
    ctlr.allOff();
    
%     ctlr.startStreamingMode();
   %ctlr.setGrayScaleLevel2();
    
%     frameN = 16*2;
%     frameM = 16*12;
%     
%     for i = 1:6*16
%         fprintf('creating frame %d\n',i);
%         frame = zeros(frameN,frameM);
%         
%         frame(:,i) = 15;
%         
%         frameCmd(i).data = ctlr.getFrameCmd16(frame);
%     end
%     
%     for i=1:numel(frameCmd)
%         ctlr.streamFrameCmd16(frameCmd(i).data)
%         pause(0.15)
%     end
%     
%     pause(0.5)
%     ctlr.allOff();
    
    %test gray scale level 2
%     ctlr.setGrayScaleLevel2();
%     
%     frameN = 16*2;
%     frameM = 16*12;
%     
%     
%     fprintf('creating frame \n');
%     frame = zeros(frameN,frameM);
%     
%     frame(:,9) = 1;
%     
%     frameCmd.data = ctlr.getFrameCmd2(frame);
%     
%     
%     ctlr.streamFrameCmd2(frameCmd.data)
%     pause(0.15)
    
    
    ctlr.allOff();
    
    ctlr.close();
end

