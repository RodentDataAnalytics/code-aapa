function [idx,centroids,w,init_centers] = run_mpckmeans(x,k,constr)
%RUN_MPCKMEANS

    [~,~,~,~,~,init_centers,~] = mpckmeans(x,k,constr,'init_only',1);

    %constr = [constr(:,2),constr(:,1)];
    save('lastrun.mat','x','constr','k');
    [idx,centroids] = Jmpckmeans(x, constr, k);
    idx = double(idx')+1;
    %final weights
    fileID1 = fopen('WeightsFinal.txt');
    tline = fgetl(fileID1);
    w = nan(1,size(x,2));
    kk = 1;
    while ischar(tline)
        w(1,kk) = str2double(tline);
        tline = fgetl(fileID1);
        kk = kk+1;
    end                
    fclose(fileID1);
end
