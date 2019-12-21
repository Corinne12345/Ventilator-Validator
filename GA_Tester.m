% GA_TESTER MATLAB CODE
%       This file GA_Tester runs signal analysis on the continuous data
%       provided by the GINA. It determines where breaths start and end and
%       then calculates outputs breath by breath quantities for inspiration
%       and expiration times, volumes and pressures.


classdef GA_Tester <handle
    properties 
        filename % string name of the current input file
        filedata % the data from the file        
        outfile % the table data specifically        
        breaths % number of breaths determined        
        time % array of signal sample time
        insp % array of time (s) for inspirations
        exp % array of time (s) for expirations
        wob %Work of Breathing signal
        tv % array of tidal volume per breath
        tvol % array of max piston volume per breath (air moved + dead vol)
        flow % array of signal sample flow
        locs % array of location of peaks (WOB) or negative flow start (flow)
        pres %pressure signal from t piece
        pres_max % array of max pressure per breath at y piece
        presA_max % array of max pressure per breath at alveoli
        presT_max % array of max pressure per breath at trachea
        pres_min % array of min pressure per breath at y piece
        presA_min % array of min pressure per breath at alveoli
        presT_min % array of min pressure per breath at trachea
        p_ave % array of average pressure per breath at y piece
        pA_ave % array of average pressure per breath at alveoli
        pT_ave % array of average pressure per breath at trachea
        g % Not used in current version, used if different row names per breath wanted
        o % Not used in current version, used if different row names per breath wanted
        insp_func
        breathstart
        breathend
        peaks
        locsdiff %peak-to-peak difference for WOB
        startinsp
        startinsp_y
        freq % a gross approximation of frequency, used for peak finder functions
        spontcheck
    end
    
    methods
        %--- Initialisation function for the class
        function obj =  GA_Tester(filename, g, o, flag, spontcheck)           
            obj.filename = string(filename);             
            currentFolder = pwd;
            data = char(fullfile(currentFolder, 'GA_TestData', filename));
            
            [~,sheet_name]=xlsfinfo(data);
            obj.filedata = readtable(data,'Sheet', sheet_name{4}); 
            %obj.filedata now contains the continuous data from GINA
            obj.g = g; 
            obj.o = o;     
            obj.spontcheck = spontcheck;
            
            bpb_analyser(obj,flag); %call to bpb_analyser 
        end
        
        %--- bpb_analyser function calls all functions to make
        %calculations, creates and populates output table
        function bpb_analyser(obj, flag)  %makes the data table
            try
                alreadySaved = 0;
                
                freqfinder(obj, flag);
                inspexptime(obj,flag);
                tidalfinder(obj, 1);
                tidalfinder(obj, 2);
                pressure_data(obj, 1);
                pressure_data(obj, 2);
                pressure_data(obj, 3);
                
                length(obj.p_ave)
                
                %save figures
                if flag == 1
                    indicator = '_WOB';
                else
                    indicator = '_Flow';
                end
                fname = join([obj.filename,indicator]);
                folderName = fullfile(pwd, fname) ;   % Your destination folder
                mkdir(folderName)
                FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
                for iFig = 1:length(FigList)
                    FigHandle = FigList(iFig);
                    FigName   = num2str(get(FigHandle, 'Number'));
                    set(0, 'CurrentFigure', FigHandle);
                    savefig(fullfile(folderName, [FigName '.fig']));
                end
                
                alreadySaved = 1;
                
                %make the table
                header = {'TestName','Breath', 'Tidal_Volume',...
                'Piston_Volume', 'Insp_Time_s', 'Exp_Time_s', 'Py_max',...
                'Py_min', 'Py_mean', 'Ptr_max', 'Ptr_min', 'Ptr_mean',...
                'Palv_max', 'Palv_min', 'Palv_mean'};
                [~, name, ~] = fileparts(obj.filename);
                %{
                % Not used in current version, used if seperate row names per
                breath wanted. Need to use matlab rownames function for this
                functionality if isequal(name,obj.o) name = obj.g; end
                %}           
                rownames = cell([obj.breaths,1]); %make a cellular string array
                    % of this size
                size(rownames);
                for i = 1:obj.breaths               
                    rownames{i} = char(name); 
                        % + i, if separate names per row wanted
                end 

                out = zeros(obj.breaths, 15); 
            
                      
                %Populate table with data
                 for i = 1:obj.breaths                
                    out(i, 2) = i; 
                    out(i, 3) = obj.tv(i); % tidal volume dat 
                    out(i,4) = obj.tvol(i);
                    out(i, 5) = obj.insp(i); %inspiratory times
                    out(i,6) = obj.exp(i);                
                    out(i,7) = obj.pres_max(i); %max diff pressures
                    out(i,8) = obj.pres_min(i); %min diff pressures
                    out(i,9) = obj.p_ave{i};
                    out(i,10) = obj.presA_max(i);
                    out(i,11) = obj.presA_min(i);
                    out(i,12) = obj.pA_ave{i};
                    out(i,13) = obj.presT_max(i);
                    out(i,14) = obj.presT_min(i);
                    out(i,15) = obj.pT_ave{i};                
                 end
             
                 %Delete last row if final breath was not a full breath
                 %(determined based on expiration start locations and pressure
                 %data
                 while out(length(out), 6) == 0 
                    out(length(out), :) = [];
                    rownames(length(out)) = [];
                 end
                 while out(length(out), 9) == 200
                     out(length(out), :) = [];
                     rownames(length(out)) = [];
                 end
                 while out(length(out), 3) ==0
                     out(length(out), :) = [];
                     rownames(length(out)) = [];
                 end

                 k =  array2table(out, 'VariableNames', header);
                 k.TestName = rownames; 

                 obj.outfile = k;
             
                 %Plotting thew WOB vs time and FREQ vs time of 10 min
                 %functions to identify misidentified breaths
                 %{
                 if flag == 1
                     obj.flow = table2array(obj.filedata(:,6)); 
                     figure('NumberTitle', 'off', 'Name', 'Identifying misidentified breaths over 10 minute GINA recording')

                         subplot(2,2,1);
                         plot(obj.time, obj.wob)
                         xlabel('Time (s)');
                         ylabel('Work of Breathing (J)');
                         title('Identifying incorrect WOB calculations');

                         subplot(2,2,2);
                         plot(obj.time, obj.tvol);
                         xlabel('Time (s)');
                         ylabel('Piston volume (ml)');
                         title('Identifying morphological errors in volume signal');


                         subplot(2,2,3);
                         plot(obj.time, obj.pres);
                         xlabel('Time (s)');
                         ylabel('Pressure at Y piece (atm)');
                         title('Identifying morphological errors in pressure signal');

                         subplot(2,2,4);
                         plot(obj.time, obj.flow);
                         xlabel('Time (s)');
                         ylabel('Flow (l/min)');
                         title('Identifying morphological errors in flow signal');
                         grid

                 end
                 %}
           
            catch e
                fprintf(e.identifier);
                fprintf(e.message);
                fprintf('\n');
                str = join(['An error occured. Most likely, your data in file ', obj.filename, ' is too random for this version of GINA_ANALYSER']);
                warndlg(str);
                if alreadySaved ~=1
                    %saving figures
                    if flag == 1
                        indicator = '_WOB';
                    else
                        indicator = '_Flow';
                    end
                    fname = join([obj.filename,indicator]);
                    folderName = fullfile(pwd, fname) ;
                    %folderName = fullfile(pwd, obj.filename) ;   % Your destination folder
                    mkdir(folderName)
                    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
                    for iFig = 1:length(FigList)
                        FigHandle = FigList(iFig);
                        FigName   = num2str(get(FigHandle, 'Number'));
                        set(0, 'CurrentFigure', FigHandle);
                        savefig(fullfile(folderName, [FigName '.fig']));
                    end
                end
                
            end
                 
                 
             
        end
           
        
        %--- freqfinder function determines number of breaths
        function freqfinder(obj, flag)
            
            %calculation using WOB, channel X
            if flag ==1
            % Take file, run peak analysis, count peaks/time,  then get
            % location of peaks
                obj.wob  = table2array(obj.filedata(:,9));
                
                %if wob does not start at a 0 point (ie starts during a
                %breath), delete til 0 point
                counter = 0;
                for i = 1:length(obj.wob)
                    if obj.wob(i) ~= 0
                        counter = counter+1;
                    else
                        break
                    end
                end
                
                for i = 1:counter
                    obj.filedata(1,:) = [];
                end
                
                %reset wob and time properties
                obj.wob  = table2array(obj.filedata(:,9));
                obj.time = table2array(obj.filedata(:,1));   
                
                %find peaks of WOB. Peak determines end of inhalation,
                %start of exhalation. If WOB data > 0, inhalation.
                m = max(obj.wob);            
                [obj.peaks, obj.locs] = findpeaks(obj.wob, obj.time,...
                    'MinPeakProminence', m/2);           
                obj.locsdiff = zeros(1, length(obj.locs)-1);

                for i = 1:(length(obj.locs)-1)
                    obj.locsdiff(1, i) = (obj.locs(i+1) - obj.locs(i)); 
                        % gives the peak to peak length
                end

                obj.breaths = length(obj.locsdiff); %number of full breaths
                obj.freq = obj.breaths/obj.time(length(obj.time));
               
            end
            
            %calculation using flow
            if flag ==2
                f = table2array(obj.filedata(:,6)); %flow
                t = table2array(obj.filedata(:,1)); %time
                %Butterworth filter design to smooth noise around
                %inflection point in flow signal.
                
                if obj.spontcheck == 1
                
                    n = 3;
                    Wn = 20/(2000/2);
                    [b,a] = butter(n,Wn, 'low');
                    fil_flow  = filtfilt(b,a,f); % applies filter and fixes phase shift issues.
                    str = 'Butterworth';
                else
                    fil_flow = lowpass(f, 0.0001);
                    str = 'Lowpass';
                end
                
                
                % TESTING PURPOSES
                %name = join([obj.filename, '_flowfilt']);
                figure(1)
                 
                plot(t,f); 
                title('Time domain filtering')
                hold on
                plot(t, fil_flow) 
                newstr = join(['Filtered :', str]);
                legend('Unfiltered', newstr);
                hold off 
                grid
                
                
                %now, every time the signal goes from negative to positive,
                %a breath has started.                
                %replace flow signal with filtered signal
                for i = 1:length(f)
                    obj.filedata{i,6} = fil_flow(i);
                end
                
                %delete data up to first breath
                counter = 0;
                for i = 1:length(fil_flow)
                    if fil_flow(i) < 0  || (fil_flow(i+1)-fil_flow(i))/(t(i+1) - t(i)) < 1
                        counter = counter + 1;
                    else 
                        break
                    end
                end
                height(obj.filedata)
                %name = join([obj.filename, '_chop']);
                figure(2)
                plot(t, fil_flow, '-b', t(counter), fil_flow(counter), 'or')
                title('Identifying Signal Start');
                xlabel('Time (s)');
                ylabel('Filtered Flow (l/min)');
                legend('Filtered Flow', 'Start point');
                grid
                
                i = 1;
                while i < counter
                    obj.filedata(1, :) = [];
                    i = i+1;
                end
                
                height(obj.filedata)
                 
                
                %reset flow and time properties
                obj.flow = table2array(obj.filedata(:,6));
                obj.time = table2array(obj.filedata(:,1));
                
                length(obj.flow)
                length(obj.time)
                
                %name = join([obj.filename, '_trim']);
                figure(3)
                plot(obj.time, obj.flow);
                title('Did flow trim?')
                grid
                
                
                %breaths will now be equal to number of expirations (flow
                %from positive to negative)
                b = 0;                
                for i = i:length(obj.flow)-1
                    if obj.flow(i) >= 0 && obj.flow(i+1) <=0
                        b = b+1;                        
                    end
                end
                
                obj.breaths = b;
                %breaths = b
            end            
            
           
        end
        
        
        %--- function inspexptime calculates the time in seconds of each
        %inspiration and expiration per breath
        function inspexptime(obj, flag)
            
            %case of using WOB for breaths
            if flag  == 1
                      
                for j = 1:length(obj.locs)  %cycle through the peaks
                     
                    counter = 0; %reset counter. If counter == 1, an 
                        % inspiration start time has been recorded so we 
                        % need to cycle on to the next breath
                    while counter == 0
                        for i = 1:length(obj.time) %cycle through time 
                            % increments
                          timecounter = obj.time(i);
                          % for a time period between timecounter and
                          % locsdiff(i), if WOB > 0, then insp has begun
                              if timecounter < obj.locs(j) && (j == 1 || ...
                                      (timecounter > obj.locs(j-1))) 
                                        %ie, if the current time < the upcoming peak 
                                  if obj.wob(i) ~= 0 && obj.wob(i) >0
                                      counter = 1;  
                                      obj.startinsp(j) = timecounter; %time
                                        %stamp that this inspiration starts
                                      break
                                  end                                      
                                  
                                  if counter == 1
                                      break
                                  end
                                  
                              end

                        end                     
                    end
                     
                    obj.insp(j) = obj.locs(j) - obj.startinsp(j); 
                        %inspiration time equals time stamp of expiration 
                        % start minus time stamp of inspiration start
                    
                  if j>1
                    obj.exp(j-1) = obj.startinsp(j) - obj.locs(j-1); 
                        % expiration time equals time stamp of next 
                        % insp start minus time stamp of exp start
                  end
                end
                
                %change time beginning back to zero and adjust all time
                %samples
                start_t = obj.filedata{1,1};
                for i = 1:height(obj.filedata)
                    new_t = obj.filedata{i,1} - start_t;
                    obj.filedata{i, 1} = new_t;
                end                
                
                obj.time = table2array(obj.filedata(:,1));
                
                %reset startinsp times
                obj.wob = table2array(obj.filedata(:,9));                
                m = max(obj.wob);            
                [obj.peaks, obj.locs] = findpeaks(obj.wob, obj.time,...
                    'MinPeakProminence', m/2); %find location of WOB peaks
                               
                for i = 1:length(obj.startinsp)
                    obj.startinsp(i) = obj.startinsp(i) - start_t;
                end   
                
                for i = 1:length(obj.startinsp)
                    for j = 1:length(obj.time) 
                        if obj.time(j) == obj.startinsp(i)
                            obj.startinsp_y(i) = obj.wob(j);
                        end
                    end
                end
                
                figure()
                 title('Detection of spontaneous breaths') 
                 x = obj.time; 
                 y = obj.wob; 
                 plot(x,y) 
                 hold on 
                 plot(obj.locs, obj.peaks, 'og');
                 hold on
                 plot(obj.startinsp, obj.startinsp_y, 'or');
                 legend('WOB', 'Exp. start', 'Insp. start');
                 hold off
                               
            end     
            
            
            % case of using Flow for breaths
            if flag ==2  
                %finds timestamps of where inspirations start and whre
                %expirations start
                obj.breaths
                for i = 1:obj.breaths
                    for j = 1:length(obj.time) - 1
                        %inspirations
                        if i== 1&& obj.flow(j) <=0 && obj.flow(j+1) >=0
                            obj.startinsp(i) = obj.time(j+1);
                        elseif obj.flow(j) <=0 && obj.flow(j+1) >=0 &&...
                                obj.time(j) > obj.startinsp(i-1)
                            obj.startinsp(i) = obj.time(j+1);
                        end
                        %expirations
                        if i==1 && obj.flow(j)>=0 && obj.flow(j+1) <=0
                            obj.locs(i) = obj.time(j+1);
                            break
                        elseif obj.flow(j)>=0 && obj.flow(j+1) <=0 && ...
                                obj.time(j) > obj.locs(i-1)
                            obj.locs(i) = obj.time(j+1);
                            break
                        end
                    end
                    
                   %time calculations for inspirations and expirations per
                   %breath
                    obj.insp(i) = obj.locs(i) - obj.startinsp(i);                     
                    if i>1
                        obj.exp(i-1) = obj.startinsp(i) - obj.locs(i-1);
                        if i == obj.breaths
                            obj.exp(i) = 0; %this means the last breath is 
                                % incomplete, row deleted in bpb_analyser
                        end
                    end                    
                end                
                
                %change time start back to zero and adjust time stamps
                start_t = obj.filedata{1,1};
                for i = 1:height(obj.filedata)
                    new_t = obj.filedata{i,1} - start_t;
                    obj.filedata{i, 1} = new_t;
                end                
                
                obj.time = table2array(obj.filedata(:,1));            
                                
                for i = 1:length(obj.startinsp)
                    obj.startinsp(i) = obj.startinsp(i) - start_t;
                    if length(obj.locs) == length(obj.startinsp)
                        obj.locs(i) = obj.locs(i) - start_t;
                    elseif i < length(obj.startinsp)
                        obj.locs(i) = obj.locs(i) - start_t;
                    end
                end
                
                %TESTING PURPOSES ONLY
                
                %locsposition used for testing where breaths end on a plot
                
                locspos = zeros(1, obj.breaths);
                lengthoflocs = length(obj.locs)
                for i = 1:length(obj.locs) 
                    for j = 1:length(obj.time)
                        
                        if i ==1 && obj.locs(i) == obj.time(j) 
                            locspos(i) = obj.time(j); 
                            locsflow(i) = obj.flow(j); 
                            break 
                        end
                            
                        if i > 1 && obj.locs(i) == obj.time(j) && obj.time(j) >locspos(i-1) 
                            locspos(i) = obj.time(j); 
                            locsflow(i) = obj.flow(j); 
                        end
                        
                    end
                end
                
                for i = 1:length(obj.startinsp) 
                    for j = 1:length(obj.time)
                        
                        if i ==1 && obj.startinsp(i) == obj.time(j) 
                            startpos(i) = obj.time(j); 
                            startflow(i) = obj.flow(j); 
                            break 
                        end
                            
                        if i > 1 && obj.startinsp(i) == obj.time(j) && obj.time(j) >startpos(i-1) 
                            startpos(i) = obj.time(j); 
                            startflow(i) = obj.flow(j); 
                        end
                        
                    end
                end
                
                %here
                
                %name = join([obj.filename, '_flow_detect']);
                figure(4)
                plot(obj.time, obj.flow); 
                hold on 
                plot(obj.locs, locsflow, 'og', obj.startinsp, startflow, 'or' ); %this is where breaths end and start
                legend('Flow (l/min)','Start Exp','Start Insp')
                title('Breath Detection using Flow Signal')
                xlabel('Time (s)')
                ylabel('Flow (l/min)')
                hold off
                grid
                            
                
            end  
            obj.freq = obj.breaths/obj.time(length(obj.time));
        end
        
        
        %--- function tidalfinder calculates peak volumes off volume
        %signals
        function tidalfinder(obj, tnum)
            if tnum ==1
                vol = table2array(obj.filedata(:,7));
                m = max(vol);           
                [pks, lcs] = findpeaks(vol, obj.time,'MinPeakProminence',...
                    m/2); 
                
                %name = join([obj.filename, '_tidal_detect']);
                figure(5)
                plot(obj.time, vol, '-b', lcs, pks, 'or')
                title('Tidal Volume signal peak recognition')
                xlabel('Time (s)')
                ylabel('Volume (ml)')
                legend('Volume signal', 'peak detection');
                grid
                
                while length(pks) >obj.breaths
                    pks(length(pks)) = [];
                end
                while length(pks) < obj.breaths
                    pks(length(pks)+1) = 0;
                end
                obj.tv = pks;
                %teevee = length(obj.tv);
            elseif tnum == 2                
                vol = table2array(obj.filedata(:,8));  
                m = max(vol);
                [pks, lcs] = findpeaks(vol, obj.time,'MinPeakHeight',...
                    m/2, 'MinPeakDistance', (1/obj.freq)*2/3);
                
                
                    
                %name = join([obj.filename, '_piston_detect']);
                figure(6)
                plot(obj.time, vol, '-b', lcs, pks, 'or')
                title('Piston Volume signal peak recognition')
                xlabel('Time (s)')
                ylabel('Volume (ml)')
                legend('Volume signal', 'peak detection');
                grid
                
                while length(pks)>obj.breaths
                    pks(length(pks)) =[];
                end
                while length(pks) < obj.breaths
                    pks(length(pks)+1) = 0;
                end
                obj.tvol = pks;
                %teevol = length(obj.tvol);
            end 
            
        end
        
        
        % --- function pressure_data calculates max, min and average
        % pressures
        function pressure_data(obj, pnum)
            
                % Pressure signal selection
                if pnum ==1 %py
                    p = table2array(obj.filedata(:,3));  
                    obj.pres = p;
                     
                elseif pnum ==2 %Palv
                    p = table2array(obj.filedata(:,4)); 
                elseif pnum ==3 %Ptr
                    p = table2array(obj.filedata(:,5)); 
                end
                
                
                t = obj.time;  
                %filter the signal p to remove noise
                %{
                [b,a] = butter(3, 20/2000/2, 'low'); 
                filtp = filtfilt(b,a,p);
                
                figure
                plot(t, p, '-b', t, filtp, '-r')
                legend('Unfiltered', 'Filtered')
                title('Butterworth filter on Pressure signal')
                xlabel('Time (s)')
                ylabel('Pressure (atm)')
                grid
                %}
                %{
                [up, low] = envelope(p, 40, 'peaks');
                figure()
                plot(t,p, '-b', t, up, '-g', t,low, '-m');
                legend('Pressure signal', 'Upper envelope', 'Lower Envelope');
                xlabel('Time (s)')
                ylabel('Pressure (atm)')
                grid
                %}
                
                
                z = lowpass(p, 0.0001);
                t_test = t;
                %trim the first 5 and last 5 data points because of the
                %filter overshoot
                counter = 0;
                while counter < 10
                        z(1) = [];
                        t_test(1) = [];
                        z(length(z)) = [];
                        t_test(length(t_test)) = [];
                        counter = counter + 1;
                end
                        
                %name = join([obj.filename, '_presfilt']);
                
                figure()
                plot(t,p, '-b',  t_test,z, '-r');
                legend('Pressure signal', 'Lowpass Filtered Wn = 0.0001');
                xlabel('Time (s)')
                ylabel('Pressure (atm)')
                title('Lowpass filtering pressure signal')
                grid
                
                p = z;    
                
                p_opp = -1*p; %signal inverted for calculating mins 
                
                %findpeaks only works if signal is above zero. Shifts
                %signal above zero by amp1, runs peak analysis, shifts
                %signal and peaks back again
                
                max1 = max(p);
                min1 = min(p);
                amp1 = abs(max1-min1);
                %shifts signal up
                for i = 1: length(p)
                    p(i) = p(i) + amp1;
                end
                max1 = max(p);
                
                %TESTING PURPOSES
                %{
                figure() plot(t, p); grid
                %}
                
                [pks, w] = findpeaks(p,t_test, 'MinPeakHeight',...
                    (max1-amp1/4), 'MinPeakDistance', (1/obj.freq)*2/3);
                lenpks = length(pks);
                pk2pk1 = w(2) - w(1);
                
                %shift pks and p values back again
                for i = 1:length(pks)
                    pks(i) = pks(i) - amp1;
                end
                for i = 1:length(p)
                    p(i) = p(i)-amp1;
                end
           
                max2 = max(p_opp);
                min2 = min(p_opp);
                amp2 = abs(max2-min2);
               
                %Similar routine as previous, using inverted pressure
                %signal to findpeaks for minimums
                
                %shifts up
                for i = 1:length(p_opp)
                    p_opp(i) = p_opp(i) + amp2;
                end
                max2 = max(p_opp);
                
                %TESTING PURPOSES ONLY
                %{
                [b,a] = butter(3, 20/35/2, 'low'); new_p_opp =
                filtfilt(b,a,p_opp);
                %}
                %[up, ~] = envelope(p_opp, 40, 'rms');
                %{
                y = lowpass(p_opp, 0.2);
                
                
                figure() plot(p_opp); hold on %plot(t, new_p_opp); plot(y)
                hold off grid
                %}

                [pks1, locs1] = findpeaks(p_opp, t_test, 'MinPeakDistance', pk2pk1*2/3, 'MinPeakHeight', (max2-amp2/4)); 
                
                %shift pks values back again
                for i = 1:length(pks1)
                    pks1(i) = -1*(pks1(i) - amp1);
                end
                
                %trim if there is a min before the first max
                if locs1(1)<w(1)
                    locs1(1) = [];
                    pks1(1) = [];
                end
                
                
                
                %if there are more maxs than breaths, clip the last breath
                while length(pks)>obj.breaths
                    pks(length(pks)) = [];
                    w(length(w)) = [];
                    pks1(length(pks1)) = [];
                    locs1(length(locs1)) = [];
                end

                %add a zero to the end to ensure when data organised in
                %table in bpb_analyser, arrays are the same length
                %(otherwise error)
                while length(pks) < obj.breaths
                    pks(length(pks) +1) = 0;
                    w(length(w) + 1) = 0;
                end
                while length(pks1) < obj.breaths
                    pks1(length(pks1)+1) = 0;
                    locs1(length(locs1)+1) = 0;
                end
                
                %plot to see where peaks are identified
                %name = join([obj.filename, 'pres_detect']);
                figure()
                plot(t_test, p, '-b', locs1, pks1, 'or');
                hold on
                plot(w, pks, 'og')
                title('Pressure max and min identification')
                xlabel('Time (s)');
                ylabel('Pressure (atm)');
                legend('Pressure (atm)', 'Min', 'Max')
                hold off
                grid
                
                lenofpks = length(pks)
                lenofpks1 = length(pks1)
                lenoflocs1 = length(locs1)
                %max and min pressures
                if pnum ==1
                    obj.pres_max = pks;            
                    obj.pres_min = -1*pks1;
                elseif pnum ==2
                    obj.presA_max = pks;            
                    obj.presA_min = -1*pks1;
                elseif pnum ==3
                    obj.presT_max = pks;            
                    obj.presT_min = -1*pks1;
                end

                %calculation of average pressure across each breath
                sample_mins = cell(obj.breaths,1); 
                for i = 1:length(locs1)
                    for j = 1:length(t)
                        if t(j) == locs1(i)                        
                            sample_mins{i} = j; %time index location of min
                        end                               
                    end
                end 
                for i = 1:length(sample_mins)-1
                    if sample_mins{i}>sample_mins{i+1}
                        sample_mins(i+1) = [];
                    end
                end
                while sample_mins{length(sample_mins)}>length(p)
                    sample_mins{length(sample_mins)} = [];
                end
                    
                    
                %smins = length(sample_mins)
                %s = sample_mins
                for i = 1:(length(sample_mins)-2)
                    min_ = sample_mins{i};               
                    max_ = sample_mins{i+1};
                    sum_p = 0;
                    for j = min_:max_
                        sum_p = sum_p + p(j);
                    end
                    if pnum ==1
                        %pave1 = length(obj.p_ave)
                        obj.p_ave{i} = sum_p/(max_ - min_);                            
                    elseif pnum ==2
                        obj.pA_ave{i} = sum_p/(max_ - min_); 
                        %o = obj.pA_ave
                    elseif pnum ==3
                        obj.pT_ave{i} = sum_p/(max_ - min_);                            
                    end

                                   
                end   
                
                if pnum ==1
                    while length(obj.p_ave) < obj.breaths
                        obj.p_ave{length(obj.p_ave)+1} = 200;
                        fprintf('\nin the loop')
                    end
                elseif pnum ==2
                    while length(obj.pA_ave) < obj.breaths
                        obj.pA_ave{length(obj.pA_ave)+1} = 200;
                        fprintf('\nin the loop')
                    end
                elseif pnum ==3
                    while length(obj.pT_ave) < obj.breaths
                        obj.pT_ave{length(obj.pT_ave)+1} = 200;
                        fprintf('\nin the loop')
                    end
                end
                
                %b = obj.breaths
                %pave2 = length(obj.p_ave)
                %pppp = obj.p_ave
                
        end
        
    end
end

    