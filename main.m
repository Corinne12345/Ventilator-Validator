% This is the main file that calls on the data and spits the stuff out
close all
clear;
clc;

% USER DON'T TOUCH THIS

    % Import the data.    
   a_vent = readtable('b_vent.xlsx', 'Range', 'A1:C60001');
   head(a_vent, 100)
   %b_vent = readtable('b_vent.xlsx', 'Range', 'A1:C60001'); 
     
   %FileValidator;
   
   % Global variables
   global file_nalm;
   global file_lab;
   global f;
   global flow_check;
   global pressure_check;
   global vol_check;
   global peep_check;
   global peak_check;
   global infantData;
   global presVol;
      
   period = 1/f(1,1);          


% Get the timestamps
    %nalm:
    [~,sheet_name]=xlsfinfo(file_nalm);
    [~, text] = xlsread(file_nalm, sheet_name{1}, 'G2');
    T_n = datevec(datetime(text{1,1},'InputFormat','dd/MM/yyyy h:mm:ss a'));
       
    %flow:    
    fid = fopen(file_lab);
    %dl = fscanf(fid, '%s');
    i = 1;
    while (i <= 2)
        A = fgetl(fid);
        i= i + 1;
    end
    fclose(fid);
    B = split(A,'=');
    T_l = datevec(datetime(B{2}));
    

% Get data   

lab_Data = readtable(file_lab, 'FileType', 'text');
lab_Data  = removevars(lab_Data, {'FlowHigh_l_min_'});
lab_Data.Properties.VariableNames = {'Time_lab', 'Flow_lab', 'P_diff_lab', 'Vol_tid_lab'};
%head(lab_Data);
for i = 1:height(lab_Data)
    %y = (-1)*lab_Data{i,2};
    z = (-1)*lab_Data{i,3};
    %lab_Data{i,2} = y;
    lab_Data{i,3} = z;
end


nalm_Data = readtable(file_nalm,'Sheet', sheet_name{4});


nalm_Data = removevars(nalm_Data, {'Prm', 'Palv', 'Ptr', 'Vol', 'ChX'});
nalm_Data.Properties.VariableNames = {'Time_nalm', 'P_diff_nalm', 'Flow_nalm', 'Vol_tid_nalm'};
%swap around these rows and columns to be the same as for lab_data
nalm_Data = movevars(nalm_Data, 'P_diff_nalm', 'After', 'Flow_nalm');

%Run tests

test1 = Tester(nalm_Data, lab_Data, T_n, T_l, period);
if flow_check == 1
    %run flow function
    flowPlotter(test1);
end
if pressure_check == 1
    pressurePlotter(test1)
end
if vol_check ==1
    volumePlotter(test1)
end
if peep_check == 1
    peepPlotter(test1)
end
if infantData ==1
    infantDataCollector(test1, a_vent)
end
if peak_check ==1
    peakPlotter(test1, infantData)
end

if presVol == 1
    pressVolCurve(test1, infantData)
end

















