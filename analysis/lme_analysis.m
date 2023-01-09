%% 線形混合モデル（実験3）
% 目的変数：光沢感変化量
% 固定効果：説明変数
% 変量効果：物体条件の切片と係数への効果

clear all;

flag_par = 3;
object = object_paramater(flag_par);
pass.mat = '../../mat/';

%% 変数準備
% 目的変数
load('../../analysis_result/exp_realistic/all/GEindex/GEindex.mat');

% 説明変数

load('../../mat/regress_var/highlight_lum_diff.mat');
load('../../mat/regress_var/contrast_diff.mat');
load('../../mat/regress_var/color_diff.mat');
pass_save = '../../analysis_result/exp_realistic/all/LME_result/';
%}

%{
load('../../mat/regress_var/HL_30per/highlight_lum_diff.mat');
load('../../mat/regress_var/HL_30per/contrast_diff.mat');
load('../../mat/regress_var/HL_30per/color_diff.mat');
pass_save = '../../analysis_result/exp_realistic/all/LME_result/HL_30per/';
%}

load('../../mat/stimuli_color/hue_mean_360.mat');
load('../../mat/stimuli_color/hue_mean_360_mod.mat');

%% 変数整理
for i = 1:object.material_num
    
    switch i
        case 1
            hue_num = object.hue_num;
        case 2
            hue_num = object.hue_metal_num;
    end
    
    for j = 1:object.light_num
        for k = 1:object.rough_num

            switch i
                case 1
                    % 素材条件ごとに抜き出す
                    pla.gloss_diff.all_reshape = reshape(GEindex{i}, [numel(GEindex{i}), 1]);
                    pla.HL_lum_diff.all_reshape = reshape(highlight_lum_diff{i}, [numel(highlight_lum_diff{i}), 1]);
                    pla.contrast_diff.all_reshape = reshape(contrast_diff{i}, [numel(contrast_diff{i}), 1]);
                    pla.color_diff.all_reshape = reshape(color_diff{i}, [numel(color_diff{i}), 1]);
                    
                    % z-score化
                    pla.gloss_diff.normalized = normalize(pla.gloss_diff.all_reshape);
                    pla.HL_lum_diff.normalized = normalize(pla.HL_lum_diff.all_reshape);
                    pla.contrast_diff.normalized = normalize(pla.contrast_diff.all_reshape);
                    pla.color_diff.normalized = normalize(pla.color_diff.all_reshape);
                case 2
                    % 素材条件ごとに抜き出す
                    metal.gloss_diff.all_reshape = reshape(GEindex{i}, [numel(GEindex{i}), 1]);
                    metal.HL_lum_diff.all_reshape = reshape(highlight_lum_diff{i}, [numel(highlight_lum_diff{i}), 1]);
                    metal.contrast_diff.all_reshape = reshape(contrast_diff{i}, [numel(contrast_diff{i}), 1]);
                    metal.color_diff.all_reshape = reshape(color_diff{i}, [numel(color_diff{i}), 1]);
                    
                    % z-score化
                    metal.gloss_diff.normalized = normalize(metal.gloss_diff.all_reshape);
                    metal.HL_lum_diff.normalized = normalize(metal.HL_lum_diff.all_reshape);
                    metal.contrast_diff.normalized = normalize(metal.contrast_diff.all_reshape);
                    metal.color_diff.normalized = normalize(metal.color_diff.all_reshape);
            end
            
        end
    end
    
    switch i
        case 1
            % 変量効果用の変数
            pla.obj_condition = reshape(repmat(1:6, [hue_num,1]), [6*hue_num, 1]);
            
            % 物体条件について平均
            pla.gloss_diff.obj_mean = mean(GEindex{i}, [3,4]);
            pla.HL_lum_diff.obj_mean = mean(highlight_lum_diff{i}, [3,4]);
            pla.contrast_diff.obj_mean = mean(contrast_diff{i}, [3,4]);
            pla.color_diff.obj_mean = mean(color_diff{i}, [3,4]);
            
        case 2
            % 変量効果用の変数
            metal.obj_condition = reshape(repmat(1:6, [hue_num,1]), [6*hue_num, 1]);
            
            % 物体条件について平均
            metal.gloss_diff.obj_mean = mean(GEindex{i}, [3,4]);
            metal.HL_lum_diff.obj_mean = mean(highlight_lum_diff{i}, [3,4]);
            metal.contrast_diff.obj_mean = mean(contrast_diff{i}, [3,4]);
            metal.color_diff.obj_mean = mean(color_diff{i}, [3,4]);
            
    end
    
end

%% 相関
% 物体条件全体で正規化された値を色相ごとに物体条件について平均し、色相方向の変化について相関を見る
for i = 1:2
    switch i
        case 1
            hue_num = object.hue_num;
            
            % 全体に対して正規化されたデータを「物体条件*8色相」の形にする
            pla.gloss_diff.normalized_reshape = reshape(pla.gloss_diff.normalized, [hue_num, 6])';
            pla.HL_lum_diff.normalized_reshape = reshape(pla.HL_lum_diff.normalized, [hue_num, 6])';
            pla.contrast_diff.normalized_reshape = reshape(pla.contrast_diff.normalized, [hue_num, 6])';
            pla.color_diff.normalized_reshape = reshape(pla.color_diff.normalized, [hue_num, 6])';
            
            % 物体条件について平均
            pla.gloss_diff.normalized_mean = mean(pla.gloss_diff.normalized_reshape, 1);
            pla.HL_lum_diff.normalized_mean = mean(pla.HL_lum_diff.normalized_reshape, 1);
            pla.contrast_diff.normalized_mean = mean(pla.contrast_diff.normalized_reshape, 1);
            pla.color_diff.normalized_mean = mean(pla.color_diff.normalized_reshape, 1);
            
            % 相関
            pla.variables_mean = [pla.gloss_diff.normalized_mean', pla.HL_lum_diff.normalized_mean', pla.contrast_diff.normalized_mean', pla.color_diff.normalized_mean'];
            pla.corrcoef_hue = corrcoef(pla.variables_mean);
        case 2
            hue_num = object.hue_metal_num;
            
            % 全体に対して正規化されたデータを「物体条件*8色相」の形にする
            metal.gloss_diff.normalized_reshape = reshape(metal.gloss_diff.normalized, [hue_num, 6])';
            metal.HL_lum_diff.normalized_reshape = reshape(metal.HL_lum_diff.normalized, [hue_num, 6])';
            metal.contrast_diff.normalized_reshape = reshape(metal.contrast_diff.normalized, [hue_num, 6])';
            metal.color_diff.normalized_reshape = reshape(metal.color_diff.normalized, [hue_num, 6])';
            
            % 物体条件について平均
            metal.gloss_diff.normalized_mean = mean(metal.gloss_diff.normalized_reshape, 1);
            metal.HL_lum_diff.normalized_mean = mean(metal.HL_lum_diff.normalized_reshape, 1);
            metal.contrast_diff.normalized_mean = mean(metal.contrast_diff.normalized_reshape, 1);
            metal.color_diff.normalized_mean = mean(metal.color_diff.normalized_reshape, 1);
            
            % 相関
            metal.variables_mean = [metal.gloss_diff.normalized_mean', metal.HL_lum_diff.normalized_mean', metal.contrast_diff.normalized_mean', metal.color_diff.normalized_mean'];
            metal.corrcoef_hue = corrcoef(metal.variables_mean);
    end
end

% 色相間での各変数の変化を可視化する
%graph_color = [[0 0 0]; [0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]];
graph_color = [[0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]; [0.4660 0.6740 0.1880]];
for i = 1:2
    switch i
        case 1
            hue_num = object.hue_num;
        case 2
            hue_num = object.hue_metal_num;
    end
    
    figure;
    hold on;
    
    x = mean(hue_mean_360_mod{i}, [2 3]);
    for n = 1:4
        switch i
            case 1
                h_color(n) = plot(x, pla.variables_mean(:,n), '-o', 'Color', graph_color(n,:));
            case 2
                h_color(n) = plot(x(1:8), metal.variables_mean(1:8,n), '-o', 'Color', graph_color(n,:));
                %h_cuau(n) = plot(x(9:10), metal.variables_mean(9:10,n), '-s', 'Color', graph_color(n,:));
                
                h_cuau(1) = plot(x(9), metal.variables_mean(9,n), 's', 'Color', graph_color(n,:));
                h_cuau(2) = plot(x(10), metal.variables_mean(10,n), 'd', 'Color', graph_color(n,:));
        end
    end
    ax = gca;
    
    xlabel('Color direction (degree)', 'FontSize', 16);
    xlim([-10 360]);
    ylabel('Value', 'FontSize', 16);
    ylim([-2 2]);
    ax.FontSize = 14;
    
    lgd_txt = {'GE-index', 'highlight brightness', 'brightness contrast', 'color contrast'};
    lgd = legend(lgd_txt, 'FontSize', 14);
    lgd.Location = 'best';
    
    %lgd_txt = {'GE-index', 'highlight brightness', 'brightness contrast', 'color contrast'};
    %legend(h_color, lgd_txt, 'FontSize', 14, 'Location', 'eastoutside');
    file_name = strcat(pass_save, 'variables_hue_value_', object.material(i), '.png');
    saveas(gcf, file_name);
    
    hold off;
    
end
%}

%% 線形混合モデル
tbl_pla = table(pla.gloss_diff.normalized, pla.HL_lum_diff.normalized, pla.contrast_diff.normalized, pla.color_diff.normalized, pla.obj_condition, 'VariableNames', {'gloss_diff', 'lum_diff', 'lum_contrast_diff', 'color_diff', 'object_condition'});
tbl_metal = table(metal.gloss_diff.normalized, metal.HL_lum_diff.normalized, metal.contrast_diff.normalized, metal.color_diff.normalized, metal.obj_condition, 'VariableNames', {'gloss_diff', 'lum_diff', 'lum_contrast_diff', 'color_diff', 'object_condition'});

lme_pla = fitlme(tbl_pla, 'gloss_diff ~ lum_diff + lum_contrast_diff + color_diff + (1|object_condition) + (lum_diff-1|object_condition) + (lum_contrast_diff-1|object_condition) + (color_diff-1|object_condition)')
lme_pla.Rsquared
lme_metal = fitlme(tbl_metal, 'gloss_diff ~ lum_diff + lum_contrast_diff + color_diff + (1|object_condition) + (lum_diff-1|object_condition) + (lum_contrast_diff-1|object_condition) + (color_diff-1|object_condition)')
lme_metal.Rsquared

for i = 1:object.material_num
    figure;
    x = 1:3;
    switch i
        case 1
            y = lme_pla.Coefficients.Estimate(2:end)';
        case 2
            y = lme_metal.Coefficients.Estimate(2:end)';
    end
    
    bar(x,y);
    ax = gca;
    
    xticks(x);
    xticklabels(["highlight brightness", "brightness contrast", "color contrast"]);
    xtickangle(45);
    %ylabel("Regression coefficient");
    ylim([-0.10 0.6]);
    yticks(-0.1:0.1:0.6);
    ax.FontSize = 14;
    
    file_name = strcat(pass_save, 'LME_result_', object.material(i), '.png');
    saveas(gcf, file_name);

end

%% 物体条件ごとに説明変数可視化（正規化なし）
graph_color = [[0 0 0]; [0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]];
clear y;
for i = 1:object.material_num
    f = figure;
    count_panel = 0;
    
    if i == 1
        hue_name = object.hue;
        hue_num = object.hue_num;
    elseif i == 2
        hue_name = object.hue_metal;
        hue_num = object.hue_metal_num;
    end
    
    for j = 1:object.light_num
        for k = 1:object.rough_num
            count_panel = count_panel + 1;
            subplot(2,3, count_panel);
            hold on;
            
            x = hue_mean_360_mod{i}(:,j,k);
            
            y(:,1) = GEindex{i}(:,:,j,k)';
            y(:,2) = highlight_lum_diff{i}(:,:,j,k)';
            y(:,3) = contrast_diff{i}(:,:,j,k)';
            y(:,4) = color_diff{i}(:,:,j,k)';
            
            for n = 1:4
                switch i
                    case 1
                        h_color(n) = plot(x, y(:,n), '-o', 'Color', graph_color(n,:));
                    case 2
                        h_color(n) = plot(x(1:8), y(1:8,n), '-o', 'Color', graph_color(n,:));
                        
                        h_cuau(1) = plot(x(9), y(9,n), 's', 'Color', graph_color(n,:));
                        h_cuau(2) = plot(x(10), y(10,n), 'd', 'Color', graph_color(n,:));
                        
                end
            end
            
            xlabel('Color direction (degree)');
            xlim([-20 360]);
            ylabel('Value');
            
            title(strcat(object.material(i), ', ', object.light(j), ', roughness:', num2str(object.rough_v(k))));
            
            %{
            lgd_txt = {'GE-index', 'highlight brightness', 'brightness contrast', 'color contrast'};
            legend(h_color, lgd_txt, 'FontSize', 14, 'Location', 'eastoutside');
            if i == 2
                t = {'Cu', 'Au'};
                legend(h_cuau, t, 'FontSize', 14, 'Location', 'eastoutside');
            end
            %}
            
            clear y
        end
    end
    
    f.WindowState = 'maximized';
    file_name = strcat(pass_save, 'variables_hue_value_', object.material(i), '_all.png');
    saveas(gcf, file_name);
    
end

%% 照明条件ごとにデータをわける
% プラスチック素材の面光源条件における説明力を確認
for i = 1:object.material_num
    
    if i == 1
        hue_name = object.hue;
        hue_num = object.hue_num;
    elseif i == 2
        hue_name = object.hue_metal;
        hue_num = object.hue_metal_num;
    end
    
    for j = 1:object.light_num
        switch i
            case 1
                % 素材・照明条件ごとに取り出す
                pla.light.gloss_diff.all_reshape(:,j) = reshape(GEindex{i}(:,:,j,:), [numel(GEindex{i}(:,:,j,:)), 1]);
                pla.light.HL_lum_diff.all_reshape(:,j) = reshape(highlight_lum_diff{i}(:,:,j,:), [numel(highlight_lum_diff{i}(:,:,j,:)), 1]);
                pla.light.contrast_diff.all_reshape(:,j) = reshape(contrast_diff{i}(:,:,j,:), [numel(contrast_diff{i}(:,:,j,:)), 1]);
                pla.light.color_diff.all_reshape(:,j) = reshape(color_diff{i}(:,:,j,:), [numel(color_diff{i}(:,:,j,:)), 1]);
                
            case 2
                % 素材・照明条件ごとに抜き出す
                metal.light.gloss_diff.all_reshape(:,j) = reshape(GEindex{i}(:,:,j,:), [numel(GEindex{i}(:,:,j,:)), 1]);
                metal.light.HL_lum_diff.all_reshape(:,j) = reshape(highlight_lum_diff{i}(:,:,j,:), [numel(highlight_lum_diff{i}(:,:,j,:)), 1]);
                metal.light.contrast_diff.all_reshape(:,j) = reshape(contrast_diff{i}(:,:,j,:), [numel(contrast_diff{i}(:,:,j,:)), 1]);
                metal.light.color_diff.all_reshape(:,j) = reshape(color_diff{i}(:,:,j,:), [numel(color_diff{i}(:,:,j,:)), 1]);
        end
    end
    
    switch i
        case 1
            % z-score化（照明条件ごと）
            pla.light.gloss_diff.normalized = normalize(pla.light.gloss_diff.all_reshape);
            pla.light.HL_lum_diff.normalized = normalize(pla.light.HL_lum_diff.all_reshape);
            pla.light.contrast_diff.normalized = normalize(pla.light.contrast_diff.all_reshape);
            pla.light.color_diff.normalized = normalize(pla.light.color_diff.all_reshape);
            
            % 変量効果用の変数
            pla.light.obj_condition = reshape(repmat(1:3, [hue_num,1]), [3*hue_num, 1]);
            
        case 2
            metal.light.gloss_diff.normalized = normalize(metal.light.gloss_diff.all_reshape);
            metal.light.HL_lum_diff.normalized = normalize(metal.light.HL_lum_diff.all_reshape);
            metal.light.contrast_diff.normalized = normalize(metal.light.contrast_diff.all_reshape);
            metal.light.color_diff.normalized = normalize(metal.light.color_diff.all_reshape);
       
            metal.light.obj_condition = reshape(repmat(1:3, [hue_num,1]), [3*hue_num, 1]);
    end

end

% 相関
for i = 1:object.material_num
    for j = 1:object.light_num
        switch i
            case 1
                hue_num = object.hue_num;

                % 全体に対して正規化されたデータを「物体条件*8色相」の形にする
                pla.light.gloss_diff.normalized_reshape(:,:,j) = reshape(pla.light.gloss_diff.normalized(:,j), [hue_num, 3])';
                pla.light.HL_lum_diff.normalized_reshape(:,:,j) = reshape(pla.light.HL_lum_diff.normalized(:,j), [hue_num, 3])';
                pla.light.contrast_diff.normalized_reshape(:,:,j) = reshape(pla.light.contrast_diff.normalized(:,j), [hue_num, 3])';
                pla.light.color_diff.normalized_reshape(:,:,j) = reshape(pla.light.color_diff.normalized(:,j), [hue_num, 3])';

                % 物体条件について平均
                pla.light.gloss_diff.normalized_mean(:,:,j) = mean(pla.light.gloss_diff.normalized_reshape(:,:,j), 1);
                pla.light.HL_lum_diff.normalized_mean(:,:,j) = mean(pla.light.HL_lum_diff.normalized_reshape(:,:,j), 1);
                pla.light.contrast_diff.normalized_mean(:,:,j) = mean(pla.light.contrast_diff.normalized_reshape(:,:,j), 1);
                pla.light.color_diff.normalized_mean(:,:,j) = mean(pla.light.color_diff.normalized_reshape(:,:,j), 1);

                % 相関
                pla.light.variables_mean(:,:,j) = [pla.light.gloss_diff.normalized_mean(:,:,j)', pla.light.HL_lum_diff.normalized_mean(:,:,j)', pla.light.contrast_diff.normalized_mean(:,:,j)', pla.light.color_diff.normalized_mean(:,:,j)'];
                pla.light.corrcoef_hue(:,:,j) = corrcoef(pla.light.variables_mean(:,:,j));
                
            case 2
                hue_num = object.hue_metal_num;

                % 全体に対して正規化されたデータを「物体条件*8色相」の形にする
                metal.light.gloss_diff.normalized_reshape(:,:,j) = reshape(metal.light.gloss_diff.normalized(:,j), [hue_num, 3])';
                metal.light.HL_lum_diff.normalized_reshape(:,:,j) = reshape(metal.light.HL_lum_diff.normalized(:,j), [hue_num, 3])';
                metal.light.contrast_diff.normalized_reshape(:,:,j) = reshape(metal.light.contrast_diff.normalized(:,j), [hue_num, 3])';
                metal.light.color_diff.normalized_reshape(:,:,j) = reshape(metal.light.color_diff.normalized(:,j), [hue_num, 3])';

                % 物体条件について平均
                metal.light.gloss_diff.normalized_mean(:,:,j) = mean(metal.light.gloss_diff.normalized_reshape(:,:,j), 1);
                metal.light.HL_lum_diff.normalized_mean(:,:,j) = mean(metal.light.HL_lum_diff.normalized_reshape(:,:,j), 1);
                metal.light.contrast_diff.normalized_mean(:,:,j) = mean(metal.light.contrast_diff.normalized_reshape(:,:,j), 1);
                metal.light.color_diff.normalized_mean(:,:,j) = mean(metal.light.color_diff.normalized_reshape(:,:,j), 1);

                % 相関
                metal.light.variables_mean(:,:,j) = [metal.light.gloss_diff.normalized_mean(:,:,j)', metal.light.HL_lum_diff.normalized_mean(:,:,j)', metal.light.contrast_diff.normalized_mean(:,:,j)', metal.light.color_diff.normalized_mean(:,:,j)'];
                metal.light.corrcoef_hue(:,:,j) = corrcoef(metal.light.variables_mean(:,:,j));               
        end 
    end
end

% 色相間での各変数の変化を可視化する
graph_color = [[0 0 0]; [0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]];
for i = 1:object.material_num
    for j = 1:object.light_num
        figure;
        hold on;

        x = mean(hue_mean_360_mod{i}, [2 3]);
        for n = 1:4
            switch i
                case 1
                    h_color(n) = plot(x, pla.light.variables_mean(:,n,j), '-o', 'Color', graph_color(n,:));
                case 2
                    h_color(n) = plot(x(1:8), metal.light.variables_mean(1:8,n,j), '-o', 'Color', graph_color(n,:));
                    %h_cuau(n) = plot(x(9:10), metal.light.variables_mean(9:10,n,j), '-s', 'Color', graph_color(n,:));
                    
                    h_cuau(1) = plot(x(9), metal.light.variables_mean(9,n), 's', 'Color', graph_color(n,:));
                    h_cuau(2) = plot(x(10), metal.light.variables_mean(10,n), 'd', 'Color', graph_color(n,:));
            end
        end
        ax = gca;

        xlabel('Color direction (degree)');
        xlim([-10 360]);
        ylabel('Value');
        
        title(strcat(object.material(i),', ',object.light(j)));

        %lgd_txt = {'GE-index', 'highlight brightness', 'brightness contrast', 'color contrast'};
        %legend(h_color, lgd_txt, 'FontSize', 14, 'Location', 'eastoutside');
        
        file_name = strcat(pass_save, 'light_result/variables_hue_value_', object.material(i), '_', object.light(j), '.png');
        saveas(gcf, file_name);

        hold off;
    end
end

%% 素材・照明条件ごとの線形混合モデル
j = 1; % 照明条件：area
tbl_pla_area = table(pla.light.gloss_diff.normalized(:,j), pla.light.HL_lum_diff.normalized(:,j), pla.light.contrast_diff.normalized(:,j), pla.light.color_diff.normalized(:,j), pla.light.obj_condition, 'VariableNames', {'gloss_diff', 'lum_diff', 'lum_contrast_diff', 'color_diff', 'object_condition'});
tbl_metal_area = table(metal.light.gloss_diff.normalized(:,j), metal.light.HL_lum_diff.normalized(:,j), metal.light.contrast_diff.normalized(:,j), metal.light.color_diff.normalized(:,j), metal.light.obj_condition, 'VariableNames', {'gloss_diff', 'lum_diff', 'lum_contrast_diff', 'color_diff', 'object_condition'});
fprintf('light : %s\n',object.light(j));
lme_pla_area = fitlme(tbl_pla_area, 'gloss_diff ~ lum_diff + lum_contrast_diff + color_diff + (1|object_condition) + (lum_diff-1|object_condition) + (lum_contrast_diff-1|object_condition) + (color_diff-1|object_condition)')
lme_pla_area.Rsquared
lme_metal_area = fitlme(tbl_metal_area, 'gloss_diff ~ lum_diff + lum_contrast_diff + color_diff + (1|object_condition) + (lum_diff-1|object_condition) + (lum_contrast_diff-1|object_condition) + (color_diff-1|object_condition)')
lme_metal_area.Rsquared

j = 2; % 照明条件：envmap
tbl_pla_envmap = table(pla.light.gloss_diff.normalized(:,j), pla.light.HL_lum_diff.normalized(:,j), pla.light.contrast_diff.normalized(:,j), pla.light.color_diff.normalized(:,j), pla.light.obj_condition, 'VariableNames', {'gloss_diff', 'lum_diff', 'lum_contrast_diff', 'color_diff', 'object_condition'});
tbl_metal_envmap = table(metal.light.gloss_diff.normalized(:,j), metal.light.HL_lum_diff.normalized(:,j), metal.light.contrast_diff.normalized(:,j), metal.light.color_diff.normalized(:,j), metal.light.obj_condition, 'VariableNames', {'gloss_diff', 'lum_diff', 'lum_contrast_diff', 'color_diff', 'object_condition'});
fprintf('light : %s\n',object.light(j));
lme_pla_envmap = fitlme(tbl_pla_envmap, 'gloss_diff ~ lum_diff + lum_contrast_diff + color_diff + (1|object_condition) + (lum_diff-1|object_condition) + (lum_contrast_diff-1|object_condition) + (color_diff-1|object_condition)')
lme_pla_envmap.Rsquared
lme_metal_envmap = fitlme(tbl_metal_envmap, 'gloss_diff ~ lum_diff + lum_contrast_diff + color_diff + (1|object_condition) + (lum_diff-1|object_condition) + (lum_contrast_diff-1|object_condition) + (color_diff-1|object_condition)')
lme_metal_envmap.Rsquared

% プロット
for i = 1:object.material_num
    for j = 1:object.light_num
        figure;
        x = 1:3;
        
        if i == 1 && j == 1
            y = lme_pla_area.Coefficients.Estimate(2:end)';
        elseif i == 1 && j == 2
            y = lme_pla_envmap.Coefficients.Estimate(2:end)';
        elseif i == 2 && j == 1
            y = lme_metal_area.Coefficients.Estimate(2:end)';
        elseif i == 2 && j == 2
            y = lme_metal_envmap.Coefficients.Estimate(2:end)';
        end

        bar(x,y);
        ax = gca;
        
        title(strcat(object.material(i),', ',object.light(j)));

        xticks(x);
        xticklabels(["highlight brightness", "brightness contrast", "color contrast"]);
        xtickangle(45);
        %ylabel("Regression coefficient");
        ylim([-0.35 0.85]);
        %yticks(-0.1:0.1:0.6);
        ax.FontSize = 14;
        
        file_name = strcat(pass_save, 'light_result/LME_result_', object.material(i), '_', object.light(j), '.png');
        
    end
end

