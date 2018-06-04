function [Tlist , Flist, fnlist] = extractFinalFidelity(directory)
 
    searchstr = [directory '*BHrampInitialFinal.txt'];
    Files = dir( searchstr );
    j = 1;
    for k = 1:length(Files)
        filename    = [directory Files(k).name];
        s           = dir(filename);
        if s.bytes == 0
            % empty file
        else
            % open the file and read it
            rampData    = dlmread(filename);
    
            Tlist(j)    = rampData(end,1);
            Flist(j)    = rampData(end,end);
            fnlist{j}   = strtok(filename,'B');
            j = j + 1;
        end
        
    end
end