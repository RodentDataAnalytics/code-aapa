 function cm = clustering_correlation_matrix(feat_val,idx,centroids)    
    % measure the correlation between two matrices
    % defined by the first N elements of two clusters
    % (where N is the size of the smallest cluster).
    % Sort elements by their respective distance to the
    % centroids

    k = length(unique(idx)); %must assume k = 1:K, no gaps
    cm = zeros(k, k);
    
    for ic = 1:k
        for jc = ic:k
            if ic == jc
                cm(ic, jc) = 1;
                cm(jc, ic) = 1;
            else
                sel1 = find(idx == ic);
                sel2 = find(idx == jc);

                feat_norm1 = max(feat_val(sel1, :)) - min(feat_val(sel1, :));            
                feat_norm2 = max(feat_val(sel2, :)) - min(feat_val(sel2, :));            

                dist1 = sum(((feat_val(sel1, :) - repmat(centroids(:, ic)', length(sel1), 1)) ./ repmat(feat_norm1, length(sel1), 1)).^2, 2);
                dist2 = sum(((feat_val(sel2, :) - repmat(centroids(:, jc)', length(sel2), 1)) ./ repmat(feat_norm2, length(sel2), 1)).^2, 2);

                [~, ord] = sort(dist1);
                sel1 = sel1(ord);
                [~, ord] = sort(dist2);
                sel2 = sel2(ord);

                n1 = length(sel1);
                n2 = length(sel2);
                n = min(n1, n2);                                

                % compute the correlation between n elements
                rho = corr2( feat_val(sel1(1:n), :), feat_val(sel2(1:n), :) );
                cm(ic, jc) = rho;
                cm(jc, ic) = rho;                                    
            end
        end
    end
 end