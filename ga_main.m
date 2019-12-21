
% GA_MAIN MATLAB CODE
%       This file ga_main is called by GA_Analyser when 'GO' is selected on
%       the GINA_ANALYSER GUI. In this file, data from GA_TestData is sent
%       to undergo analysis in GA_Tester. Output is arranged into a table,
%       saved in GA_Output folder as an xlsx doc. This output file will be
%       named according to GINA_ANALYSER GUI selection to 'add data to
%       existing table' or 'create new table' and will be named according
%       to the users chosen file name. GA_TestData and GA_OutputData are
%       saved in the same directory as all MATLAB files.

fprintf('Entered main')

% ---Imports global values and sets up full file formatting for new_table
% and add_table
global file_gina 
global add_check
global new_check
global flag
    if isempty(flag) %if no selection made, set automatic to be flag = 2
        flag = 2;
    end
currentfolder = pwd;
global new_table % only executes if new_check ==1   
    
    n = fullfile(currentfolder, 'GA_OutputData', new_table);
    new_table = n;
global add_table % only executes if add_check == 1 
    
    l = fullfile(currentfolder, 'GA_OutputData', add_table);
    add_table = l;
global spontcheck
    
    

% --- Creates bigtable to which all post-analysed data is appended
header = {'TestName','Breath', 'Tidal_Volume','Piston_Volume', ...
    'Insp_Time_s', 'Exp_Time_s', 'Py_max', 'Py_min', 'Py_mean',...
    'Ptr_max', 'Ptr_min', 'Ptr_mean', 'Palv_max', 'Palv_min', 'Palv_mean'};
bigtable = cell2table(cell(0,15), 'VariableNames',header);



% --- Catches error of the input file already having been saved to the
% excel file previously. See fileslistcheck function.
fileslist = file_gina;
[newfilelist,g,o] = fileslistcheck(add_table,fileslist, add_check, ...
    new_check, new_table); 
if isequal(newfilelist,0)
    return
end



% --- For each input file selection, run GA_Tester Analysis and append to
% bigtable
for i = 1:length(file_gina)
fileslist = string(file_gina(i)); 
test = GA_Tester(fileslist, g, o, flag, spontcheck); %Analysis 
bigtable = vertcat(bigtable, test.outfile); %Table appending
% Data rounding to 2dp (can be commented out if total accuracy required)
    bigtable.Tidal_Volume = round(bigtable.Tidal_Volume, 2);
    bigtable.Piston_Volume = round(bigtable.Piston_Volume, 2);
    bigtable.Insp_Time_s = round(bigtable.Insp_Time_s, 2);
    bigtable.Exp_Time_s = round(bigtable.Exp_Time_s, 2);
    bigtable.Py_max = round(bigtable.Py_max, 2);
    bigtable.Py_min = round(bigtable.Py_min, 2);
    bigtable.Py_mean = round(bigtable.Py_mean, 2);
    bigtable.Ptr_max = round(bigtable.Ptr_max, 2);
    bigtable.Ptr_min = round(bigtable.Ptr_min, 2);
    bigtable.Ptr_mean = round(bigtable.Ptr_mean, 2);
    bigtable.Palv_max = round(bigtable.Palv_max, 2);
    bigtable.Palv_min = round(bigtable.Palv_min, 2);
    bigtable.Palv_mean = round(bigtable.Palv_mean, 2);
end



% --- If 'Add data...' box checked in GUI, appends bigtable to existing
% table
if add_check == 1     
    T1 = readtable(add_table, 'Sheet', 1, 'ReadRowNames', false);    
    newT = vertcat(T1, bigtable);      
    writetable(newT, add_table);   
    
end

% --- If 'Create new table' box checked in GUI, creates table and
% overwrites any past data in file
if new_check == 1 
   existingmatrix = readtable(new_table, 'Sheet', 1);
   [m,n] = size(existingmatrix);
   cleartable = array2table(strings(m,n));
   writetable(cleartable, new_table, 'Sheet', 1)      
   writetable(bigtable, new_table, 'Sheet', 1);
   
   
end

% --- Executes if no errors, informs user that analysis is complete


msgbox("Analysis completed");


% --- This function creates logs added input files to the second sheet of
% the output xlsx file. If a the user attempts to add a file that has
% already been added (or that has an identical name), user is prompted to
% choose to add file again or not.
function [f,g,o] = fileslistcheck(addtable, fileslist, addcheck, ...
    newcheck, newtable)
    s = length(fileslist);   
    log = strings(s, 1);
    
    for i = 1:s
       log(i) = fileslist(i);
    end
    
    log = array2table(log);
    log.Properties.VariableNames = {'Data_Log'};
    
    if newcheck == 1 %means we are overriding so need to delete the ...
        % existing log files
        g = 0;
        o = 0;
        if ~isfile(newtable)  
            T = cell2table(cell(0,7));
            writetable(T, newtable);
        end
        f = fileslist;       
        existingmatrix = readtable(newtable, 'Sheet', 2);
        n = numel(existingmatrix);
        cleartable = array2table(strings(n,1));
        writetable(cleartable, newtable, 'Sheet', 2);
        writetable(log, newtable, 'Sheet', 2);        
    end
    
    
    if addcheck ==1 %check for file previously added
        o = 0;       
        exOpen(addtable);        
        existingmatrix = readtable(addtable, 'Sheet', 2);        
        n = numel(existingmatrix);
    
        for i = 1:s
            for j = 1: n                  
                if isequal((log{i,1}), string(table2cell...
                        (existingmatrix(j,1))))
                    filestring = log{i,1};                    
                    m = ["The data name", filestring,...
                        "has been previously added to this file.",... 
                        "Do you wish to add it again or skip?"];
                    message = join(m);
                    answer = questdlg(message, 'Warning', 'Add again',...
                        'Skip', 'Skip');%send user a warning error
                    
                    switch answer %user prompted to answer                        
                        case 'Add again'                            
                            number = 1;
                            newf = '';
                            card = 0;
                            
                            while card == 0
                                newf = join([filestring,"(", number, ")"]);
                                if isequal(newf, string(table2cell...
                                        (existingmatrix(j,1))))
                                   number = number + 1;
                                else
                                    card = 1;
                                end
                            end
                             
                            for k = 1:length(fileslist) 
                                    if isequal(filestring, fileslist(k,1))
                                        fileslist(k,:) = [];
                                    end
                            end
                            
                            f = fileslist;
                            l = height(log);
                            log{l, :} = filestring;                           
                            g = newf;
                            o = filestring;
                            
                        case 'Skip'
                            if isequal(length(fileslist),1) %if there's ...
                                % only one file selected and user ...
                                % chooses to not re-add
                                dlg('Process quit as there are no new files to add');
                                f = 0;
                                g = 0;
                            else %delete the relevant file name from ...
                                %files to be analysed in GA_Tester,...
                                % prevents analysis
                                for k = 1:length(fileslist)
                                    if isequal(filestring, fileslist(k,1))
                                        fileslist(k,:) = [];
                                    end
                                end
                                f = fileslist;
                                g = 0;
                            end 
                    end

                else %if file is not already on the log
                    f = fileslist;
                    g = 0;
                end

            end
        end  
        
        %add new file names to log
        t  = vertcat(existingmatrix, log);       
        writetable(t, addtable, 'Sheet', 2);
    end
    
end