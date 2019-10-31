

classdef Tester < handle
    
    properties
        sam_rate = .05
        %Errors for FlowLab
        erFLflow = .05 %(sl/min), 
        erFLvol = .01 %sl
        erFLdp = .1 %mbar
        erFLfreq = 1 %bpm
        erFLcomp = 1 %ml/mbar
        
        %adjust these later
        
        erFlow = .17 
        erVol = .17
        erP = .2        
        
        currentFolder = pwd;
        folderName
        newFile
        size
        x1
        x2
        x0
        y2p
        y2v
        int
        vent %pressure is col2, volume is col4
        
        nalm_Data
        lab_Data
        T_n
        T_l
        
        scale_fac 
        
        valid = 1; %changes to 0 if test is not valid    
        ex
            
    end
    
    methods
        function obj = Tester(nalm_Data, lab_Data, T_n, T_l, folderName) 
        
            obj.nalm_Data = nalm_Data;
            obj.lab_Data = lab_Data;
            obj.T_n = T_n;
            obj.T_l = T_l;            
            obj.folderName = string(folderName);
             
            fileTrimmer(obj);
            if obj.ex == 1                
                return
            end
            
            setFile(obj); 
            delayCalc(obj);
            labDataScaler(obj);  
            
            file = fullfile('Tests_Results', string(folderName));
            mkdir (file)
                        
            variableCompare(obj);   
            flowPlotter(obj);
            pressurePlotter(obj);
               
     
        end     
               
        function variableCompare(obj)
            
            seconds = 40;
            obj.int = seconds/obj.sam_rate;
            
            obj.x1 = obj.newFile{1:obj.int,1};
            obj.x2 = obj.newFile{1:obj.int,5};
            obj.x0 = 0:0.01:seconds;
            
        end
        
        function flowPlotter(obj)
           
            y1 = obj.newFile{1:obj.int,2};
            y2 = obj.newFile{1:obj.int,6};
            
            y10 = interp1(obj.x1,y1,obj.x0);
            y20 = interp1(obj.x2, y2, obj.x0); 
                       
            figure
                     
            plot(obj.x0, y10)
            title("Flow Comparison test")
            xlabel("Time (s)")
            ylabel("Flow (l/min)")                         
           
            hold on
            plot(obj.x0, y20)            
            legend({"FlowAnalyser", "GINA"});  
                       
            hold off 
            
            filename1 = fullfile(obj.currentFolder, 'Tests_Results',obj.folderName, 'flowTest.fig');            
            savefig(filename1);
            grid
            
            % Bland-Altman part
            [means,diffs,meanDiff,CR,linFit] = BlandAltman(y10,y20,3, 'Flow'); %decide how you'll factor in error 
            if abs(meanDiff)> obj.erFlow
                obj.valid = 0;
            end
            for i = 1:length(means)
                if  means(i)*linFit(1)+linFit(2) > CR(1) ||  means(i)*linFit(1)+linFit(2) < CR(2)
                        obj.valid = 0;
                end
            end   
            filename2 = fullfile(obj.currentFolder,'Tests_Results',obj.folderName, 'Bland-Altman_flow.fig');
            savefig(filename2);
           
        end
        
        function pressurePlotter(obj)
                       
            figure             
            y1 = -1*obj.newFile{1:obj.int, 3};
            y2 = obj.newFile{1:obj.int, 7};
            
            y10 = interp1(obj.x1,y1,obj.x0);
            obj.y2p = interp1(obj.x2, y2, obj.x0);  
            
            plot(obj.x0, y10)
            title("Pressure comparison test")
            xlabel("Time (s)")
            ylabel("Pressure (mbar)")
            
            hold on
            plot(obj.x0, obj.y2p)
            legend({"FlowAnalyser", "GINA"});
            
            hold off  
            filename = fullfile(obj.currentFolder,'Tests_Results',obj.folderName, 'pressureTest.fig');
            
            savefig(filename);
            grid
            
            % Bland-Altman part
            [means,diffs,meanDiff,CR,linFit] = BlandAltman(y10,obj.y2p,3, 'Pressure');
            if abs(meanDiff)> obj.erP %if meandiff is more than acceptable error
                obj.valid = 0;
            end
            % or if the bland altman line goes outside of the 95% CI           
            
            for i = 1:length(means)
                if  means(i)*linFit(1)+linFit(2) > CR(1) ||  means(i)*linFit(1)+linFit(2) < CR(2)
                        obj.valid = 0;
                end
            end
            filename2 = fullfile(obj.currentFolder,'Tests_Results',obj.folderName, 'Bland-Altman_pressure.fig');
            savefig(filename2);
           
        end    
        
        function volumePlotter(obj) %%% currently not in use
            figure
            y1 = obj.newFile{1:obj.int, 4};
            y2 = obj.newFile{1:obj.int, 8};
            
            y10 = interp1(obj.x1,y1,obj.x0);                    
            
            obj.y2v = interp1(obj.x2, y2, obj.x0);  
            
            plot(obj.x0, y10)
            title("Volume comparison test")
            xlabel("Time (s)")
            ylabel("Volume (ml)")
            
            hold on
            plot(obj.x0, obj.y2v)
            legend({"FlowLab", "NALM"});
            
            hold off 
            filename = fullfile(obj.currentFolder,obj.folderName, 'volumeTest.fig');
            
            savefig(filename);
            grid
        end
        
        function peak = peakPlotter(obj)
            peak = rms(obj.y2p);            
        end
        
        function setFile(obj)
            %set time back to 0 for nalmdata
           offset = 0;
           t1 =  obj.nalm_Data{1,1};         
           for i = 1:height(obj.nalm_Data)
                x =  obj.nalm_Data{i,1}-t1;
                obj.nalm_Data{i,1} = x;
           end
           
           t2 = obj.lab_Data{1,1};
           for i = 1:height(obj.lab_Data)
               x= (obj.lab_Data{i,1}-t2);
               obj.lab_Data{i,1} = x; 
               
               %offset volume
               if offset == 0
                   
                   if obj.lab_Data{i,4} < 0 && abs((obj.lab_Data{i+1,4} - obj.lab_Data{i,4})/.05)<0.2
                       offset = obj.lab_Data{i,4};
                   end
               end               
                              
               %value = obj.lab_Data{i,4};
               %obj.lab_Data{i,4} = value + offset;               
               
           end          
         
                      
           obj.newFile = [obj.lab_Data obj.nalm_Data];   
           %head(obj.newFile)
           
           
           obj.size = height(obj.newFile);
           
        end  
        
        function labDataScaler(obj)
            for i = 1:obj.size
                x_old = obj.newFile{i, 1};
                x_new = x_old*(1 + obj.scale_fac(1));
                obj.newFile{i, 1} = x_new;
            end
        end                
        
        function fileTrimmer(obj)
            
            %Trims both to same start time             
            time_interval = etime(obj.T_l, obj.T_n);
            if (time_interval > 15)               
               obj.ex = 1;               
               return
            end
                        
            rows_to_delete = time_interval/obj.sam_rate -3;       
                                  
            obj.nalm_Data(1:rows_to_delete, :) = [];    
            
            %{
            
            plot(obj.nalm_Data{:,1}, obj.nalm_Data{:,2});
            
            hold on
            plot(obj.lab_Data{:,1}, obj.lab_Data{:,2});
            %}
           
                       
            %trim nalm to first positive grad where y > 0

            f_nalm = table2array(obj.nalm_Data(:,2));
            t_nalm = table2array(obj.nalm_Data(:,1));           
            
            
            i_n = 1;            
            m = max(f_nalm);

            for i = 4:length(t_nalm)
                y4 = f_nalm(i);
                y3 = f_nalm(i-1);
                y2 = f_nalm(i-2);
                y1 = f_nalm(i-3);
                x4 = t_nalm(i);
                x3 = t_nalm(i-1);
                x_2 = t_nalm(i-2);
                x_1 = t_nalm(i-3);
                if  (y4-y3)/(x4-x3)> 20 && (y3-y2)/(x3-x_2)> 10 && abs((y2-y1)/(x_2-x_1)) <=10 && y1 > -m/2
                    i_n = i-3;
                    break                
                end
            end
            
            obj.nalm_Data(1:i_n, :) = [];
            
            %b = size(obj.nalm_Data)

         

            %trim flowLab to first positive grad
            f_lab = table2array(obj.lab_Data(:,2));
            t_lab = table2array(obj.lab_Data(:,1));
           % c = size(f_lab)
            il = 1;

            for i = 4:length(t_lab)
                y4 = f_lab(i);
                y3 = f_lab(i-1);
                y2 = f_lab(i-2);
                y1 = f_lab(i-3);
                x4 = t_lab(i);
                x3 = t_lab(i-1);
                x_2 = t_lab(i-2);
                x_1 = t_lab(i-3);
                
                if (y4-y3)/(x4-x3)> 20 && (y3-y2)/(x3-x_2)> 10 && abs((y2-y1)/(x_2-x_1)) <=10  && y1 > -m/2
                   il = i-3;
                   break
                end
            end
            
            obj.lab_Data(1:il, :) = [];
            
            %d = size(obj.lab_Data)
            
           
            %Trim both to same end time
            len_nalm = height(obj.nalm_Data);            
            len_lab = height(obj.lab_Data);

            diff_len = len_nalm - len_lab - 1;
            
            
                       
            if(diff_len > 0)
                %delete the extra cells off nalm_Data
                obj.nalm_Data((len_nalm - diff_len):len_nalm, :) = [];
            elseif(diff_len < 0)
                %same for nalm
                obj.lab_Data((len_lab - diff_len):len_nalm, :) = [];
            end
            
            %append data so time signatures start at 0
            
           % e = size(obj.nalm_Data)
            %f = size(obj.lab_Data)
            
            
            
        end        
        
        function delayCalc(obj)
            
            
            f_lab = table2array(obj.newFile(:,2));
            t_lab = table2array(obj.newFile(:,1));
            [pks_l, locs_l] = findpeaks(f_lab, t_lab, 'MinPeakProminence', 3.5);
                       
            t_nalm = table2array(obj.newFile(:,5));
            f_nalm = table2array(obj.newFile(:,6)) ;
                        
            [pks_n, locs_n] = findpeaks(f_nalm, t_nalm, 'MinPeakProminence', 3.5 );          
           
            
            diff = length(locs_n)- length(locs_l);
            
            if diff > 0
                locs_n((length(locs_n)-diff +1):length(locs_n), :) = [];
            elseif diff < 0
                locs_l((length(locs_l) - diff -1):length(locs_l),:) = [];
            end
            
           % length(locs_n)
          %  length(locs_l)  
                     
            loc_diff = locs_n - locs_l;
            x = transpose(0:length(loc_diff)-1); 
            p = polyfit(x, loc_diff, 1);          
                                    
            obj.scale_fac = p(1);       
            
            figure          
            plot(x,loc_diff);
            title("Delay")
            xlabel("Samples")
            ylabel("Time diff (s)")
            hold on
            
            x1 = linspace(0, length(loc_diff));
            y1 = polyval(p, x1);
            plot(x1, y1);
            hold off;
            grid     
            %}
                 
        end
        
        function infantDataCollector(obj, a_vent)
            dt = 0.001;  
            t0 = a_vent{1,1};
            for i = 1:height(a_vent)
                t = a_vent{i,1};
                a_vent{i,1} = t - t0;
                
                flow = a_vent{i,2};                
                vol = 1000/60*flow*dt;
                a_vent{i,4} = vol;                
            end
            
            obj.vent = a_vent;
            
        end
            
        
    
    end
end

    