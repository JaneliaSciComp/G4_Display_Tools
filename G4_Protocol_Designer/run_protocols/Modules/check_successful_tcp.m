function check_successful_tcp()

    global ctlr

    if ctlr.tcpConn == -1
        system('"C:\Program Files (x86)\HHMI G4\G4 Host" &');
        status = 1;
        while status~=0
            [status, ~] = system('tasklist | find /I "G4 Host.exe"');
            pause(0.1);
        end
        ctlr = PanelsController();
        ctlr.mode = 0;
        ctlr.open();
    end

end