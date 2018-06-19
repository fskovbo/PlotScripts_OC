function main()
    clear all; close all; clc;
    
%     %%%% FIX
%     Mlist = {5:40 , 5:40};
%     prefixnum = [640480:640480+length(Mlist{1})-1; ...
%                  620717:620752                      ];
% %     Mlist = {5:40};
% %     prefixnum =  620717:620752;
% %     
%     for j = 1:size(prefixnum,1)
%         for i = 1:size(prefixnum,2)
%            prefix{j,i} = num2str(prefixnum(j,i)); 
%         end
%     end
    
    %%%%%
    
    readDirs = {'../../mnt/5partIpoptMsweep/','../../mnt/5partAmoebaMsweep/'};
    writeDirectory = 'Plots/5partAnalysis/';
    
    set(0, 'DefaultTextInterpreter', 'latex');
    set(0, 'DefaultLegendInterpreter', 'latex');
    set(0, 'defaultAxesTickLabelInterpreter','latex');
    set(0, 'defaultAxesFontSize',12);
    
    %% plot fidelity vs basis size
%     [Mlist , prefix] = extractBasisSize(readDirs);

    Mlist = {5:2:35 , 5:2:35};
    prefixnum = [853048:853063 ; 852915:852930];
    for j = 1:size(prefixnum,1)
        for i = 1:size(prefixnum,2)
           prefix{j,i} = num2str(prefixnum(j,i)); 
        end
    end
    
    basisData = processData(readDirs,Mlist,prefix);
    legtext = {'Interior Point','Nelder-Mead'};    
    
    fig = makeBasisFidelityPlot(basisData,legtext);
        
    % save figure 
    figname = [writeDirectory 'FidelityBasisSize'];
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    print(fig,figname,'-dpdf','-bestfit') 


end

function basisData = processData(readDirs,Mlist,prefix)

    basisData = [];

    maxlength = 0;
    for i = 1:length(Mlist)
       maxlength = max( length(Mlist{i}) , maxlength ); 
    end
    
    for j = 1:length(readDirs)
        
        readDirectory = readDirs{j};
        M = Mlist{j};
        bData = [M', zeros(length(M),4)];

        for i = 1:length(M)

            % find data for M = BasisSize(i) with prefix{i}
            searchstr = [readDirectory prefix{j,i} '*BHrampInitialFinal.txt'];
            Files = dir( searchstr );
            FData = zeros(1,length(Files));
            for k = 1:length(Files)
                filename     = [readDirectory Files(k).name];
                fidData      = dlmread(filename);
                FData(k)     = fidData(end,end);
            end
           
            bData(i,2) = median(FData);
            bData(i,3) = prctile(FData,25);
            bData(i,4) = prctile(FData,75);
            bData(i,5) = max(FData);
        end
        
        if length(M) < maxlength
           bData(end:maxlength,:) = repmat(bData(end,:),maxlength-length(M)+1,1);
        end
        
        basisData = [basisData , bData];
    end
    
end

function [Mlist , prefix] = extractBasisSize(readDirs)

    

    for j = 1:length(readDirs)
        readDirectory = readDirs{j};
        searchstr = [readDirectory '*ProgressCache.txt'];
        Files = dir( searchstr ); 
        
        M = [];
        l = 0;
        
        for k = 1:length(Files)
            filename    = [readDirectory Files(k).name];
            CacheData   = dlmread(filename);
            Mtmp        = CacheData(1,end);
            
            if ismember(Mtmp, M)
                M               = [M , Mtmp];
                unsortprefix{l} = strtok(filename,'_');
                l               = l+1;
            end
        end
        
        [sortM , index] = sort(M);
        Mlist{j} = sortM;
        for i = 1:length(M)
            prefix{j,i} = unsortprefix{index(i)}
        end
        
    end
 
end

function fig = makeBasisFidelityPlot(data,legendEntries)

    %  ---- data format -----
    % M (1) | median (1) | 25 perc (1) | 75 perc (1) | best (1) | median (2) |
    % ...
    
    co = [    0    0.4470    0.7410
         0.8500    0.3250    0.0980
         0.9290    0.6940    0.1250
         0.4940    0.1840    0.5560
         0.4660    0.6740    0.1880
         0.3010    0.7450    0.9330
         0.6350    0.0780    0.1840];
    
    fig = figure;  
    
    % plot fidelity data for each method in subplot
    sub(1) = subplot(2,1,1);
    hold on
    box on
    for i = 1:(size(data,2))/5
        M       = data(:,1 + (i-1)*5);
        algdata = data(:,(2+(i-1)*5):(i*5));
        color   = co(i,:);
        
        xx = [M' , fliplr(M')];
        yy = [algdata(:,2)' , fliplr(algdata(:,3)')];
        fill(xx,yy,color,'FaceAlpha',0.4,'EdgeColor','none');
        p(i) = plot(M,algdata(:,2),'Linewidth',2,'Color',color);
        plot(M,algdata(:,3),'Linewidth',2,'Color',color);
        plot(M,algdata(:,1),'LineStyle',':','Linewidth',2,'Color',color);
    end
       
    limsy=get(gca,'YLim');
    set(gca,'Ylim',[limsy(1) 1]);
    ylabel('Fidelity $F$')
    
    legend(p,legendEntries,'Location','SouthEast')

    
    % plot best infidelity achieved for each method in subplot
    sub(2) = subplot(2,1,2);
    hold on
    box on
    for i = 1:(size(data,2))/5
        M       = data(:,1 + (i-1)*5);
        algdata = data(:,(2+(i-1)*5):(i*5));
        color   = co(i,:);
        
        plot(M,1-algdata(:,4),'Linewidth',2,'Color',color);
    end
    
    limsy=get(gca,'YLim');
    set(gca,'Ylim',[1e-4 0.8*1e-1]);
    yticks([1e-4 1e-3 1e-2])
    set(gca, 'YScale', 'log')
    ax = gca;
    ax.YGrid = 'on';
    ax.YMinorGrid = 'off';
    
    
    % adjust subplot size and stack them
    subpos = get(sub(1), 'Position');
    set(sub(1), 'position', [subpos(1), subpos(2)-subpos(4)*0.5, subpos(3), subpos(4)*1.5] );
    subpos = get(sub(2), 'Position');
    set(sub(2), 'position', [subpos(1), subpos(2), subpos(3), subpos(4)*0.5] );
    
    xlabel('Basis Size $M$','FontSize',12)
    ylabel('$1-F$','FontSize',12)
    
    annotation(gcf,'textbox',...
    [0.122304084595696 0.873777279000283 0.0305186246418337 0.0547703180212016],...
    'String','(\textbf{a})',...
    'LineStyle','none',...
    'Interpreter','latex',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off');
    
    samexaxis('xmt','on','ytac','join','yld',1,'YTickAntiClash')
    
    annotation(gcf,'textbox',...
    [0.122536928251765 0.262536430729644 0.0305186246418337 0.0547703180212017],...
    'String','(\textbf{b})',...
    'LineStyle','none',...
    'Interpreter','latex',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off');
    
end
