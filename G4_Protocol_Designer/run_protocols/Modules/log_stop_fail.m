function log_stopped = log_stop_fail()

    global ctlr

    disp("Log failed to stop. Retrying...");
    log_stopped = ctlr.stopLog();
    if ~log_stopped
        disp("Log failed to stop. Please stop manually.");
    end

end