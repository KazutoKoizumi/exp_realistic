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
