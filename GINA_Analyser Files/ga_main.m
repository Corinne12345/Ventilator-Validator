
%USER DO NOT EDIT

%import global values

global file_gina %this is a horizontal cell array
global presVol_check
global flow_check
global pres_check
global add_check
global new_check

%Create table to which everything will be appended
x = zeros(1, 8);              
header = {'TestCode','Breath', 'Tidal_Volume', 'Insp_Time', 'Exp_Time', 'P_max', 'P_min', 'P_ave'};
bigtable = [header; num2cell(x)];

%This loop goes through every file selected and extracts the data into
%individual outfiles
classname = class(file_gina);
for i = 1:length(file_gina)
    if classname == 'cell'
        dataname = string(file_gina(i));   %for each file 
    else
        dataname = string(file_gina);
    end
    test = GA_Tester(dataname,  presVol_check, flow_check, pres_check); 
    % Take each outfile and append to a big table.
    bigtable = vertcat(bigtable, test.outfile);  
   
end

%Take big table and depending on add_check and new_check, save






