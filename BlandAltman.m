function [means,diffs,meanDiff,CR,linFit] = BlandAltman(var1, var2, flag, param)
 
    %%%Plots a Bland-Altman Plot
    %%%INPUTS:
    %%% var1 and var2 - vectors of the measurements
    %%%flag - how much you want to plot
        %%% 0 = no plot
        %%% 1 = just the data
        %%% 2 = data and the difference and CR lines
        %%% 3 = above and a linear fit
    %%%
    %%%OUTPUTS:
    %%% means = the means of the data
    %%% diffs = the raw differences
    %%% meanDiff = the mean difference
    %%% CR = the 2SD confidence limits
    %%% linfit = the paramters for the linear fit
    %%% accErr is a percent
    
    str1 = ['Bland-Altman plot for', string(param)];
    newStr1 = join(str1);
    str2 = [string(param), ' measurement differences'];
    newStr2 = join(str2);
    
    if (nargin<1)
       %%%Use test data
       var1=[512,430,520,428,500,600,364,380,658,445,432,626,260,477,259,350,451];%,...
       var2=[525,415,508,444,500,625,460,390,642,432,420,605,227,467,268,370,443];
       flag = 3;
    end
    
    if nargin==2
        flag = 0;
    end
    
    means = mean([var1;var2]);
    diffs = var1-var2;
    
    meanDiff = mean(diffs);
    sdDiff = std(diffs);
    CR = [meanDiff + 1.96 * sdDiff, meanDiff - 1.96 * sdDiff]; %%95% confidence range
    
    linFit = polyfit(means,diffs,1); %%%work out the linear fit coefficients
    
    %%% Plot the normal distribution, use shapiro wilk test for normality
    figure
    histfit(diffs)
    title(newStr2)
    xlabel('Difference')
    ylabel('Frequency')
    grid
    
    %%%plot results unless flag is 0
    figure
    if flag ~= 0
        plot(means,diffs,'o')
        hold on
        if flag > 1
            h1 = plot(means, ones(1,length(means)).*CR(1),'k--'); %%%plot the upper CR
            h2 = plot(means, ones(1,length(means)).*CR(2),'k--'); %%%plot the lower CR
           % plot(means, ones(1,length(means)).*(CR(1)-CR(1)*accErr),'k-') %%% plot upper acceptable error
           % plot(means, ones(1,length(means)).*(CR(2)-CR(2)*accErr),'k-') %%% plot lower acceptable error
            h3 = plot(means,ones(1,length(means)).*meanDiff,'k-'); %%%plot meanDiff
        end
        if flag > 2
            h4 = plot(means, means.*linFit(1)+linFit(2),'m-'); %%%plot the linear fit
        end
        
        title(newStr1)
        xlabel('Mean of FlowLab and GINA')
        ylabel('FlowLab - GINA')
        
        str = ['y = ', string(round(linFit(1), 2)),'x + ', string(round(linFit(2), 2))];
        eqstr = join(str);
        label(h4,eqstr ,'location','center') %% equation of line
        
        %str1 = ['CImax', string(CR(1))];
        joinstr1 = 'CI 1.96s';
        label(h1, joinstr1, 'location', 'right')
        
        %str2 = ['CImin', string(CR(2))];
        joinstr2 = 'CI -1.96s';
        label(h2, joinstr2, 'location', 'right')
         
        str3 = ['Mean: ', string(round(meanDiff, 2))];
        joinstr3 = join(str3);
        label(h3, joinstr3, 'location', 'right') %% mean label
        
        
    end
    grid
    
    
end