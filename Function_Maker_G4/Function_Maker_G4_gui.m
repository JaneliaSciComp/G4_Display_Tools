function varargout = Function_Maker_G4_gui(varargin)
% FUNCTION_MAKER_G4_GUI MATLAB code for Function_Maker_G4_gui.fig
%      FUNCTION_MAKER_G4_GUI, by itself, creates a new FUNCTION_MAKER_G4_GUI or raises the existing
%      singleton*.
%
%      H = FUNCTION_MAKER_G4_GUI returns the handle to a new FUNCTION_MAKER_G4_GUI or the handle to
%      the existing singleton*.
%
%      FUNCTION_MAKER_G4_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FUNCTION_MAKER_G4_GUI.M with the given input arguments.
%
%      FUNCTION_MAKER_G4_GUI('Property','Value',...) creates a new FUNCTION_MAKER_G4_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Function_Maker_G4_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Function_Maker_G4_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Function_Maker_G4_gui

% Last Modified by GUIDE v2.5 17-Aug-2017 13:44:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Function_Maker_G4_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @Function_Maker_G4_gui_OutputFcn, ...
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


% --- Executes just before Function_Maker_G4_gui is made visible.
function Function_Maker_G4_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Function_Maker_G4_gui (see VARARGIN)

% Choose default command line output for Function_Maker_G4_gui
handles.output = hObject;

%calculate default function
handles = pushbutton2_Callback(hObject, eventdata, handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Function_Maker_G4_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Function_Maker_G4_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
pushbutton2_Callback(hObject, eventdata, handles);


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
set(hObject, 'String', {'static', 'sawtooth', 'triangle', 'sine', 'cosine', 'square', 'loom'});


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
pushbutton2_Callback(hObject, eventdata, handles);


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
pushbutton2_Callback(hObject, eventdata, handles);


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



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
pushbutton2_Callback(hObject, eventdata, handles);


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



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
pushbutton2_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
pushbutton2_Callback(hObject, eventdata, handles);



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double
pushbutton2_Callback(hObject, eventdata, handles);


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


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FMgui2script_G4(handles.param);


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
pushbutton2_Callback(hObject, eventdata, handles);


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
pushbutton2_Callback(hObject, eventdata, handles);


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
set(hObject, 'String', {'static', 'sawtooth', 'triangle', 'sine', 'cosine', 'square', 'loom'});



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double
pushbutton2_Callback(hObject, eventdata, handles);


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
pushbutton2_Callback(hObject, eventdata, handles);


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
pushbutton2_Callback(hObject, eventdata, handles);


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
pushbutton2_Callback(hObject, eventdata, handles);


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


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
pushbutton2_Callback(hObject, eventdata, handles);



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double
pushbutton2_Callback(hObject, eventdata, handles);


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


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5
pushbutton2_Callback(hObject, eventdata, handles);


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3
pushbutton2_Callback(hObject, eventdata, handles);


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
set(hObject, 'String', {'static', 'sawtooth', 'triangle', 'sine', 'cosine', 'square', 'loom'});



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double
pushbutton2_Callback(hObject, eventdata, handles);


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
pushbutton2_Callback(hObject, eventdata, handles);


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
pushbutton2_Callback(hObject, eventdata, handles);


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
pushbutton2_Callback(hObject, eventdata, handles);


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


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6
pushbutton2_Callback(hObject, eventdata, handles);



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double
pushbutton2_Callback(hObject, eventdata, handles);


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


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7
pushbutton2_Callback(hObject, eventdata, handles);


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4
pushbutton2_Callback(hObject, eventdata, handles);


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
set(hObject, 'String', {'static', 'sawtooth', 'triangle', 'sine', 'cosine', 'square', 'loom'});



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double
pushbutton2_Callback(hObject, eventdata, handles);


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



function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double
pushbutton2_Callback(hObject, eventdata, handles);


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
pushbutton2_Callback(hObject, eventdata, handles);


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



function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit19 as text
%        str2double(get(hObject,'String')) returns contents of edit19 as a double
pushbutton2_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8
pushbutton2_Callback(hObject, eventdata, handles);



function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double
pushbutton2_Callback(hObject, eventdata, handles);


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


% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9
pushbutton2_Callback(hObject, eventdata, handles);


% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5
pushbutton2_Callback(hObject, eventdata, handles);


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
set(hObject, 'String', {'static', 'sawtooth', 'triangle', 'sine', 'cosine', 'square', 'loom'});



function edit21_Callback(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit21 as text
%        str2double(get(hObject,'String')) returns contents of edit21 as a double
pushbutton2_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit22_Callback(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit22 as text
%        str2double(get(hObject,'String')) returns contents of edit22 as a double
pushbutton2_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit23_Callback(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit23 as text
%        str2double(get(hObject,'String')) returns contents of edit23 as a double
pushbutton2_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit24_Callback(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit24 as text
%        str2double(get(hObject,'String')) returns contents of edit24 as a double
pushbutton2_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox10.
function checkbox10_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox10
pushbutton2_Callback(hObject, eventdata, handles);



function edit25_Callback(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit25 as text
%        str2double(get(hObject,'String')) returns contents of edit25 as a double
pushbutton2_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit25_CreateFcn(hObject, eventdata, ~)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit28_Callback(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit25 as text
%        str2double(get(hObject,'String')) returns contents of edit25 as a double
pushbutton2_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit28_CreateFcn(hObject, eventdata, ~)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit29_Callback(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit25 as text
%        str2double(get(hObject,'String')) returns contents of edit25 as a double
pushbutton2_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit29_CreateFcn(hObject, eventdata, ~)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit30_Callback(hObject, eventdata, handles)
% hObject    handle to edit30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit25 as text
%        str2double(get(hObject,'String')) returns contents of edit25 as a double
pushbutton2_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit30_CreateFcn(hObject, eventdata, ~)
% hObject    handle to edit30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit31_Callback(hObject, eventdata, handles)
% hObject    handle to edit31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit25 as text
%        str2double(get(hObject,'String')) returns contents of edit25 as a double
pushbutton2_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit31_CreateFcn(hObject, eventdata, ~)
% hObject    handle to edit31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit32_Callback(hObject, eventdata, handles)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit25 as text
%        str2double(get(hObject,'String')) returns contents of edit25 as a double
pushbutton2_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit32_CreateFcn(hObject, eventdata, ~)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function handles = pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%determine gui visibilities
set(handles.pushbutton2,'visible','off')
if get(handles.checkbox3, 'Value') == 1
    vis = 'on';
else
    vis = 'off';
    set(handles.checkbox5,'Value',0)
    set(handles.checkbox7,'Value',0)
    set(handles.checkbox9,'Value',0)
end
set(handles.popupmenu2,'visible',vis)
set(handles.edit6,'visible',vis)
set(handles.edit7,'visible',vis)
set(handles.edit8,'visible',vis)
set(handles.edit9,'visible',vis)
set(handles.edit10,'visible',vis)
set(handles.checkbox4,'visible',vis)
set(handles.checkbox5,'enable',vis)

if get(handles.checkbox5, 'Value') == 1
    vis = 'on';
else
    vis = 'off';
    set(handles.checkbox7,'Value',0)
    set(handles.checkbox9,'Value',0)
end
set(handles.popupmenu3,'visible',vis)
set(handles.edit11,'visible',vis)
set(handles.edit12,'visible',vis)
set(handles.edit13,'visible',vis)
set(handles.edit14,'visible',vis)
set(handles.edit15,'visible',vis)
set(handles.checkbox6,'visible',vis)
set(handles.checkbox7,'enable',vis)

if get(handles.checkbox7, 'Value') == 1
    vis = 'on';
else
    vis = 'off';
    set(handles.checkbox9,'Value',0)
end
set(handles.popupmenu4,'visible',vis)
set(handles.edit16,'visible',vis)
set(handles.edit17,'visible',vis)
set(handles.edit18,'visible',vis)
set(handles.edit19,'visible',vis)
set(handles.edit20,'visible',vis)
set(handles.checkbox8,'visible',vis)
set(handles.checkbox9,'enable',vis)

if get(handles.checkbox9, 'Value') == 1
    vis = 'on';
else
    vis = 'off';
end
set(handles.popupmenu5,'visible',vis)
set(handles.edit21,'visible',vis)
set(handles.edit22,'visible',vis)
set(handles.edit23,'visible',vis)
set(handles.edit24,'visible',vis)
set(handles.edit25,'visible',vis)
set(handles.checkbox10,'visible',vis)


if get(handles.popupmenu1, 'Value') == 1
    vis = {'on', 'off', 'off', 'off', 'off', 'off'};
elseif get(handles.popupmenu1, 'Value') == 7
    vis = {'off', 'on', 'on', 'off', 'on', 'on'};
else
    vis = {'off', 'on', 'on', 'on', 'off', 'on'};
end
set(handles.edit1,'enable',vis{1})
set(handles.edit2,'enable',vis{2})
set(handles.edit3,'enable',vis{3})
set(handles.edit5,'enable',vis{4})
set(handles.edit28,'enable',vis{5})
set(handles.checkbox2,'enable',vis{6})

if get(handles.popupmenu2, 'Value') == 1
    vis = {'on', 'off', 'off', 'off', 'off', 'off'};
elseif get(handles.popupmenu2, 'Value') == 7
    vis = {'off', 'on', 'on', 'off', 'on', 'on'};
else
    vis = {'off', 'on', 'on', 'on', 'off', 'on'};
end
set(handles.edit6,'enable',vis{1})
set(handles.edit7,'enable',vis{2})
set(handles.edit8,'enable',vis{3})
set(handles.edit10,'enable',vis{4})
set(handles.edit29,'enable',vis{5})
set(handles.checkbox4,'enable',vis{6})

if get(handles.popupmenu3, 'Value') == 1
    vis = {'on', 'off', 'off', 'off', 'off', 'off'};
elseif get(handles.popupmenu3, 'Value') == 7
    vis = {'off', 'on', 'on', 'off', 'on', 'on'};
else
    vis = {'off', 'on', 'on', 'on', 'off', 'on'};
end
set(handles.edit11,'enable',vis{1})
set(handles.edit12,'enable',vis{2})
set(handles.edit13,'enable',vis{3})
set(handles.edit15,'enable',vis{4})
set(handles.edit30,'enable',vis{5})
set(handles.checkbox6,'enable',vis{6})

if get(handles.popupmenu4, 'Value') == 1
    vis = {'on', 'off', 'off', 'off', 'off', 'off'};
elseif get(handles.popupmenu4, 'Value') == 7
    vis = {'off', 'on', 'on', 'off', 'on', 'on'};
else
    vis = {'off', 'on', 'on', 'on', 'off', 'on'};
end
set(handles.edit16,'enable',vis{1})
set(handles.edit17,'enable',vis{2})
set(handles.edit18,'enable',vis{3})
set(handles.edit20,'enable',vis{4})
set(handles.edit31,'enable',vis{5})
set(handles.checkbox8,'enable',vis{6})

if get(handles.popupmenu5, 'Value') == 1
    vis = {'on', 'off', 'off', 'off', 'off', 'off'};
elseif get(handles.popupmenu5, 'Value') == 7
    vis = {'off', 'on', 'on', 'off', 'on', 'on'};
else
    vis = {'off', 'on', 'on', 'on', 'off', 'on'};
end
set(handles.edit21,'enable',vis{1})
set(handles.edit22,'enable',vis{2})
set(handles.edit23,'enable',vis{3})
set(handles.edit25,'enable',vis{4})
set(handles.edit32,'enable',vis{5})
set(handles.checkbox10,'enable',vis{6})

if get(handles.popupmenu6, 'Value') == 1
    vis = 'on';
    set(handles.text21,'visible','off')
else
    vis = 'off';
    set(handles.text21,'visible','on')
end
set(handles.popupmenu7,'visible',vis)
set(handles.popupmenu10,'visible',vis)
set(handles.pushbutton7,'visible',vis)
set(handles.edit27,'visible',vis)
set(handles.edit34,'visible',vis)
set(handles.text12,'visible',vis)
set(handles.text13,'visible',vis)
set(handles.text18,'visible',vis)

%clear previous function parameters
if isfield(handles, 'param')
    handles = rmfield(handles, 'param');
end
handles.dont_load = 0;

%get function parameters
type_strings = {'pfn', 'afn'};
handles.param.type = type_strings{get(handles.popupmenu6, 'Value')};
handles.step_size = str2double(get(handles.edit34, 'String'));

popup_strings = get(handles.popupmenu1, 'String');
handles.param.section{1} = popup_strings{get(handles.popupmenu1, 'Value')};
handles.param.val(1) = str2double(get(handles.edit1, 'String'));
handles.param.low(1) = str2double(get(handles.edit2, 'String'));
handles.param.high(1) = str2double(get(handles.edit3, 'String'));
handles.param.dur(1) = str2double(get(handles.edit4, 'String'));
handles.param.freq(1) = str2double(get(handles.edit5, 'String'));
handles.units = get(handles.popupmenu10, 'Value');
if handles.units==2
    handles.param.freq(1) = dps2freq(handles.param.freq(1),handles.step_size,handles.param.high(1),handles.param.low(1),handles.param.section{1});
end
handles.param.size_speed_ratio(1) = str2double(get(handles.edit28, 'String'));
handles.param.flip(1) = get(handles.checkbox2, 'Value');

next_section = get(handles.checkbox3, 'Value');
if next_section == 1
    popup_strings = get(handles.popupmenu2, 'String');
    handles.param.section{2} = popup_strings{get(handles.popupmenu2, 'Value')};
    handles.param.val(2) = str2double(get(handles.edit6, 'String'));
    handles.param.low(2) = str2double(get(handles.edit7, 'String'));
    handles.param.high(2) = str2double(get(handles.edit8, 'String'));
    handles.param.dur(2) = str2double(get(handles.edit9, 'String'));
    handles.param.freq(2) = str2double(get(handles.edit10, 'String'));
    if handles.units==2
        handles.param.freq(2) = dps2freq(handles.param.freq(2),handles.step_size,handles.param.high(2),handles.param.low(2),handles.param.section{2});
    end
    handles.param.size_speed_ratio(2) = str2double(get(handles.edit29, 'String'));
    handles.param.flip(2) = get(handles.checkbox4, 'Value');
    
    next_section = get(handles.checkbox5, 'Value');
if next_section == 1
    popup_strings = get(handles.popupmenu3, 'String');
    handles.param.section{3} = popup_strings{get(handles.popupmenu3, 'Value')};
    handles.param.val(3) = str2double(get(handles.edit11, 'String'));
    handles.param.low(3) = str2double(get(handles.edit12, 'String'));
    handles.param.high(3) = str2double(get(handles.edit13, 'String'));
    handles.param.dur(3) = str2double(get(handles.edit14, 'String'));
    handles.param.freq(3) = str2double(get(handles.edit15, 'String'));
    if handles.units==2
        handles.param.freq(3) = dps2freq(handles.param.freq(3),handles.step_size,handles.param.high(3),handles.param.low(3),handles.param.section{3});
    end
    handles.param.size_speed_ratio(3) = str2double(get(handles.edit30, 'String'));
    handles.param.flip(3) = get(handles.checkbox6, 'Value');
    
    next_section = get(handles.checkbox7, 'Value');
if next_section == 1
    popup_strings = get(handles.popupmenu4, 'String');
    handles.param.section{4} = popup_strings{get(handles.popupmenu4, 'Value')};
    handles.param.val(4) = str2double(get(handles.edit16, 'String'));
    handles.param.low(4) = str2double(get(handles.edit17, 'String'));
    handles.param.high(4) = str2double(get(handles.edit18, 'String'));
    handles.param.dur(4) = str2double(get(handles.edit19, 'String'));
    handles.param.freq(4) = str2double(get(handles.edit20, 'String'));
    if handles.units==2
        handles.param.freq(4) = dps2freq(handles.param.freq(4),handles.step_size,handles.param.high(4),handles.param.low(4),handles.param.section{4});
    end
    handles.param.size_speed_ratio(4) = str2double(get(handles.edit31, 'String'));
    handles.param.flip(4) = get(handles.checkbox8, 'Value');
    
    next_section = get(handles.checkbox9, 'Value');
if next_section == 1
    popup_strings = get(handles.popupmenu5, 'String');
    handles.param.section{5} = popup_strings{get(handles.popupmenu5, 'Value')};
    handles.param.val(5) = str2double(get(handles.edit21, 'String'));
    handles.param.low(5) = str2double(get(handles.edit22, 'String'));
    handles.param.high(5) = str2double(get(handles.edit23, 'String'));
    handles.param.dur(5) = str2double(get(handles.edit24, 'String'));
    handles.param.freq(5) = str2double(get(handles.edit25, 'String'));
    if handles.units==2
        handles.param.freq(5) = dps2freq(handles.param.freq(5),handles.step_size,handles.param.high(5),handles.param.low(5),handles.param.section{5});
    end
    handles.param.size_speed_ratio(5) = str2double(get(handles.edit32, 'String'));
    handles.param.flip(5) = get(handles.checkbox10, 'Value');
end
end
end
end

%get frame rate of function
if strcmp(handles.param.type,'pfn') == 1
    handles.param.frames = str2double(get(handles.edit27, 'String'));
    handles.param.gs_val = get(handles.popupmenu7, 'Value')^2;
    fps = 1000/(sqrt(handles.param.gs_val));
else
    fps = 1000;
end

%check if function values are within acceptable limits
if strcmp(handles.param.type,'pfn') == 1
    if any([handles.param.val handles.param.low handles.param.high]<0) || any([handles.param.val handles.param.low handles.param.high]>handles.param.frames)
        handles.param.val(handles.param.val<0) = 1;
        handles.param.low(handles.param.low<0) = 1;
        handles.param.high(handles.param.high<0) = 1;
        handles.param.val(handles.param.val>handles.param.frames) = handles.param.frames;
        handles.param.low(handles.param.low>handles.param.frames) = handles.param.frames;
        handles.param.high(handles.param.high>handles.param.frames) = handles.param.frames;
        handles.dont_load = 1;
        pushbutton6_Callback(hObject, eventdata, handles)
    end
else
    if any([handles.param.val handles.param.low handles.param.high]<-10) || any([handles.param.val handles.param.low handles.param.high]>10)
        handles.param.val(handles.param.val<-10) = -10;
        handles.param.low(handles.param.low<-10) = -10;
        handles.param.high(handles.param.high<-10) = -10;
        handles.param.val(handles.param.val>10) = 10;
        handles.param.low(handles.param.low>10) = 10;
        handles.param.high(handles.param.high>10) = 10;
        handles.dont_load = 1;
        pushbutton6_Callback(hObject, eventdata, handles)
    end
end

%calculate function
func = Function_Maker_G4(handles.param);
handles.func = func;
time = (1:length(func))/fps;

%plot function to figure
plot(time, func);
grid on
datacursormode on
xlabel('time (s)')
if strcmp(handles.param.type,'pfn') == 1
    ylabel('frame')
else
    ylabel('AO voltage')
end
axis([0 max(time) min(func)-1 max(func)+1])

%set function title
if strcmp(handles.param.type,'pfn')
    title = ['Position Function @ ' num2str(fps) ' Hz (for ' num2str(handles.param.gs_val) '-bit patterns)'];
else
    title = ['Analog Output Function @ ' num2str(fps) ' Hz'];
end
set(handles.text22,'String',title);

%set function name
pfn_dir = 'C:\matlabroot\G4\Position Functions\';
afn_dir = 'C:\matlabroot\G4\Analog Output Functions\';
save_dir = get(handles.text8,'String');
if strcmp(save_dir,pfn_dir)==0 && strcmp(save_dir,afn_dir)==0
    handles.save_dir = get(handles.text8,'String');
else
    if strcmp(handles.param.type,'pfn') == 1
        handles.save_dir = pfn_dir;
    else
        handles.save_dir = afn_dir;
    end
end
if ~exist(handles.save_dir,'dir')
    mkdir(handles.save_dir)
end
set(handles.text8,'String',handles.save_dir);

%set function ID
handles.param.ID = get_function_ID(handles.param.type, handles.save_dir);
set(handles.text10,'String',[num2str(handles.param.ID,'%04d') '_']);

guidata(hObject, handles);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.save_dir = uigetdir('', 'Pick a Directory');
set(handles.text8,'String',handles.save_dir);

%set function ID
handles.param.ID = get_function_ID(handles.param.type, handles.save_dir);
set(handles.text10,'String',[num2str(handles.param.ID,'%04d') '_']);

guidata(hObject, handles);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.filename = get(handles.edit33,'String');

save_function_G4(handles.func, handles.param, handles.save_dir, handles.filename)


% --- Executes on selection change in popupmenu6.
function popupmenu6_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu6
if get(hObject,'Value')==2
    set(handles.popupmenu10, 'Value',1);
    popupmenu10_Callback(hObject, eventdata, handles)
end
pushbutton2_Callback(hObject, eventdata, handles);


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
set(hObject, 'String', {'Position Function', 'Analog Output Function'});


% --- Executes on selection change in popupmenu7.
function popupmenu7_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu7
pushbutton2_Callback(hObject, eventdata, handles);


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
set(hObject, 'String', {'1 bit', '4 bits'});


% --- Executes on selection change in popupmenu10.
function popupmenu10_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu10 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu10
prev_units = handles.units;
handles.units = get(handles.popupmenu10,'Value');
if handles.units ~=prev_units
    if handles.units==1
        reverse = 0;
    else
        reverse = 1;
    end
    popup_strings = get(handles.popupmenu1, 'String');
    type = popup_strings([get(handles.popupmenu1, 'Value') get(handles.popupmenu2, 'Value') get(handles.popupmenu3, 'Value') get(handles.popupmenu4, 'Value') get(handles.popupmenu5, 'Value')]);
    low = [str2double(get(handles.edit2, 'String')) str2double(get(handles.edit7, 'String')) str2double(get(handles.edit12, 'String')) str2double(get(handles.edit17, 'String')) str2double(get(handles.edit22, 'String'))];
    high = [str2double(get(handles.edit3, 'String')) str2double(get(handles.edit8, 'String')) str2double(get(handles.edit13, 'String')) str2double(get(handles.edit18, 'String')) str2double(get(handles.edit23, 'String'))];
    freq = [str2double(get(handles.edit5, 'String')) str2double(get(handles.edit10, 'String')) str2double(get(handles.edit15, 'String')) str2double(get(handles.edit20, 'String')) str2double(get(handles.edit25, 'String'))];
    set(handles.edit5, 'String', num2str(dps2freq(freq(1),handles.step_size,high(1),low(1),type{1},reverse)));
    set(handles.edit10, 'String', num2str(dps2freq(freq(2),handles.step_size,high(2),low(2),type{2},reverse)));
    set(handles.edit15, 'String', num2str(dps2freq(freq(3),handles.step_size,high(3),low(3),type{3},reverse)));
    set(handles.edit20, 'String', num2str(dps2freq(freq(4),handles.step_size,high(4),low(4),type{4},reverse)));
    set(handles.edit25, 'String', num2str(dps2freq(freq(5),handles.step_size,high(5),low(5),type{5},reverse)));
end
pushbutton2_Callback(hObject, eventdata, handles);


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
set(hObject, 'String', {'frequency (Hz)', 'deg/sec'});


function edit27_Callback(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit27 as text
%        str2double(get(hObject,'String')) returns contents of edit27 as a double
pushbutton2_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit27_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit34_Callback(hObject, eventdata, handles)
% hObject    handle to edit34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit34 as text
%        str2double(get(hObject,'String')) returns contents of edit34 as a double
pushbutton2_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit34_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.dont_load==0
    [handles.filename, handles.save_dir] = uigetfile('*.mat');
    load(fullfile(handles.save_dir,handles.filename));
    set(handles.text8,'String',handles.save_dir);
    set(handles.text10,'String',[num2str(handles.param.ID,'%04d') '_']);
else
    type = get(handles.popupmenu6, 'Value');
    if type==1
        pfnparam = handles.param;
    else
        afnparam = handles.param;
    end
end

if exist('pfnparam','var')
    handles.param = pfnparam;
    set(handles.edit27, 'String',num2str(handles.param.frames));
    set(handles.popupmenu7, 'Value',sqrt(handles.param.gs_val));
    if ~isfield(pfnparam,'size_speed_ratio') %add ability to load functions made before looming option was added
        handles.param.size_speed_ratio = 40*ones(size(handles.param.val));
    end
    type = 1;
elseif exist('afnparam','var')
    handles.param = afnparam;
    type = 2;
else
    error('function file structure not recognized')
end

num_sections = length(handles.param.section);
set(handles.checkbox3, 'Value', 0);
set(handles.checkbox5, 'Value', 0);
set(handles.checkbox7, 'Value', 0);
set(handles.checkbox9, 'Value', 0);
set(handles.popupmenu6, 'Value', type);

section_strings = {'static','sawtooth', 'triangle', 'sine', 'cosine', 'square', 'loom'};
section_val = find(strcmp(section_strings,handles.param.section{1}));
set(handles.popupmenu1, 'Value', section_val);
set(handles.edit1, 'String', num2str(handles.param.val(1)));
set(handles.edit2, 'String', num2str(handles.param.low(1)));
set(handles.edit3, 'String', num2str(handles.param.high(1)));
set(handles.edit4, 'String', num2str(handles.param.dur(1)));
set(handles.edit5, 'String', num2str(handles.param.freq(1)));
set(handles.edit28, 'String', num2str(handles.param.size_speed_ratio(1)));
set(handles.checkbox2, 'Value', handles.param.flip(1));

if num_sections>1
    set(handles.checkbox3, 'Value', 1);
    section_val = find(strcmp(section_strings,handles.param.section{2}));
    set(handles.popupmenu2, 'Value', section_val);
    set(handles.edit6, 'String', num2str(handles.param.val(2)));
    set(handles.edit7, 'String', num2str(handles.param.low(2)));
    set(handles.edit8, 'String', num2str(handles.param.high(2)));
    set(handles.edit9, 'String', num2str(handles.param.dur(2)));
    set(handles.edit10, 'String', num2str(handles.param.freq(2)));
    set(handles.edit29, 'String', num2str(handles.param.size_speed_ratio(2)));
    set(handles.checkbox4, 'Value', handles.param.flip(2));
    
    if num_sections>2
    set(handles.checkbox5, 'Value', 1);
    section_val = find(strcmp(section_strings,handles.param.section{3}));
    set(handles.popupmenu3, 'Value', section_val);
    set(handles.edit11, 'String', num2str(handles.param.val(3)));
    set(handles.edit12, 'String', num2str(handles.param.low(3)));
    set(handles.edit13, 'String', num2str(handles.param.high(3)));
    set(handles.edit14, 'String', num2str(handles.param.dur(3)));
    set(handles.edit15, 'String', num2str(handles.param.freq(3)));
    set(handles.edit30, 'String', num2str(handles.param.size_speed_ratio(3)));
    set(handles.checkbox6, 'Value', handles.param.flip(3));
    
    if num_sections>3
    set(handles.checkbox7, 'Value', 1);
    section_val = find(strcmp(section_strings,handles.param.section{4}));
    set(handles.popupmenu4, 'Value', section_val);
    set(handles.edit16, 'String', num2str(handles.param.val(4)));
    set(handles.edit17, 'String', num2str(handles.param.low(4)));
    set(handles.edit18, 'String', num2str(handles.param.high(4)));
    set(handles.edit19, 'String', num2str(handles.param.dur(4)));
    set(handles.edit20, 'String', num2str(handles.param.freq(4)));
    set(handles.edit31, 'String', num2str(handles.param.size_speed_ratio(4)));
    set(handles.checkbox8, 'Value', handles.param.flip(4));
    
    if num_sections>4
    set(handles.checkbox9, 'Value', 1);
    section_val = find(strcmp(section_strings,handles.param.section{5}));
    set(handles.popupmenu5, 'Value', section_val);
    set(handles.edit21, 'String', num2str(handles.param.val(5)));
    set(handles.edit22, 'String', num2str(handles.param.low(5)));
    set(handles.edit23, 'String', num2str(handles.param.high(5)));
    set(handles.edit24, 'String', num2str(handles.param.dur(5)));
    set(handles.edit25, 'String', num2str(handles.param.freq(5)));
    set(handles.edit32, 'String', num2str(handles.param.size_speed_ratio(5)));
    set(handles.checkbox10, 'Value', handles.param.flip(5));
    end
    end
    end
end

guidata(hObject, handles);

if handles.dont_load == 1
    handles.dont_load = 0;
    return
else
    pushbutton2_Callback(hObject, eventdata, handles);
end
set(handles.text10,'String',[num2str(handles.param.ID,'%04d') '_']);


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('*.mat', 'Select a pattern file');

try
    load(fullfile(pathname,filename),'pattern');
    handles.step_size = rad2deg(pattern.param.true_step_size);
    set(handles.edit34,'String',num2str(handles.step_size));
    set(handles.edit27,'String',num2str(pattern.x_num));
    set(handles.popupmenu7,'Value',round(sqrt(pattern.gs_val)));
    pushbutton2_Callback(hObject, eventdata, handles);
catch
    error('Expected pattern metadata not found in selected file')
end
