%% 実験1,3それぞれで明るさコントラストと光沢感増大量の関係を検討

clear all

%% 実験1
flag_par = 1;
object_exp1 = object_paramater(flag_par);
idx = make_index(flag_par);

load('../../../exp_luminance_gloss/mat/stimuli_color/contrast'); % オリジナルの無彩色刺激は実験1と2で同じ
load('../../../exp_luminance_gloss/mat/regress_var/gloss_diff.mat'); % 光沢感増大量
exp1.GEindex_hue = gloss_diff.all;

% 色相について平均した値をGEindexとする場合
exp1.contrast_gray = [contrast.gray(1:2:end), contrast.gray(2:2:end)]; % 物体条件 * 彩色条件
exp1.GEindex = permute(mean(gloss_diff.all, 2), [1 3 2]);
txt = ["BC", "DC"];
for m = 1:object_exp1.method_num
    figure;
    x = exp1.contrast_gray(:,m);
    y = exp1.GEindex(:,m);
    scatter(x,y);
    
    xlabel('lightness contrast');
    ylabel('GE index');
    title(txt(m));
    
    corrcoef_exp1(:,:,m) = corrcoef(x,y);
    
end

% 色相で平均しない場合
exp1.contrast_gray_hue = repmat(contrast.gray, [1,8]);
for m = 1:object_exp1.method_num
    contrast_gray = reshape(exp1.contrast_gray_hue(m:2:end,:)', [54*8,1]);
    GEindex = reshape(gloss_diff.all(:,:,m)', [numel(gloss_diff.all(:,:,m)),1]);
    
    figure;
    scatter(contrast_gray, GEindex);
    
    xlabel('lightness contrast');
    ylabel('GE index');
    title(object_exp1.method(m));
end

clear contrast contrast_gray contrast_gray_hue gloss_diff GEindex

%% 実験3
flag_par = 3;
object_exp3 = object_paramater(flag_par);

load('../../mat/stimuli_color/contrast_gray.mat');
load('../../analysis_result/exp_realistic/all/GEindex/GEindex.mat');
exp3.contrast_gray_hue = contrast_gray;
exp3.GEindex_hue = GEindex;

% 色相で平均
for i = 1:object_exp3.material_num
    
    contrast_mean = permute(mean(contrast_gray{i}, 1), [2 3 1]);
    x = reshape(contrast_mean, [numel(contrast_mean),1]);
    
    GEindex_mean = permute(mean(GEindex{i}, 2), [3 4 1 2]);
    y = reshape(GEindex_mean, [numel(GEindex_mean),1]);
    
    figure;
    scatter(x,y);
    
    xlabel('lightness contrast');
    ylabel('GE index');
    title(object_exp3.material(i));
    
    corrcoef_exp3(:,:,i) = corrcoef(x,y);
end

for i = 1:object_exp3.material_num
    
    x = reshape(contrast_gray{i}, [numel(contrast_gray{i}),1]);
    y = reshape(permute(GEindex{i}, [2 3 4 1]), [numel(GEindex{i}),1]);
    
    figure;
    scatter(x,y);
    
    xlabel('lightness contrast');
    ylabel('GE index');
    title(object_exp3.material(i));
end

%% 実験1と実験3の結果を同時にプロット
% 色相については平均した値
graph_color = [[0 0.4470 0.7410]; [0.8500 0.3250 0.0980]];
txt_lgd = cell(2,2);
txt_lgd(1,:) = {'exp1 DC', 'exp4 plastic'};
txt_lgd(2,:) = {'exp1 BC', 'exp4 metal'};
for i = 1:object_exp3.material_num
    if i == 1
        m = 2;
    elseif i == 2
        m = 1;
    end
    
    exp1_contrast = exp1.contrast_gray(:,m);
    exp1_GEindex = exp1.GEindex(:,m);
    
    exp3_contrast_tmp = mean(exp3.contrast_gray_hue{i},1);
    exp3_GEindex_tmp = mean(exp3.GEindex_hue{i},2);
    count = 1;
    for j = 1:object_exp3.light_num
        for k = 1:object_exp3.rough_num
            exp3_contrast(count,:) = exp3_contrast_tmp(:,j,k);
            exp3_GEindex(count,:) = exp3_GEindex_tmp(:,:,j,k);
            count = count + 1;
        end
    end
    
    % 相関
    merge_contrst = cat(1, exp1_contrast, exp3_contrast);
    merge_GEindex = cat(1, exp1_GEindex, exp3_GEindex);
    corrcoef_merge(:,:,i) = corrcoef(merge_contrst, merge_GEindex);
    
    % プロット
    figure;
    scatter(exp1_contrast, exp1_GEindex, [], graph_color(1,:));
    hold on;
    scatter(exp3_contrast, exp3_GEindex, [], graph_color(2,:));
    
    xlabel('brightness contrast', 'FontSize', 16);
    ylabel('GE index', 'FontSize', 16);
    title(object_exp3.material(i));
    
    ax = gca;
    ax.FontSize = 14;
    
    legend(txt_lgd(i,:), 'FontSize', 14);
    
end

