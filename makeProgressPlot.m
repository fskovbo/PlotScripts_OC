function fig = makeProgressPlot(data,legendEntries, maxprop)

    %  ---- data format -----
    % Npropagatons (1) | median (1) | 25 perc (1) | 75 perc (1) | Npropagatons (2) | ...
    
    co = [    0    0.4470    0.7410
         0.8500    0.3250    0.0980
         0.9290    0.6940    0.1250
         0.4940    0.1840    0.5560
         0.4660    0.6740    0.1880
         0.3010    0.7450    0.9330
         0.6350    0.0780    0.1840];
    
  
    fig = figure;
    box on
    hold on
    
    minval = 1;
    
    for i = 1:(size(data,2))/4
        Nprop   = data(:,1 + (i-1)*4);
        algdata = data(:,(2+(i-1)*4):(4*i));
        color   = co(i,:);
        
        xx = [Nprop' , fliplr(Nprop')];
        yy = [algdata(:,2)' , fliplr(algdata(:,3)')];
        fill(xx,yy,color,'FaceAlpha',0.4,'EdgeColor','none');
        p(i) = plot(Nprop,algdata(:,2),'Linewidth',2,'Color',color);
        plot(Nprop,algdata(:,3),'Linewidth',2,'Color',color);
        plot(Nprop,algdata(:,1),'LineStyle',':','Linewidth',2,'Color',color);
        
        minval = min([minval, algdata(end,2)]);
    end

    xlabel('Number of Time Evolutions')
    ylabel('Cost $\mathcal{J}$')
    set(gca,'YScale','log')
    
    xlim([0 , maxprop])
    ylim([0.5*minval , 1])
    
    legend(p,legendEntries)

end