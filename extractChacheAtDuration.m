function [iter , cost , Nprop] = extractChacheAtDuration(directory,fileID,comm)
    
    searchstr = [fileID ,  '*ProgressCache.txt'];
    Files = dir( searchstr ); 
    for k = 1:length(Files)
        filename    = [directory Files(k).name];
        cacheData   = dlmread(filename);
        
        cost_ar{k}       = cacheData(:,2);
        iter_lng(k)      = size(cacheData,1);
        prop_ar{k}       = cacheData(:,4);
        prop_N(k)        = cacheData(end,4);
        prop_1(k)        = cacheData(1,4);
    end
    
    % if Npropagations is not commulative make it
    if ~comm 
       for k = 1:length(prop_ar)
           propvec = prop_ar{k};
           
           for i = 2:length(propvec)
                propvec(i) = propvec(i) + propvec(i-1);
           end
           
           prop_ar{k} = propvec;
           prop_N(k)  = propvec(end);
       end
    end
    
    % interpolate data such it has uniform length  
    max_lng     = max(iter_lng);
    min_prop    = max(prop_1);
    max_prop    = max(prop_N);
    iter        = (1:max_lng)'; 
    Nprop       = (min_prop:max_prop+1)';
    
    for k = 1:length(iter_lng)      
       % extend cost
       ck   = cost_ar{k};
       pk   = prop_ar{k};
       
       pku  = unique(pk);
       cku  = ck(1:length(pku));
       
       cost(:,k) = interp1( [pku ; (max_prop+1)] , [cku ; cku(end)] , Nprop );
    end
    
end