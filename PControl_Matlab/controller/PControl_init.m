function PC = PControl_init()
%PControl_init
%PControl initializer script
global currentExp;
userSettings;

PC.gain_max = 10;
PC.gain_min = -10;
PC.gain_val = 0;


PC.offset_max = 5;
PC.offset_min = -5;
PC.offset_val = 0;

PC.x_pos = 1;
PC.y_pos = 1;

PC.x_mode = 0;  % default is open loop
PC.y_mode = 0;

PC.current_pattern = 0; % use this as the init value to check if real pattern is set

% load the currentExp file, we cannot load and save mat file in the init_serial
% because it is nested function and panel_control_paths.m cannnot be called.
% if exist('myPCCfg.mat','file')
%     load([controller_path '\myPCCfg'],'-mat');
% else
%     myPCCfg.portNum = 99; %trust user instead of a default value   
% end

%if initialize serial port 
% if init_serial == 1  
%     Panel_com('ctr_reset');
% end

%save serial port number to currentExp
% save([controller_path '\myPCCfg'], 'myPCCfg');

% load the currentExp file - 

if exist('CurrentExp.mat','file')
    try
        load('CurrentExp.mat')
        PC.num_patterns = currentExp.pattern.num_patterns;
        %PC.numVelFunc = currentExp.function.numVelFunc;
        %PC.numPosFunc = currentExp.function.numPosFunc;
        for j = 1:currentExp.pattern.num_patterns
            PC.pattern_x_size(j) = currentExp.pattern.x_num(j);
            PC.pattern_y_size(j) = currentExp.pattern.y_num(j);
        end
    catch ME
        currentExp.pattern.num_patterns=0;
        warndlg('The currentExp.mat file on the PC is corrupted.','corrupted currentExp.mat file');
    end
        
else  % first time to ran PControl
    currentExp.pattern.num_patterns=0;
    warndlg('No currentExp.mat file is found on your PC', 'No currentExp.mat found');
end

PC.num_patterns = currentExp.pattern.num_patterns;
%PC.numVelFunc = currentExp.function.numVelFunc;
%PC.numPosFunc = currentExp.function.numPosFunc;
for j = 1:currentExp.pattern.num_patterns
     PC.pattern_x_size(j) = currentExp.pattern.x_num(j); 
     PC.pattern_y_size(j) = currentExp.pattern.y_num(j); 
end

