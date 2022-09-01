%% 彩度をもとに光沢感変化量を補正する

clear all;

exp = 'exp_realistic';
sn = 'all';

flag_par = 3;
object = object_paramater(flag_par);

load('../../analysis_result/exp_realistic/all/GEindex/GEindex.mat');
load('../../analysis_result/exp_realistic/all/GEindex/CI95_GEindex.mat');
load('../../analysis_result/exp_realistic/all/GEindex/BS_GEindex.mat');

load('../../mat/stimuli_color/sat_mean.mat');
load('../../mat/stimuli_color/sat_HL_mean.mat');

load('../../mat/stimuli_color/exp_color/sat_exp1_mean.mat');
load('../../mat/stimuli_color/exp_color/sat_exp1_HL_mean.mat');

%% 彩度による補正
% 実験1のハイライト彩度/実験3のハイライト彩度
GEindex_mod = cell(1,2);
BS_GEindex_mod = cell(1,2);
CI95_GEindex_mod = cell(1,2);

for i = 1:object.material_num % 素材
    
    if i == 1
        num_chromatic = numel(object.hue);
        m = 2;
    elseif i == 2
        num_chromatic = numel(object.hue_metal);
        m = 1;
    end
    
    GEindex_mod_tmp = zeros(1,num_chromatic,2,3);
    BS_GEindex_mod_tmp = zeros(10000,num_chromatic,2,3);
    CI95_GEindex_mod_tmp = zeros(2,num_chromatic,2,3);
    
    for j = 1:object.light_num % 照明
        for k = 1:object.rough_num % 表面粗さ
            for hue = 1:num_chromatic
                
                id_diff_ref = 1; % 実験1の拡散反射率(1:0.1, 2:0.3, 3:0.5)
                
                sat_exp3 = sat_HL_mean{i}(hue,j,k);
                sat_exp1 = sat_exp1_HL_mean(:,:,1,j,id_diff_ref,k,m);
                
                coeff = sat_exp1 / sat_exp3;
                
                GEindex_mod_tmp(:,hue,j,k) = GEindex{i}(:,hue,j,k) * coeff;
                
                % ブートストラップ
                BS_GEindex_mod_tmp(:,hue,j,k) = BS_GEindex{i}(:,hue,j,k) .* coeff;
                CI95_GEindex_mod_tmp(:,hue,j,k) = CI95_bootstrap(BS_GEindex_mod_tmp(:,hue,j,k));
                
            end
        end
    end
    
    GEindex_mod{i} = GEindex_mod_tmp;
    BS_GEindex_mod{i} = BS_GEindex_mod_tmp;
    CI95_GEindex_mod{i} = CI95_GEindex_mod_tmp;
    
    % 照明・粗さ条件をまとめた平均
    GEindex_mod_mean_all{i} = mean(GEindex_mod_tmp, [3 4]);
    BS_GEindex_mod_mean_all{i} = mean(BS_GEindex_mod_tmp, [3 4]);
    for hue = 1:num_chromatic
        CI95_GEindex_mod_tmp_mean_all(:,hue) = CI95_bootstrap(BS_GEindex_mod_mean_all{i}(:,hue))';
    end
    CI95_GEindex_mod_mean_all{i} = CI95_GEindex_mod_tmp_mean_all;
    
end

%% プロット
load('../../mat/stimuli_color/hue_mean_360.mat');

for i = 1:object.material_num
    
    %{
    for j = 1:object.light_num
        for k = 1:object.rough_num
            figure;
            
            hue_name = string(round(hue_mean_360{i}(:,j,k)))';
            
            x = 1:size(GEindex_mod{i}, 2);
            GEindex_y = GEindex_mod{i}(:,:,j,k);
            CI95_y = CI95_GEindex_mod{i}(:,:,j,k);
            err = abs(GEindex_y - CI95_y);
            
            errorbar(x, GEindex_y, err(1,:), err(2,:), '-o');
            
            xticks(x);
            xticklabels(hue_name);
            xtickangle(45);
            xlim([0 x(end)+1]);
            
            xlabel('Color direction (degree)');
            ylabel('GE index');
            
            graphName = strcat('GEindex_',object.material(i),'_',object.light(j),'_',object.rough(k),'.png');
            fileName = strcat('../../analysis_result/',exp,'/',sn,'/graph/GEindex_mod/',graphName);
            saveas(gcf, fileName);
        end
    end
    %}
    
    
    % 照明・粗さ条件をまとめた平均
    figure;
    hue_name = string(round(hue_mean_360{i}(:,1,1)))';
    x = 1:size(GEindex_mod{i}, 2);
    GEindex_y = GEindex_mod_mean_all{i};
    CI95_y = CI95_GEindex_mod_mean_all{i};
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
