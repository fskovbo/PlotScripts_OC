function main()
    clear all; close all; clc;

    readDirs = {'../../mnt/5partIpopt/' , '../../mnt/5partAmoeba2/'};
    writeDirectory = 'Plots/5partAnalysis/';
    
    set(0, 'DefaultTextInterpreter', 'latex');
    set(0, 'DefaultLegendInterpreter', 'latex');
    set(0, 'defaultAxesTickLabelInterpreter','latex');
    set(0, 'defaultAxesFontSize',12);

%     processBestSolutions(readDirectory,writeDirectory)

    durations = [1 , 2 , 3 , 4];
    commulativeNprop = [0 , 1];
    maxprop = 1e3;
  
    %% plot fidelity vs duration

    legEntries = {'Interior Point','Nelder-Mead'};
    [fidelityData , durIDs] = processFidelityData(readDirs,durations);
    FDfig = makeCompFidelityPlot(fidelityData,legEntries);
    
    % save figure 
    figname = [writeDirectory 'FidelityDuration'];
    FDfig.PaperPositionMode = 'auto';
    fig_pos = FDfig.PaperPosition;
    FDfig.PaperSize = [fig_pos(3) fig_pos(4)];
    print(FDfig,figname,'-dpdf','-bestfit') 
    
    %% plot cost vs Npropagations

    progfig = figure;
    Nrows = 2;
    Ncols = 2;
    rowylims = [2.5*10^(-3)     , 4*10^(-1) ; ...
                5*10^(-4)       , 0.15 ];
            
    rowyt = {[10^(-2) , 10^(-1)] , [10^(-3) , 10^(-2) , 10^(-1)]};
            
    xt  = linspace(0,maxprop,5);
    xtl = sprintfc('%d',xt);    
    % plot data in NrxNc grid and andjust axis, legends, etc.
    
    for i = 1:length(durations)
        subaxis(Nrows,Ncols,i,'SpacingVert',0,'SpacingHoriz',0.015)
        progressData    = processProgressData(readDirs,durIDs(i,:),commulativeNprop,maxprop);
        progplot        = makeProgressPlot(progressData,legEntries,maxprop);

        set(gca,'Ylim',rowylims(ceil(i/Ncols),:)) %set ylim of given row
        legend(gca,'Location','SouthEast')
        xticks(xt)
        xticklabels(xtl)
        yticks(rowyt{ceil(i/Ncols)})
%         ytl = sprintfc('%d',rowyt{ceil(i/Ncols)});
%         yticklabels(ytl)
        
        if mod(i,Ncols) ~= 0 % remove last xtick to make room for next column
            xticklabels(xtl(1:end-1))
        end
        if mod(i,Ncols) ~= 1 %remove y axis from all but first column of plot
           set(gca,'YLabel',[]);
           set(gca,'YTickLabel',[]);
        end
        if length(durations)-i >= Ncols %remove x axis for all but bottom row
            set(gca,'XLabel',[]);
            set(gca,'XTickLabel',[]);
        end
        if i~= 1 %only lengend on first subfigure
            legend(gca,'off')
        end
        
        ax = gca;
        ax.YGrid = 'on';
        ax.XGrid = 'on';
        ax.YMinorGrid = 'off';
        
    end 
    
     % add subfigure labelling
    annotation(gcf,'textbox',...
    [0.0942965657987035 0.846951882174887 0.0305186246418337 0.0547703180212017],...
    'String','(\textbf{a})$\; \; T = 1$',...
    'LineStyle','none',...
    'Interpreter','latex',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off');

    annotation(gcf,'textbox',...
    [0.501247693618254 0.846951882174887 0.0305186246418337 0.0547703180212016],...
    'String','(\textbf{b})$\; \; T = 2$',...
    'LineStyle','none',...
    'Interpreter','latex',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off');

    annotation(gcf,'textbox',...
    [0.0942965657987035 0.443067421380556 0.0305186246418337 0.0547703180212016],...
    'String','(\textbf{c})$\; \; T = 3$',...
    'LineStyle','none',...
    'Interpreter','latex',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off');

    annotation(gcf,'textbox',...
    [0.501247693618254 0.443067421380556 0.0305186246418337 0.0547703180212016],...
    'String','(\textbf{d})$\; \; T = 4$',...
    'LineStyle','none',...
    'Interpreter','latex',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off');

    % save figure 
    figname = [writeDirectory 'CostProgress'];
    progfig.PaperPositionMode = 'auto';
    fig_pos = progfig.PaperPosition;
    progfig.PaperSize = [fig_pos(3) fig_pos(4)];
    print(progfig,figname,'-dpdf','-bestfit') 

end

function [FidelityData , durIDs] = processFidelityData(readDirs, durations)

    FidelityData = [];

    for j = 1:length(readDirs)
        readDirectory = readDirs{j};
        
        % extract data
        [Tlist, Flist, IDlist] = extractFinalFidelity(readDirectory);
        TFdata = [Tlist' , Flist'];

        % sort data with respect to T
        sortedData = sortrows(TFdata,1);

        % calculate median and percentiles for each unique T
        % data format T:median:25percentile:75percentile
        [uv,idy,~] = unique(sortedData(:,1));
        nu = numel(uv);
        PlotData = zeros(nu,5);

        idy = [idy ; size(sortedData,1)+1];
        for i = 1:nu
           PlotData(i,1) = uv(i);
           % group data for given T in x
           x = sortedData(idy(i):idy(i+1)-1,2);
           PlotData(i,2) = median(x);
           PlotData(i,3) = prctile(x,25);
           PlotData(i,4) = prctile(x,75);
           PlotData(i,5) = max(x);
        end   
        
        % append data 
        FidelityData = [FidelityData , PlotData];
        
        % find ID's corresponding to given durations
        for i = 1:length(durations)
           index        = find( Tlist == durations(i));
           fullID       = IDlist{index(1)};
           durIDs{i,j}  = strtok(fullID,'_');
        end
    end 
end

function progressData = processProgressData(readDirs, fileIDs, commul, maxlength)

    progressData = [];

    for j = 1:length(readDirs)
        readDirectory   = readDirs{j};
        fileID          = fileIDs{j};
        comm            = commul(j);

        % extract cache data at duration T
        [iter , cost, Nprop] = extractChacheAtDuration(readDirectory,fileID,comm);

        iterData = zeros( length(Nprop) , 4);
        % prepare data for iteration vs cost plot
        iterData(:,1) = Nprop;
        iterData(:,2) = median(cost,2);
        iterData(:,3) = prctile(cost,25,2);
        iterData(:,4) = prctile(cost,75,2);
        
        if size(iterData,1) > maxlength
           iterData = iterData(1:maxlength,:); 
        end
        
        lprop(j)      = size(iterData,1);
        dat{j}        = iterData;
    end
    
    maxprop = max(lprop);
    for j = 1:length(readDirs)
        iterData = dat{j};
       if lprop(j) < maxprop
          iterData(end:maxprop,:) = repmat(iterData(end,:),maxprop-size(iterData,1)+1,1);
       end
        progressData = [ progressData , iterData];
    end
end


    

