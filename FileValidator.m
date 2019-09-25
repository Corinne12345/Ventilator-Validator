

function varargout = FileValidator(varargin)
% FILEVALIDATOR MATLAB code for FileValidator.fig
%      FILEVALIDATOR, by itself, creates a new FILEVALIDATOR or raises the existing
%      singleton*.
%
%      H = FILEVALIDATOR returns the handle to a new FILEVALIDATOR or the handle to
%      the existing singleton*.
%
%      FILEVALIDATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FILEVALIDATOR.M with the given input arguments.
%
%      FILEVALIDATOR('Property','Value',...) creates a new FILEVALIDATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FileValidator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FileValidator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FileValidator

% Last Modified by GUIDE v2.5 25-Sep-2019 12:33:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FileValidator_OpeningFcn, ...
                   'gui_OutputFcn',  @FileValidator_OutputFcn, ...
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


% --- Executes just before FileValidator is made visible.
function FileValidator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FileValidator (see VARARGIN)

% Choose default command line output for FileValidator
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FileValidator wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FileValidator_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
    global flow_check
    if get(hObject, 'Value') == get(hObject, 'Max')
        flow_check = 1;
    else
        flow_check = 0;
    end


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
    global pressure_check
    if get(hObject, 'Value') == get(hObject, 'Max')
        pressure_check = 1;
    else
        pressure_check = 0;
    end


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
    global vol_check
    if get(hObject, 'Value') == get(hObject, 'Max')
        vol_check = 1;
    else
        vol_check = 0;
    end


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
    global peep_check
    if get(hObject, 'Value') == get(hObject, 'Max')
        peep_check = 1;
    else
        peep_check = 0;
    end


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
    global peak_check
    if get(hObject, 'Value') == get(hObject, 'Max')
        peak_check = 1;
    else
        peak_check = 0;
    end


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to gina_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gina_filename as text
%        str2double(get(hObject,'String')) returns contents of gina_filename as a double



% --- Executes during object creation, after setting all properties.
function gina_filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gina_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to lab_Filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lab_Filename as text
%        str2double(get(hObject,'String')) returns contents of lab_Filename as a double


% --- Executes during object creation, after setting all properties.
function lab_Filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lab_Filename (see GCBO)
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
global f;
f = str2double(get(hObject, 'String'));

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


% --- Executes on button press in ginabrowse.
function ginabrowse_Callback(hObject, eventdata, handles)
% hObject    handle to ginabrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global file_nalm;
file_nalm = uigetfile({'.xlsx'}, 'GINA File Selector');
set(handles.gina_filename,'String', file_nalm);



% --- Executes on button press in labbrowse.
function labbrowse_Callback(hObject, eventdata, handles)
% hObject    handle to labbrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global file_lab;
file_lab = uigetfile({'.log'}, 'FlowLab File Selector');
set(handles.lab_Filename, 'String',file_lab);



% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
main


% --- Executes on selection change in x_axis.
function x_axis_Callback(hObject, eventdata, handles)
% hObject    handle to x_axis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns x_axis contents as cell array
%        contents{get(hObject,'Value')} returns selected item from x_axis


% --- Executes during object creation, after setting all properties.
function x_axis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_axis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in y_axis.
function y_axis_Callback(hObject, eventdata, handles)
% hObject    handle to y_axis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns y_axis contents as cell array
%        contents{get(hObject,'Value')} returns selected item from y_axis


% --- Executes during object creation, after setting all properties.
function y_axis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_axis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in infantData.
function infantData_Callback(hObject, eventdata, handles)
% hObject    handle to infantData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 global infantData
    if get(hObject, 'Value') == get(hObject, 'Max')
        infantData = 1;
    else
        infantData = 0;
    end


% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9
 global presVol
    if get(hObject, 'Value') == get(hObject, 'Max')
        presVol = 1;
    else
        presVol = 0;
    end
