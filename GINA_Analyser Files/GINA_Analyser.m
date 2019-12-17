function varargout = GINA_Analyser(varargin)
% GINA_ANALYSER MATLAB code for GINA_Analyser.fig
%      GINA_ANALYSER, by itself, creates a new GINA_ANALYSER or raises the existing
%      singleton*.
%
%      H = GINA_ANALYSER returns the handle to a new GINA_ANALYSER or the handle to
%      the existing singleton*.
%
%      GINA_ANALYSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GINA_ANALYSER.M with the given input arguments.
%
%      GINA_ANALYSER('Property','Value',...) creates a new GINA_ANALYSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GINA_Analyser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GINA_Analyser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GINA_Analyser

% Last Modified by GUIDE v2.5 11-Dec-2019 12:00:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GINA_Analyser_OpeningFcn, ...
                   'gui_OutputFcn',  @GINA_Analyser_OutputFcn, ...
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


% --- Executes just before GINA_Analyser is made visible.
function GINA_Analyser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GINA_Analyser (see VARARGIN)

% Choose default command line output for GINA_Analyser
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GINA_Analyser wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GINA_Analyser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in browse1.
function browse1_Callback(hObject, eventdata, handles)
% hObject    handle to browse1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%browse
% select multiple files & check that files have actually been selected

currentFolder = pwd;
filename = fullfile(currentFolder, 'GA_TestData', '*.xlsx');
global file_gina
file_gina = (uigetfile({filename}, 'Select one or more files', 'MultiSelect', 'on'));
set(handles.listbox1,'string', file_gina);

out = filegetter(handles, get(handles.listbox1, 'String'), filename, file_gina, handles.listbox1, hObject, eventdata);
file_gina = cellstr(out);
set(handles.listbox1,'string', file_gina);


% --- Executes on button press in go.
function go_Callback(hObject, eventdata, handles)
% hObject    handle to go (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% run data checks first
global log_file
log_file = convertCharsToStrings(get(handles.addtable, 'String'));


global file_gina
file_gina = cellstr(get(handles.listbox1,'String'));

global add_check
global new_check

    %if both boxes equal zero
    if isequal(add_check, 0) && isequal(new_check, 0)
        fprintf("line 117")
        w = warndlg("You must check at least one 'Output Option for Breath by Breath Data'");
        return
    end
%If there was no addtable, set the checkbox to '0' so that doesn't run

    if string(log_file)=='0' || isequal(string(log_file),'Select File')
        fprintf("line 124");
        add_check = 0;
        new_check = 1;
        x = get(handles.newtable, 'String');

        if isempty(x)        
            w = warndlg('FileValidator can not run without a valid existing or new table. Select a file and click "Go" again');
            resetgui(hObject, eventdata, handles, 1)
            return
        else
            a = outfilechecker(x, handles);
            set(handles.newtable, 'String', a);    
        end
    end

% If newbox ticked, check if file exists
global new_table
    if get(handles.newbox, 'Value') == 1 % the box is ticked
        check = 0;
        while check == 0
            a = get(handles.newtable, 'String');
            if isempty(a)
                w = warndlg('FileValidator can not run without a valid existing or new table. Select a file and click "Go" again');
                resetgui(hObject, eventdata, handles, 1)                
                return
            else
            % first check that user has written in a file name
            b = outfilechecker(a, handles);
                if isempty(b)
                    w = warndlg('FileValidator can not run without a valid existing or new table. Select a file and click "Go" again');
                    resetgui(hObject, eventdata, handles, 1)
                    return
                else
                    f = string(outfilechecker(a, handles)) + '.xlsx';
                end
            end

            %Now check if that file name already exists
            currentFolder = pwd;
            File = fullfile(currentFolder, 'GA_OutputData', f);      

            if isfile(File)
                str = ['File name " ', File, ' " already exists. Do you want to overwrite this file?'];
                newStr = join(str);
                answer = questdlg(newStr, 'Overwrite file? The old version will be deleted', 'Yes', 'No', 'No');
                switch answer
                    case 'Yes'           
                        new_table = f;                                    
                        check = 1;
                    case 'No'
                        set(handles.newtable, 'string', 'Enter New File Name');
                        newFile = inputdlg('Enter a new file name, no spaces: ', 'Output File Name');
                        set(handles.newtable,'String', newFile);                
                end

            else %if file name does not already exist
                new_table = f; %global variable new_table
                check = 1;
            end

        end
    end
    
    x = get(handles.listbox1, 'String');

    if isequal(x, '0') || isequal(x,'Select Files')
        w = warndlg('FileValidator can not run without a valid file selection. Select a file and click "Go" again');
        resetgui(hObject, eventdata, handles, 2)

    else
       
            ga_main %then run main file
                    
            % warndlg('Problem using GINA_Analyser. Check that any excel files being written or added to are closed. Ensure file names do not include illegal symbols. Ensure at least one box is ticked in "2. Output Options for Breath by Breath Analysis"');
           
        
        resetgui(hObject, eventdata, handles, 2) ;
        clear global
        clear
        
    end




function a = outfilechecker(f, handles) %checks that a filename has been written by user
    if strcmp(f, "Enter New File Name") || strcmp(f, "0")
        uiwait(warndlg('Please enter a new output file name'));
        newFile = inputdlg('Enter a new file name, no spaces: ', 'Output File Name');
        set(handles.newtable,'String', newFile);
        g = get(handles.newtable, 'String');
        a = outfilechecker(g, handles);
    else
        a = f;
        return
    end
    
    



% --- Executes on button press in flowcheck.
function flowcheck_Callback(hObject, eventdata, handles)
% hObject    handle to flowcheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of flowcheck
global flow_check
    if get(hObject, 'Value') == get(hObject, 'Max')
        flow_check = 1;
    else
        flow_check = 0;
    end


% --- Executes on button press in pressure.
function pressure_Callback(hObject, eventdata, handles)
% hObject    handle to pressure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pressure

global pres_check
    
    if get(hObject, 'Value') == get(hObject, 'Max')
        pres_check = 1;
    else
        pres_check = 0;
    end


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function newtable_Callback(hObject, eventdata, handles)
% hObject    handle to newtable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newtable as text
%        str2double(get(hObject,'String')) returns contents of newtable as a double



% --- Executes during object creation, after setting all properties.
function newtable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newtable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function addtable_Callback(hObject, eventdata, handles)
% hObject    handle to addtable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of addtable as text
%        str2double(get(hObject,'String')) returns contents of addtable as a double


% --- Executes during object creation, after setting all properties.
function addtable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to addtable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browse2.
function browse2_Callback(hObject, eventdata, handles)
% hObject    handle to browse2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%browse for a table
currentFolder = pwd;
filename = fullfile(currentFolder, 'GA_OutputData', '*.xlsx');
global log_file
log_file = "";
log_file = uigetfile({filename}, 'Select one file', 'MultiSelect', 'off'); 
set(handles.addtable,'String', log_file);
%tests if 0 is selected
out = filegetter(handles, get(handles.addtable, 'String'), filename, log_file, handles.addtable, hObject, eventdata); %makes sure a file is selected
log_file = string(out);
set(handles.addtable,'String', log_file);


function out = filegetter(handles, filestring, filename, setfile, releventhandle, hObject, eventdata) %checks that a file has been selected
    if length(filestring) == 1 && filestring == '0'  
        % set a question
        answer = questdlg('You must select a file/s. Click "Select File", or "Cancel" to exit and reset.', 'Choose a file', 'Select File', 'Cancel', 'Select File');
    
        switch answer
            case 'Select File'
                setfile = uigetfile({filename}, 'File Selector');
                set(releventhandle,'String', setfile);
                next = get(releventhandle, 'String');
                out = filegetter(handles, next, filename, setfile, releventhandle, hObject, eventdata);
            case 'Cancel'                
                out = 'Select File';
        end
    else        
        out = setfile;
        return
    end
    
    






% --- Executes on button press in addbox.
function addbox_Callback(hObject, eventdata, handles)
% hObject    handle to addbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of addbox
global add_check
    if get(hObject, 'Value') == get(hObject, 'Max')
        add_check = 1;
    else
        add_check = 0;
    end


% --- Executes on button press in newbox.
function newbox_Callback(hObject, eventdata, handles)
% hObject    handle to newbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of newbox

global new_check
    if get(hObject, 'Value') == get(hObject, 'Max')
        %set(handles.newbox,'String', 'yes');
        new_check = 1;
    else
        new_check = 0;
    end


% --- Executes on button press in flowbox.
function flowbox_Callback(hObject, eventdata, handles)
% hObject    handle to flowbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of flowbox
global flow_check
    if get(hObject, 'Value') == get(hObject, 'Max')
        flow_check = 1;
    else
        flow_check = 0;
    end


% --- Executes on button press in pressurebox.
function pressurebox_Callback(hObject, eventdata, handles)
% hObject    handle to pressurebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pressurebox
global pres_check
    if get(hObject, 'Value') == get(hObject, 'Max')
        pres_check = 1;
    else
        pres_check = 0
    end

% --- Executes on button press in volpresbox.
function volpresbox_Callback(hObject, eventdata, handles)
% hObject    handle to volpresbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of volpresbox
global presVol_check
    if get(hObject, 'Value') == get(hObject, 'Max')
        presVol_check = 1;
    else
        presVol_check = 0;
    end


% --- Executes on button press in helpbutton.
function helpbutton_Callback(hObject, eventdata, handles)
% hObject    handle to helpbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
open GINA_ANALYSER_MANUAL.pdf
%open file

function resetgui(hObject, eventdata, handles, erasename) 
set(handles.addbox,'value',0)
set(handles.newbox,'value',0)
global add_check
global new_check
add_check = 0;
new_check = 0;
set(handles.addtable, 'string', 'Select File');
if erasename == 1
    set(handles.newtable, 'string', 'Enter New File Name');
elseif erasename ==2
    set(handles.newtable, 'string', 'Enter New File Name');
    set(handles.listbox1, 'string', 'Select Files');
end

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
resetgui(hObject, eventdata, handles, 2) 
%also reset tick boxes

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


% --- Executes on selection change in choicemenu.
function choicemenu_Callback(hObject, eventdata, handles)
% hObject    handle to choicemenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns choicemenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from choicemenu
global flag
v = get(handles.choicemenu, 'Value');
flag = v;



% --- Executes during object creation, after setting all properties.
function choicemenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to choicemenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
