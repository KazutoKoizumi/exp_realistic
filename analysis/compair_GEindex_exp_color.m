%% 実験1と選好尺度値を比較する

clear all;

exp = 'exp_realistic';
sn = 'all';

flag_par = 3;
object = object_paramater(flag_par);
object_exp1 = object_paramater(1);
idx_exp1 = make_index(1);

% 実験1の結果
load('../../../exp_luminance_gloss/data/for_paper/exp1/CG_effect.mat');
load('../../../exp_luminance_gloss/data/for_paper/exp1/BS.mat');
load('../../../exp_luminance_gloss/mat/regress_var/gloss_diff.mat');

% 実験3の結果
load('../../analysis_result/exp_realistic/all/GEindex/GEindex_mod.mat');
load('../../analysis_result/exp_realistic/all/GEindex/GEindex_mod_mean_all.mat');
load('../../analysis_result/exp_realistic/all/GEindex/BS_GEindex_mod.mat');
load('../../analysis_result/exp_realistic/all/GEindex/BS_GEindex_mod_mean_all.mat');
load('../../analysis_result/exp_realistic/all/GEindex/CI95_GEindex_mod.mat');
load('../../analysis_result/exp_realistic/all/GEindex/CI95_GEindex_mod_mean_all.mat');

%% 色相ごとの光沢感変化量の単純な比較
for i = 1:object.material_num
    
    if i == 1
        m = 2;
    elseif i == 2
        m = 1;
    end
    
    num_chromatic = 8;
    count = 1;
    for j = 1:object.light_num
        for k = 1:object.rough_num
            
            idx_method = idx_exp1(m:2:end,:);
            
            % 実験1の結果
            id_diff_ref = 1; % 実験1の拡散反射率(1:0.1, 2:0.3, 3:0.5)
            id_exp1 = find(idx_method(:,1)==1 & idx_method(:,2)==j & idx_method(:,3)==id_diff_ref & idx_method(:,4)==k & idx_method(:,5)==m); 
            GEindex_exp1 = gloss_diff.all(id_exp1,:,m);
            GEindex_exp1_method(count,:,i) = GEindex_exp1; % 1:D条件、2:SD条件 (プラスチック条件と金属条件に順番を対応させる)
            count = count + 1;
            
            % 実験3の結果
            GEindex_exp3 = GEindex_mod{i}(:,1:8,j,k);
            CI95_exp3 = CI95_GEindex_mod{i}(:,1:8,j,k);
            err = abs(GEindex_exp3 - CI95_exp3);
            
            %% プロット
            figure;
            hold on;
            
            x = 1:num_chromatic;
            x1 = x-0.2;
            x2 = x+0.2;
            bar_width = 0.4; 
            
            bar(x1, GEindex_exp1, bar_width);
            bar(x2, GEindex_exp3, bar_width);
            errorbar(x2, GEindex_exp3, err(1,:), err(2,:), 'o', 'Color', [0 0 0]);
            
            xticks(x);
            xticklabels({'0', '45', '90', '135', '180', '225', '270', '315'});
            xtickangle(45);
            
            legend({'exp1', 'exp3'}, 'Location', 'northeastoutside');
            title('GE index');
            
            graphName = strcat('GEindex_compair_',object.material(i),'_',object.light(j),'_',object.rough(k),'.png');
            fileName = strcat('../../analysis_result/',exp,'/',sn,'/graph/GEindex_compair/',graphName);
            saveas(gcf, fileName);
            
        end
    end
end
close all;

% 平均をプロット
for i = 1:object.material_num
    figure;
    hold on;
    
    err = abs(GEindex_mod_mean_all{i}(1:8) - CI95_GEindex_mod_mean_all{i}(:,1:8));
    
    bar(x1, mean(GEindex_exp1_method(:,:,i),1), bar_width); % 順番を変更済み
    bar(x2, GEindex_mod_mean_all{i}(1:8), bar_width);
    errorbar(x2, GEindex_mod_mean_all{i}(1:8), err(1,:), err(2,:), 'o', 'Color', [0 0 0]);
    
    xticks(x);
    xticklabels({'0', '45', '90', '135', '180', '225', '270', '315'});
    xtickangle(45);
    
    legend({'exp1', 'exp3'}, 'Location', 'northeastoutside');
    title('GE index');
end

%% 相関
for i = 1:object.material_num
    
    if i == 1
        m = 2;
    elseif i == 2
        m = 1;
    end
    
    num_chromatic = 8;
    figure;
    hold on;
    count = 1;
    for j = 1:object.light_num
        for k = 1:object.rough_num
            
            idx_method = idx_exp1(m:2:end,:);
            
            % 実験1の結果
            id_diff_ref = 1; % 実験1の拡散反射率(1:0.1, 2:0.3, 3:0.5)
            id_exp1 = find(idx_method(:,1)==1 & idx_method(:,2)==j & idx_method(:,3)==id_diff_ref & idx_method(:,4)==k & idx_method(:,5)==m); 
            GEindex_exp1 = gloss_diff.all(id_exp1,:,m);
            
            % 実験3の結果
            GEindex_exp3 = GEindex_mod{i}(:,1:8,j,k);
            CI95_exp3 = CI95_GEindex_mod{i}(:,1:8,j,k);
            err = abs(GEindex_exp3 - CI95_exp3);
            
            lgd_txt{count} = strcat(object.light(j), '  roughness:', num2str(object.rough_v(k)));
            
            % 散布図
            scatter(GEindex_exp1, GEindex_exp3);
            
            count = count+1;
        end
    end
    
    xlabel('GEindex exp1');
    ylabel('GEindex exp3');
    
    legend(lgd_txt);
end
