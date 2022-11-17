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
load('../../mat/stimuli_color/hue_mean_360_mod.mat');
graph_color = [[0 0 0]; [0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]];
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
                h_cuau(n) = plot(x(9:10), metal.variables_mean(9:10,n), '-s', 'Color', graph_color(n,:));
        end
    end
    ax = gca;
    
    xlabel('Color direction (degree)');
    xlim([-10 360]);
    ylabel('Value');
    
    lgd_txt = {'GE-index', 'highlight brightness', 'brightness contrast', 'color contrast'};
    legend(h_color, lgd_txt, 'FontSize', 14, 'Location', 'eastoutside');
    
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

end