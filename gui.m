function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 19-Jan-2016 17:40:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;
set(handles.figure1, 'Color', [0 0 0]);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in playButton.
function playButton_Callback(hObject, eventdata, handles)
% hObject    handle to playButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
startMusic(handles)

function startMusic(handles)
    set(handles.filtr2,'value', 0);
    set(handles.filtr1,'value', 0);
    set(handles.clearFilter,'value', 1);
    setappdata(handles.figure1, 'counter', 2);
    fileName = getappdata(handles.figure1, 'fileName');
    set(handles.name, 'string', {fileName.fileName});
    [Y,Fs] = audioread(fileName.fileName);
    setappdata(handles.figure1, 'Y', Y);
    setappdata(handles.figure1, 'Fs', Fs);
    player = audioplayer(Y, Fs);
    sr = get(player, 'SampleRate');
    f={@updateWin, handles, Y};
    appData = struct;
    appData.player = player;
    setappdata(handles.figure1, 'appData', appData);
    setappdata(handles.figure1, 'SampleRate', sr);
    set(player, 'TimerPeriod', 1);
    set(player, 'TimerFcn', f);
    play(player);
    curve(handles);
    

function updateWin(obj, event, handles, Y)
    player = obj;
    i = getappdata(handles.figure1, 'counter');
    c = get(player, 'CurrentSample');
    t = get(player, 'TotalSamples');
    sr = get(player, 'SampleRate');
    value = strcat(num2str(round(c/sr)), ' / ' , num2str(round(t/sr)));
    set(handles.czas, 'string', value);
    setappdata(handles.figure1, 'time', round(t/sr));
    
    function curve(handles)
        Y = getappdata(handles.figure1, 'Y');
        Fs = getappdata(handles.figure1, 'Fs');
        t = 0:1/Fs:(length(Y)-1)/Fs;
        appDate = getappdata(handles.figure1, 'appData');
        player = appDate.player;
        while strcmp(get(player, 'Running'), 'on')
            pause(500/Fs);
            cs = get(player, 'CurrentSample');
            if cs ~= 1
                plot(t(cs-500:cs), Y(cs-500:cs));
                set(handles.chart, 'XTick', []);
                set(handles.chart, 'YTick', []);
                drawnow;
            end
        end
        
    
% --- Executes on button press in pauseButton.
function pauseButton_Callback(hObject, eventdata, handles)
% hObject    handle to pauseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
appdata = getappdata(handles.figure1, 'appData');
pause(appdata.player);


% --- Executes on button press in resumeButton.
function resumeButton_Callback(hObject, eventdata, handles)
% hObject    handle to resumeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
appdata = getappdata(handles.figure1, 'appData');
resume(appdata.player);
curve(handles);


% --- Executes on button press in stopButton.
function stopButton_Callback(hObject, eventdata, handles)
% hObject    handle to stopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
appData = getappdata(handles.figure1, 'appData');
stop(appData.player);


% --- Executes on button press in nextButton.
function nextButton_Callback(hObject, eventdata, handles)
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
appData = getappdata(handles.figure1, 'appData');
stop(appData.player);
currentValue = get(handles.listaUtworow,'value');
allNames = get(handles.listaUtworow,'string');
selectValue(currentValue + 1, allNames, handles)
set(handles.listaUtworow,'value', currentValue + 1);
startMusic(handles)


% --- Executes on button press in prevButton.
function prevButton_Callback(hObject, eventdata, handles)
% hObject    handle to prevButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
appData = getappdata(handles.figure1, 'appData');
stop(appData.player);
currentValue = get(handles.listaUtworow,'value');
allNames = get(handles.listaUtworow,'string');
selectValue(currentValue - 1, allNames, handles)
set(handles.listaUtworow,'value', currentValue - 1);
startMusic(handles)

% --- Executes on selection change in listaUtworow.
function listaUtworow_Callback(hObject, eventdata, handles)
% hObject    handle to listaUtworow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected_item=get(hObject,'value');
allNames = get(hObject, 'string');
selectValue(selected_item, allNames, handles);


function selectValue(selected_item, allNames, handles)
    [m, n] = size(allNames);
    if n ~= 0
        name = allNames{selected_item};
        fileName = struct;
        fileName.fileName = name;
        setappdata(handles.figure1, 'fileName', fileName);
    end
    




% Hints: contents = cellstr(get(hObject,'String')) returns listaUtworow contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listaUtworow


% --- Executes during object creation, after setting all properties.
function listaUtworow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listaUtworow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function volume_Callback(hObject, eventdata, handles)
% hObject    handle to volume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider



% --- Executes during object creation, after setting all properties.
function volume_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function czas_Callback(hObject, eventdata, handles)
% hObject    handle to czas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of czas as text
%        str2double(get(hObject,'String')) returns contents of czas as a double


% --- Executes during object creation, after setting all properties.
function czas_CreateFcn(hObject, eventdata, handles)
% hObject    handle to czas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function uri_Callback(hObject, eventdata, handles)
% hObject    handle to uri (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uri as text
%        str2double(get(hObject,'String')) returns contents of uri as a double


% --- Executes during object creation, after setting all properties.
function uri_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uri (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addFileButton.
function addFileButton_Callback(hObject, eventdata, handles)
% hObject    handle to addFileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uigetfile('*.mp3','Lista utworow');
k = get(handles.listaUtworow, 'string');
l = [k; {FileName}];
set(handles.listaUtworow,'string', l);



% --- Executes on button press in clearAllButton.
function clearAllButton_Callback(hObject, eventdata, handles)
% hObject    handle to clearAllButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.listaUtworow,'string',{});



% --- Executes on button press in addFolderButton.
function addFolderButton_Callback(hObject, eventdata, handles)
% hObject    handle to addFolderButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
folder_name = uigetdir


% --- Executes during object creation, after setting all properties.
function name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in Exit.
function Exit_Callback(hObject, eventdata, handles)
% hObject    handle to Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
appData = getappdata(handles.figure1, 'appData');
stop(appData.player);
close('all');


% --- Executes on button press in filtr1.
function filtr1_Callback(hObject, eventdata, handles)
% hObject    handle to filtr1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of filtr1
set(handles.filtr2,'value', 0);
set(handles.clearFilter,'value', 0);
appData = getappdata(handles.figure1, 'appData');
sr = getappdata(handles.figure1, 'SampleRate');
set(appData.player, 'SampleRate', sr*2);


% --- Executes on button press in filtr2.
function filtr2_Callback(hObject, eventdata, handles)
% hObject    handle to filtr2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of filtr2
set(handles.filtr1,'value', 0);
set(handles. clearFilter,'value', 0);
appData = getappdata(handles.figure1, 'appData');
sr = getappdata(handles.figure1, 'SampleRate');
set(appData.player, 'SampleRate', sr/2);


% --- Executes on button press in clearFilter.
function clearFilter_Callback(hObject, eventdata, handles)
% hObject    handle to clearFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of clearFilter
set(handles.filtr2,'value', 0);
set(handles.filtr1,'value', 0);
appData = getappdata(handles.figure1, 'appData');
sr = getappdata(handles.figure1, 'SampleRate');
set(appData.player, 'SampleRate', sr);


% --- Executes during object creation, after setting all properties.
function playButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to playButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
img = imread('icons/play.png');
set(hObject, 'CData', img);


% --- Executes during object creation, after setting all properties.
function nextButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
img = imread('icons/next.png');
set(hObject, 'CData', img);


% --- Executes during object creation, after setting all properties.
function prevButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prevButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
img = imread('icons/previous.png');
set(hObject, 'CData', img);


% --- Executes during object creation, after setting all properties.
function resumeButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resumeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
img = imread('icons/resume.png');
set(hObject, 'CData', img);


% --- Executes during object creation, after setting all properties.
function pauseButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pauseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
img = imread('icons/pause.png');
set(hObject, 'CData', img);


% --- Executes during object creation, after setting all properties.
function stopButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
img = imread('icons/stop.png');
set(hObject, 'CData', img);


% --- Executes during object creation, after setting all properties.
function addFileButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to addFileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
img = imread('icons/addFile.png');
set(hObject, 'CData', img);


% --- Executes during object creation, after setting all properties.
function clearAllButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clearAllButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
img = imread('icons/clearall.png');
set(hObject, 'CData', img);


% --- Executes during object creation, after setting all properties.
function Exit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
img = imread('icons/exit.png');
set(hObject, 'CData', img);


% --- Executes during object creation, after setting all properties.
function chart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate chart
