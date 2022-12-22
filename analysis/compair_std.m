%% 実験1と実験3で光沢感増大量の色相間での標準偏差を比較する

clear all;

flag_par = 3;
object_exp3 = object_paramater(flag_par);
object_exp1 = object_paramater(1);
idx_exp1 = make_index(1);

% 光沢感増大量読み込み（値の整理は"compair_GEindex_exp_color.m"）
load('../../analysis_result/exp_realistic/all/GEindex_compair/exp1.mat');
load('../../analysis_result/exp_realistic/all/GEindex_compair/exp3.mat');


%% プロット
graph_color = [[0 0.4470 0.7410]; [0.8500 0.3250 0.0980]];
for i = 1:object_exp3.material_num
    
    % 各照明・粗さ条件について
    x = 1:6;
    x_exp1 = x-0.17;
    x_exp3 = x+0.17;
    
    f = figure;
    hold on;
    bar_width = 0.3;
    txt_label = cell(1,6);
    count = 1;
    for j = 1:object_exp3.light_num
        for k= 1:object_exp3.rough_num
            err_exp1(:,count) = abs(exp1.GEindex_std{i}(:,:,j,k) - exp1.CI95_GEindex_std{i}(:,:,j,k));
            err_exp3(:,count) = abs(exp3.GEindex_std{i}(:,:,j,k) - exp3.CI95_GEindex_std{i}(:,:,j,k));
            
            y_exp1(:,count) = exp1.GEindex_std{i}(:,:,j,k);
            y_exp3(:,count) = exp3.GEindex_std{i}(:,:,j,k);
            
            txt_label(:,count) = {strcat(object_exp3.light(j)," ",object_exp3.rough(k))};
            
            count = count + 1;
        end
    end
    b1 = bar(x_exp1,y_exp1, 'BarWidth',bar_width, 'FaceColor',graph_color(1,:));
    errorbar(x_exp1, y_exp1, err_exp1(1,:), err_exp1(2,:), 'o', 'Color',[0,0,0]);
    
    b3 = bar(x_exp3,y_exp3, 'BarWidth',bar_width, 'FaceColor',graph_color(2,:));
    errorbar(x_exp3, y_exp3, err_exp3(1,:), err_exp3(2,:), 'o', 'Color',[0,0,0]);
    
    f.Position = [251,454,722,407];
    
    xticks(x);
    xticklabels(txt_label);
    xtickangle(30);
    
end

% プロット：素材ごとについて
clear err_exp1 err_exp3
for i = 1:object_exp3.material_num
    
    % 計算
    
    %exp1.GEindex_std_mean_all{i} = mean(exp1.GEindex_std{i}, [3 4]);
    %exp3.GEindex_std_mean_all{i} = mean(exp3.GEindex_std{i}, [3 4]);
    exp1.GEindex_std_mean_all{i} = std(exp1.GEindex_mean_all{i});
    exp3.GEindex_std_mean_all{i} = std(exp3.GEindex_mean_all{i});
    
    %exp1.BS_GEindex_std_mean_all{i} = mean(exp1.BS_GEindex_std{i}, [3 4]);
    %exp3.BS_GEindex_std_mean_all{i} = mean(exp3.BS_GEindex_std{i}, [3 4]);
    exp1.BS_GEindex_std_mean_all{i} = std(exp1.BS_GEindex_mean_all{i}, [], 2);
    exp3.BS_GEindex_std_mean_all{i} = std(exp3.BS_GEindex_mean_all{i}, [], 2);
    
    exp1.CI95_GEindex_std_mean_all{i} = CI95_bootstrap(exp1.BS_GEindex_std_mean_all{i})';
    exp3.CI95_GEindex_std_mean_all{i} = CI95_bootstrap(exp3.BS_GEindex_std_mean_all{i})';
    
    % プロット
    x = 1:2;
    
    f = figure;
    hold on;
    bar_width = 0.3;
    
    err_exp1 = abs(exp1.GEindex_std_mean_all{i} - exp1.CI95_GEindex_std_mean_all{i});
    err_exp3 = abs(exp3.GEindex_std_mean_all{i} - exp3.CI95_GEindex_std_mean_all{i});
    err = [err_exp1, err_exp3];
    y = [exp1.GEindex_std_mean_all{i}, exp3.GEindex_std_mean_all{i}];
    
    b1 = bar(x(1),y(1), 'FaceColor',graph_color(1,:));
    errorbar(x(1),y(1), err(1,1), err(2,1), 'o', 'Color', [0,0,0]);
    b3 = bar(x(2),y(2), 'FaceColor',graph_color(2,:));
    errorbar(x(2),y(2), err(1,2), err(2,2), 'o', 'Color', [0,0,0]);
    
    xticks(x);
    xticklabels({'exp1', 'exp3'});
    
    
end
clear err_exp1 err_exp3 x y

%% 有意差
% 素材・照明・粗さごとのデータで比較
% 多重比較（比較回数：12回）
comp_num = 12;
p = zeros(12,1);  % 素材、照明、粗さ
sig_diff = zeros(12,1);
id = zeros(12,3);
B = 10000;
count = 1;
for i = 1:object_exp3.material_num
    for j = 1:object_exp3.light_num
        for k= 1:object_exp3.rough_num
            
            id(count,:) = [i,j,k];
            
            sample_diff = exp1.BS_GEindex_std{i}(:,:,j,k) - exp3.BS_GEindex_std{i}(:,:,j,k);
            sdata = sort(sample_diff);
            
            % p値
            num = min([nnz(sdata<=0), nnz(sdata>=0)]);
            p(count) = num/B;
            p_param(i,j,k) = p(count);
            
            count = count + 1;
            
        end
    end
end

% Holm法で有意水準を補正して検定
[p_sort, id_sort] = sort(p);
count = 1;
sig_diff_param = zeros(2,2,3);
for i = 1:object_exp3.material_num
    for j = 1:object_exp3.light_num
        for k= 1:object_exp3.rough_num
            alpha_holm = 0.025/(comp_num+1-count);

            if p_sort(count) < alpha_holm
                sig_diff(id_sort(count)) = 1;
            else
                sig_diff(id_sort(count)) = 0;
                break;
            end
            
            count = count + 1;
            
        end
    end
end
for n = 1:comp_num
    sig_diff_param(id(n,1),id(n,2),id(n,3)) = sig_diff(n);
end



% 素材条件間
comp_num = 2;
for i = 1:object_exp3.material_num
    
    sample_diff = exp1.BS_GEindex_std_mean_all{i} - exp3.BS_GEindex_std_mean_all{i};
    sdata = sort(sample_diff);
    
    % p値
    num = min([nnz(sdata<=0), nnz(sdata>=0)]);
    p_all_mean(i) = num/B;
    
end
% Holmで有意水準補正
[p_sort_all_mean, id_sort_all_mean] = sort(p_all_mean);
count = 1;
for i = 1:object_exp3.material_num
    alpha_holm = 0.025/(comp_num+1-count);
    if p_sort_all_mean(count) < alpha_holm
        sig_diff_all_mean(id_sort_all_mean(count)) = 1;
    else
        sig_diff_all_mean(id_sort_all_mean(count)) = 0;
        break;
    end

    count = count + 1;
    
end
