
%USER DO NOT EDIT

%import global values

global file_gina %this is a horizontal cell array
global presVol_check
global flow_check
global pres_check
global add_check
global new_check

currentfolder = pwd;
global new_table % only executes if new_check ==1
    %new_table = "something.xlsx"; %for testing purposes only
    n = fullfile(currentfolder, 'GA_OutputData', new_table);
    new_table = n;
global log_file % only executes if add_check == 1
    %log_file = "pretendtest.xlsx"; %for testing only
    l = fullfile(currentfolder, 'GA_OutputData', log_file);
    log_file = l;
    
    %for testing only
    %add_check = 0;
    %new_check = 1;

%Create table to which everything will be appended
header = {'TestName','Breath', 'Tidal_Volume', 'Insp_Time_s', 'Exp_Time_s', 'P_max', 'P_min', 'P_mean'};
bigtable = cell2table(cell(0,8), 'VariableNames',header);

%This loop goes through every file selected and extracts the data into
%individual outfiles
%classname = class(file_gina)

%THE MAIN BIT
fileslist = file_gina;
%do the check here
[newfilelist,g,o] = fileslistcheck(log_file,fileslist, add_check, new_check, new_table); %namelog, fileslist, addcheck, newcheck, newtable
if isequal(newfilelist,0)
    return
end

for i = 1:length(file_gina)
fileslist = string(file_gina(i)); 
test = GA_Tester(fileslist,  presVol_check, flow_check, pres_check,g, o); %for each file 
% Take each outfile and append to a big table.
bigtable = vertcat(bigtable, test.outfile); 
end

%save the table, either concat or not 

if add_check == 1 % add to existing table %bug - this overwrites at a random point rather than adding to the end
    %tempfile = fullfile(currentfolder, 'GA_OutputData', 'temp.xlsx');
    
    T1 = readtable(log_file, 'Sheet', 1, 'ReadRowNames', false);
    %{
    header = T1.Properties.VariableNames;
    rownames = T1.Properties.RowNames;
    T2 = num2cell(table2array(T1));   
  	T3 = cell2table(T2, 'VariableNames', header, 'RowNames', rownames);
    T3 = head(T3)
    %}
    newT = vertcat(T1, bigtable);   
   
    writetable(newT, log_file);
    
    
   % T2 = readtable(tempfile);
    
    %taskkill may not be good idea as you are still using those files
    
    %!taskkill -f -im EXCEL.exe 
    
    % delete (namelog);
    
    %first check if the files we are trying to put in are already in
    
    %newT = vertcat(T1, T2);
    %writetable(newT, namelog,'Sheet', 1, 'WriteRowNames', true);
    
    %delete (tempfile); %'temp' not found for some reason
    
    
end

if new_check == 1 %create a new table with the table name 
   
   existingmatrix = readtable(new_table, 'Sheet', 1);
   [m,n] = size(existingmatrix);
   cleartable = array2table(strings(m,n));
   writetable(cleartable, new_table, 'Sheet', 1)      
   writetable(bigtable, new_table, 'Sheet', 1);
   
   
end
%{
function newfilelist = double_up_check(fileslist, addcheck, logfile, newcheck, newtable)
    if addcheck ~= 1 %if you're creating a new file, the rest is irrelevant
        newfilelist = fileslist;
        return
    end   
    newfilelist = fileslistcheck(logfile, fileslist, addcheck, newcheck, newtable);    
end
%}
fprintf("\nhooray, completed");

function [f,g,o] = fileslistcheck(namelog, fileslist, addcheck, newcheck, newtable)%adds file names to sheet 2 of the xlsx doc
    
    s = length(fileslist);
    
    %log = table('VariableNames',{'Data_Log'});
    %log(s, 1);
    log = strings(s, 1);%vertical string vector
    for i = 1:s
        %[log; fileslist(i)];
        log(i) = fileslist(i);
    end
    log = array2table(log);
    log.Properties.VariableNames = {'Data_Log'};
    
    if newcheck == 1 %means we are overriding so need to delete the existing log files
        g = 0;
        o = 0;
        if ~isfile(newtable)  
            T = cell2table(cell(0,7));
            writetable(T, newtable);
        end
        f = fileslist;
        
        fprintf("entered newcheck loop");
        
        existingmatrix = readtable(newtable, 'Sheet', 2);
        n = numel(existingmatrix);
        cleartable = array2table(strings(n,1));
        writetable(cleartable, newtable, 'Sheet', 2)
        writetable(log, newtable, 'Sheet', 2);
        
    end
    
    
    if addcheck ==1
        o = 0;
        fprintf("entered addcheck loop");
        exOpen(namelog);        
        
        %If addcheck
        existingmatrix = readtable(namelog, 'Sheet', 2); %this is from the add_table
        %size(existingmatrix)
        n = numel(existingmatrix);
    
        for i = 1:s
            for j = 1: n                  
                if isequal((log{i,1}), string(table2cell(existingmatrix(j,1))))
                    filestring = log{i,1};                    
                    m = ["The data name", filestring,"has been previously added to this file. Do you wish to add it again or skip?"];
                    message = join(m);
                    answer = questdlg(message, 'Warning', 'Add again', 'Skip', 'Skip');%send user a warning error
                    switch answer
                        case 'Add again'
                            %rename relevent filename
                            number = 1;
                            newf = '';
                            card = 0;
                            while card == 0
                                newf = join([filestring,"(", number, ")"]);
                                if isequal(newf, string(table2cell(existingmatrix(j,1))))
                                   number = number + 1;
                                else
                                    card = 1;
                                end
                            end
                             %but this doesn't actually change the file name itself, you need to do that
                            for k = 1:length(fileslist) %delete relevant filename, then add the new one
                                    if isequal(filestring, fileslist(k,1))
                                        fileslist(k,:) = [];
                                    end
                            end
                            f = fileslist; %does not vertcat because we need to read these files in
                            l = height(log);
                            log{l, :} = filestring; %put a string in this cell                           
                            g = newf;
                            o = filestring;
                        case 'Skip'
                            if isequal(length(fileslist),1) %ie, if there's only one file selected anyway 
                                dlg('Process has been quit as there are no new files to add');
                                f = 0;
                                g = 0;
                            else %delete the relevant file name
                                for k = 1:length(fileslist)
                                    if isequal(filestring, fileslist(k,1))
                                        fileslist(k,:) = [];
                                    end
                                end
                                f = fileslist;
                                g = 0;
                            end 

                    end

                else
                    f = fileslist;
                    g = 0;
                end

            end
        end  
        %now add those names in fileslist (unless it's 0) to the existing table
        %on the spreadsheet 2
        t  = vertcat(existingmatrix, log);
       
        writetable(t, namelog, 'Sheet', 2);
    end
    
end









