function varargout = change_paths(varargin)
% CHANGE_PATHS M-file for change_paths.fig
%      CHANGE_PATHS, by itself, creates a new CHANGE_PATHS or raises the existing
%      singleton*.
%
%      H = CHANGE_PATHS returns the handle to a new CHANGE_PATHS or the handle to
%      the existing singleton*.
%
%      CHANGE_PATHS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHANGE_PATHS.M with the given input arguments.
%
%      CHANGE_PATHS('Property','Value',...) creates a new CHANGE_PATHS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before change_paths_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to change_paths_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help change_paths

% Last Modified by GUIDE v2.5 07-Nov-2011 15:06:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @change_paths_OpeningFcn, ...
                   'gui_OutputFcn',  @change_paths_OutputFcn, ...
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


% --- Executes just before change_paths is made visible.
function change_paths_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to change_paths (see VARARGIN)

% Choose default command line output for change_paths
handles.output = hObject;
userSettings;
set(handles.function_path, 'String', function_path);
set(handles.pattern_path, 'String', pattern_path);
set(handles.temp_path, 'String', temp_path);
set(handles.root_path, 'String', root_path);
set(handles.controller_path, 'String', controller_path);
set(handles.cfg_path, 'String', cfg_path);
 
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes change_paths wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = change_paths_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function function_path_Callback(hObject, eventdata, handles)
% hObject    handle to function_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of function_path as text
%        str2double(get(hObject,'String')) returns contents of function_path as a double


% --- Executes during object creation, after setting all properties.
function function_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to function_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pattern_path_Callback(hObject, eventdata, handles)
% hObject    handle to pattern_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pattern_path as text
%        str2double(get(hObject,'String')) returns contents of pattern_path as a double


% --- Executes during object creation, after setting all properties.
function pattern_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pattern_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function temp_path_Callback(hObject, eventdata, handles)
% hObject    handle to temp_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of temp_path as text
%        str2double(get(hObject,'String')) returns contents of temp_path as a double


% --- Executes during object creation, after setting all properties.
function temp_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to temp_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function root_path_Callback(hObject, eventdata, handles)
% hObject    handle to root_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of root_path as text
%        str2double(get(hObject,'String')) returns contents of root_path as a double


% --- Executes during object creation, after setting all properties.
function root_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to root_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function controller_path_Callback(hObject, eventdata, handles)
% hObject    handle to controller_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of controller_path as text
%        str2double(get(hObject,'String')) returns contents of controller_path as a double


% --- Executes during object creation, after setting all properties.
function controller_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to controller_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cfg_path_Callback(hObject, eventdata, handles)
% hObject    handle to cfg_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cfg_path as text
%        str2double(get(hObject,'String')) returns contents of cfg_path as a double


% --- Executes during object creation, after setting all properties.
function cfg_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cfg_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in change_function_path.
function change_function_path_Callback(hObject, eventdata, handles)
% hObject    handle to change_function_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
new_dir = uigetdir;
if new_dir 
    function_path = new_dir;
    set(handles.function_path, 'String', function_path);
    %save('Pcontrol_paths.mat', 'function_path', '-append');
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in change_pattern_path.
function change_pattern_path_Callback(hObject, eventdata, handles)
% hObject    handle to change_pattern_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
new_dir = uigetdir;
if new_dir 
    pattern_path = new_dir;
    set(handles.pattern_path, 'String', pattern_path);
    %save('Pcontrol_paths.mat', 'pattern_path', '-append');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in change_temp_path.
function change_temp_path_Callback(hObject, eventdata, handles)
% hObject    handle to change_temp_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
new_dir = uigetdir;
if new_dir 
    temp_path = new_dir;
    set(handles.temp_path, 'String', temp_path);
    save('Pcontrol_paths.mat', 'temp_path', '-append');
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in change_root_path.
function change_root_path_Callback(hObject, eventdata, handles)
% hObject    handle to change_root_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
new_dir = uigetdir;
if new_dir 
    root_path = new_dir;
    set(handles.root_path, 'String', root_path);
    save('Pcontrol_paths.mat', 'root_path', '-append');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in change_controller_path.
function change_controller_path_Callback(hObject, eventdata, handles)
% hObject    handle to change_controller_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

new_dir = uigetdir;
if new_dir 
    controller_path = new_dir;
    set(handles.controller_path, 'String', controller_path);
    save('Pcontrol_paths.mat', 'controller_path', '-append');
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in change_cfg_path.
function change_cfg_path_Callback(hObject, eventdata, handles)
% hObject    handle to change_cfg_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
new_dir = uigetdir;
if new_dir 
    cfg_path = new_dir;
    set(handles.cfg_path, 'String', cfg_path);
    save('Pcontrol_paths.mat', 'cfg_path', '-append');
end
% Update handles structure
guidata(hObject, handles);
