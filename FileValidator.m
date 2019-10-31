
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

% Last Modified by GUIDE v2.5 31-Oct-2019 17:52:26

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
    global flow_pressure_check
    if get(hObject, 'Value') == get(hObject, 'Max')
        flow_pressure_check = 1;
    else
        flow_pressure_check = 0;
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

f = get(hObject, 'String');

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
currentFolder = pwd;
filename = fullfile( currentFolder, 'Tests_data', '*.xlsx');
global file_nalm
file_nalm = uigetfile({filename}, 'GINA File Selector');
set(handles.gina_filename,'String', file_nalm);
out = filegetter(handles, get(handles.gina_filename, 'String'), filename, file_nalm, handles.gina_filename);
file_nalm = out;



function out = filegetter(handles, filestring, filename, setfile, releventhandle)
    if filestring ~= '0'  
        out = setfile;
        return
    else
    uiwait(warndlg('You must select a file'));
    setfile = uigetfile({filename}, 'GINA File Selector');
    set(releventhandle,'String', setfile);
    next = get(releventhandle, 'String');
    out = filegetter(handles, next, filename, setfile, releventhandle);
    end
      



% --- Executes on button press in labbrowse.
function labbrowse_Callback(hObject, eventdata, handles)
% hObject    handle to labbrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currentFolder = pwd;
filename = fullfile( currentFolder, 'Tests_Data', '*.log');
global file_lab
file_lab = uigetfile({filename}, 'FlowLab File Selector');
set(handles.lab_Filename, 'String',file_lab);
out = filegetter(handles, get(handles.lab_Filename, 'String'), filename, file_lab, handles.lab_Filename);
file_lab = out;

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%First check the filename. If it's cool, run the main file
global nameFile


check = 0;
while check == 0
    a = get(handles.nameFile, 'String');          
    % first check that a file name exists
    f = outfilecheck(a, handles);
    
    %{ 
    Check that a frequency is set
    
    b = get(handles.edit3, 'String');
    f = str2double(freqcheck(b, handles));
    %}
    
    %Then check if file exists
    currentFolder = pwd;
    File = fullfile(currentFolder, 'Tests_Results', string(f(1)));      
    
    if exist(File, 'dir')
        str = ['File name " ', File, ' " already exists. Do you want to overwrite this file?'];
        newStr = join(str);
        answer = questdlg(newStr, 'Overwrite file?', 'Yes', 'No', 'No');
        switch answer
            case 'Yes'           
                nameFile = f{1};
                check = 1;
            case 'No'
                set(handles.nameFile, 'string', 'Edit Text');
                newFile = inputdlg('Enter a new file name, no spaces: ', 'Output File Name');
                set(handles.nameFile,'String', newFile);                
        end
    
    else 
        nameFile = string(f(1));
        check = 1;
    end

end

main

function a = outfilecheck(f, handles)
    if f == "Edit Text"
        uiwait(warndlg('Please enter an output file name'));
        newFile = inputdlg('Enter a new file name, no spaces: ', 'Output File Name');
        set(handles.nameFile,'String', newFile);
        g = get(handles.nameFile, 'String');
        a = outfilecheck(g, handles);
    else
        a = f;
        return
    end
%{    
function b = freqcheck(f, handles)
    if f == ''
        uiwait(warndlg('Please enter a frequency'));
        newFreq = inputdlg('Enter a new frequency value');
        set(handles.edit3,'String', newFreq);
        g = get(handles.edit3, 'String');
        b = freqcheck(g, handles);
    else
        b = f;
        return
    end
    %}



function nameFile_Callback(hObject, eventdata, handles)
% hObject    handle to nameFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nameFile as text
%        str2double(get(hObject,'String')) returns contents of nameFile as a double

%{
global nameFile
File = get(hObject, 'String');
check = 0;
while check == 0;
    if isfile(File)
        str = ['File name " ', File, ' " already exists. Do you want to overwrite this file?']
        newStr = join(str);
        ans = questdlg(newStr, 'Overwrite file?', 'Yes', 'No', 'No');
        switch ans
            case 'Yes'           
                nameFile = File;
                check = 1;
            case 'No'

        end
    end
end
%}

% --- Executes during object creation, after setting all properties.
function nameFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nameFile (see GCBO)
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


% --- Executes on button press in helpmenu.
function helpmenu_Callback(hObject, eventdata, handles)
% hObject    handle to helpmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%open HELP file
open GINA-VALIDATOR-MANUAL.pdf

function resetgui(hObject, eventdata, handles)
set(handles.gina_filename, 'string', 'GINA File');
set(handles.lab_Filename, 'string', 'FlowAnalyser File');
set(handles.edit5, 'string', '');
set(handles.nameFile, 'string', 'Edit Text');



% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
resetgui(hObject, eventdata, handles)
clear
