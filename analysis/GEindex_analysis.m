%% 色相ごとに効果量（有彩色-無彩色の選好尺度値）を求める

clear all;

flag_par = 3;
object = object_paramater(flag_par);

exp = 'exp_realistic';
sn = 'all';

load(strcat('../../analysis_result/exp_realistic/',sn,'/psv.mat'));
load(strcat('../../analysis_result/exp_realistic/',sn,'/psv_CI.mat'));
load(strcat('../../analysis_result/exp_realistic/',sn,'/BS_sample.mat'));

B = size(BS_sample{1},1);

%% 効果量の算出
GEindex = cell(1,2);
BS_GEindex = cell(1,2);

for i = 1:object.material_num
    
    if i == 1
        num_chromatic = numel(object.hue);
    elseif i == 2
        num_chromatic = numel(object.hue_metal);
    end
    
    GEindex_tmp_material = zeros(1,num_chromatic, object.light_num, object.rough_num);
    BS_GEindex_tmp_material = zeros(B,num_chromatic, object.light_num, object.rough_num);
    for j = 1:object.light_num
        for k = 1:object.rough_num
            
            psv_tmp = psv{i}(:,:,j,k);
            GEindex_tmp = psv_tmp(1,1:num_chromatic) - psv_tmp(1,num_chromatic+1:end);
            
            % ブートストラップサンプル
            BS_tmp = BS_sample{i}(:,:,j,k);
            BS_GEindex_tmp = BS_tmp(:,1:num_chromatic) - BS_tmp(:,num_chromatic+1:end);
            
            GEindex_tmp_material(:,:,j,k) = GEindex_tmp;
            BS_GEindex_tmp_material(:,:,j,k) = BS_GEindex_tmp;
        end
    end
    
    GEindex{i} = GEindex_tmp_material;
    BS_GEindex{i} = BS_GEindex_tmp_material;
    
    % 照明・粗さ条件をまとめた平均
    GEindex_mean_all{i} = mean(GEindex_tmp_material, [3 4]);
    BS_GEindex_mean_all{i} = mean(BS_GEindex_tmp_material, [3 4]);
    
end

%% 信頼区間
CI95_GEindex = cell(1,2);
for i = 1:object.material_num
    
    if i == 1
        num_chromatic = numel(object.hue);
    elseif i == 2
        num_chromatic = numel(object.hue_metal);
    end
    
    CI95_GEindex_tmp = zeros(2, num_chromatic, object.light_num, object.rough_num);
    for j = 1:object.light_num
        for k = 1:object.rough_num
            num_chromatic = size(BS_GEindex{i},2);
            
            for hue = 1:num_chromatic
                CI95_tmp = CI95_bootstrap(BS_GEindex{i}(:,hue,j,k));
                CI95_GEindex_tmp(:,hue,j,k) = CI95_tmp';
                
            end
            
        end
    end
    
    CI95_GEindex{i} = CI95_GEindex_tmp;
    
    % 照明・粗さ条件をまとめた平均
    for hue = 1:num_chromatic
        CI95_GEindex_tmp_mean_all(:,hue) = CI95_bootstrap(BS_GEindex_mean_all{i}(:,hue))';
    end
    CI95_GEindex_mean_all{i} = CI95_GEindex_tmp_mean_all;
    
end

%% プロット
% 色相名を角度に
load('../../mat/stimuli_color/hue_mean_360.mat');

for i = 1:object.material_num
    
    %{
    if i == 1
        hue_name = object.hue;
    elseif i == 2
        hue_name = object.hue_metal;
    end
    %}
    
    
    for j = 1:object.light_num
        for k = 1:object.rough_num
            figure;
            
            hue_name = string(round(hue_mean_360{i}(:,j,k)))';
            
            x = 1:size(GEindex{i}, 2);
            GEindex_y = GEindex{i}(:,:,j,k);
            CI95_y = CI95_GEindex{i}(:,:,j,k);
            err = abs(GEindex_y - CI95_y);
            
            errorbar(x, GEindex_y, err(1,:), err(2,:), '-o');
            
            xticks(x);
            xticklabels(hue_name);
            xtickangle(45);
            xlim([0 x(end)+1]);
            
            xlabel('Color direction (degree)');
            ylabel('GE index');
            
            graphName = strcat('GEindex_',object.material(i),'_',object.light(j),'_',object.rough(k),'.png');
            fileName = strcat('../../analysis_result/',exp,'/',sn,'/graph/GEindex/',graphName);
            saveas(gcf, fileName);
        end
    end
    %}
    
    %{
    % 照明・粗さ条件をまとめた平均
    figure;
    hue_name = string(round(hue_mean_360{i}(:,1,1)))';
    x = 1:size(GEindex{i}, 2);
    GEindex_y = GEindex_mean_all{i};
    CI95_y = CI95_GEindex_mean_all{i};
    err = abs(GEindex_y - CI95_y);
    bar(x, GEindex_y);
    hold on;
    errorbar(x, GEindex_y, err(1,:), err(2,:), 'o', 'Color', [0 0 0], 'LineWidth', 1);
    title('mean');
    xticks(x);
    xticklabels(hue_name);
    xtickangle(45);
    xlim([0 x(end)+1]);
    xlabel('Color direction (degree)');
    ylabel('GE index');
    hold off;
    %}
    
end

    