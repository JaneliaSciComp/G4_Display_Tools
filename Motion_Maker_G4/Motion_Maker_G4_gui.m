function varargout = Motion_Maker_G4_gui(varargin)
% Motion_Maker_G4_gui MATLAB code for Motion_Maker_G4_gui.fig
%      Motion_Maker_G4_gui, by itself, creates a new Motion_Maker_G4_gui or raises the existing
%      singleton*.
%
%      H = Motion_Maker_G4_gui returns the handle to a new Motion_Maker_G4_gui or the handle to
%      the existing singleton*.
%
%      Motion_Maker_G4_gui('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in Motiont_Maker_G4_gui.M with the given input arguments.
%
%      Motion_Maker_G4_gui('Property','Value',...) creates a new Motion_Maker_G4_gui or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Motion_Maker_G4_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Motion_Maker_G4_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Motion_Maker_G4_gui

% Last Modified by GUIDE v2.5 31-Mar-2017 09:13:30

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Motion_Maker_G4_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @Motion_Maker_G4_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Motion_Maker_G4_gui is made visible.
function Motion_Maker_G4_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Motion_Maker_G4_gui (see VARARGIN)

%set default additional options
sdata.aa_samples = 15;
sdata.aa_poles = 1;
sdata.phase_shift = 0;
sdata.back_frame = 0;
sdata.flip_right = 0;
sdata.snap_dots = 0;
sdata.dot_re_random = 1;
sdata.color = [0 1 0; 0.6 0 0.9];
s2data.enable = [0 0];
s2data.sa_mask = [0 0 pi 0];
s2data.long_lat_mask = [-pi pi -pi/2 pi/2 0];
if exist('C:\matlabroot\G4\Arena\arena_parameters.mat','file')
    load('C:\matlabroot\G4\Arena\arena_parameters.mat');
    s3data.arena_pitch = rad2deg(aparam.rotations(2));
    set(handles.edit2, 'String', num2str(round(1000*rad2deg(p_rad))/1000));
    s3data.updated = 1;
else
    s3data.arena_pitch = 0;
    s3data.updated = 0;
end
handles.tag = findobj('Tag','Motion_Maker_G4_gui');
setappdata(handles.tag,'sdata',sdata);
setappdata(handles.tag,'s2data',s2data);
setappdata(handles.tag,'s3data',s3data);
handles.loaded_pattern = 0;

% This sets up the initial plot - only do when we are invisible
% so window can get raised using Motion_Maker_G4_gui.
if strcmp(get(hObject,'Visible'),'off')
    handles = pushbutton1_Callback(hObject, eventdata, handles);
end

% Choose default command line output for Motion_Maker_G4_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Motion_Maker_G4_gui wait for user response (see UIRESUME)
% uiwait(handles.Motion_Maker_G4_gui);


% --- Outputs from this function are returned to the command line.
function varargout = Motion_Maker_G4_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function handles = pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%reset step_size color
set(handles.edit2,'BackgroundColor','white');
set(handles.pushbutton1,'String','working');pause(0.001);

%hide unused options
popupmenu1_Callback(handles.popupmenu1, eventdata, handles);
popupmenu7_Callback(handles.popupmenu7, eventdata, handles);

%gather pattern parameters
popup_strings = get(handles.popupmenu1, 'String');
handles.param.pattern_type = popup_strings{get(handles.popupmenu1, 'Value')};
popupmenu1_Callback(hObject, eventdata, handles);
handles.param.num_dots = round(str2double(get(handles.edit18, 'String')));
handles.param.dot_radius = deg2rad(str2double(get(handles.edit17, 'String')));
popup_strings = get(handles.popupmenu9, 'String');
handles.param.dot_size = popup_strings{get(handles.popupmenu9, 'Value')};
popup_strings = get(handles.popupmenu8, 'String');
handles.param.dot_occ = popup_strings{get(handles.popupmenu8, 'Value')};
popup_strings = get(handles.popupmenu2, 'String');
handles.param.motion_type = popup_strings{get(handles.popupmenu2, 'Value')};
popup_strings = get(handles.popupmenu5, 'String');
popup_strings = popup_strings{get(handles.popupmenu5, 'Value')};
handles.param.gs_val = str2double(popup_strings(1));
popup_strings = get(handles.popupmenu7, 'String');
handles.param.pattern_fov = popup_strings{get(handles.popupmenu7, 'Value')};
handles.param.spat_freq = deg2rad(str2double(get(handles.edit1, 'String')));
handles.param.step_size = deg2rad(str2double(get(handles.edit2, 'String')));
handles.param.duty_cycle = str2double(get(handles.edit3, 'String'));
handles.param.levels = [str2double(get(handles.edit5, 'String')), ...
    str2double(get(handles.edit6, 'String')), str2double(get(handles.edit14, 'String'))];
handles.param.levels = str2double({get(handles.edit5, 'String'), ...
    get(handles.edit6, 'String'), get(handles.edit14, 'String')});
handles.param.dot_level = get(handles.popupmenu10, 'Value')-1;
handles.param.pole_coord = deg2rad(str2double({get(handles.edit7, 'String'), ...
    get(handles.edit8, 'String')}));
handles.param.motion_angle = deg2rad(str2double(get(handles.edit9, 'String')));
handles.param.checker_layout = get(handles.checkbox4, 'Value');

%get arena configurations
s3data = getappdata(handles.tag,'s3data');
if s3data.updated == 1
    handles.param.arena_pitch = deg2rad(s3data.arena_pitch);
    s3data.updated = 0;
    setappdata(handles.tag,'s3data',s3data);
    set(handles.edit10, 'String', num2str(s3data.arena_pitch));
else
    handles.param.arena_pitch = deg2rad(str2double(get(handles.edit10, 'String')));
end

% get more options
sdata = getappdata(handles.tag,'sdata');
handles.param.aa_samples = sdata.aa_samples;
handles.param.aa_poles = sdata.aa_poles;
handles.param.phase_shift = sdata.phase_shift;
handles.param.back_frame = sdata.back_frame;
handles.param.flip_right = sdata.flip_right;
handles.param.snap_dots = sdata.snap_dots;
handles.param.dot_re_random = sdata.dot_re_random;
handles.color = sdata.color;

%get mask options
if strncmpi(handles.param.pattern_fov,'f',1)
    s2data = getappdata(handles.tag,'s2data');
    if s2data.enable(1)
        handles.param.sa_mask = s2data.sa_mask;
    else
        handles.param.sa_mask = [0 0 pi 0];
    end
    if s2data.enable(2)
        handles.param.long_lat_mask = s2data.long_lat_mask;
    else
        handles.param.long_lat_mask = [-pi pi -pi/2 pi/2 0];
    end
else
    handles.param.sa_mask = [deg2rad(str2double({get(handles.edit11,'String'), ...
        get(handles.edit12,'String'), get(handles.edit13,'String')})), 0];
    handles.param.long_lat_mask = deg2rad([-180 180 -90 90 0]);
end

%generate pattern
[handles.Pats, handles.param.true_step_size, handles.param.rot180] = Motion_Maker_G4(handles.param);
handles.num_frames = size(handles.Pats,3);
handles.param.stretch = ones(handles.num_frames,1);
if handles.param.checker_layout==1
    handles.Pats = checkerboard_pattern(handles.Pats);
end

%update step size if needed to be changed
if abs(handles.param.step_size-handles.param.true_step_size)>0.00001
    set(handles.edit2,'String',num2str(rad2deg(handles.param.true_step_size)));
    set(handles.edit2,'BackgroundColor','yellow');
end

%set pattern name
if handles.loaded_pattern
    handles.loaded_pattern = 0;
else
    handles.save_dir = get(handles.text26,'String');
    if ~exist(handles.save_dir,'dir')
        mkdir(handles.save_dir)
    end
    handles.param.ID = get_pattern_ID(handles.save_dir);
end
set(handles.text41,'String',[num2str(handles.param.ID,'%04d') '_']);

%generate arena projection
handles.cur_frame = 1+handles.param.back_frame;
set(handles.edit16,'String',num2str(handles.cur_frame));
set(handles.text24,'String',num2str(handles.num_frames));
handles.plot_type = get(handles.popupmenu6, 'Value');
arena_projection(handles.Pats, handles.param.gs_val, handles.color, handles.plot_type, handles.cur_frame, handles.param.checker_layout);

%update pattern
set(handles.pushbutton1,'String','Update Pattern')

%set plot visualization
popupmenu6_Callback(handles.popupmenu6, eventdata, handles);

guidata(hObject, handles);



% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.Motion_Maker_G4_gui)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.Motion_Maker_G4_gui,'Name') '?'],...
                     ['Close ' get(handles.Motion_Maker_G4_gui,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.Motion_Maker_G4_gui)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

%hide unused parameters for selected pattern type
popup_val = get(handles.popupmenu1, 'Value');
if popup_val < 4
        strings = {'on' 'on' 'off'};
elseif popup_val == 4
        strings = {'on' 'off' 'on'};
elseif popup_val == 5
        strings = {'off' 'off' 'off'};
end

set(handles.text4,'visible',strings{1})
set(handles.edit2,'visible',strings{1})

set(handles.text3,'visible',strings{2})
set(handles.text5,'visible',strings{2})
set(handles.edit1,'visible',strings{2})
set(handles.edit3,'visible',strings{2})

set(handles.text28,'visible',strings{3})
set(handles.text29,'visible',strings{3})
set(handles.text30,'visible',strings{3})
set(handles.text32,'visible',strings{3})
set(handles.text36,'visible',strings{3})
set(handles.edit17,'visible',strings{3})
set(handles.edit18,'visible',strings{3})
set(handles.popupmenu8,'visible',strings{3})
set(handles.popupmenu9,'visible',strings{3})
set(handles.popupmenu10,'visible',strings{3})


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'square grating', 'sine grating' 'edge', 'starfield', 'off-on'});


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'rotation', 'translation', 'expansion-contraction'});



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, ~)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'1', '15'});


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'duty-matched', 'off'});


% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5


% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'1 bit', '4 bits'});


% --- Executes during object creation, after setting all properties.
function text24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.cur_frame = handles.cur_frame + 1;
if handles.cur_frame>handles.num_frames;
    handles.cur_frame = 1;
end
set(handles.edit16,'String',num2str(handles.cur_frame));
arena_projection(handles.Pats, handles.param.gs_val, handles.color, handles.plot_type, handles.cur_frame, handles.param.checker_layout);
guidata(hObject, handles);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.cur_frame = handles.cur_frame - 1;
if handles.cur_frame<1;
    handles.cur_frame = handles.num_frames;
end
set(handles.edit16,'String',num2str(handles.cur_frame));
arena_projection(handles.Pats, handles.param.gs_val, handles.color, handles.plot_type, handles.cur_frame, handles.param.checker_layout);
guidata(hObject, handles);


% --- Executes on selection change in popupmenu6.
function popupmenu6_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu6
handles.plot_type = get(hObject, 'Value');
if handles.plot_type == 1
        strings = {'on' 'off'};
else
        strings = {'off' 'on'};
end
set(handles.text37,'visible',strings{1})
set(handles.text38,'visible',strings{2})
set(handles.text39,'visible',strings{1})
set(handles.text40,'visible',strings{2})
arena_projection(handles.Pats, handles.param.gs_val, handles.color, handles.plot_type, handles.cur_frame, handles.param.checker_layout);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupmenu6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'mercator projection', 'grid projection'});


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.save_dir = uigetdir('', 'Pick a Directory');
set(handles.text26,'String',handles.save_dir);

%set pattern ID
handles.param.ID = get_pattern_ID(handles.save_dir);
set(handles.text41,'String',[num2str(handles.param.ID,'%04d') '_']);
guidata(hObject, handles);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.save_dir = get(handles.text26,'String');
handles.patName = get(handles.edit15,'String');

%save .mat and .pat files
if handles.param.checker_layout==0
    save_pattern_G4(handles.Pats, handles.param, handles.save_dir, handles.patName)
else
    save_pattern_checkerboard_G4(handles.param, handles.save_dir, handles.patName, handles.Pats)
end


% --- Executes during object creation, after setting all properties.
function text26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: place code in OpeningFcn to populate axes1


% --- Executes on selection change in popupmenu7.
function popupmenu7_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu7

if get(hObject, 'Value') == 1
    strings = {'on', 'off'};
else
    strings = {'off', 'on'};
end
set(handles.edit7,'visible',strings{1})
set(handles.edit8,'visible',strings{1})
set(handles.text11,'visible',strings{1})
set(handles.text12,'visible',strings{1})
set(handles.pushbutton9,'visible',strings{1})

set(handles.edit11,'visible',strings{2})
set(handles.edit12,'visible',strings{2})
set(handles.edit13,'visible',strings{2})
set(handles.edit9,'visible',strings{2})
set(handles.text14,'visible',strings{2})
set(handles.text15,'visible',strings{2})
set(handles.text16,'visible',strings{2})
set(handles.text13,'visible',strings{2})

% --- Executes during object creation, after setting all properties.
function popupmenu7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', {'full-field', 'local (mask-centered)'});



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double
frame = str2double(get(hObject,'String'));
if frame<1
    handles.cur_frame = 1;
elseif frame>handles.num_frames
    handles.cur_frame = handles.num_frames;
else
    handles.cur_frame = round(frame);
end
set(hObject,'String',num2str(handles.cur_frame));
arena_projection(handles.Pats, handles.param.gs_val, handles.color, handles.plot_type, handles.cur_frame, handles.param.checker_layout);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edit16.
function edit16_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on selection change in popupmenu8.
function popupmenu8_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu8


% --- Executes during object creation, after setting all properties.
function popupmenu8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', {'closest', 'sum', 'mean'});


function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double


% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in popupmenu9.
function popupmenu9_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu9 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu9


% --- Executes during object creation, after setting all properties.
function popupmenu9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', {'static', 'distance-relative'});


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3



function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double


% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

more_options;

guidata(hObject, handles);


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mask_options;

guidata(hObject, handles);


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, handles.save_dir] = uigetfile('*.mat');
load(fullfile(handles.save_dir,filename));

handles.param.ID = str2double(filename(end-10:end-7)); %get ID
handles.patName = filename(1:end-11); %remove ID and filetype from name

try 
    handles.param = pattern.param;
    handles.Pats = pattern.Pats;

    popup_val = find(strncmpi(handles.param.pattern_type,{'sq' 'si' 'ed' 'st' 'of'},2));
    set(handles.popupmenu1, 'Value',popup_val);
    popup_val = find(strncmpi(handles.param.motion_type,{'r' 't' 'e'},1));
    set(handles.popupmenu2, 'Value',popup_val);
    popup_val = find(strncmpi(handles.param.dot_size,{'s' 'd'},1));
    set(handles.popupmenu9, 'Value',popup_val);
    popup_val = find(strncmpi(handles.param.dot_occ,{'c' 's' 'm'},1));
    set(handles.popupmenu8, 'Value',popup_val);
    set(handles.popupmenu10, 'Value',handles.param.dot_level+1);
    popup_val = find(strncmpi(handles.param.pattern_fov,{'f' 'l'},1));
    set(handles.popupmenu7, 'Value',popup_val);
    popup_val = find(handles.param.gs_val==[1, 4]);
    set(handles.popupmenu5, 'Value',popup_val);

    set(handles.edit18, 'String',num2str(handles.param.num_dots));
    set(handles.edit17, 'String',num2str(rad2deg(handles.param.dot_radius)));
    set(handles.edit1, 'String',num2str(rad2deg(handles.param.spat_freq)));
    set(handles.edit2, 'String',num2str(rad2deg(handles.param.step_size)));
    set(handles.edit3, 'String',num2str(handles.param.duty_cycle));
    set(handles.edit5, 'String',num2str(handles.param.levels(1)));
    set(handles.edit6, 'String',num2str(handles.param.levels(2)));
    set(handles.edit14, 'String',num2str(handles.param.levels(3)));
    set(handles.edit7, 'String',num2str(rad2deg(handles.param.pole_coord(1))));
    set(handles.edit8, 'String',num2str(rad2deg(handles.param.pole_coord(2))));
    set(handles.edit9, 'String',num2str(rad2deg(handles.param.motion_angle)));
    set(handles.edit10, 'String',num2str(rad2deg(handles.param.arena_pitch)));
    set(handles.edit11,'String',num2str(rad2deg(handles.param.sa_mask(1))));
    set(handles.edit12,'String',num2str(rad2deg(handles.param.sa_mask(2))));
    set(handles.edit13,'String',num2str(rad2deg(handles.param.sa_mask(3))));

    sdata = getappdata(handles.tag,'sdata');
    sdata.aa_samples = handles.param.aa_samples;
    sdata.aa_poles = handles.param.aa_poles;
    sdata.phase_shift = handles.param.phase_shift;
    sdata.back_frame = handles.param.back_frame;
    sdata.flip_right = handles.param.flip_right;
    sdata.snap_dots = handles.param.snap_dots;
    sdata.dot_re_random = handles.param.dot_re_random;
    
    s2data.sa_mask = handles.param.sa_mask;
    s2data.long_lat_mask = handles.param.long_lat_mask;
    s2data.enable = [0 0];
    if s2data.sa_mask(3)<pi
        s2data.enable(1) = 1;
    end
    if abs(diff(s2data.long_lat_mask(1:2)))<2*pi || abs(diff(s2data.long_lat_mask(3:4)))<pi
        s2data.enable(2) = 1;
    end
    handles.tag = findobj('Tag','Motion_Maker_G4_gui');
    setappdata(handles.tag,'sdata',sdata);
    setappdata(handles.tag,'s2data',s2data);
    handles.loaded_pattern = 1;
    if isfield(param,'checkerboad_layout')
        set(handles.checkbox4, 'Value', param.checkerboard_layout);
    else
        set(handles.checkbox4, 'Value', 0);
    end
    
    guidata(hObject, handles);
    
    %check if Pattern is same size as current arena
    load('C:\matlabroot\G4\Arena\arena_parameters.mat','arena_x');
    if numel(arena_x)~=numel(handles.Pats(:,:,1))
        disp('warning: loaded pattern was made for a differently-sized arena')
    end
    
    pushbutton1_Callback(hObject, eventdata, handles);
    
catch 
    disp('could not load all pattern parameters')
    handles.Pats = squeeze(pattern.Pats);
    if max(max(max(max(handles.Pats))))>1
        handles.param.gs_val = 4;
    else
        handles.param.gs_val = 1;
    end
    handles.plot_type = 2;
    handles.cur_frame = 1;
    handles.num_frames = size(handles.Pats,3);
    set(handles.edit16,'String',num2str(handles.cur_frame));
    set(handles.text24,'String',num2str(handles.num_frames));
    set(handles.edit15,'String',handles.patName);
    set(handles.text41,'String',[num2str(handles.param.ID,'%04d') '_']);
    set(handles.popupmenu6, 'Value', handles.plot_type);
    
    guidata(hObject, handles);
    
    arena_projection(handles.Pats, handles.param.gs_val, handles.color, handles.plot_type, handles.cur_frame, handles.param.checker_layout);
end
    

% --- Executes on selection change in popupmenu10.
function popupmenu10_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu10 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu10


% --- Executes during object creation, after setting all properties.
function popupmenu10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', {'set as 1st level', 'random, spread (0 to 1st level)', 'random, high or low (either 0 or 1st level)'});


% --- Executes during object creation, after setting all properties.
function Motion_Maker_G4_gui_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Motion_Maker_G4_gui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

MMgui2script_G4(handles.param);


% --- Executes on button press in pushbutton11.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

configure_arena;

