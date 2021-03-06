function fig = makeCompFidelityPlot(data,legendEntries)

    %  ---- data format -----
    % T(1) | median (1) | 25 perc (1) | 75 perc (1) | best (1) | T (2) |
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
        T       = data(:,1 + (i-1)*5);
        algdata = data(:,(2+(i-1)*5):(i*5));
        color   = co(i,:);
        
        xx = [T' , fliplr(T')];
        yy = [algdata(:,2)' , fliplr(algdata(:,3)')];
        fill(xx,yy,color,'FaceAlpha',0.4,'EdgeColor','none');
        p(i) = plot(T,algdata(:,2),'Linewidth',2,'Color',color);
        plot(T,algdata(:,3),'Linewidth',2,'Color',color);
        plot(T,algdata(:,1),'LineStyle',':','Linewidth',2,'Color',color);
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
        T       = data(:,1 + (i-1)*5);
        algdata = data(:,(2+(i-1)*5):(i*5));
        color   = co(i,:);
        
        plot(T,1-algdata(:,4),'Linewidth',2,'Color',color);
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
    
    
    xlabel('Duration $T$ $[ J^{-1} ]$','FontSize',12)
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