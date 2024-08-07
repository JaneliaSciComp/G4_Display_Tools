function FGgui2script_G4(handles)
    % FUNCTION FGgui2script_G4(param)
    %
    % creates a matlab script file that will create and save the function
    % specified by the current parameters in the G4_Function_Generator_gui
    % 
    % Script saved in the directory 'C:\matlabroot\G4\Scripts\'
    %
    % inputs:
    % param: all function parameters

    %determine function type
    param = handles.param;
    pfn_dir = handles.pfn_dir;
    afn_dir = handles.afn_dir;
    script_dir = handles.script_dir;
    if strcmp(param.type,'pfn')==1
        tempname = 'temp_position_function_script_G4.m';
        [folderpath,  foldername] = fileparts(pfn_dir);
    else
        tempname = 'temp_AO_function_script_G4.m';
        [folderpath, foldername] = fileparts(afn_dir);
    end

    %create script file
    script_dir = handles.script_dir;
    if ~exist(script_dir, 'dir')
        mkdir(script_dir);
    end
    if exist([script_dir tempname],'file')
        recycle('on');
        delete([script_dir tempname]);
        recycle('off');
    end
    FID = fopen(fullfile(script_dir, tempname),'a');

    %print descriptive comments of script
    fprintf(FID,'%s\n','% Script version of G4_Function_Generator with current GUI parameters');
    fprintf(FID,'%s\n',['% (script saved in ' script_dir ')']);
    fprintf(FID,'%s\n','%');
    fprintf(FID,'%s\n','% Save this script with a new filename to keep it from being overwritten');
    fprintf(FID,'%s\n','');
    fprintf(FID,'%s\n','%% user-defined function parameters');

    %print simple function parameters
    fprintf(FID,'%s\n',[param.type 'param.type = ''' param.type '''; %number of frames in pattern']);
    if strcmp(param.type,'pfn')==1
        fprintf(FID,'%s\n',['pfnparam.frames = ' num2str(param.frames) '; %number of frames in pattern']);
        fprintf(FID,'%s\n',['pfnparam.gs_val = ' num2str(param.gs_val) '; %brightness bits in pattern']);
    end

    %get text for parameter arrays by looping through every section
    secstr = [param.type 'param.section = { '];
    highstr = [param.type 'param.high = [ '];
    lowstr = [param.type 'param.low = [ '];
    durstr = [param.type 'param.dur = [ '];
    freqstr = [param.type 'param.freq = [ '];
    valstr = [param.type 'param.val = [ '];
    sizespeedstr = [param.type 'param.size_speed_ratio = [ '];
    flipstr = [param.type 'param.flip = [ '];
    for i=1:length(param.section)
        secstr = [secstr '''' param.section{i} ''' '];
        highstr = [highstr num2str(param.high(i)) ' '];
        lowstr = [lowstr num2str(param.low(i)) ' '];
        durstr = [durstr num2str(param.dur(i)) ' '];
        freqstr = [freqstr num2str(param.freq(i)) ' '];
        valstr = [valstr num2str(param.val(i)) ' '];
        sizespeedstr = [sizespeedstr num2str(param.size_speed_ratio(i)) ' '];
        flipstr = [flipstr num2str(param.flip(i)) ' '];
    end

    %print parameter arrays with comments
    fprintf(FID,'%s\n',[secstr '}; %static, sawtooth, traingle, sine, cosine, or square']);
    fprintf(FID,'%s\n',[durstr ']; %section duration (in s)']);
    fprintf(FID,'%s\n',[valstr ']; %function value for static sections']);
    fprintf(FID,'%s\n',[highstr ']; %high end of function range {for non-static sections}']);
    fprintf(FID,'%s\n',[lowstr ']; %low end of function range {for non-static sections}']);
    fprintf(FID,'%s\n',[freqstr ']; %frequency of section {for non-static sections}']);
    fprintf(FID,'%s\n',[sizespeedstr ']; %size/speed ratio {for looms}']);
    fprintf(FID,'%s\n',[flipstr ']; %flip the range of values of function {for non-static sections}']);
    fprintf(FID,'%s\n','');
    fprintf(FID,'%s\n','');

    %print script to generate function
    fprintf(FID,'%s\n','%% generate function');
    fprintf(FID,'%s\n',['func = G4_Function_Generator(' param.type 'param);']);
    fprintf(FID,'%s\n','');
    fprintf(FID,'%s\n','');

    %print script to save function
    fprintf(FID,'%s\n','%% save function');
    fprintf(FID,'%s\n',['save_dir = ''' fullfile(folderpath, foldername) ''';']);
    fprintf(FID,'%s\n',[param.type 'param.ID = get_function_ID(''' param.type ''',save_dir);']);
    fprintf(FID,'%s\n','filename = ''TestFunction'';');
    fprintf(FID,'%s\n',['save_function_G4(func, ' param.type 'param, save_dir, filename);']);
    fprintf(FID,'%s\n','');

    %close script file and open in Matlab
    fclose(FID);
    if strcmp(param.type,'pfn')==1
        edit(fullfile(script_dir, 'temp_position_function_script_G4.m'));
    else
        edit(fullfile(script_dir, 'temp_AO_function_script_G4.m'));
    end

end