%% 光沢感変化量の色相間の有意差の有無をカラーマップに表示

clear all;

exp = 'exp_realistic';
sn = 'all';

flag_par = 3;
object = object_paramater(flag_par);

%% 読み込み
load('../../analysis_result/exp_realistic/all/GEindex/GEindex.mat');
load('../../analysis_result/exp_realistic/all/GEindex/BS_GEindex.mat');
load('../../mat/stimuli_color/hue_mean_360.mat');
load('../../mat/stimuli_color/hue_mean_360_mod.mat');

%% 有意差の有無の検定
p_GEindex = cell(1,2);
sig_diff_GEindex = cell(1,2);
for i = 1:object.material_num
    
    if i == 1
        num_sti = numel(object.hue_pair_list)/2;
    elseif i == 2
        num_sti = numel(object.hue_metal_pair_list)/2;
    end
    
    [p_tmp, sig_diff_tmp] = significant_difference_realistic(BS_GEindex{i}, num_sti, flag_par);
    
    p_GEindex{i} = p_tmp;
    sig_diff_GEindex{i} = sig_diff_tmp;
    
end
save(strcat('../../analysis_result/',exp,'/',sn,'/GEindex/p_GEindex'),'p_GEindex');
save(strcat('../../analysis_result/',exp,'/',sn,'/GEindex/sig_diff_GEindex'),'sig_diff_GEindex');

%% 
for i = 1:object.material_num
    
    if i == 1
        num_sti = numel(object.hue_pair_list)/2;
    elseif i == 2
        num_sti = numel(object.hue_metal_pair_list)/2;
    end 
    
    for j = 1:object.light_num
        for k = 1:object.rough_num
            fig = figure;
            
            % 色相名
            hue_name_tmp = round(mean(hue_mean_360_mod{i}(:,j,:), 3));
            hue_name_label = string(hue_name_tmp)';
            hue_name_label = cat(2, hue_name_label, append(hue_name_label, ' achromatic'));
            
            %% p値の整理
            count = 1;
            p_matrix = zeros(num_sti, num_sti);
            sig_diff_matrix = zeros(num_sti, num_sti);
            
            for u = 1:num_sti
                for v = 1:num_sti
                    if v > u
                        p_matrix(u,v) = p_GEindex{i}(count,:,j,k);
                        sig_diff_matrix(u,v) = sig_diff_GEindex{i}(count,:,j,k);
                        count = count + 1;
                    end
                end
            end
            
            p_matrix = p_matrix + p_matrix' + diag(NaN(1,num_sti));
            sig_diff_matrix = sig_diff_matrix + sig_diff_matrix' + diag(NaN(1,num_sti));
            
            %% カラーマップ化
            color_map = zeros(num_sti, num_sti, 3);
            p_str = strings(num_sti);
            c_list_hsv = [[0, 1, 1]; [0, 0.7, 1]; [0, 0.4, 1]];
            c_list = hsv2rgb(c_list_hsv);
            c_list(4:5,:) = [[1,1,1]; [0,0,0]];
            
            for u = 1:num_sti
                for v = 1:num_sti
                    pvalue = p_matrix(u,v);
                    
                    % 有意差の有無をもとに色付け
                    if sig_diff_matrix(u,v) == 1
                        color_map(u,v,:) = c_list(1,:);
                        p_str(u,v) = "";
                    elseif sig_diff_matrix(u,v) == 0
                        color_map(u,v,:) = c_list(4,:);
                        p_str(u,v) = string(pvalue);
                    else
                        color_map(u,v,:) = c_list(5,:);
                        p_str(u,v) = "NaN";
                    end
                end
            end
            
            f = image(color_map);
            ax = gca;
            
            xt = repmat(1:num_sti, [num_sti, 1]);
            yt = repmat((1:num_sti)', [1, num_sti]);
            xt = reshape(xt, [1, numel(xt)]);
            yt = reshape(yt, [1, numel(yt)]);
            p_str = reshape(p_str, [1, numel(p_str)]);
            text(xt, yt, p_str, 'HorizontalAlignment', 'center', 'FontSize', 14);
            
            xticks(1:num_sti);
            yticks(1:num_sti);
            xticklabels(hue_name_label);
            xtickangle(45);
            yticklabels(hue_name_label);
            
            fig.WindowState = 'maximized';
            graph_name = strcat('sig_diff_GEindex_colormap_', object.material(i), '_', object.light(j), '_', object.rough(k), '.png');
            file_name = strcat('../../analysis_result/',exp,'/',sn,'/graph/sig_diff_GEindex_colormap/',graph_name);
            saveas(gcf, file_name);
            close;
        end
    end 

end


%% 物体条件（照明・粗さ）について平均した値について有意差検定・可視化
load('../../analysis_result/exp_realistic/all/GEindex/GEindex_mean_all.mat');
load('../../analysis_result/exp_realistic/all/GEindex/BS_GEindex_mean_all.mat');
clear p_tmp p_sort id_sort sig_diff_tmp

% 有意差の有無の検定
p_GEindex_mean_all = cell(1,2);
sig_diff_GEindex_mean_all = cell(1,2);
B = 10000;
for i = 1:object.material_num
    
    if i == 1
        num_sti = numel(object.hue_pair_list)/2;
    elseif i == 2
        num_sti = numel(object.hue_metal_pair_list)/2;
    end
    
    color_pair = nchoosek(1:num_sti,2);
    p_tmp = zeros(size(color_pair,1),1);
    sig_diff_tmp = zeros(size(color_pair,1),1);
    
    % p値の計算
    for n = 1:size(color_pair,1)
        sample_diff = BS_GEindex_mean_all{i}(:,color_pair(n,1)) - BS_GEindex_mean_all{i}(:,color_pair(n,2));
        sdata = sort(sample_diff);

        % p値
        num = min([nnz(sdata<=0), nnz(sdata>=0)]);
        p_tmp(n,1) = num/B;
    end
    clear n;
    
    % Holm法で有意水準を補正して検定
    [p_sort, id_sort] = sort(p_tmp);
    for n = 1:size(color_pair,1)
        alpha_holm = 0.025/(size(color_pair,1)+1-n);

        if p_sort(n) < alpha_holm
            sig_diff_tmp(id_sort(n),:) = 1;
        else
            sig_diff_tmp(id_sort(n),:) = 0;
            break;
        end
    end
    
    p_GEindex_mean_all{i} = p_tmp;
    sig_diff_GEindex_mean_all{i} = sig_diff_tmp;
    
end
    
% カラーマップ化
for i = 1:object.material_num
    
    if i == 1
        num_sti = numel(object.hue_pair_list)/2;
    elseif i == 2
        num_sti = numel(object.hue_metal_pair_list)/2;
    end 
    
    fig = figure;

    % 色相名
    hue_name_tmp = round(mean(hue_mean_360_mod{i}(:,j,:), 3));
    hue_name_label = string(hue_name_tmp)';

    % p値の整理
    count = 1;
    p_matrix_mean_all = zeros(num_sti, num_sti);
    sig_diff_matrix_mean_all = zeros(num_sti, num_sti);

    for u = 1:num_sti
        for v = 1:num_sti
            if v > u
                p_matrix_mean_all(u,v) = p_GEindex_mean_all{i}(count,:);
                sig_diff_matrix_mean_all(u,v) = sig_diff_GEindex_mean_all{i}(count,:);
                count = count + 1;
            end
        end
    end
    p_matrix_mean_all = p_matrix_mean_all + p_matrix_mean_all' + diag(NaN(1,num_sti));
    sig_diff_matrix_mean_all = sig_diff_matrix_mean_all + sig_diff_matrix_mean_all' + diag(NaN(1,num_sti));

    % カラーマップ化
    color_map = zeros(num_sti, num_sti, 3);
    p_str = strings(num_sti);
    c_list_hsv = [[0, 1, 1]; [0, 0.7, 1]; [0, 0.4, 1]];
    c_list = hsv2rgb(c_list_hsv);
    c_list(4:5,:) = [[1,1,1]; [0,0,0]];

    for u = 1:num_sti
        for v = 1:num_sti
            pvalue = p_matrix_mean_all(u,v);

            % 有意差の有無をもとに色付け
            if sig_diff_matrix_mean_all(u,v) == 1
                color_map(u,v,:) = c_list(1,:);
                p_str(u,v) = "";
            elseif sig_diff_matrix_mean_all(u,v) == 0
                color_map(u,v,:) = c_list(4,:);
                p_str(u,v) = string(pvalue);
            else
                color_map(u,v,:) = c_list(5,:);
                p_str(u,v) = "NaN";
            end
        end
    end

    f = image(color_map);
    ax = gca;

    xt = repmat(1:num_sti, [num_sti, 1]);
    yt = repmat((1:num_sti)', [1, num_sti]);
    xt = reshape(xt, [1, numel(xt)]);
    yt = reshape(yt, [1, numel(yt)]);
    p_str = reshape(p_str, [1, numel(p_str)]);
    text(xt, yt, p_str, 'HorizontalAlignment', 'center', 'FontSize', 14);

    xticks(1:num_sti);
    yticks(1:num_sti);
    xticklabels(hue_name_label);
    xtickangle(45);
    yticklabels(hue_name_label);

    fig.WindowState = 'maximized';
    graph_name = strcat('sig_diff_GEindex_colormap_mean_all_', object.material(i), '.png');
    file_name = strcat('../../analysis_result/',exp,'/',sn,'/graph/sig_diff_GEindex_colormap/',graph_name);
    saveas(gcf, file_name);
    close;
    
end
    
    






