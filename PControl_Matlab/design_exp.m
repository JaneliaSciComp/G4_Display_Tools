function varargout = design_exp(varargin)
% DESIGN_EXP Application M-file for design_exp.fig
%   DESIGN_EXP, by itself, creates a new DESIGN_EXP or raises the existing
%   singleton*.
%
%   H = DESIGN_EXP returns the handle to a new DESIGN_EXP or the handle to
%   the existing singleton*.
%
%   DESIGN_EXP('CALLBACK',hObject,eventData,handles,...) calls the local
%   function named CALLBACK in DESIGN_EXP.M with the given input arguments.
%
%   DESIGN_EXP('Property','Value',...) creates a new DESIGN_EXP or raises the
%   existing singleton*.  Starting from the left, property value pairs are
%   applied to the GUI before lbox2_OpeningFunction gets called.  An
%   unrecognized property name or invalid value makes property application
%   stop.  All inputs are passed to design_exp_OpeningFcn via varargin.
%
%   *See GUI Options - GUI allows only one instance to run (singleton).
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2000-2006 The MathWorks, Inc.

% Edit the above text to modify the response to help design_exp

% Last Modified by GUIDE v2.5 02-Dec-2015 11:14:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',          mfilename, ...
                   'gui_Singleton',     gui_Singleton, ...
                   'gui_OpeningFcn',    @design_exp_OpeningFcn, ...
                   'gui_OutputFcn',     @design_exp_OutputFcn, ...
                   'gui_LayoutFcn',     [], ...
                   'gui_Callback',      []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before design_exp is made visible.
function design_exp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to design_exp (see VARARGIN)

% Choose default command line output for design_exp
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

if nargin == 3,
    initial_dir = pwd;
elseif nargin > 4
    if strcmpi(varargin{1},'dir')
        if exist(varargin{2},'dir')
            initial_dir = varargin{2};
        else
            errordlg('Input argument must be a valid directory','Input Argument Error!')
            return
        end
    else
        errordlg('Unrecognized input argument','Input Argument Error!');
        return;
    end
end

handles.patternList = cell(0);
handles.functionList = cell(0);
handles.aoList = cell(0);

% Populate the listbox
load_listbox(initial_dir,handles)
% Return figure handle as first output argument
    
% UIWAIT makes design_exp wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = design_exp_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% ------------------------------------------------------------
% Callback for list box - open .fig with guide, otherwise use open
% ------------------------------------------------------------
function source_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to source_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns source_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from source_listbox

get(handles.figure1,'SelectionType');
if strcmp(get(handles.figure1,'SelectionType'),'open')
    index_selected = get(handles.source_listbox,'Value');
    file_list = get(handles.source_listbox,'String');
    filename = file_list{index_selected};
    if  handles.is_dir(handles.sorted_index(index_selected))
        cd (filename)
        load_listbox(pwd,handles)
    else
        [path,name,ext] = fileparts(filename);
        switch ext
            case '.pat'
                patternList = handles.patternList;
                patternListDisp = get(handles.pattern_listbox,'String');
                if isempty(patternList)
                    patternList{1}= fullfile(pwd,filename);
                    patternListDisp{1} = name;
                    set(handles.pattern_remove, 'enable', 'On');
                else
                    patternList{end+1} = fullfile(pwd,filename);
                    patternListDisp{end+1} = name;
                    if length(patternList)>=2
                        set(handles.pattern_up, 'enable', 'On');
                        set(handles.pattern_down, 'enable', 'On');
                    end
                end
                handles.patternList = patternList;
                set(handles.pattern_listbox,'String', patternListDisp);
            case '.pfn'
                functionList = handles.functionList;
                functionListDisp = get(handles.function_listbox,'String');
                if isempty(functionList)
                    functionList{1}= fullfile(pwd,filename);
                    functionListDisp{1} = name;
                    set(handles.function_remove, 'enable', 'On');
                else
                    functionList{end+1} = fullfile(pwd,filename);
                    functionListDisp{end+1} = name;
                    if length(functionList)>=2
                        set(handles.function_up, 'enable', 'On');
                        set(handles.function_down, 'enable', 'On');
                    end
                end
                handles.functionList = functionList;
                set(handles.function_listbox,'String', functionListDisp);                
            case '.afn'
                aoList = handles.aoList;
                aoListDisp = get(handles.ao_listbox,'String');
                if isempty(aoList)
                    aoList{1} = fullfile(pwd,filename);
                    aoListDisp{1} = name;
                    set(handles.ao_remove, 'enable', 'On');
                else
                    aoList{end+1} = fullfile(pwd, filename);
                    aoListDisp{end+1} = name;
                    if length(aoList)>=2
                        set(handles.ao_up, 'enable', 'On');
                        set(handles.ao_down, 'enable', 'On');
                    end
                end
                handles.aoList = aoList;
                set(handles.ao_listbox,'String', aoListDisp);                                
            otherwise
                errordlg('Wrong file type!','File Type Error','modal');
        end
        guidata(hObject, handles);
    end
end
% ------------------------------------------------------------
% Read the current directory and sort the names
% ------------------------------------------------------------
function load_listbox(dir_path,handles)
cd (dir_path)
dir_struct = dir(dir_path);
[sorted_names,sorted_index] = sortrows({dir_struct.name}');
handles.file_names = sorted_names;
handles.is_dir = [dir_struct.isdir];
handles.sorted_index = sorted_index;
guidata(handles.figure1,handles)
set(handles.source_listbox,'String',handles.file_names,...
	'Value',1)
set(handles.current_dir,'String',pwd)


% --- Executes during object creation, after setting all properties.
function source_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to source_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Add the current directory to the path, as the pwd might change thru' the
% gui. Remove the directory from the path when gui is closed 
% (See figure1_DeleteFcn)
setappdata(hObject, 'StartPath', pwd);
addpath(pwd);


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Remove the directory added to the path in the figure1_CreateFcn.
if isappdata(hObject, 'StartPath')
    rmpath(getappdata(hObject, 'StartPath'));
end



% --- Executes on selection change in function_listbox.
function function_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to function_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns function_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from function_listbox


% --- Executes during object creation, after setting all properties.
function function_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to function_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ao_listbox.
function ao_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to ao_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ao_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ao_listbox


% --- Executes during object creation, after setting all properties.
function ao_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ao_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pattern_listbox.
function pattern_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to pattern_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pattern_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pattern_listbox


% --- Executes during object creation, after setting all properties.
function pattern_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pattern_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in choose_pattern.
function choose_pattern_Callback(hObject, eventdata, handles)
% hObject    handle to choose_pattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function exp_dir_Callback(hObject, eventdata, handles)
% hObject    handle to exp_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exp_dir as text
%        str2double(get(hObject,'String')) returns contents of exp_dir as a double


% --- Executes during object creation, after setting all properties.
function exp_dir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exp_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pattern_up.
function pattern_up_Callback(hObject, eventdata, handles)
% hObject    handle to pattern_up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
patternIndex = get(handles.pattern_listbox,'Value');
patternListDisp = get(handles.pattern_listbox,'String');
patternList = handles.patternList;
numPatterns = length(patternListDisp);
if ~(patternIndex == 1)
    patternList([patternIndex-1 patternIndex]) = patternList([patternIndex patternIndex-1]);
    patternListDisp([patternIndex-1 patternIndex]) = patternListDisp([patternIndex patternIndex-1]);
end
set(handles.pattern_listbox, 'String', patternListDisp);
set(handles.pattern_listbox,'Value', max(1,patternIndex-1)); % set this to 1 to prevent attempt to delete
% files just removed from the list
handles.patternList = patternList;
guidata(hObject, handles);  % Update handles structure


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

patternList = handles.patternList;
functionList = handles.functionList;
aoList = handles.aoList;

numPattern = length(patternList);
numFunction = length(functionList);
numAo = length(aoList);

expDir = handles.saveExpDir;


%%save pattern files
pattsDir = [expDir, '\Patterns'];

if exist(pattsDir, 'dir')
    if ~isempty(dir([pattsDir, '\*.pat']))
        delete([pattsDir '\*.pat']);
    end
else
    mkdir(pattsDir);
end
    
pattCounter = 0;

for j = 1:numPattern
    fid = fopen(patternList{j});
    if fid<= 0
        warningMsg = [patternList{j}  ' is a invalid pattern file'];
        warndlg(warningMsg, 'Invalid pattern');
        continue;
    end    
    
    patHeader = fread(fid,7,'uchar');
    fclose(fid);
    
    pattCounter = pattCounter + 1;
    
    % set up currentPatts structure with pattern info
    currentPatts.x_num(pattCounter) = patHeader(2)*256+patHeader(1);
    currentPatts.y_num(pattCounter) = patHeader(4)*256+patHeader(3);
    currentPatts.gs_val(pattCounter) = patHeader(5);
    currentPatts.row_num(pattCounter) = patHeader(6);
    currentPatts.col_num(pattCounter) = patHeader(7);
    
    [patFilePath,patFileName,patFileExt] = fileparts(patternList{j});
    currentPatts.pattNames{pattCounter} = patFileName;
    currentPatts.patternList = patternList;
    
    switch length(num2str(pattCounter))
        case 1
            patFileName = ['pat000' num2str(pattCounter) '.pat'];
        case 2
            patFileName = ['pat00', num2str(pattCounter) '.pat'];
        case 3
            patFileName = ['pat0', num2str(pattCounter) '.pat'];
        case 4
            patFileName = ['pat', num2str(pattCounter) '.pat'];
        otherwise
            disp('The pattern number is too big.');
    end
    destFile = fullfile(pattsDir, patFileName);

    result1 = copyfile(patternList{j},destFile);  %% SS
end

currentPatts.num_patterns = pattCounter;
currentPatts.patternList = patternList;
currentExp.pattern = currentPatts;

%% save function files
funDir = [expDir, '\Functions'];

if exist(funDir, 'dir')
    if ~isempty(dir([funDir, '\*.pfn']))
        delete([funDir '\*.pfn']);
    end
else
    mkdir(funDir);
end

block_size = 512; % all data must be in units of block size
funCounter = 0;
    
for j = 1:numFunction
    fid = fopen(functionList{j});
    if fid<= 0
        warningMsg = [functionList{j}  ' is a invalid function file'];
        warndlg(warningMsg, 'invalid function');
        continue;
    end
    
    funcHeader = fread(fid, block_size, 'uchar');
    fclose(fid);
    
    funCounter = funCounter + 1;
    % set up currentFunc structure with function info
    [funFilePath,funFileName,funFileExt] = fileparts(functionList{j});
    currentFunc.functionName{funCounter} = funFileName;
    currentFunc.functionSize{funCounter} = funcHeader(4)*2^32+funcHeader(3)*2^16+funcHeader(2)*2^8+funcHeader(1); 


    switch length(num2str(funCounter))
        case 1
            funcFileName = ['fun000' num2str(funCounter) '.pfn'];
        case 2
            funcFileName = ['fun00', num2str(funCounter) '.pfn'];
        case 3
            funcFileName = ['fun0', num2str(funCounter) '.pfn'];
        case 4
            funcFileName = ['fun', num2str(funCounter) '.pfn'];
        otherwise
            disp('The number of function you choose exceeds the maximum.');
            break;
    end
    
    destFile = fullfile(funDir, funcFileName);
    result1 = copyfile(functionList{j},destFile);  %% SS
end

currentFunc.numFunc = funCounter;
currentFunc.functionList = functionList;
currentExp.function = currentFunc;
%%save ao function files
aoDir = [expDir, '\Analog Output Functions'];

if exist(aoDir, 'dir')
    if ~isempty(dir([aoDir, '\*.afn']))
        delete([pattsDir '\*.afn']);
    end
else
    mkdir(aoDir);
end

block_size = 512; % all data must be in units of block size
aoCounter = 0;
    
for j = 1:numAo
    fid = fopen(aoList{j});
    if fid<= 0
        warningMsg = [aoList{j}  ' is a invalid ao file'];
        warndlg(warningMsg, 'invalid ao');
        continue;
    end
    
    funcHeader = fread(fid, block_size, 'uchar');
    fclose(fid);
    
    aoCounter = aoCounter + 1;
    % set up currentFunc structure with function info
    
    [aoFilePath,aoFileName,aoFileExt] = fileparts(aoList{j});
    currentAOFunc.aoFunctionName{aoCounter} = aoFileName;
    currentAOFunc.aoFunctionSize{aoCounter} = funcHeader(4)*2^32+funcHeader(3)*2^16+funcHeader(2)*2^8+funcHeader(1); 


    switch length(num2str(aoCounter))
        case 1
            aoFileName = ['ao000' num2str(aoCounter) '.afn'];
        case 2
            aoFileName = ['ao00', num2str(aoCounter) '.afn'];
        case 3
            aoFileName = ['ao0', num2str(aoCounter) '.afn'];
        case 4
            aoFileName = ['ao', num2str(aoCounter) '.afn'];
        otherwise
            disp('The number of ao you choose exceeds the maximum.');
            break;
    end
    
    destFile = fullfile(aoDir, aoFileName);
    result1 = copyfile(aoList{j},destFile);  %% SS
end

currentAOFunc.numaoFunc = aoCounter;
currentAOFunc.aoList = aoList;
currentExp.aoFunction = currentAOFunc;

%save the configuration
save([expDir, '\currentExp.mat'], 'currentExp');
uiwait(msgbox('Done!','Success','modal'));



% --- Executes on button press in pattern_down.
function pattern_down_Callback(hObject, eventdata, handles)
% hObject    handle to pattern_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
patternIndex = get(handles.pattern_listbox,'Value');
patternListDisp = get(handles.pattern_listbox,'String');
patternList = handles.patternList;
numPatterns = length(patternList);
if ~(patternIndex == numPatterns)
    patternListDisp([patternIndex patternIndex+1]) = patternListDisp([patternIndex+1 patternIndex]);
    patternList([patternIndex patternIndex+1]) = patternList([patternIndex+1 patternIndex]);
end
set(handles.pattern_listbox, 'String', patternListDisp);
set(handles.pattern_listbox,'Value', min(numPatterns,patternIndex+1)); % set this to 1 to prevent attempt to delete
% files just removed from the list
handles.patternList = patternList;
guidata(hObject, handles);  % Update handles structure

% --- Executes on button press in pattern_remove.
function pattern_remove_Callback(hObject, eventdata, handles)
% hObject    handle to pattern_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
patternIndex = get(handles.pattern_listbox,'Value');
patternListDisp = get(handles.pattern_listbox,'String');
patternList = handles.patternList; 
numPatterns = length(patternList);
patternToKeep = [1:(patternIndex-1) (patternIndex+1):numPatterns];
% create an index of the files to keep    
patternListDisp = patternListDisp([patternToKeep]); 
patternList = patternList([patternToKeep]);
set(handles.pattern_listbox, 'String', patternListDisp);
set(handles.pattern_listbox,'Value', 1); % set this to 1 to prevent attempt to delete
% files just removed from the list
handles.patternList = patternList;
guidata(hObject, handles);  % Update handles structure
if(length(patternList) == 1) 
    set(handles.pattern_up, 'enable', 'Off');
    set(handles.pattern_down, 'enable', 'Off');    
elseif (isempty(patternList))
    set(handles.pattern_remove, 'enable', 'Off');
end

% --- Executes on button press in function_up.
function function_up_Callback(hObject, eventdata, handles)
% hObject    handle to function_up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
functionIndex = get(handles.function_listbox,'Value');
functionListDisp = get(handles.function_listbox,'String');
functionList = handles.functionList;
numfunctions = length(functionList);
if ~(functionIndex == 1)
    functionList([functionIndex-1 functionIndex]) = functionList([functionIndex functionIndex-1]);
    functionListDisp([functionIndex-1 functionIndex]) = functionListDisp([functionIndex functionIndex-1]);
end
set(handles.function_listbox, 'String', functionListDisp);
set(handles.function_listbox,'Value', max(1,functionIndex-1)); % set this to 1 to prevent attempt to delete
% files just removed from the list
handles.functionList = functionList;
guidata(hObject, handles);  % Update handles structure

% --- Executes on button press in function_down.
function function_down_Callback(hObject, eventdata, handles)
% hObject    handle to function_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
functionIndex = get(handles.function_listbox,'Value');
functionListDisp = get(handles.function_listbox,'String');
functionList = handles.functionList;
numfunctions = length(functionList);
if ~(functionIndex == numfunctions)
    functionList([functionIndex functionIndex+1]) = functionList([functionIndex+1 functionIndex]);
    functionListDisp([functionIndex functionIndex+1]) = functionListDisp([functionIndex+1 functionIndex]);
end
set(handles.function_listbox, 'String', functionListDisp);
set(handles.function_listbox,'Value', min(numfunctions,functionIndex+1)); % set this to 1 to prevent attempt to delete
% files just removed from the list
handles.functionList = functionList;
guidata(hObject, handles);  % Update handles structure

% --- Executes on button press in function_remove.
function function_remove_Callback(hObject, eventdata, handles)
% hObject    handle to function_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
functionIndex = get(handles.function_listbox,'Value');
functionListDisp = get(handles.function_listbox,'String');
functionList = handles.functionList;

numfunctions = length(functionList);
functionToKeep = [1:(functionIndex-1) (functionIndex+1):numfunctions];
% create an index of the files to keep    
functionListDisp = functionListDisp([functionToKeep]);    
functionList = functionList([functionToKeep]);   
set(handles.function_listbox, 'String', functionListDisp);
set(handles.function_listbox,'Value', 1); % set this to 1 to prevent attempt to delete
% files just removed from the list
handles.functionList = functionList;
guidata(hObject, handles);  % Update handles structure
if(length(functionList) == 1) 
    set(handles.function_up, 'enable', 'Off');
    set(handles.function_down, 'enable', 'Off');    
elseif (isempty(functionList))
    set(handles.function_remove, 'enable', 'Off');
end

% --- Executes on button press in ao_up.
function ao_up_Callback(hObject, eventdata, handles)
% hObject    handle to ao_up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
aoIndex = get(handles.ao_listbox,'Value');
aoListDisp = get(handles.ao_listbox,'String');
aoList = handles.aoList;
numaos = length(aoList);
if ~(aoIndex == 1)
    aoList([aoIndex-1 aoIndex]) = aoList([aoIndex aoIndex-1]);
    aoListDisp([aoIndex-1 aoIndex]) = aoListDisp([aoIndex aoIndex-1]);
end
set(handles.ao_listbox, 'String', aoListDisp);
set(handles.ao_listbox,'Value', max(1,aoIndex-1)); % set this to 1 to prevent attempt to delete
% files just removed from the list
handles.aoList = aoList;
guidata(hObject, handles);  % Update handles structure

% --- Executes on button press in ao_down.
function ao_down_Callback(hObject, eventdata, handles)
% hObject    handle to ao_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
aoIndex = get(handles.ao_listbox,'Value');
aoListDisp = get(handles.ao_listbox,'String');
aoList = handles.aoList;
numaos = length(aoList);
if ~(aoIndex == numaos)
    aoList([aoIndex aoIndex+1]) = aoList([aoIndex+1 aoIndex]);
    aoListDisp([aoIndex aoIndex+1]) = aoListDisp([aoIndex+1 aoIndex]);
end
set(handles.ao_listbox, 'String', aoListDisp);
set(handles.ao_listbox,'Value', min(numaos,aoIndex+1)); % set this to 1 to prevent attempt to delete
% files just removed from the list
handles.aoList = aoList;
guidata(hObject, handles);  % Update handles structure

% --- Executes on button press in ao_remove.
function ao_remove_Callback(hObject, eventdata, handles)
% hObject    handle to ao_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
aoIndex = get(handles.ao_listbox,'Value');
aoListDisp = get(handles.ao_listbox,'String');
aoList = handles.aoList;
numaos = length(aoList);
aoToKeep = [1:(aoIndex-1) (aoIndex+1):numaos];
% create an index of the files to keep    
aoList = aoList([aoToKeep]); 
aoListDisp = aoListDisp([aoToKeep]);
set(handles.ao_listbox, 'String', aoListDisp);
set(handles.ao_listbox,'Value', 1); % set this to 1 to prevent attempt to delete
% files just removed from the list
handles.aoList = aoList;
guidata(hObject, handles);  % Update handles structure
if(length(aoList) == 1) 
    set(handles.ao_up, 'enable', 'Off');
    set(handles.ao_down, 'enable', 'Off');    
elseif (isempty(aoList))
    set(handles.ao_remove, 'enable', 'Off');
end


% --- Executes on button press in choose_dir.
function choose_dir_Callback(hObject, eventdata, handles)
% hObject    handle to choose_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userSettings;
expDir = uigetdir(exp_path, 'Pick a Directory');
if expDir
    set(handles.exp_dir, 'string', expDir);
    set(handles.save,'enable', 'on');
    handles.saveExpDir = expDir;
    currentExpFile = fullfile(expDir,'currentExp.mat');
    if exist(currentExpFile, 'file')
        load(currentExpFile);
        if currentExp.pattern.num_patterns
            set(handles.pattern_listbox,'String', currentExp.pattern.pattNames);
        end
        
        if currentExp.function.numFunc
            set(handles.function_listbox,'String', currentExp.function.functionName);
        end
        
        if currentExp.aoFunction.numaoFunc
            set(handles.ao_listbox,'String', currentExp.aoFunction.aoFunctionName);
        end
        
        handles.patternList = currentExp.pattern.patternList;
        if numel(handles.patternList)
            set(handles.pattern_up, 'enable', 'On');
            set(handles.pattern_down, 'enable', 'On');
            set(handles.pattern_remove, 'enable', 'On');
        else
            set(handles.pattern_up, 'enable', 'Off');
            set(handles.pattern_down, 'enable', 'Off');
            set(handles.pattern_remove, 'enable', 'Off');            
        end
        handles.functionList = currentExp.function.functionList;
        if numel(handles.functionList)
            set(handles.function_up, 'enable', 'On');
            set(handles.function_down, 'enable', 'On');
            set(handles.function_remove, 'enable', 'On');
        else
            set(handles.function_up, 'enable', 'On');
            set(handles.function_down, 'enable', 'On');
            set(handles.function_remove, 'enable', 'On');          
        end
        
        handles.aoList = currentExp.aoFunction.aoList;
         if numel(handles.aoList)
            set(handles.ao_up, 'enable', 'On');
            set(handles.ao_down, 'enable', 'On');
            set(handles.ao_remove, 'enable', 'On');
        else
            set(handles.ao_up, 'enable', 'Off');
            set(handles.ao_down, 'enable', 'Off');
            set(handles.ao_remove, 'enable', 'Off');
        end       
        handles.currentExpFile = currentExp;
    end
end
guidata(hObject, handles);
