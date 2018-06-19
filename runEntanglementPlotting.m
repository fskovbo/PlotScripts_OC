function main()
    close all; clear all; clc;

    datadir = 'Data/CorrelationData/';
    types = {'Exp' , 'Quench'};
    typenames = {'Exponential Ramp','Abrupt Quench'};
    time = 0:0.005:3;
    minr = 1;
    maxr = 6;
    
    
    set(0, 'DefaultTextInterpreter', 'latex');
    set(0, 'DefaultLegendInterpreter', 'latex');
    set(0, 'defaultAxesTickLabelInterpreter','latex');
    set(0, 'defaultAxesFontSize',12);
    
    
    %% plot entanglement/correlation graphs
    fig = figure;
    for i = 1:length(types)
        
       subaxis(3,length(types),i,'SpacingVert',0,'SpacingHoriz',0)
       plotEntanglementEntropy(datadir,types{i},time,7);
       title(typenames{i})
       if i ~= 1
           set(gca,'YLabel',[]);
           set(gca,'YTickLabel',[]);
           legend(gca,'off')
       end
       set(gca,'XLabel',[]);
       set(gca,'XTickLabel',[]);
       set(gca,'Ylim',[-0.3,4])
       
       
       subaxis(3,length(types),i+length(types),'SpacingVert',0,'SpacingHoriz',0)
       plotSingleParticleCorrelations(datadir,types{i},time,minr,maxr);
       if i ~= 1
           set(gca,'YLabel',[]);
           set(gca,'YTickLabel',[]);
       end
       set(gca,'XLabel',[]);
       set(gca,'XTickLabel',[]);
       set(gca,'Ylim',[-0.1,1.1])
       legend(gca,'off')
       
       subaxis(3,length(types),i+2*length(types),'SpacingVert',0,'SpacingHoriz',0)
       plotDensityCorrelations(datadir,types{i},time,minr,maxr);
       if i ~= 1
           set(gca,'YLabel',[]);
           set(gca,'YTickLabel',[]);
           legend(gca,'off')
       end
       if i ~= length(types)
          xl = xticklabels;
          xticklabels(xl(1:end-1))
       end
       set(gca,'Ylim',[0.89,1.09])
    end
    
    % add subfigure labelling
    annotation(gcf,'textbox',...
    [0.090725137227275 0.849332834555839 0.0305186246418337 0.0547703180212016],...
    'String','(\textbf{a})',...
    'LineStyle','none',...
    'Interpreter','latex',...
    'FontWeight','bold',...
    'FontSize',12,...
    'FitBoxToText','off');

    annotation(gcf,'textbox',...
    [0.090725137227275 0.583543611856744 0.0305186246418337 0.0547703180212016],...
    'String','(\textbf{c})',...
    'LineStyle','none',...
    'Interpreter','latex',...
    'FontWeight','bold',...
    'FontSize',12,...
    'FitBoxToText','off');

    annotation(gcf,'textbox',...
    [0.090725137227275 0.315379567984546 0.0305186246418337 0.0547703180212016],...
    'String','(\textbf{e})',...
    'LineStyle','none',...
    'Interpreter','latex',...
    'FontWeight','bold',...
    'FontSize',12,...
    'FitBoxToText','off');

    annotation(gcf,'textbox',...
    [0.494233909157101 0.849332834555839 0.0305186246418337 0.0547703180212016],...
    'String','(\textbf{b})',...
    'LineStyle','none',...
    'Interpreter','latex',...
    'FontWeight','bold',...
    'FontSize',12,...
    'FitBoxToText','off');

    annotation(gcf,'textbox',...
    [0.494233909157101 0.583543611856744 0.0305186246418337 0.0547703180212016],...
    'String','(\textbf{d})',...
    'LineStyle','none',...
    'Interpreter','latex',...
    'FontWeight','bold',...
    'FontSize',12,...
    'FitBoxToText','off');

    annotation(gcf,'textbox',...
    [0.494233909157101 0.315379567984546 0.0305186246418337 0.0547703180212016],...
    'String','(\textbf{f})',...
    'LineStyle','none',...
    'Interpreter','latex',...
    'FontWeight','bold',...
    'FontSize',12,...
    'FitBoxToText','off');

    % save figure 
    figname = ['Plots/' 'EntanglementGrowth'];
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    print(fig,figname,'-dpdf','-bestfit') 

    %% plot light cone
    fig = figure;
    plotLightCone(datadir,types{2},time,2,maxr);
    
    % save figure 
    figname = ['Plots/' 'CorrelationLightCone'];
    pos=get(fig, 'Position');
    set(fig, 'Position', [pos(1), pos(2), pos(3), pos(4)*0.65]);
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    print(fig,figname,'-dpdf','-bestfit') 

end


function h = plotEntanglementEntropy(dir,type,time,maxbond)

    filename = [dir 'EntanglementEntropies_' type '.txt'];
    data = dlmread(filename);
    
    % only look at half of system because symmetry
    data = data(:,1:maxbond);
    h = plot(time,data,'LineWidth',1.5);
    
    xlabel('Time $t$ $[ J^{-1} ]$')
    ylabel('Entropy $S$')
    
    for i = 1:maxbond
        legentries{i} = ['Bond ' num2str(i)];
    end
    
    lgd = legend(h,legentries,'Location','northeast','NumColumns',2);
    legend('boxoff')    
end

function h = plotSingleParticleCorrelations(dir,type,time,minr,maxr)

    filename = [dir 'SingleParticleCorr_' type '.txt'];
    data = dlmread(filename);
    
    
    h = plot(time,data,'LineWidth',1.5);
    
    xlabel('Time $t$ $[ J^{-1} ]$')
    ylabel('$\langle \hat{a}_{0}^{\dag} \hat{a}_{r} \rangle$')

    for i = minr:maxr
        legentries{i} = ['r = ' num2str(i)];
    end
    
    lgd = legend(h,legentries,'Location','northeast','NumColumns',2);
    legend('boxoff')    
end

function h = plotDensityCorrelations(dir,type,time,minr,maxr)

    filename = [dir 'DensityDensityCorr_' type '.txt'];
    data = dlmread(filename);
    
    h = plot(time,data,'LineWidth',1.5);
    
    xlabel('Time $t$ $[ J^{-1} ]$')
    ylabel('$\langle \hat{n}_{0}^{\dag} \hat{n}_{r} \rangle$')

    for i = minr:maxr
        legentries{i} = ['r = ' num2str(i)];
    end
    
    lgd = legend(h,legentries,'Location','southeast','NumColumns',2);
    legend('boxoff')    
end

function h = plotLightCone(dir,type,time,minr,maxr)

    filename = [dir 'DensityDensityCorr_' type '.txt'];
    data = dlmread(filename);
    data = data(:,2:end);
    
    dur = ceil(length(time)/1.5);
    
    r = minr:maxr;
    h = imagesc('XData',r,'YData',time(1:dur),'CData',data(1:dur,:)./data(1,:));
    hold on
    plot([r(1)-0.5 , r(end)+0.5], [0.3 1.3],'k--','LineWidth',1.5)
    ylim([time(1) , time(dur)])
    xlim([r(1)-0.5 , r(end)+0.5])
    xticks(r)
    
    ylabel('Time $t$ $[ J^{-1} ]$')
    xlabel('Distance $r$')

    colorbar
    caxis([0.97 1.01])
end