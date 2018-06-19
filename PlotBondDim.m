function main()
    clear all; close all; clc;
    
    readDir     = 'Data/BondDimData_LongStep/';
%     writeDir    = readDir;
    writeDir    = 'Plots/BondDimAnalysis/';
    Tstr        = '5.0';
    
    set(0, 'DefaultTextInterpreter', 'latex');
    set(0, 'DefaultLegendInterpreter', 'latex');
    set(0, 'defaultAxesTickLabelInterpreter','latex');
    set(0, 'defaultAxesFontSize',12);

    Dvals   = [20,30,40,50,1000];

    file1    = [readDir 'TimeEvolBondDimT' Tstr 'maxM'];
    file2    = [readDir 'DMRGstateBondDim.txt'];
    
    for i = 1:length(Dvals)
        filename        = [file1 num2str(Dvals(i)) '.txt'];
        [t,u,F(:,i),g(:,i),M(:,:,i)] = extractData(filename);
        lgdstr{i} = ['$D = \:$' num2str(Dvals(i))];
    end
    
    fig = plotRampPlusBondDim(t,u,M,4,length(Dvals));
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    print(fig,[writeDir 'BondDimEvolution'],'-dpdf','-bestfit')
    
    
    pause(0.5)
    fig = plotFidelity(t,u,F,lgdstr);
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    print(fig,[writeDir 'FidelityTruncation'],'-dpdf','-bestfit')
    
    pause(0.5)
    fig = plotGradientComparison(t,u,g,lgdstr);
    fig.PaperPositionMode = 'auto';;
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    print(fig,[writeDir 'GradientTruncation'],'-dpdf','-bestfit')
    
    pause(0.5)
    fig = plotInitialBondDim(file2);
    pos=get(fig, 'Position');
    set(fig, 'Position', [pos(1), pos(2), pos(3), pos(4)*0.5]);
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    print(fig,[writeDir 'InitialBondDim'],'-dpdf','-bestfit')

end


function [t,u,F,g,M] = extractData(filename)
    data    = dlmread(filename);
    
    t       = data(:,1);
    u       = data(:,2);
    F       = data(:,3);
    g       = data(:,4);
    M       = data(:,5:end);

end


function fig = plotGradientComparison(t,u,g,lgdstr)
    
    fig = figure;
    
    t = 0:length(t)-1;
    
    subplot(3,1,1)
    hold on
    ax = gca;
    ax.ColorOrderIndex = size(g,2);
    h(size(g,2)) = plot(t,g(:,end),'Linewidth',3);
    ax = gca;
    ax.ColorOrderIndex = 1;
    h(1:size(g,2)-1) = plot(t,g(:,1:end-1),'--','Linewidth',2);
    ylabel('Gradient $\frac{\partial \mathcal{J}}{\partial u (t_i)}$')
    xlim([t(1) t(end)])
    ylim([-1.9 * 1e-3 , 1.9 * 1e-3])
    yticks([-1e-3 0 1e-3])
    yticklabels({'$\raisebox{.75pt}{-}10^{-3}$','0','$10^{-3}$'})
    
    lgd = legend(h,lgdstr,'NumColumns',3);
    legend('boxoff')
    set(lgd,'Position',[ 0.337435720591458 0.668214286849615 0.51012855881708 0.0869047596341086])
    lgd.FontSize = 10;
    
    subplot(3,1,2)
    hold on
    diff = g(:,end) - g(:,1:end-1);
    plot(t,diff,'Linewidth',2)
    ylabel('Diff.')
    xlim([t(1) t(end)])
    ylim([-4.5 *1e-5 , 4.5 *1e-5])
    yticks([-4e-5 -2e-5 0 2e-5 4e-5])
    yticklabels({'$\raisebox{.75pt}{-}4 \mathrm{e}\raisebox{.75pt}{-}5$','$\raisebox{.75pt}{-}2 \mathrm{e}\raisebox{.75pt}{-}5$','0','$2 \mathrm{e}\raisebox{.75pt}{-}5$','$4 \mathrm{e}\raisebox{.75pt}{-}5$'})

    
    subplot(3,1,3)
    hold on
    plot(t,abs(diff),'Linewidth',2)
    ylabel('Abs. Diff.')
    xlabel('Parameter index $i$')
    xlim([t(1) t(end)])
    ylim([1e-7 2e-4])
    set(gca,'YScale','log')
    yticks([ 1e-7 1e-6 1e-5 1e-4])
    
    annotation(gcf,'textbox',...
    [0.122304084595696 0.873777279000283 0.0305186246418337 0.0547703180212016],...
    'String','(\textbf{a})',...
    'LineStyle','none',...
    'Interpreter','latex',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off');

annotation(gcf,'textbox',...
    [0.122536928251765 0.5990991674123 0.0305186246418337 0.0547703180212017],...
    'String','(\textbf{b})',...
    'LineStyle','none',...
    'Interpreter','latex',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off');

annotation(gcf,'textbox',...
    [0.122536928251765 0.328712901317879 0.0305186246418337 0.0547703180212016],...
    'String','(\textbf{c})',...
    'LineStyle','none',...
    'Interpreter','latex',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off');
    
    samexaxis('xmt','on','ytac','join','yld',1,'YTickAntiClash')
end


function fig = plotInitialBondDim(filename)
    data    = dlmread(filename);
    sites   = 1:size(data,1);
    
    fig = figure;
    h = plot(sites,data,'-o','Linewidth',2,'MarkerSize',5);
    set(h, {'MarkerFaceColor'}, get(h,'Color')); 
    
    xlim([sites(1) sites(end)])
    xlabel('Bond nr.')
    ylabel('Bond Dimension')
    
    lgd = legend(h,{'Intial State','Target State'});
end


function fig = plotRampPlusBondDim(t,u,M,minbond,bondDimIndex)
    
    [~, index] = min(abs(u-3.37));
    bonds = minbond:ceil(size(M,2)/2);

    fig = figure;
    hold on
    
    subplot(2,1,1)
    hold on
    plot(t,u,'Linewidth',2,'Color',[0,0,0])
    plot([t(index),t(index)], [0 , 60],'--','Linewidth',1.5,'Color',[0,0,0]);
    xlim([t(1) t(end)])
    ylim([0 60])
    yticks([20 40 60])
    ylabel('Control $U [J]$')
    
    subplot(2,1,2)
    box on
    hold on
    h = plot(t,M(:,bonds,bondDimIndex),'Linewidth',2);
    plot([t(index),t(index)], [0 , 10000],'--','Color',[0,0,0],'Linewidth',1.5);
    xlabel('Time $t$ $[J^{-1}]$')
    ylabel('Bond Dimension')
    xlim([t(2) t(end)])
    ylim([0 , max(M(end,bonds,bondDimIndex))])

    for i = 1:length(bonds)
       lgdstr{i} = ['Bond ' num2str(bonds(i))]; 
    end
    
    lgd = legend(h,lgdstr,'NumColumns',2);
    legend('boxoff')
    set(lgd,'Position',[0.146364292020029 0.337142859262135 0.510128558817079 0.154444440205892])
    lgd.FontSize = 10;
    
    samexaxis('xmt','on','ytac','join','yld',1,'YTickAntiClash')
    
    annotation(gcf,'textbox',...
    [0.125812856525521 0.870777279000283 0.0305186246418337 0.0547703180212016],...
    'String','(\textbf{a})',...
    'LineStyle','none',...
    'Interpreter','latex',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off');

    annotation(gcf,'textbox',...
    [0.123746201434722 0.463634421857436 0.0305186246418338 0.0547703180212015],...
    'String','(\textbf{b})',...
    'LineStyle','none',...
    'Interpreter','latex',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off');

end


function fig = plotFidelity(t,u,F,lgdstr)
   
    fig = figure;
      
    subplot(2,1,1)
    hold on
    
    ax = gca;
    ax.ColorOrderIndex = size(F,2);
    h(size(F,2)) = plot(t,1-F(:,end),'Linewidth',3);
    ax = gca;
    ax.ColorOrderIndex = 1;
    h(1:size(F,2)-1) = plot(t,1-F(:,1:end-1),'--','Linewidth',2);
    
    ylim([0.45 , 1.15])
    xlim([t(1) t(end)])
    set(gca,'YScale','log')
    yticks([.5 .6 .8 1])
    ylabel('Infidelity $1-F$')
    
    lgd = legend(h,lgdstr,'NumColumns',2);     
    legend('boxoff')
    set(lgd,'Position',[ 0.532345751756288 0.783253971546416 0.343670970468538 0.117777774598863])
    lgd.FontSize = 10;
    
    
    subplot(2,1,2)
    hold on
    diff = abs((1-F(:,end))-(1-F(:,1:end-1)));
    plot(t,diff,'Linewidth',2);
    ylim([1e-6 , 1])
    xlim([t(1) t(end)])
    set(gca,'YScale','log')
    yticks([ 1e-5 1e-3 1e-1])
    ylabel('Abs. Diff.')
    
    xlabel('Time $t$ $[J^{-1}]$')
   
    samexaxis('xmt','on','ytac','join','yld',1,'YTickAntiClash')
    
    annotation(gcf,'textbox',...
    [0.123746201434722 0.873777279000283 0.0305186246418337 0.0547703180212016],...
    'String','(\textbf{a})',...
    'LineStyle','none',...
    'Interpreter','latex',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off');

    annotation(gcf,'textbox',...
    [0.123746201434722 0.463634421857436 0.0305186246418338 0.0547703180212015],...
    'String','(\textbf{b})',...
    'LineStyle','none',...
    'Interpreter','latex',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off');
end