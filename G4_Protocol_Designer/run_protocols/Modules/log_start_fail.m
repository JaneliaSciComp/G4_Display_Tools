function log_started = log_start_fail(runcon)
    
    global ctlr

     disp("Log failed to start, retrying...");
     log_started = ctlr.startLog();
     if ~log_started
         disp("Log failed a second time, aborting experiment.");
         runcon.abort_experiment();
     end

end