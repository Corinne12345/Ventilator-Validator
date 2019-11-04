function out = filegetter(handles, filestring, filename, setfile, releventhandle) %checks that a file has been selected
    if filestring ~= '0'  
        out = setfile;
        return
    else
    % set a question
    answer = questdlg('You must select one file. Click "Select File", or "Cancel" to exit.', 'Choose a file', 'Select File', 'Cancel', 'Select File');
    
    switch answer
        case 'Select File'
            setfile = uigetfile({filename}, 'File Selector');
            set(releventhandle,'String', setfile);
            next = get(releventhandle, 'String');
            out = filegetter(handles, next, filename, setfile, releventhandle);
        case 'Cancel'
            out = '0'; 
    end
    end