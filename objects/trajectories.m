classdef trajectories < handle
    %TRAJECTORIES Summary of this class goes here
    %   Detailed explanation goes here
    properties(GetAccess = 'public', SetAccess = 'public')
        % use two-phase clustering
        clustering_two_phase = 1;
        % force use of must link constraints in the first phase
        clustering_must_link = 0;
    end
    
    properties(GetAccess = 'public', SetAccess = 'public')
        items = [];        
        parent = []; % parent set of trajectories (if these are the segments)
    end
    
    properties(GetAccess = 'public', SetAccess = 'public')
        hash_ = -1;
        trajhash_ = [];
        partitions_ = [];       
        parent_mapping_ = [];
        segmented_idx_ = [];
        segmented_map_ = [];        
    end
    
    methods
        % constructor
        function inst = trajectories(traj)
            if nargin == 1
                inst.items = traj;            
            end
        end
               
        function sz = count(obj)
            sz = length(obj.items);            
        end          
        
        function obj2 = append(obj, x)
            obj2 = trajectories([]);    
            if isa(x, 'trajectory')
                obj2.items = [obj.items, x];                            
            elseif isa(x, 'trajectories')
                obj2.items = [obj.items, x.items];                
            else
                error('Ops');
            end
        end    
        
        function idx = index_of(obj, set, trial, track, off, len)
            if isempty(obj.trajhash_ )
               % compute hashes of trajectories and add them to a hashtable               
               obj.trajhash_ = containers.Map(arrayfun( @(t) t.hash_value, obj.items), 1:obj.count);
            end
            
            hash = trajectory.compute_hash(set, trial, track, off, len);
            % do we have it?
            if obj.trajhash_.isKey(hash)
                idx = obj.trajhash_(hash);
            else
                idx = -1;
            end            
        end            
        
        function out = hash_value(obj)            
            if obj.hash_ == -1                                          
                % compute hash
                if obj.count == 0
                    obj.hash_ = 0;
                else
                    obj.hash_ = obj.items(1).hash_value;
                    for i = 2:obj.count                        
                        obj.hash_ = hash_combine(obj.hash_, obj.items(i).hash_value);
                    end
                end                
            end
            out = obj.hash_;
        end
        
        function [ segments, partition, cum_partitions ] = partition(obj, f, nmin, varargin)
        %   SEGMENT(LSEG, OVLP) breaks all trajectories into segments
        %   of length LEN and overlap OVL (given in %)   
        %   returns an array of trajectory segments
            
            % see if cached
            cache_dir = globals.CACHE_DIRECTORY;
            fhash = f.hash_value;
            id = hash_value( [obj.hash_value, f.hash_value, nmin ] );
            id = hash_combine (id, hash_value( [varargin] ) );             
            fn = fullfile(cache_dir, ['segments_', num2str(id), '.mat']);
            if exist(fn, 'file')            
                load(fn);  
                segments = seg;
            else                                          
                fprintf('Segmenting trajectories... ');
                [progress, nmax] = process_options(varargin, 'ProgressCallback', [], ...
                                                             'MaxSegments', 0);

                % construct new object
                segments = trajectories([]);
                partition = zeros(1, obj.count);
                cum_partitions = zeros(1, obj.count);
                p = 1;
                off = 0;
                for i = 1:obj.count                
                    newseg = f.apply1(obj.items(i));

                    if ~isempty(newseg) && newseg.count >= nmin                    
                        if nmax > 0 && nmax < newseg.count                            
                            segments = segments.append(newseg.items(1:nmax));
                        else
                            segments = segments.append(newseg);
                        end
                        partition(i) = newseg.count;
                        cum_partitions(i) = off;
                        off = off + newseg.count;
                    else
                        cum_partitions(i) = off;
                    end

                    if segments.count > p*500
                        fprintf('%d ', segments.count);
                        p = p + 1;
                        if ~isempty(progress)
                            mess = sprintf('Segmenting trajectories [total segments: %d]', segments.count);
                            if progress(mess, i/obj.count)
                                error('Operation cancelled');
                            end
                        end
                    end  
                end
                segments.partitions_ = partition;
                segments.parent = obj;

                fprintf(': %d segments created.\n', segments.count);
            
                % cache it for next time
                seg = segments;
                save(fn, 'seg');
            end
        end
        
        function out = partitions(inst)
            if inst.count > 0 && isempty(inst.partitions_)
                id = [-1, -1, -1];
                n = 0;
                for i = 1:inst.count    
                    if ~isequal(id, inst.items(i).data_identification)
                        if n > 0
                           inst.partitions_ = [inst.partitions_, n];
                        end
                        id = inst.items(i).data_identification;                            
                    end
                    n = n + 1;
                end
                if n > 0
                    inst.partitions_ = [inst.partitions_, n];
                end                        
            end
            out = inst.partitions_;
        end
        
        function out = parent_mapping(inst)
            if inst.count > 0 && ~isempty(inst.partitions) && isempty(inst.parent_mapping_)
                inst.parent_mapping_ = zeros(1, inst.count);
                idx = 0;
                tmp = inst.partitions();
                for i = 1:length(tmp)
                    for j = 1:tmp(i);
                        idx = idx + 1;                        
                        inst.parent_mapping_(idx) = i;
                    end
                end                                                
            end
            out = inst.parent_mapping_;
        end
        
        function out = segmented_index(inst)
            if inst.count > 0 && ~isempty(inst.partitions) && isempty(inst.segmented_idx_)
                inst.segmented_idx_ = find(inst.partitions > 0);                
            end
            out = inst.segmented_idx_;
        end
        
        function out = segmented_mapping(inst)
            if inst.count > 0 && ~isempty(inst.partitions) && isempty(inst.segmented_map_)                
                inst.segmented_map_ = zeros(1, length(inst.partitions));
                inst.segmented_map_(inst.partitions > 0) = 1:sum(inst.partitions > 0);
            end
            out = inst.segmented_map_;
        end                
     
        function featval = compute_features_pca(obj, feat, nfeat)
            featval = obj.compute_features(feat);            
            % featval = (featval - repmat(min(featval), size(featval, 1), 1)) ./ repmat( max(featval) - min(featval), size(featval, 1), 1);
            [coeff, score] = pca(featval, 'Centered', 'on');
                
            featval = featval*coeff(:, 1:nfeat);                
        end
        
        function featval = compute_features(obj, feat, varargin)
            %COMPUTE_FEATURES Computes feature values for each trajectory/segment. Returns a vector of
            %   features.                        
            [progress] = process_options(varargin, ...
                               'ProgressCallback', []);
                           
            featval = zeros(obj.count, length(feat));            
            for idx = 1:length(feat)
                id = feat(idx).hash_value;
                desc = feat(idx).description;
                % check if we already have the values for this feature cached
                key = hash_combine(obj.hash_value, id);
            
                fn = fullfile(globals.CACHE_DIRECTORY, ['features_' num2str(key) '.mat']);
                if exist(fn, 'file')
                    load(fn);                    
                    featval(:, idx) = tmp;
                else                    
                    % not cached - compute it we shall
                    fprintf('\nComputing ''%s'' feature values for %d trajectories/segments...', desc, obj.count);
                    
                    q = floor(obj.count / 1000);
                    fprintf('0.0% ');                                        
                
                    for i = 1:obj.count
                        % compute and append feature values for each segment
                        featval(i, idx) = obj.items(i).compute_feature(feat(idx));

                        if mod(i, q) == 0
                            val = 100.*i/obj.count;
                            if val < 10.
                                fprintf('\b\b\b\b\b%02.1f%% ', val);
                            else
                                fprintf('\b\b\b\b\b%04.1f%%', val);
                            end    
                            
                            if ~isempty(progress)
                                mess = sprintf('[%d/%d] Computing ''%s'' feature values', idx, length(feat), desc);
                                if progress(mess, i/obj.count)
                                    error('Operation cancelled');
                                end                                
                            end
                        end                       
                    end
                    fprintf('\b\b\b\b\bDone.\n');
                    
                    % save it
                    tmp = featval(:, idx);
                    save(fn, 'tmp');                    
                end                                                
            end                                            
        end
                 
        function [map, idx, tag_map] = match_tags(obj, labels, tags, sel_tags)
            % start with an empty set
            map = zeros(obj.count, length(tags));
            idx = repmat(-1, 1, length(labels));
                                
            % for each label
            for i = 1:size(labels, 1)
                % see if we have this trajectory/segment
                id = labels{i, 1};
                if isempty(id)
                    continue;
                end

                pos = obj.index_of(id(1), id(2), id(3), id(4), id(5));
                if pos ~= -1
                    idx(i) = pos;
                    % add labels        
                    tmp = labels{i, 2};
                    for k = 1:length(tmp)
                        map(pos, tmp(k)) = 1;                        
                    end                    
                end                
            end 
            
            if nargin > 3 && ~isempty(sel_tags)
                tag_map = zeros(1, length(tags));
                % remap labels
                new_map = zeros(length(map), length(sel_tags));                
                for i = 1:length(tags)
                    tag_map(i) = 0; % default = no mapping
                    for j = 1:length(sel_tags)
                        if sel_tags(j).matches(tags(i).abbreviation)
                            tag_map(i) = j;
                            new_map(:, j) = new_map(:,j) | map(:, i);
                            break;
                        end
                    end
                end
                % replace tags with new selection
                map = new_map;
            else
                tag_map = 1:length(tags);
            end
        end                   
                              
        function res = classifier(inst, config, traj_tags, selected_tags)
            if isempty(selected_tags)
                selected_tags = config.TAGS;
            end
            labels_map = traj_tags.matrix(selected_tags);
            labels_set = sum(labels_map, 2) > 0;
            
            % add the 'undefined' tag index
            undef_tag_idx = tag.tag_position(selected_tags, base_config.UNDEFINED_TAG.abbreviation);
            if undef_tag_idx > 0
                selected_tags = selected_tags([1:undef_tag_idx - 1, (undef_tag_idx + 1):length(selected_tags)]);          
                tag_new_idx = [1:undef_tag_idx, undef_tag_idx:length(selected_tags)];
                tag_new_idx(undef_tag_idx) = 0;
            else
                tag_new_idx = 1:length(selected_tags);
            end
            
            labels = repmat({-1}, 1, inst.count);
            for i = 1:inst.count
                class = find(labels_map(i, :) == 1);
                if ~isempty(class)
                    % for the 'undefined' class set label idx to zero..
                    if class(1) == undef_tag_idx
                        labels{i} = 0;
                    else
                        % rebase all tags after the undefined index
                        labels{i} = arrayfun( @(x) tag_new_idx(x), class);
                    end                                       
                end
            end
                         
            % unmatched = find(labels_idx == -1);
            extra_lbl = {};
            extra_feat = []; 
           % extra_ids = [];
            
            % TODO: reimplement/rerhink the mixing of trajectory labels
%             if ~isempty(unmatched)
%                 % load all trajectories
%                 cache_trajectories;
%             
%                 for i = 1:length(unmatched)
%                     id = labels_data{unmatched(i), 1};
%                     % unmatched segments - look at the global trajectories cache               
%                     idx = g_trajectories.index_of(id(1), id(2), id(3), -1, 0);                
%                     if idx == -1
%                         fprintf('Warning: could not match label #%d to any trajectory\n', unmatched(i));
%                     else
%                         seg = g_trajectories.items(idx).sub_segment(id(4), id(5));
%                         extra_feat = [extra_feat; seg.compute_features(feat)];
%                         tmp = labels_data{unmatched(i), 2};
%                         extra_lbl = [extra_lbl, tag_new_idx(tmp)];
%                         extra_ids = [extra_ids; id];
%                     end
%                 end
%             end                
             % feat_val = [extra_feat; inst.compute_features(feat)];
            feat_val = config.clustering_feature_values;            
                         
            res = semisupervised_clustering(config, inst, feat_val, [extra_lbl, labels], selected_tags, length(extra_lbl));            
        end   
                
        
        function [mapping] = match_segments(inst, other_seg, varargin)
            addpath(fullfile(fileparts(mfilename('fullpath')), '/extern'));
            [seg_dist, tolerance, len_tolerance] = process_options(varargin, ...
                'SegmentDistance', 0, 'Tolerance', 20, 'LengthTolerance', 0 ...
            );            
            
            if len_tolerance == 0
                len_tolerance = tolerance;
            end
            mapping = ones(1, inst.count)*-1;
            idx = 1;
            if other_seg.count > inst.count            
                for i = 1:other_seg.count
                    while( ~isequal(inst.items(idx).data_identification, other_seg.items(i).data_identification) || ...
                             inst.items(idx).offset < other_seg.items(i).offset - seg_dist - tolerance)                      
                        idx = idx + 1;                    
                        if idx == inst.count
                            break;
                        end                    
                    end
                    % all right now try to match the offset
                    if abs(inst.items(idx).offset - other_seg.items(i).offset) < seg_dist + tolerance && ...
                       abs(inst.items(idx).compute_feature(features.LENGTH) - other_seg.items(i).compute_feature(features.LENGTH)) < len_tolerance
                        % we have a match!
                        mapping(idx) = i;
                        idx = idx + 1;                    
                    end               
                    if idx == inst.count
                        break;
                    end
                end
            else
                for i = 1:inst.count                    
                    if( ~isequal(other_seg.items(idx).data_identification, inst.items(i).data_identification))
                       continue;
                    end    
                    % test if we overshoot the segment                   
                    loop = 0;
                    while (other_seg.items(idx).offset < inst.items(i).offset - seg_dist - tolerance)                        
                        if ~isequal(other_seg.items(idx).data_identification, inst.items(i).data_identification)
                            loop = 1;
                            break;
                        end
                        idx = idx + 1;                    
                        if idx == other_seg.count
                            break;
                        end                    
                    end
                    if loop
                        continue;
                    end
                    % all right now try to match the offset
                    if abs(inst.items(i).offset - seg_dist - other_seg.items(idx).offset) < tolerance && ...
                       abs(inst.items(i).compute_feature(base_config.FEATURE_LENGTH) - other_seg.items(idx).compute_feature(base_config.FEATURE_LENGTH)) < len_tolerance
                        % we have a match!
                        mapping(i) = idx;
                        idx = idx + 1;                  
                    end               
                    if idx == other_seg.count
                        break;
                    end
                end
            end
        end                     
    end        
end