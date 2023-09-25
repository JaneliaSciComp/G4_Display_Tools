function timeLogCommand

    ctlr = PanelsController();
    ctlr.open(true);
    ctlr.setRootDirectory("C:\matlabroot\G4");
    ctlr.setControlMode(2);
    ctlr.setPatternID(1);
    rsps = [];
    runTime = [];
    seqTime = [];
    for i =   [randi([1, 100], 1, 100)]% randi([0, 65534], 1, 20)] % 
        disp(i);
        ctlr.startLog()
        rsp = ctlr.startDisplay(i);
        seqStart = tic;
        ctlr.stopLog()
        seqComplete = toc(seqStart);
        rsps = [rsps; rsp];
        runTime = [runTime; i];
        seqTime = [seqTime; seqComplete];
    end
    T = table(rsps, runTime, seqTime);
    writetable(T, "stopLogTimes2.xlsx", "Sheet", "2023-09-24")
end