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
% 物体条件に関して平均を取って、色相間で正規化した値の相関
% 色相に対して正規化して平均した値についての相関と同じ
pla.variables_mean = [pla.gloss_diff.obj_mean', pla.HL_lum_diff.obj_mean', pla.contrast_diff.obj_mean', pla.color_diff.obj_mean'];
pla.variables_mean_normalized = normalize(pla.variables_mean);
pla.corrcoef_hue = corrcoef(pla.variables_mean_normalized);
metal.variables_mean = [metal.gloss_diff.obj_mean', metal.HL_lum_diff.obj_mean', metal.contrast_diff.obj_mean', metal.color_diff.obj_mean'];
metal.variables_mean_normalized = normalize(metal.variables_mean);
metal.corrcoef_hue = corrcoef(metal.variables_mean_normalized);

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