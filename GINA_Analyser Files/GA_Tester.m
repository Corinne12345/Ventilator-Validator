classdef GA_Tester <handle
    properties
        filename %string name of the current file
        filedata %the data from the file
        freq
        tv
        breaths
        outfile %the table data specifically
        locsdiff
        time
        insp
        exp
        wob
        
    end
    methods
        function obj =  GA_Tester(filename, presVol_check, flow_check, pres_check)
            
            obj.filename = string(filename);            
            data = fullfile('Tests_Data', filename);
            [~,sheet_name]=xlsfinfo(data);
            obj.filedata = readtable(data,'Sheet', sheet_name{4}); %obj.filedata now contains the continuous data from GINA
                 
            %{
            file = fullfile('Tests_Results', filename); % makes the output file with all of the data from this individual test
            mkdir (file)
            %}
            
            if bpb_check == 1
                bpb_analyser(obj);
            end
            
            if presVol_check == 1
                presVol_plotter(obj);
            end
            
            if flow_check == 1
                flow_plotter(obj)
            end
            
            if pres_check == 1
                pres_plotter(obj)
            end
            
        end
        
        function bpb_analyser(obj)  %makes the data table
            %run methods 
            freqfinder(obj);
            tidalfinder(obj);
            inspexptime(obj);
            
            tv = size(obj.tv)
            
            %make the outfile
            x = zeros(obj.breaths, 8);              
            header = {'TestCode', 'Breath', 'Tidal_Volume', 'Insp_Time', 'Exp_Time', 'P_max', 'P_min', 'P_ave'};
            out = [header; num2cell(x)];
            
            %add in the testcode and breath count (based on wob)
            j = 1;
            for i = 2:obj.breaths +1
                out{i,1} = obj.filename;
                out{i, 2} = j;
                j = j+1;
            end 
            
             out =  size(out)
            insp = size(obj.insp)
            
            %Populate with data
             for i = 2:obj.breaths
                out{i, 3} = obj.tv(i); % tidal volume dat             
                out{i, 4} = obj.insp(i); %inspiratory times
                out{i,5} = obj.exp(i); %expiratory times
             end
            
                        
            %pmax
            
            %pmin
            
            %pave
            
            
            
        end
        
        function freqfinder(obj)
            % Take file, run peak analysis, count peaks/time            
            
            w = table2array(obj.filedata(:,9)); %chX, must be set as WOB
            t = table2array(obj.filedata(:,1));            
            %timeInterval = round(((time{length(time)} - time{1})/60), 2); %Time of data collection in minutes            
            
            [~, locs] = findpeaks(w, t);
            
                               
            obj.locsdiff = zeros(1, length(locs)-1);
            
            for i = 1:(length(locs)-1)
                obj.locsdiff(1, i) = (locs(i+1) - locs(i)); % gives the peak to peak length
            end
            
            wavelength = mean(obj.locsdiff);
            obj.wob = w;
            obj.time = t;
            obj.freq = 1/wavelength; 
            obj.breaths = length(obj.locsdiff);
            
            
        end
        
        function tidalfinder(obj)
            vol = table2array(obj.filedata(:,7));
            
            %m = max(vol);           
            
            [pks, ~] = findpeaks(vol, obj.time); %'MinPeakProminence', m/2
            len = length(pks)
            pks(len) = [];
            obj.tv = pks;
        end
        
        function inspexptime(obj)
            startinsp = 0;
            for j = 1:length(obj.locsdiff)  %cycle through the peaks
                for i = 1:length(obj.time) %cycle through time increments
                      timecounter = obj.time(i);
                      % for a time period between timecounter and locsdiff(i),
                      % if WOB > 0, then insp has begun
                      if timecounter < obj.locsdiff(j) %ie, if the current time < the upcoming peak
                          for k = 2:length(obj.wob)
                              if obj.wob(k) ~= 0
                                  startinsp = timecounter;
                              end
                          end
                      end
                end
                obj.insp(j) = obj.locsdiff(j) - startinsp;
                if j == 1
                    obj.exp(j) = startinsp;
                else
                obj.exp(i) = startinsp - obj.locsdiff(j-1);
                end
            end
                                  
              
              
              
        end
        
        
        function presVol_plotter(obj)
        end
        
        function presVol_plotAnalysis(obj)
        end            
        
        function flow_plotter(obj)
        end
        
        function pres_plotter(obj)
        end
    
    end
end

    