function main()
    clear all; close all; clc;

    readDirs = {'../../../mnt/5partIpopt/' , '../../../mnt/5partAmoeba/'};
    writeDirectory = '../../DataProcessing/Plots/5partAnalysis/';
    
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
%     [fidelityData , durIDs] = processFidelityData(readDirs,durations);
%     FDfig = makeCompFidelityPlot(fidelityData,legEntries);
%     
%     % save figure 
%     figname = [writeDirectory 'FidelityDuration'];
%     FDfig.PaperPositionMode = 'auto';
%     fig_pos = FDfig.PaperPosition;
%     FDfig.PaperSize = [fig_pos(3) fig_pos(4)];
%     print(FDfig,figname,'-dpdf','-bestfit') 
    
    %% plot cost vs Npropagations
    durIDs =    {'../../../mnt/5partIpopt/837422', '../../../mnt/5partAmoeba/828324'; ...
                 '../../../mnt/5partIpopt/837529', '../../../mnt/5partAmoeba/828334'; ...
                 '../../../mnt/5partIpopt/837539', '../../../mnt/5partAmoeba/828381'; ...
                 '../../../mnt/5partIpopt/837549', '../../../mnt/5partAmoeba/828391'}

%     durIDs =    { '../../../mnt/5partAmoeba/828324'; ...
%                   '../../../mnt/5partAmoeba/828334'; ...
%                   '../../../mnt/5partAmoeba/828381'; ...
%                   '../../../mnt/5partAmoeba/828391'}
%               
%     readDirs = { '../../../mnt/5partAmoeba/'};
%     legEntries = {'Nelder-Mead'};
%     commulativeNprop = 1;

    for i = 1:length(durations)
        progressData    = processProgressData(readDirs,durIDs(i,:),commulativeNprop,maxprop);
        progfig         = makeProgressPlot(progressData,legEntries,maxprop);
        
        % save figure 
        figname = [writeDirectory 'CostProgressT' num2str(durations(i))];
        progfig.PaperPositionMode = 'auto';
        fig_pos = progfig.PaperPosition;
        progfig.PaperSize = [fig_pos(3) fig_pos(4)];
        print(progfig,figname,'-dpdf','-bestfit') 
    end  

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


    

