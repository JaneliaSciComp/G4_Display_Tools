function write_error_log(command, msg)
    
    fid = fopen('panel_com_error_log.txt','at');
    msg = [command, ' command failed. Response message: ', msg];
    if fid == -1
        disp(msg);
    else
        fprintf(fid, [datestr(now, 'mm/dd/yy HH:MM:SS'),':  ',msg, '\n\n']);

    end
    fclose(fid);


end