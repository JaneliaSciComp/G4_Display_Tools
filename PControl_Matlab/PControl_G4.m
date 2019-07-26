function varargout = PControl_G4(varargin)
% PCONTROL_G4 M-file for PControl_G4.fig

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @PControl_G4_OpeningFcn, ...
    'gui_OutputFcn',  @PControl_G4_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before PControl_G4 is made visible.
function PControl_G4_OpeningFcn(hObject, eventdata, handles, varargin)
global currentState hPcontrol ctlr currentExp;
handles.output = hObject;
handles.Running = 0;
hPcontrol = gcf;
% run the init program -
% if ~exist('PControl_paths.mat', 'file')
%     initialize_Pcontrol_paths;
% end

ctlr = PanelsController();
ctlr.mode = 1;
ctlr.open();
if ctlr.tcpConn == -1
    system('"C:\Program Files (x86)\HHMI G4\G4 Host" &');
    pause(15);
    ctlr = PanelsController();
    ctlr.mode = 1;
    ctlr.open();
end

set(handles.setPosFunc, 'enable', 'off');
set(handles.frame_rate, 'enable', 'off');
set(handles.x_pos_val, 'enable', 'off');
set(handles.x_pos_plus, 'enable', 'off');
set(handles.x_pos_minus, 'enable', 'off');
set(handles.gain_slider, 'value', 0);
set(handles.offset_slider, 'value', 0);
set(handles.gain_slider, 'enable', 'off');
set(handles.offset_slider, 'enable', 'off');
set(handles.gain_zero, 'enable', 'off');
set(handles.offset_zero, 'enable', 'off');
set(findall(handles.ao_panel, '-property', 'enable'), 'enable', 'off');
set(handles.status_display, 'String',' ');


%add tab
% Set the colors indicating a selected/unselected tab
handles.unselectedTabColor=get(handles.tab1text,'BackgroundColor');
handles.selectedTabColor=handles.unselectedTabColor-0.1;

% Set units to normalize for easier handling
set(handles.tab1text,'Units','normalized')
set(handles.tab2text,'Units','normalized')
set(handles.tab1panel,'Units','normalized')
set(handles.tab2panel,'Units','normalized')

% Create tab labels (as many as you want according to following code template)

% Tab 1
pos1=get(handles.tab1text,'Position');
handles.a1=axes('Units','normalized',...
    'Box','on',...
    'XTick',[],...
    'YTick',[],...
    'Color',handles.selectedTabColor,...
    'Position',[pos1(1) pos1(2) pos1(3) pos1(4)+0.01],...
    'ButtonDownFcn','PControl_G4(''a1bd'',gcbo,[],guidata(gcbo))');
handles.t1=text('String','Controller',...
    'Units','normalized',...
    'Position',[(pos1(3)-pos1(1))/2,pos1(2)/2+pos1(4)],...
    'HorizontalAlignment','left',...
    'VerticalAlignment','middle',...
    'Margin',0.001,...
    'FontSize',8,...
    'Backgroundcolor',handles.selectedTabColor,...
    'ButtonDownFcn','PControl_G4(''t1bd'',gcbo,[],guidata(gcbo))');

% Tab 2
pos2=get(handles.tab2text,'Position');
pos2(1)=pos1(1)+pos1(3);
handles.a2=axes('Units','normalized',...
    'Box','on',...
    'XTick',[],...
    'YTick',[],...
    'Color',handles.unselectedTabColor,...
    'Position',[pos2(1) pos2(2) pos2(3) pos2(4)+0.01],...
    'ButtonDownFcn','PControl_G4(''a2bd'',gcbo,[],guidata(gcbo))');
handles.t2=text('String','Streaming',...
    'Units','normalized',...
    'Position',[pos2(3)/2,pos2(2)/2+pos2(4)],...
    'HorizontalAlignment','left',...
    'VerticalAlignment','middle',...
    'Margin',0.001,...
    'FontSize',8,...
    'Backgroundcolor',handles.unselectedTabColor,...
    'ButtonDownFcn','PControl_G4(''t2bd'',gcbo,[],guidata(gcbo))');

% Manage panels (place them in the correct position and manage visibilities)
pan1pos=get(handles.tab1panel,'Position');
set(handles.tab2panel,'Position',pan1pos)
set(handles.tab2panel,'Visible','off')



%% update the status and update GUI accordingly
%% add codes here after Andy added update GUI command
handles.ctlr = ctlr;
handles.PC = PControl_init;

userSettings;
load(fullfile(default_exp_path,'currentExp.mat'));
Panel_com('change_root_directory',default_exp_path);

movegui(gcf, 'center');
set(handles.gain_slider, 'max', handles.PC.gain_max ,'min', ...
    handles.PC.gain_min,'Value',handles.PC.gain_val);
set(handles.gain_val, 'String', [num2str(handles.PC.gain_val) ' X']);

set(handles.offset_slider, 'max', handles.PC.offset_max ,'min', ...
    handles.PC.offset_min,'Value',handles.PC.offset_val);
set(handles.offset_val, 'String', [num2str(handles.PC.offset_val) ' V']);

% Update handles structure
guidata(hObject, handles);
update_status_display('> > > > >  Welcome to the Panels control program  < < < < < <');

%initialization
currentState.funcXID = 1;
currentState.funcYID = 1;
currentState.pattID = 0;
currentState.pattName = 'NONE';
currentState.funcXName = 'default';
currentState.funcYName = 'default';
currentState.pattName = 'default';
currentState.dac2FuncID = 0;
currentState.dac3FuncID = 0;
currentState.dac4FuncID = 0;
currentState.dac5FuncID = 0;
currentState.dac4Channels = 0;
currentState.dac2Active = 0;
currentState.dac3Active = 0;
currentState.dac4Active = 0;
currentState.dac5Active = 0;
handles.trialDuration = 0;
handles.frameRate = 0;
handles.PC.x_mode = 1;
handles.grayLevel = 0;
handles.GSlevel = 2;

%set the current path
set(handles.current_dir, 'string', default_exp_path);

%add the pattern list
if currentExp.pattern.num_patterns
    patternList = currentExp.pattern.pattNames;
    patternList = ['0: none', patternList];
    set(handles.setAPattern, 'String', patternList);
    set(handles.setAPattern, 'Value', 1);
end

%add the function list
if currentExp.function.numFunc
    funcList = currentExp.function.functionName;
    funcList = ['0: none', funcList];
    set(handles.setPosFunc, 'String', funcList);
    set(handles.setPosFunc, 'Value', currentState.funcXID);
end

%add the ao function list
if currentExp.aoFunction.numaoFunc
    aoFuncList = currentExp.aoFunction.aoFunctionName;
    aoFuncList = ['0: none', aoFuncList];
    set(handles.dac2_ao_func_list, 'String', aoFuncList);
    set(handles.dac3_ao_func_list, 'String', aoFuncList);
    set(handles.dac4_ao_func_list, 'String', aoFuncList);
    set(handles.dac5_ao_func_list, 'String', aoFuncList);
    
    set(handles.dac2_ao_func_list, 'Value', 1);
    set(handles.dac3_ao_func_list, 'Value', 1);
    set(handles.dac4_ao_func_list, 'Value', 1);
    set(handles.dac5_ao_func_list, 'Value', 1);
end

%initialized the tab2
[I, map] = imread('Please_Load.bmp', 'BMP');
axes(handles.axes3);
colormap(map);
image(I);
axis off; axis image;

handles.x_pos = 1;
handles.y_pos = 1;
handles.pattern_x_size = 1;
handles.pattern_y_size = 1;

guidata(hObject, handles);


% Text object 1 callback (tab 1)
function t1bd(hObject,eventdata,handles)

set(hObject,'BackgroundColor',handles.selectedTabColor)
set(handles.t2,'BackgroundColor',handles.unselectedTabColor)
set(handles.a1,'Color',handles.selectedTabColor)
set(handles.a2,'Color',handles.unselectedTabColor)
set(handles.tab1panel,'Visible','on')
set(handles.tab2panel,'Visible','off')
set(handles.Start_button, 'enable', 'on')
set(handles.trial_duration, 'enable', 'on')
set(handles.working_mode, 'value',1);

% Text object 2 callback (tab 2)
function t2bd(hObject,eventdata,handles)

set(hObject,'BackgroundColor',handles.selectedTabColor)
set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
set(handles.a2,'Color',handles.selectedTabColor)
set(handles.a1,'Color',handles.unselectedTabColor)
set(handles.tab2panel,'Visible','on')
set(handles.tab1panel,'Visible','off')
set(handles.Start_button, 'enable', 'off')
set(handles.trial_duration, 'enable', 'off')
Panel_com('set_control_mode',0);


% Axes object 1 callback (tab 1)
function a1bd(hObject,eventdata,handles)

set(hObject,'Color',handles.selectedTabColor)
set(handles.a2,'Color',handles.unselectedTabColor)
set(handles.t1,'BackgroundColor',handles.selectedTabColor)
set(handles.t2,'BackgroundColor',handles.unselectedTabColor)
set(handles.tab1panel,'Visible','on')
set(handles.tab2panel,'Visible','off')
set(handles.Start_button, 'enable', 'on')
set(handles.trial_duration, 'enable', 'on')
set(handles.working_mode, 'value',1);

% Axes object 2 callback (tab 2)
function a2bd(hObject,eventdata,handles)

set(hObject,'Color',handles.selectedTabColor)
set(handles.a1,'Color',handles.unselectedTabColor)
set(handles.t2,'BackgroundColor',handles.selectedTabColor)
set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
set(handles.tab2panel,'Visible','on')
set(handles.tab1panel,'Visible','off')
set(handles.Start_button, 'enable', 'off')
set(handles.trial_duration, 'enable', 'off')
Panel_com('set_control_mode',0);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
%close the serial port connection
global ctlr currentExp;
userSettings;
selection = questdlg('Close Panel Controller?','Close Request Function', 'Yes','No','Yes');
switch selection,
    case 'Yes',
        %         save([controller_path, '\currentExp.mat'], 'currentExp');
        if exist('ctlr')
            %fclose(ctlr);
            ctlr.close();
            clear ctlr;
            clear hPcontrol;
        end
        delete(hObject)
    case 'No'
        return
end


% --- Outputs from this function are returned to the command line.
function varargout = PControl_G4_OutputFcn(hObject, eventdata, handles)
% no outputs, so this function does nothing fancy
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function gain_slider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function gain_slider_Callback(hObject, eventdata, handles)
handles.PC.gain_val = round(get(hObject,'Value')*100)/10;   % this is done so only one dec place
set(handles.gain_val, 'String', [num2str(handles.PC.gain_val) ' X']);
guidata(hObject, handles);
%send command to controller
Send_Gain_Bias(handles);

% --- Executes on button press in gain_zero.
function gain_zero_Callback(hObject, eventdata, handles)
% set slider value to zero and execute the slider call back
set(handles.gain_slider, 'Value', 0);
gain_slider_Callback(handles.gain_slider, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function offset_slider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function offset_slider_Callback(hObject, eventdata, handles)
handles.PC.offset_val = round(get(hObject,'Value')*200)/10;
set(handles.offset_val, 'String', [num2str(handles.PC.offset_val) ' V']);
guidata(hObject, handles);
%send command to controller
Send_Gain_Bias(handles);

% --- Executes on button press in offset_zero.
function offset_zero_Callback(hObject, eventdata, handles)
% set slider value to zero and execute the slider call back
set(handles.offset_slider, 'Value', 0);
offset_slider_Callback(handles.offset_slider, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function Pattern_ID_menu_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



% --- Executes during object creation, after setting all properties.
function x_pos_val_s_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function x_pos_val_s_Callback(hObject, eventdata, handles)
user_entry = str2double(get(hObject,'string'));
if isnan(user_entry)
    errordlg('You must enter a numeric value','Bad Input','modal')
    set(handles.x_pos_val_s, 'string', num2str(handles.x_pos));
elseif (user_entry ~= round(user_entry) )
    errordlg('You must enter an integer','Bad Input','modal')
    set(handles.x_pos_val_s, 'string', num2str(handles.x_pos));
elseif ( (user_entry < 0)|(user_entry > handles.pattern_x_size) )
    errordlg('Number is out of the range for this pattern','Bad Input','modal')
    set(handles.x_pos_val_s, 'string', num2str(handles.x_pos));
else  % once you get here this is actually good input
    handles.x_pos = user_entry;
    guidata(hObject, handles);
end
display_curr_frame(handles)

function x_pos_val_Callback(hObject, eventdata, handles)
%        str2double(get(hObject,'String')) returns contents of x_pos_val_s as a double
user_entry = str2double(get(hObject,'string'));
if isnan(user_entry)
    errordlg('You must enter a numeric value','Bad Input','modal')
    set(handles.x_pos_val, 'string', num2str(handles.PC.x_pos));
elseif (user_entry ~= round(user_entry) )
    errordlg('You must enter an integer','Bad Input','modal')
    set(handles.x_pos_val, 'string', num2str(handles.PC.x_pos));
elseif ( (user_entry < 0)|(user_entry > handles.PC.pattern_x_size(handles.PC.current_pattern) ) )
    errordlg('Number is out of the range for this pattern','Bad Input','modal')
    set(handles.x_pos_val, 'string', num2str(handles.PC.x_pos));
else  % once you get here this is actually good input
    handles.PC.x_pos = user_entry;
    guidata(hObject, handles);
    %send x and y pos out to controller
    Panel_com('set_position', [handles.PC.x_pos, handles.PC.y_pos]);
end



% --- Executes during object creation, after setting all properties.
function y_pos_val_s_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function y_pos_val_s_Callback(hObject, eventdata, handles)
user_entry = str2double(get(hObject,'string'));
if isnan(user_entry)
    errordlg('You must enter a numeric value','Bad Input','modal')
    set(handles.y_pos_val_s, 'string', num2str(handles.y_pos));
elseif (user_entry ~= round(user_entry) )
    errordlg('You must enter an integer','Bad Input','modal')
    set(handles.y_pos_val_s, 'string', num2str(handles.y_pos));
elseif ( (user_entry < 0)|(user_entry > handles.pattern_y_size) )
    errordlg('Number is out of the range for this pattern','Bad Input','modal')
    set(handles.y_pos_val_s, 'string', num2str(handles.y_pos));
else  % once you get here this is actually good input
    handles.y_pos = user_entry;
    guidata(hObject, handles);
end
display_curr_frame(handles)

function x_pos_plus_s_Callback(hObject, eventdata, handles)
% increment the x_pos, wrap around if too big
temp_pos = handles.x_pos + 1;
if (temp_pos > handles.pattern_x_size)
    temp_pos = 1;
end
handles.x_pos = temp_pos;
set(handles.x_pos_val_s, 'string', num2str(temp_pos));
guidata(hObject, handles);
display_curr_frame(handles)

function x_pos_minus_s_Callback(hObject, eventdata, handles)
% decrement the x_pos, wrap around if hits zero
temp_pos = handles.x_pos - 1;
if (temp_pos <= 0)
    temp_pos = handles.pattern_x_size;
end
handles.x_pos = temp_pos;
set(handles.x_pos_val_s, 'string', num2str(temp_pos));
guidata(hObject, handles);
display_curr_frame(handles)


% --- Executes on button press in y_pos_plus_s.
function y_pos_plus_s_Callback(hObject, eventdata, handles)
% increment the y_pos, wrap around if too big
temp_pos = handles.y_pos + 1;
if (temp_pos > handles.pattern_y_size)
    temp_pos = 1;
end
handles.y_pos = temp_pos;
set(handles.y_pos_val_s, 'string', num2str(temp_pos));
guidata(hObject, handles);
display_curr_frame(handles)


% --- Executes on button press in y_pos_minus_s.
function y_pos_minus_s_Callback(hObject, eventdata, handles)
% decrement the y_pos, wrap around if hits zero
temp_pos = handles.y_pos - 1;
if (temp_pos <= 0)
    temp_pos = handles.pattern_y_size;
end
handles.y_pos = temp_pos;
set(handles.y_pos_val_s, 'string', num2str(temp_pos));
guidata(hObject, handles);
display_curr_frame(handles)


% --------------------------------------------------------------------
function menu_commands_Callback(hObject, eventdata, handles)
% do nothing, this is just the first level menu callback.


% --------------------------------------------------------------------
function menu_reset_Callback(hObject, eventdata, handles)
% open up a dialog box to get the address of the panel to reset
prompt = {'Which panel to reset (0 for all) ?'};
dlg_title = 'Panel Reset';
num_lines= 1;
def     = {'0'};
answer  = inputdlg(prompt,dlg_title,num_lines,def);

% If choose cancel, return.
if isempty(answer)
    return;
end

% do some error checking
num_answer = str2double(answer);
if ( ~isnan(num_answer) && (num_answer == round(num_answer)) )
    Panel_com('reset' , [num_answer]);  % call reset if OK
else    %otherwise, error and do nothing
    errordlg('Panel address must be an integer - no action taken','Bad Input','modal')
end

% --------------------------------------------------------------------
function menu_all_off_Callback(hObject, eventdata, handles)
Panel_com('all_off');

% --------------------------------------------------------------------
function menu_all_on_Callback(hObject, eventdata, handles)
Panel_com('all_on');

% --------------------------------------------------------------------
function menu_configuration_Callback(hObject, eventdata, handles)
% do nothing, this is just the first level menu callback.

% --- Executes on button press in Start_button.
function Start_button_Callback(hObject, eventdata, handles)
if (handles.Running == 0 && handles.trialDuration>0)   %if not currently running
    Panel_com('set_control_mode', handles.PC.x_mode);
    Panel_com('start_display', round(handles.trialDuration));     %send start command to the controller
    handles.Running = 1;    % set running flag to 1
    guidata(hObject, handles);%update the data
    set(hObject, 'string', 'STOP');         % make button say STOP
    set(hObject, 'backgroundcolor', [0.9 0 0]);
    pause(handles.trialDuration);
    set(hObject, 'string', 'START');    % turn button to START
    set(hObject, 'backgroundcolor', [0 0.5 0]);
else
    Panel_com('stop_display');     %send stop command to the controller
    set(hObject, 'string', 'START');    % turn button to START
    set(hObject, 'backgroundcolor', [0 0.5 0]);
end
handles.Running = 0;    % set running flag to off
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_play_pattern_Callback(hObject, eventdata, handles)
% launch the GUI for playing the patterns
Pattern_Player;


% --------------------------------------------------------------------
function menu_functions_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function menu_load_currentExp_Callback(hObject, eventdata, handles)
choose_pats;

% --- Executes during object creation, after setting all properties.
function working_mode_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in working_mode.
function working_mode_Callback(hObject, eventdata, handles)
% mode value is the menu index minus 1, so 0, 1, or 2
handles.PC.x_mode = get(hObject,'Value')-1;
guidata(hObject, handles);

if handles.PC.x_mode
    Panel_com('set_control_mode', handles.PC.x_mode);
end

switch handles.PC.x_mode
    case 0
        set(handles.setPosFunc, 'enable', 'off');
        set(handles.frame_rate, 'enable', 'off');
        set(handles.x_pos_val, 'enable', 'off');
        set(handles.x_pos_plus, 'enable', 'off');
        set(handles.x_pos_minus, 'enable', 'off');
        set(handles.gain_slider, 'value', 0);
        set(handles.offset_slider, 'value', 0);
        set(handles.gain_slider, 'enable', 'off');
        set(handles.offset_slider, 'enable', 'off');
        set(handles.gain_zero, 'enable', 'off');
        set(handles.offset_zero, 'enable', 'off');
        set(findall(handles.ao_panel, '-property', 'enable'), 'enable', 'off');
    case 1
        set(handles.setPosFunc, 'enable', 'on');
        set(handles.frame_rate, 'enable', 'off');
        set(handles.x_pos_val, 'enable', 'off');
        set(handles.x_pos_plus, 'enable', 'off');
        set(handles.x_pos_minus, 'enable', 'off');
        set(handles.gain_slider, 'value', 0);
        set(handles.offset_slider, 'value', 0);
        set(handles.gain_slider, 'enable', 'off');
        set(handles.offset_slider, 'enable', 'off');
        set(handles.gain_zero, 'enable', 'off');
        set(handles.offset_zero, 'enable', 'off');
        set(findall(handles.ao_panel, '-property', 'enable'), 'enable', 'on');
    case 2
        set(handles.setPosFunc, 'enable', 'off');
        set(handles.frame_rate, 'enable', 'on');
        set(handles.x_pos_val, 'enable', 'off');
        set(handles.x_pos_plus, 'enable', 'off');
        set(handles.x_pos_minus, 'enable', 'off');
        set(handles.gain_slider, 'enable', 'off');
        set(handles.offset_slider, 'enable', 'off');
        set(handles.gain_slider, 'value', 0);
        set(handles.offset_slider, 'value', 0);
        set(handles.gain_zero, 'enable', 'off');
        set(handles.offset_zero, 'enable', 'off');
        set(findall(handles.ao_panel, '-property', 'enable'), 'enable', 'on');
    case 3
        set(handles.setPosFunc, 'enable', 'off');
        set(handles.frame_rate, 'enable', 'off');
        set(handles.x_pos_val, 'enable', 'on');
        set(handles.x_pos_plus, 'enable', 'on');
        set(handles.x_pos_minus, 'enable', 'on');
        set(handles.gain_slider, 'enable', 'off');
        set(handles.offset_slider, 'enable', 'off');
        set(handles.gain_slider, 'value', 0);
        set(handles.offset_slider, 'value', 0);
        set(handles.gain_zero, 'enable', 'off');
        set(handles.offset_zero, 'enable', 'off');
        set(findall(handles.ao_panel, '-property', 'enable'), 'enable', 'off');
    case 4
        set(handles.setPosFunc, 'enable', 'off');
        set(handles.frame_rate, 'enable', 'off');
        set(handles.x_pos_val, 'enable', 'on');
        set(handles.x_pos_plus, 'enable', 'on');
        set(handles.x_pos_minus, 'enable', 'on');
        set(handles.gain_slider, 'enable', 'on');
        set(handles.offset_slider, 'enable', 'on');
        set(handles.gain_slider, 'value', 0);
        set(handles.offset_slider, 'value', 0);
        set(handles.gain_zero, 'enable', 'on');
        set(handles.offset_zero, 'enable', 'on');
        set(findall(handles.ao_panel, '-property', 'enable'), 'enable', 'off');
    case {5,6}
        set(handles.setPosFunc, 'enable', 'on');
        set(handles.frame_rate, 'enable', 'off');
        set(handles.x_pos_val, 'enable', 'on');
        set(handles.x_pos_plus, 'enable', 'on');
        set(handles.x_pos_minus, 'enable', 'on');
        set(handles.gain_slider, 'enable', 'on');
        set(handles.offset_slider, 'enable', 'on');
        set(handles.gain_slider, 'value', 0);
        set(handles.offset_slider, 'value', 0);
        set(handles.gain_zero, 'enable', 'on');
        set(handles.offset_zero, 'enable', 'on');
        set(findall(handles.ao_panel, '-property', 'enable'), 'enable', 'off');
end


% --- Executes during object creation, after setting all properties.
function y_loop_menu_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in y_loop_menu.
function y_loop_menu_Callback(hObject, eventdata, handles)
% mode value is the menu index minus 1, so 0, 1, or 2
handles.PC.y_mode = get(hObject,'Value') - 1;
guidata(hObject, handles);
Panel_com('set_control_mode', [handles.PC.x_mode handles.PC.y_mode]);


% --------------------------------------------------------------------
function menu_exit_Callback(hObject, eventdata, handles)
% hObject    handle to menu_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%figure1_CloseRequestFcn(gcf, eventdata, handles);



% --------------------------------------------------------------------

function Update_current_patterns(handles, Pattern_ID)
% update the current pattern
% pattern_ID should be an integer

global currentExp;
handles.PC.current_pattern = Pattern_ID;
handles.PC.y_pos = 1;
handles.PC.x_pos = 1;
set(handles.x_pos_val, 'string', 1);
handles.pattern_x_size = currentExp.pattern.x_num(Pattern_ID);
handles.pattern_y_size = currentExp.pattern.y_num(Pattern_ID);
guidata(gcf, handles);
%update_status_display(['Pattern ' num2str(Pattern_ID) ' is the current pattern']);

function Send_Gain_Bias(handles)
% this function sends out the new gain and bias values to the controller
%Panel_com('stop_display')
gain = round(10*handles.PC.gain_val/(handles.PC.gain_max));
bias = round(5*handles.PC.offset_val/(handles.PC.offset_max));
Panel_com('set_gain_bias', [gain, bias]);
%update_status_display(['Sending: gain = ' num2str(gain) ', bias = ' num2str(bias)]);
% if handles.Running == true
%     Panel_com('start_display');
% end

% --------------------------------------------------------------------
function menu_reset_ctrl_Callback(hObject, eventdata, handles)
% resets the controller CPU (and eventually the CF controller also
global newString;
Panel_com('ctr_reset');
%update_status_display(newString);


% --------------------------------------------------------------------
function menu_LED_blink_Callback(hObject, eventdata, handles)
% % toggles controller LED - as a check that controller is responsive
Panel_com('led_tog');


% --------------------------------------------------------------------
function menu_set_Pat_ID_Callback(hObject, eventdata, handles)
global currentState currentExp;

%if currentExp.pattern.num_patterns ~=0
setPattern;

%wait till user chooses a pattern or closes the setPattern GUI
while ~currentState.closeSetPat
    pause(0.01);
end

%if chose a pattern, update GUI; if close the GUI, do nothing
if currentState.chosePat
    pattID = currentState.pattID;
    Update_current_patterns(handles, pattID);
    
    
    set(handles.offset_slider, 'enable', 'on');
    set(handles.gain_slider, 'enable', 'on');
    set(handles.gain_zero, 'enable', 'on');
    set(handles.offset_zero, 'enable', 'on');
    set(handles.working_mode, 'enable', 'on');
    set(handles.x_pos_val, 'enable', 'on');
    set(handles.x_pos_plus, 'enable', 'on');
    set(handles.x_pos_minus, 'enable', 'on');
    
    set(handles.y_loop_menu, 'enable', 'on');
    set(handles.y_pos_val_s, 'enable', 'on');
    set(handles.y_pos_plus_s, 'enable', 'on');
    set(handles.y_pos_minus_s, 'enable', 'on');
    
    set(handles.Start_button, 'enable', 'on');
end

%else
%    warndlg('You have no patterns to be set, please load patterns to currentExp card first.', 'Empty pattern list');
%end

% --------------------------------------------------------------------
function menu_test_adc_Callback(hObject, eventdata, handles)
% open up a dialog box to get the channel number

prompt = {'Please connect DAC0 to an ADC channel to be tested and connect DAC1 to a scope. You should see a 0 - 4 Volt triangle wave for about 20 seconds. Enter the ADC channel to be tested, from 1 to 8'};
dlg_title = 'test ADC';
num_lines= 1; def = {'1'};
answer  = inputdlg(prompt,dlg_title,num_lines,def);

% If choose cancel, return.
if isempty(answer)
    return;
end

% do some error checking
num_answer = str2double(answer) - 1;
if ( ~isnan(num_answer) && (num_answer == round(num_answer)) && (num_answer >= 0) && (num_answer <= 7) )
    Panel_com('adc_test', [num_answer]);
else    %otherwise, error and do nothing
    errordlg('ADC channel to test must be a positive integer from 1 to 8 -- no action taken','Bad Input','modal')
end




% --------------------------------------------------------------------
function status_Callback(hObject, eventdata, handles)
% hObject    handle to status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

report_status;


% --------------------------------------------------------------------
function panelProg_Callback(hObject, eventdata, handles)
% hObject    handle to panelProg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function help_Callback(hObject, eventdata, handles)
% hObject    handle to help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function busNum_Callback(hObject, eventdata, handles)
% hObject    handle to busNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Panel_com('show_bus_number');

% --------------------------------------------------------------------
function version_Callback(hObject, eventdata, handles)
% hObject    handle to version (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Panel_com('get_version');




% --------------------------------------------------------------------
function menu_config_Callback(hObject, eventdata, handles)
% hObject    handle to menu_config (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function set_Pcontrol_paths_Callback(hObject, eventdata, handles)
% hObject    handle to set_Pcontrol_paths (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
change_paths;


% --- Executes on button press in Update.
function Update_Callback(hObject, eventdata, handles)
% hObject    handle to Update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Panel_com('update_gui_info');


% --- Executes during object creation, after setting all properties.
function status_display_CreateFcn(hObject, eventdata, handles)
% hObject    handle to status_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in setAPattern.
function setAPattern_Callback(hObject, eventdata, handles)
% hObject    handle to setAPattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns setAPattern contents as cell array
%        contents{get(hObject,'Value')} returns selected item from setAPattern
global currentState currentExp
contents = get(hObject,'String');
pattID= get(hObject,'Value')-1;

currentState.pattID = pattID;
currentState.pattName = contents{currentState.pattID+1};

if currentExp.pattern.num_patterns ~=0 && pattID >0
    Update_current_patterns(handles, pattID);
    Panel_com('set_pattern_id', pattID);
end

% --- Executes during object creation, after setting all properties.
function setAPattern_CreateFcn(hObject, eventdata, handles)
% hObject    handle to setAPattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in setPosFunc.
function setPosFunc_Callback(hObject, eventdata, handles)
% hObject    handle to setPosFunc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns setPosFunc contents as cell array
%        contents{get(hObject,'Value')} returns selected item from setPosFunc
global currentState currentExp;
contents = get(hObject,'String');
currentState.funcXID = get(hObject,'Value');
currentState.funcXName = contents{currentState.funcXID};
if currentState.funcXID ~= 1
    Panel_com('set_pattern_func_id', currentState.funcXID-1);
end

% --- Executes during object creation, after setting all properties.
function setPosFunc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to setPosFunc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in setFuncY.
function setFuncY_Callback(hObject, eventdata, handles)
% hObject    handle to setFuncY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns setFuncY contents as cell array
%        contents{get(hObject,'Value')} returns selected item from setFuncY
global currentState currentExp;
contents = get(hObject,'String');
currentState.funcYID = get(hObject,'Value');
currentState.funcYName = contents{currentState.funcYID};
if currentState.funcYID - 1 < currentExp.function.numVelFunc
    Panel_com('set_velFunc_id', [2, currentState.funcYID - 1]);  % call reset if OK
else
    Panel_com('set_posFunc_id', [2, currentState.funcYID-currentExp.function.numVelFunc - 1]);
end

% --- Executes during object creation, after setting all properties.
function setFuncY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to setFuncY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in log_enable.
function log_enable_Callback(hObject, eventdata, handles)
% hObject    handle to log_enable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of log_enable
logEnable = get(hObject,'Value');
if logEnable
    Panel_com('start_log');
else
    Panel_com('stop_log');
end

% --- Executes during object creation, after setting all properties.
function log_enable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to log_enable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in text100.
function dac2_active_Callback(hObject, eventdata, handles)
% hObject    handle to text100 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of text100
global currentState
isDac2Active = get(hObject,'Value');
currentState.dac2Active = isDac2Active;

if isDac2Active
    currentState.dac4Channels = bitset(currentState.dac4Channels, 1, 1);
else
    currentState.dac4Channels = bitset(currentState.dac4Channels, 1, 0);
end

tempArg = dec2bin(currentState.dac4Channels,4);

Panel_com('set_active_ao_channels', tempArg);

% --- Executes on selection change in dac2_ao_func_list.
function dac2_ao_func_list_Callback(hObject, eventdata, handles)
% hObject    handle to dac2_ao_func_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dac2_ao_func_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dac2_ao_func_list
global currentState    

contents = get(hObject,'String');    
currentState.dac2FuncID = get(hObject,'Value')-1;
currentState.dac2FuncName = contents{currentState.dac2FuncID+1};
dac2FuncID = currentState.dac2FuncID;
if dac2FuncID ~= 0
    Panel_com('set_ao_function_id', [0, dac2FuncID]);
end


% --- Executes during object creation, after setting all properties.
function dac2_ao_func_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dac2_ao_func_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dac3_ao_func_list.
function dac3_ao_func_list_Callback(hObject, eventdata, handles)
% hObject    handle to dac3_ao_func_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dac3_ao_func_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dac3_ao_func_list
global currentState
contents = get(hObject,'String');
currentState.dac3FuncID = get(hObject,'Value')-1;
currentState.dac3FuncName = contents{currentState.dac3FuncID+1};
dac3FuncID = currentState.dac3FuncID;
if dac3FuncID~=0
    %Update_current_patterns(handles, pattID);
    Panel_com('set_ao_function_id', [1, dac3FuncID]);
end


% --- Executes during object creation, after setting all properties.
function dac3_ao_func_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dac3_ao_func_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dac4_ao_func_list.
function dac4_ao_func_list_Callback(hObject, eventdata, handles)
% hObject    handle to dac4_ao_func_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dac4_ao_func_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dac4_ao_func_list
global currentState
contents = get(hObject,'String');
currentState.dac4FuncID = get(hObject,'Value')-1;
currentState.dac4FuncName = contents{currentState.dac4FuncID+1};
dac4FuncID = currentState.dac4FuncID;
if dac4FuncID~=0
    %Update_current_patterns(handles, pattID);
    Panel_com('set_ao_function_id', [2, dac4FuncID]);
end

% --- Executes during object creation, after setting all properties.
function dac4_ao_func_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dac4_ao_func_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dac5_ao_func_list.
function dac5_ao_func_list_Callback(hObject, eventdata, handles)
% hObject    handle to dac5_ao_func_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dac5_ao_func_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dac5_ao_func_list
global currentState

contents = get(hObject,'String');    
currentState.dac5FuncID = get(hObject,'Value')-1;
currentState.dac5FuncName = contents{currentState.dac5FuncID+1};
dac5FuncID = currentState.dac5FuncID;
if dac5FuncID ~=0
    %Update_current_patterns(handles, pattID);
    Panel_com('set_ao_function_id', [2, dac5FuncID]);
end

% --- Executes during object creation, after setting all properties.
function dac5_ao_func_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dac5_ao_func_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dac3_active.
function dac3_active_Callback(hObject, eventdata, handles)
% hObject    handle to dac3_active (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dac3_active
global currentState
isDac3Active = get(hObject,'Value');
currentState.dac3Active = isDac3Active;

if isDac3Active
    currentState.dac4Channels = bitset(currentState.dac4Channels, 2, 1);
else
    currentState.dac4Channels = bitset(currentState.dac4Channels, 2, 0);
end

tempArg = dec2bin(currentState.dac4Channels,4);

Panel_com('set_active_ao_channels', tempArg);

% --- Executes on button press in dac4_active.
function dac4_active_Callback(hObject, eventdata, handles)
% hObject    handle to dac4_active (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dac4_active
global currentState
isDac4Active = get(hObject,'Value');
currentState.dac4Active = isDac4Active;

if isDac4Active
    currentState.dac4Channels = bitset(currentState.dac4Channels, 3, 1);
else
    currentState.dac4Channels = bitset(currentState.dac4Channels, 3, 0);
end

tempArg = dec2bin(currentState.dac4Channels,4);

Panel_com('set_active_ao_channels', tempArg);

% --- Executes on button press in dac5_active.
function dac5_active_Callback(hObject, eventdata, handles)
% hObject    handle to dac5_active (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dac5_active
global currentState
isDac5Active = get(hObject,'Value');
currentState.dac5Active = isDac5Active;

if isDac5Active
    currentState.dac4Channels = bitset(currentState.dac4Channels, 4, 1);
else
    currentState.dac4Channels = bitset(currentState.dac4Channels, 4, 0);
end

tempArg = dec2bin(currentState.dac4Channels,4);

Panel_com('set_active_ao_channels', tempArg);



function current_dir_Callback(hObject, eventdata, handles)
% hObject    handle to current_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of current_dir as text
%        str2double(get(hObject,'String')) returns contents of current_dir as a double


% --- Executes during object creation, after setting all properties.
function current_dir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in choose_dir.
function choose_dir_Callback(hObject, eventdata, handles)
% hObject    handle to choose_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global currentExp;
userSettings;
dirName = uigetdir(default_exp_path,'choose a experiment directory');
if isequal(dirName,0)
    return
else
    if ~exist(fullfile(dirName, 'currentExp.mat'), 'file')
        warndlg('This isn''t a valid experiment directory. Please try again!', 'Wrong directory');
        return;
    end
    set(handles.current_dir, 'string', dirName);
    Panel_com('change_root_directory', dirName);
    handles.expDir = dirName;
    try
        load(fullfile(dirName, 'currentExp.mat'));
        %add the pattern list
        if currentExp.pattern.num_patterns
            patternList = currentExp.pattern.pattNames;
        else
            patternList = '';
        end
        patternList = ['0: none', patternList];
        set(handles.setAPattern, 'String', patternList);
        set(handles.setAPattern, 'Value', 1);
        
        %add the function list
        if currentExp.function.numFunc
            funcList = currentExp.function.functionName;
        else
            funcList = '';
        end
        funcList = ['0: default function', funcList];
        set(handles.setPosFunc, 'String', funcList);
        set(handles.setPosFunc, 'Value', 1);
        
        if currentExp.aoFunction.numaoFunc
            aoFuncList = currentExp.aoFunction.aoFunctionName;
        else
            aoFuncList = '';
        end
        aoFuncList = ['0: none', aoFuncList];
        set(handles.dac2_ao_func_list, 'String', aoFuncList);
        set(handles.dac3_ao_func_list, 'String', aoFuncList);
        set(handles.dac4_ao_func_list, 'String', aoFuncList);
        set(handles.dac5_ao_func_list, 'String', aoFuncList);
        
        set(handles.dac2_ao_func_list, 'Value', 1);
        set(handles.dac3_ao_func_list, 'Value', 1);
        set(handles.dac4_ao_func_list, 'Value', 1);
        set(handles.dac5_ao_func_list, 'Value', 1);
    catch
        
    end
    guidata(hObject, handles);
end


% --------------------------------------------------------------------
function menu_load_ao_currentExp_Callback(hObject, eventdata, handles)
% hObject    handle to menu_load_ao_currentExp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choose_ao;


% --- Executes on button press in Panel_check.
function Panel_check_Callback(hObject, eventdata, handles)
% hObject    handle to Panel_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Panel_check
display_curr_frame(handles);

% --- Executes on button press in Pixel_check.
function Pixel_check_Callback(hObject, eventdata, handles)
% hObject    handle to Pixel_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Pixel_check
display_curr_frame(handles);

% --- Executes on selection change in gray_level.
function gray_level_Callback(hObject, eventdata, handles)
% hObject    handle to gray_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns gray_level contents as cell array
%        contents{get(hObject,'Value')} returns selected item from gray_level

contents = cellstr(get(hObject,'String'));
grayLevel = contents{get(hObject,'Value')};
handles.grayLevel = str2double(grayLevel);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function gray_level_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gray_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in send_gs.
function send_gs_Callback(hObject, eventdata, handles)
% hObject    handle to send_gs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userSettings;
frameN = 16*NumofRows;
frameM = 16*NumofColumns;
if handles.GSlevel == 16
    frame = handles.grayLevel*ones(frameN,frameM);
    frameData = handles.ctlr.getFrameCmd16Mex(frame);
    handles.ctlr.streamFrameCmd16(frameData)
elseif handles.GSlevel == 2
    frame = handles.grayLevel*ones(frameN,frameM);
    frameData = handles.ctlr.getFrameCmd2Mex(frame);
    handles.ctlr.streamFrameCmd2(frameData);
end

% --- Executes on button press in pushbutton31.
function pushbutton31_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function frame_rate_Callback(hObject, eventdata, handles)
% hObject    handle to frame_rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frame_rate as text
%        str2double(get(hObject,'String')) returns contents of frame_rate as a double
handles.frameRate = str2double(get(hObject,'String'));
guidata(hObject, handles);
Panel_com('set_frame_rate', handles.frameRate);


% --- Executes during object creation, after setting all properties.
function frame_rate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function trial_duration_Callback(hObject, eventdata, handles)
% hObject    handle to trial_duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trial_duration as text
%        str2double(get(hObject,'String')) returns contents of trial_duration as a double
handles.trialDuration = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function trial_duration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trial_duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in openPattern.
function openPattern_Callback(hObject, eventdata, handles)
% hObject    handle to openPattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userSettings;
cd(pattern_path)
[FileName,PathName] = uigetfile('P*.mat','Select a Pattern File');
if (all(FileName ~= 0))
    load([PathName FileName]);
    handles.pattern = pattern;
    
    handles.pattern_x_size = pattern.x_num;
    handles.pattern_y_size = pattern.y_num;
    handles.x_pos = 1;
    set(handles.x_pos_val_s, 'string', num2str(handles.x_pos));
    set(handles.x_pos_val_s, 'enable', 'on');
    handles.y_pos = 1;
    set(handles.y_pos_val_s, 'string', num2str(handles.y_pos));
    set(handles.y_pos_val_s, 'enable', 'on');
    set(handles.y_pos_plus_s, 'enable', 'on');
    set(handles.y_pos_minus_s, 'enable', 'on');
    set(handles.x_pos_plus_s, 'enable', 'on');
    set(handles.x_pos_minus_s, 'enable', 'on');
    
    set(handles.Pixel_check, 'enable', 'on');
    set(handles.Pixel_check, 'value', 0);
    set(handles.Panel_check, 'enable', 'on');
    set(handles.Panel_check, 'value', 0);
    
    guidata(hObject, handles);
    cla(handles.axes3);
    display_curr_frame(handles);
    
end

function display_curr_frame(handles)

%step 1: udpate display on the panel 
userSettings;
handles.ctlr.stretch = handles.pattern.stretch(handles.x_pos,handles.y_pos);
switch handles.pattern.gs_val
    case 1
        % the color maps
        C = [0 0 0; 0 1 0];   % 2 colors - on / off
        frameData = handles.ctlr.getFrameCmd2Mex(handles.pattern.Pats(:,:,handles.x_pos,handles.y_pos));
        handles.ctlr.streamFrameCmd2(frameData)
    case 4
        C = [0 0 0; 0 2/16 0; 0 3/16 0; 0 4/16 0; 0 5/16 0; 0 6/16 0; 0 7/16 0; 0 8/16 0; ...
            0 9/16 0; 0 10/16 0; 0 11/16 0; 0 12/16 0; 0 13/16 0; 0 14/16 0; 0 15/16 0; 0 1 0];  % 16 levels of gscale
        frameData = handles.ctlr.getFrameCmd16Mex(handles.pattern.Pats(:,:,handles.x_pos,handles.y_pos));
        handles.ctlr.streamFrameCmd16(frameData)
    otherwise
        error('the graycale value is not appropriately set for this pattern - must be 1, 2, 3, or 4');
end


%step 2: update the display in GUI
axes(handles.axes3)

% here we add a one to the image to correctly index into the color map
%imshow(handles.pattern.Pats(:,:,handles.x_pos,handles.y_pos)+1, C, 'notruesize')

displayPatternData = handles.pattern.Pats(:,:,handles.x_pos,handles.y_pos)+1;
if flipUpDown == 1
    displayPatternData = flipud(displayPatternData);
end

if flipLeftRight == 1
    displayPatternData = fliplr(displayPatternData);
end

image(displayPatternData);

axis off; axis image; colormap(C);
hold on
numRows = size(handles.pattern.Pats, 1);
numCols = size(handles.pattern.Pats, 2);
numR= numRows/16;
numC= numCols/16;

% plot Pixel_lines
if (get(handles.Pixel_check,'Value') == get(handles.Pixel_check,'Max'))
    %make horizontal lines
    for j = 1.5:numRows
        plot([0.5 numCols + 0.5], [j j],'w');
    end
    %make vertical lines
    for j = 1.5:numCols
        plot([j j], [0.5 numRows + 0.5],'w');
    end
    % plot Panel_lines
end

if(get(handles.Panel_check,'Value') == get(handles.Panel_check,'Max'))
    for j = 1.5:numRows
        if (mod(j,16) == 0.5) plot([0.5 numCols + 0.5], [j j],'r', 'LineWidth',2);
        end
    end
    %make vertical lines
    for j = 1.5:numCols
        if (mod(j,16) == 0.5) plot([j j], [0.5 numRows + 0.5],'r', 'LineWidth',2);
        end
    end
end

function stretch_num_Callback(hObject, eventdata, handles)
% hObject    handle to stretch_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stretch_num as text
%        str2double(get(hObject,'String')) returns contents of stretch_num as a double

stretch = str2double(get(hObject,'String'));
if handles.GSlevel == 2
    if isnan(stretch)||stretch<0 || stretch > 105
        warndlg('Stretch is a value between 0 and 105.', 'Wrong input value');
        return;
    end
elseif handles.GSlevel == 16
    if isnan(stretch)||stretch<0 || stretch > 19
        warndlg('Stretch is a value between 0 and 19.', 'Wrong input value');
        return;
    end
end

handles.ctlr.stretch = stretch;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function stretch_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stretch_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menu_design_exp_Callback(hObject, eventdata, handles)
% hObject    handle to menu_design_exp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
design_exp;


% --- Executes when selected object is changed in choose_gs.
function choose_gs_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in choose_gs
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

oldGS = eventdata.OldValue;
newGS = get(eventdata.NewValue,'String');
switch lower(newGS)
    case 'gs2'
        handles.GSlevel = 2;
        set(handles.stretch_range, 'String', 'Stretch (0-105)');
        set(handles.gray_level, 'String',{'0'; '1'});
    case 'gs16'
        handles.GSlevel = 16;
        set(handles.stretch_range, 'String', 'Stretch (0-20)');
        set(handles.gray_level, 'String',{'0';'1';'2';'3';'4';'5';'6';'7';'8';'9';'10';'11';'12';'13';'14';'15'});
    otherwise
        disp('Unknown choice')
end
set(handles.gray_level,'Value', 1);
set(handles.stretch_num, 'string',0);
handles.ctlr.stretch = 0;
handles.grayLevel = 0;
guidata(hObject, handles);


% --- Executes on button press in x_pos_plus.
function x_pos_plus_Callback(hObject, eventdata, handles)
% hObject    handle to x_pos_plus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% increment the x_pos, wrap around if too big
temp_pos = handles.x_pos + 1;
if (temp_pos > handles.pattern_x_size)
    temp_pos = 1;
end
handles.x_pos = temp_pos;
set(handles.x_pos_val, 'string', num2str(temp_pos));
guidata(hObject, handles);
Panel_com('set_position_x', handles.x_pos);

% --- Executes on button press in x_pos_minus.
function x_pos_minus_Callback(hObject, eventdata, handles)
% hObject    handle to x_pos_minus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
temp_pos = handles.x_pos - 1;
if (temp_pos <= 0)
    temp_pos = handles.pattern_x_size;
end
handles.x_pos = temp_pos;
set(handles.x_pos_val, 'string', num2str(temp_pos));
guidata(hObject, handles);
Panel_com('set_position_x', handles.x_pos);
