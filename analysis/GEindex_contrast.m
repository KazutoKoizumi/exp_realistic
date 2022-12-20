%% 実験1,3それぞれで明るさコントラストと光沢感増大量の関係を検討

clear all

%% 実験1
flag_par = 1;
object = object_paramater(flag_par);
idx = make_index(flag_par);

load('../../../exp_luminance_gloss/mat/stimuli_color/contrast'); % オリジナルの無彩色刺激は実験1と2で同じ
load('../../../exp_luminance_gloss/mat/regress_var/gloss_diff.mat'); % 光沢感増大量

% 色相について平均した値をGEindexとする場合
contrast_gray = [contrast.gray(1:2:end), contrast.gray(2:2:end)]; % 物体条件 * 彩色条件
GEindex = permute(mean(gloss_diff.all, 2), [1 3 2]);
txt = ["BC", "DC"];
for m = 1:object.method_num
    figure;
    x = contrast_gray(:,m);
    y = GEindex(:,m);
    scatter(x,y);
    
    xlabel('lightness contrast');
    ylabel('GE index');
    title(txt(m));
    
    corrcoef_exp1(:,:,m) = corrcoef(x,y);
    
end

% 色相で平均しない場合
contrast_gray_hue = repmat(contrast.gray, [1,8]);
for m = 1:object.method_num
    contrast_gray = reshape(contrast_gray_hue(m:2:end,:)', [54*8,1]);
    GEindex = reshape(gloss_diff.all(:,:,m)', [numel(gloss_diff.all(:,:,m)),1]);
    
    figure;
    scatter(contrast_gray, GEindex);
    
    xlabel('lightness contrast');
    ylabel('GE index');
    title(object.method(m));
end

clear contrast contrast_gray contrast_gray_hue gloss_diff GEindex

%% 実験3
flag_par = 3;
object = object_paramater(flag_par);

load('../../mat/stimuli_color/contrast_gray.mat');
load('../../analysis_result/exp_realistic/all/GEindex/GEindex.mat');

% 色相で平均
for i = 1:object.material_num
    
    contrast_mean = permute(mean(contrast_gray{i}, 1), [2 3 1]);
    x = reshape(contrast_mean, [numel(contrast_mean),1]);
    
    GEindex_mean = permute(mean(GEindex{i}, 2), [3 4 1 2]);
    y = reshape(GEindex_mean, [numel(GEindex_mean),1]);
    
    figure;
    scatter(x,y);
    
    xlabel('lightness contrast');
    ylabel('GE index');
    title(object.material(i));
    
    corrcoef_exp3(:,:,i) = corrcoef(x,y);
end

for i = 1:object.material_num
    
    x = reshape(contrast_gray{i}, [numel(contrast_gray{i}),1]);
    y = reshape(permute(GEindex{i}, [2 3 4 1]), [numel(GEindex{i}),1]);
    
    figure;
    scatter(x,y);
    
    xlabel('lightness contrast');
    ylabel('GE index');
    title(object.material(i));
end


