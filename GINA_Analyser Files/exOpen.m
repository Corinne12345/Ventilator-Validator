%test if an excel file is already open

function exOpen(logfile)
    fprintf("\nentered exOpen");
%This code is not my own, from https://au.mathworks.com/matlabcentral/answers/93885-how-can-i-determine-if-an-xls-file-is-open-in-microsoft-excel-without-using-dde-commands-using-mat
    ex = actxGetRunningServer('Excel.Application');
        
    if exist('ex','var')
        fprintf("\nentered if");
        %Get the names of all open Excel files
        wbs = ex.Workbooks
        wbs.Count
       %List the entire path of all excel workbooks that are currently open
        for i = 1:wbs.Count
            fprintf("\nentered for");
            logfile %for testing
            a = string(wbs.Item(i).FullName); %put ";" when testing is over
            class(a);
            if isequal(a, logfile) %this part is mine
                %prompt user to save and close
                [~,name, ext] = fileparts(logfile);
                filename = strcat(name, ext);
                message = join(["Please save and close the file", filename, ", then select OK" ]); 
                waitfor(warndlg(message));
                exOpen(logfile);            
            end
        end
    end
end