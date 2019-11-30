% This is the main file that calls on the data and spits the stuff out

%addpath(genpath('Validation_GUI'))


% USER DON'T TOUCH THIS

  
      
   % Global variables
  
       
         
       global nameFile;
       global errorMessage;      
       global file_lab
       global file_nalm

             
       
    
% Get data  
% FlowLab
    %Date and Time
    filename1 = fullfile('Tests_Data', file_lab);
    fid = fopen(filename1);    
        i = 1;
        while (i <= 2)
            A = fgetl(fid);
            i= i + 1;
        end
        fclose(fid);
        B = split(A,'=');
        
        T_l = datevec(datetime(B{2}));
        
     %Data        
        lab_Data = readtable(filename1, 'FileType', 'text');

        lab_Data  = removevars(lab_Data, {'FlowHigh_l_min_'});
        lab_Data.Properties.VariableNames = {'Time_lab', 'Flow_lab', 'P_diff_lab', 'Vol_tid_lab'};
        %head(lab_Data);
        for i = 1:height(lab_Data)
            %y = (-1)*lab_Data{i,2};
            z = (-1)*lab_Data{i,3};
            %lab_Data{i,2} = y;
            lab_Data{i,3} = z;
        end
        
%NALM
    %Date and Time
    filename2 = fullfile('Tests_Data', file_nalm);
    [~,sheet_name]=xlsfinfo(filename2);
    [~, text] = xlsread(filename2, sheet_name{1}, 'G2');    
    T_n = datevec(datetime(text{1,1},'InputFormat','dd/MM/yyyy h:mm:ss a'));

    %Data    
    nalm_Data = readtable(filename2,'Sheet', sheet_name{4});
    nalm_Data = removevars(nalm_Data, {'Prm', 'Palv', 'Ptr', 'Vol', 'ChX'});
    %head(nalm_Data)
    
    nalm_Data.Properties.VariableNames = {'Time_nalm', 'P_diff_nalm', 'Flow_nalm', 'Vol_tid_nalm'};
    %swap around these rows and columns to be the same as for lab_data
    nalm_Data = movevars(nalm_Data, 'P_diff_nalm', 'After', 'Flow_nalm');

%Run tests

test1 = Tester(nalm_Data, lab_Data, T_n, T_l, nameFile);
if test1.ex == 1
    uiwait(msgbox('Time interval between files can not be longer than 15s. Re-enter data and restart FileValidator'));
    %resetgui   
    return
end

if test1.valid == 0
    errorMessage = 'Validation failed';
else
    errorMessage = 'Validation passed';
end
myhandle = findobj('Tag','edit5');
set(myhandle, 'String',errorMessage);
p = peakPlotter(test1);
myhandle1 = findobj('Tag','edit6');
set(myhandle1, 'String',p);




















