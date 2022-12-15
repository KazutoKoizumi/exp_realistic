%% 実験1と選好尺度値を比較する

clear all;

exp = 'exp_realistic';
sn = 'all';

flag_par = 3;
object_exp3 = object_paramater(flag_par);
object_exp1 = object_paramater(1);
idx_exp1 = make_index(1);

% 実験1の結果
%load('../../../exp_luminance_gloss/data/for_paper/exp1/CG_effect.mat');
load('../../../exp_luminance_gloss/data/for_paper/exp1/BS.mat');
load('../../../exp_luminance_gloss/mat/regress_var/gloss_diff.mat');

% 実験3の結果
load('../../analysis_result/exp_realistic/all/GEindex/GEindex.mat');
load('../../analysis_result/exp_realistic/all/GEindex/GEindex_mean_all.mat');
load('../../analysis_result/exp_realistic/all/GEindex/BS_GEindex.mat');
load('../../analysis_result/exp_realistic/all/GEindex/BS_GEindex_mean_all.mat');
load('../../analysis_result/exp_realistic/all/GEindex/CI95_GEindex.mat');
load('../../analysis_result/exp_realistic/all/GEindex/CI95_GEindex_mean_all.mat');
exp3.GEindex = GEindex;
exp3.GEindex_mean_all = GEindex_mean_all;
exp3.BS_GEindex = BS_GEindex;
exp3.BS_GEindex_mean_all = BS_GEindex_mean_all;
exp3.CI95_GEindex = CI95_GEindex;
exp3.CI95_GEindex_mean_all = CI95_GEindex_mean_all;
clear GEindex GEindex_mean_all BS_GEindex BS_GEindex_mean_all CI95_GEindex CI95_GEindex_mean_all;

% 色相名を角度に
load('../../mat/stimuli_color/hue_mean_360.mat');
load('../../mat/stimuli_color/hue_mean_360_mod.mat');

% グラフ設定
graph_color = [[0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]];
sz.sgt = 12;
sz.lgd = 8; %16;

%% 実験1の値を整理
% 実験3のデータと同じ構造にする
% 形状はbunnyのみ（1）、照明は2条件、拡散反射率は3条件を平均する、粗さは3条件、彩色条件は順番を反転（プラスチックと金属に対応させる）

% BSに関する事前整理
BS_psv_exp1(:,:,:,1) = BS.color.psv(:,:,1:2:end); % BC条件
BS_psv_exp1(:,:,:,2) = BS.color.psv(:,:,2:2:end); % DC条件

for m = 1:2 % 彩色条件
    if m == 1
        i = 2;
    elseif m == 2
        i = 1;
    end
    
    idx_method = idx_exp1(m:2:end,:);
    for j = 1:object_exp1.light_num % 照明
        for k = 1:object_exp1.rough_num % 粗さ
            
            id_exp1 = find(idx_method(:,1)==1 & idx_method(:,2)==j & idx_method(:,4)==k & idx_method(:,5)==m);
            GEindex_exp1_tmp = mean(gloss_diff.all(id_exp1,:,m),1); % 拡散反射率について平均
            GEindex_tmp(:,:,j,k) = GEindex_exp1_tmp;
            
            BS_psv_tmp = BS_psv_exp1(:,:,id_exp1,m);
            BS_GEindex_exp1_tmp = BS_psv_tmp(:,2:9,:) - BS_psv_tmp(:,1,:);
            BS_GEindex_exp1_tmp = mean(BS_GEindex_exp1_tmp, 3); % 拡散反射率について平均
            BS_GEindex_tmp(:,:,j,k) = BS_GEindex_exp1_tmp;
            
            for hue = 1:8
                CI95_GEindex_tmp(:,hue,j,k) = CI95_bootstrap(BS_GEindex_exp1_tmp(:,hue))';
            end
            
        end
    end
    
    GEindex{i} = GEindex_tmp;
    GEindex_mean_all{i} = mean(GEindex{i}, [3,4]);
    BS_GEindex{i} = BS_GEindex_tmp;
    BS_GEindex_mean_all{i} = mean(BS_GEindex{i}, [3,4]);
    CI95_GEindex{i} = CI95_GEindex_tmp;
    
    % 信頼区間：照明・粗さ条件をまとめた平均
    for hue = 1:8
        CI95_GEindex_mean_all_tmp(:,hue) = CI95_bootstrap(BS_GEindex_mean_all{i}(:,hue))';
    end
    CI95_GEindex_mean_all{i} = CI95_GEindex_mean_all_tmp;
    
end
exp1.GEindex = GEindex;
exp1.GEindex_mean_all = GEindex_mean_all;
exp1.BS_GEindex = BS_GEindex;
exp1.BS_GEindex_mean_all = BS_GEindex_mean_all;
exp1.CI95_GEindex = CI95_GEindex;
exp1.CI95_GEindex_mean_all = CI95_GEindex_mean_all;
clear GEindex GEindex_mean_all BS_GEindex BS_GEindex_mean_all CI95_GEindex CI95_GEindex_mean_all gloss_diff;

clear GEindex_tmp GEindex_exp1_tmp BS_GEindex_tmp BS_GEindex_exp1_tmp BS_psv_exp1 BS_psv_tmp CI95_GEindex_tmp CI95_GEindex_mean_all_tmp
clear id_exp1 idx_exp1 hue

%% 色相ごとの光沢感変化量の単純な比較
for i = 1:object_exp3.material_num
    
    hue_deg = hue_mean_360_mod{i};
    hue_num = 8;
    
    %% 全プロット
    f = figure;
    for j = 1:object_exp3.light_num
        subplot(2,1,j);
        for k = 1:object_exp3.rough_num
            
            % 実験1の結果
            GEindex_exp1 = exp1.GEindex{i}(:,:,j,k);
            CI95_exp1 = exp1.CI95_GEindex{i}(:,:,j,k);
            err_exp1 = abs(GEindex_exp1 - CI95_exp1);
            
            % 実験3の結果（金属のCu,Auの結果は除く）
            GEindex_exp3 = exp3.GEindex{i}(:,1:8,j,k);
            CI95_exp3 = exp3.CI95_GEindex{i}(:,1:8,j,k);
            err_exp3 = abs(GEindex_exp3 - CI95_exp3);
            
            % 横軸の色相
            hue_x_exp1 = [0,45,90,135,180,225,270,315];
            hue_x_exp3 = round(hue_deg(1:8,j,k));
            
            % プロット
            hold on;
            h_exp1(k) = errorbar(hue_x_exp1, GEindex_exp1, err_exp1(1,:), err_exp1(2,:), '--o', 'Color', graph_color(k,:));
            h_exp3(k) = errorbar(hue_x_exp3, GEindex_exp3, err_exp3(1,:), err_exp3(2,:), '-o', 'Color', graph_color(k,:));
            
        end
        
        % サブプロットのタイトル
        t_txt = object_exp3.light(j);
        title(t_txt, 'FontSize', sz.sgt);
        
        % axis
        xlim([-20 360]);
        xlabel('Color direction (degree)');
        ylabel('GE index');
        
        % legend
        lgd = legend(h_exp3, num2cell(object_exp3.rough));
        lgd.NumColumns = 1;
        lgd.Title.String = 'roughness';
        lgd.Title.FontWeight = 'normal';
        lgd.FontSize = sz.lgd;
        lgd.Location = 'northeastoutside';
        
        % save
        f.Position = [715,1081,1074,964];
        graphName = strcat('GEindex_compair_',object_exp3.material(i),'.png');
        fileName = strcat('../../analysis_result/',exp,'/',sn,'/graph/GEindex_compair/',graphName);
        saveas(gcf, fileName);
        
    end
    
    %% 粗さ条件をまとめた平均をプロット
    f = figure;
    hue_deg_rough_mean = mean(hue_deg, 3);
    for j = 1:object_exp3.light_num
        
        % 実験1の結果（粗さについて平均）
        GEindex_mean_exp1 = mean(exp1.GEindex{i}(:,:,j,:),4);
        CI95_mean_exp1 = mean(exp1.CI95_GEindex{i}(:,:,j,:),4);
        err_exp1 = abs(GEindex_mean_exp1 - CI95_mean_exp1);
        
        % 実験3の結果（粗さについて平均）
        GEindex_mean_exp3 = mean(exp3.GEindex{i}(:,1:8,j,:),4);
        CI95_mean_exp3 = mean(exp3.CI95_GEindex{i}(:,1:8,j,:), 4);
        err_exp3 = abs(GEindex_mean_exp3 - CI95_mean_exp3);
        
        % 横軸の色相
        hue_x_exp1 = [0,45,90,135,180,225,270,315];
        hue_x_exp3 = hue_deg_rough_mean(1:8,j);
        if hue_x_exp3(1) > 180
            hue_x_exp3(1) = hue_x_exp3(1) - 360;
        end
        
        % プロット
        hold on;
        h_exp1(j) = errorbar(hue_x_exp1, GEindex_mean_exp1, err_exp1(1,:), err_exp1(2,:), '--o', 'Color', graph_color(j,:));
        h_exp3(j) = errorbar(hue_x_exp3, GEindex_mean_exp3, err_exp3(1,:), err_exp3(2,:), '-o', 'Color', graph_color(j,:));
        
    end
    
    title('roughness mean')
    xlim([-20 360]);
    xlabel('Color direction (degree)');
    ylabel('GE index');
    
    % legend
    lgd = legend(h_exp3, num2cell(object_exp3.light));
    lgd.NumColumns = 1;
    lgd.Title.String = 'roughness';
    lgd.Title.FontWeight = 'normal';
    lgd.FontSize = sz.lgd;
    lgd.Location = 'northeastoutside';
    
    % save
    f.Position = [364,1499,866,550];
    graphName = strcat('GEindex_compair_',object_exp3.material(i),'_mean.png');
    fileName = strcat('../../analysis_result/',exp,'/',sn,'/graph/GEindex_compair/',graphName);
    saveas(gcf, fileName);
    
end

clear GEindex_exp1 GEindex_mean_exp1 CI95_exp1 CI95_mean_exp1
clear GEindex_exp3 GEindex_mean_exp3 CI95_exp3 CI95_mean_exp3
clear err_exp1 err_exp3 hue_x_exp1 hue_x_exp3 t_txt


%% 相関
for i = 1:object_exp3.material_num
    
    figure;
    hold on;
    
    count = 1;
    for j = 1:object_exp3.light_num
        for k = 1:object_exp3.rough_num
            
            % 実験1の結果
            GEindex_exp1 = exp1.GEindex{i}(:,:,j,k);
            
            % 実験3の結果
            GEindex_exp3 = exp3.GEindex{i}(:,1:8,j,k);
            
            lgd_txt{count} = strcat(object_exp3.light(j), '  roughness:', num2str(object_exp3.rough_v(k)));
            
            % 散布図
            scatter(GEindex_exp1, GEindex_exp3);
            
            count = count+1;
        end
    end
    
    xlabel('GEindex exp1');
    ylabel('GEindex exp3');
    
    legend(lgd_txt);
end
clear GEindex_exp1 GEindex_exp3
%}

%% 物体条件それぞれで色相について平均して実験1と3に差があるかを見る
% 実験3の金属素材についてはCuとAuも含む
for i = 1:object_exp3.material_num
    
    exp1.GEindex_hue_mean{i} = mean(exp1.GEindex{i}, 2);
    exp3.GEindex_hue_mean{i} = mean(exp3.GEindex{i}, 2);
    
    exp1.BS_GEindex_hue_mean{i} = mean(exp1.BS_GEindex{i}, 2);
    exp3.BS_GEindex_hue_mean{i} = mean(exp3.BS_GEindex{i}, 2);
    
    % 信頼区間
    for j = 1:object_exp3.light_num
        for k= 1:object_exp3.rough_num
            exp1.CI95_GEindex_hue_mean{i}(:,:,j,k) = CI95_bootstrap(exp1.BS_GEindex_hue_mean{i}(:,:,j,k))';
            exp3.CI95_GEindex_hue_mean{i}(:,:,j,k) = CI95_bootstrap(exp3.BS_GEindex_hue_mean{i}(:,:,j,k))';
        end
    end
    
    % 素材ごとの光沢感増大量平均（色相・物体条件について平均）
    exp1.GEindex_mean_all_hue_mean{i} = mean(exp1.GEindex_mean_all{i}, 2);
    exp3.GEindex_mean_all_hue_mean{i} = mean(exp3.GEindex_mean_all{i}, 2);
    exp1.BS_GEindex_mean_all_hue_mean{i} = mean(exp1.BS_GEindex_mean_all{i}, 2);
    exp3.BS_GEindex_mean_all_hue_mean{i} = mean(exp3.BS_GEindex_mean_all{i}, 2);
    exp1.CI95_GEindex_mean_all_hue_mean{i} = CI95_bootstrap(exp1.BS_GEindex_mean_all_hue_mean{i})';
    exp3.CI95_GEindex_mean_all_hue_mean{i} = CI95_bootstrap(exp3.BS_GEindex_mean_all_hue_mean{i})';
    
end

% プロット
graph_color = [[0 0.4470 0.7410]; [0.8500 0.3250 0.0980]];
clear err_exp1 err_exp3
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
        for k = 1:object_exp3.rough_num
            
            err_exp1(:,count) = abs(exp1.GEindex_hue_mean{i}(:,:,j,k) - exp1.CI95_GEindex_hue_mean{i}(:,:,j,k));
            err_exp3(:,count) = abs(exp3.GEindex_hue_mean{i}(:,:,j,k) - exp3.CI95_GEindex_hue_mean{i}(:,:,j,k));
            
            y_exp1(:,count) = exp1.GEindex_hue_mean{i}(:,:,j,k);
            y_exp3(:,count) = exp3.GEindex_hue_mean{i}(:,:,j,k);
            
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

% プロット
% 素材ごとについて
for i = 1:object_exp3.material_num
    
    x = 1:2;
    
    f = figure;
    hold on;
    bar_width = 0.3;
    
    err_exp1 = abs(exp1.GEindex_mean_all_hue_mean{i} - exp1.CI95_GEindex_mean_all_hue_mean{i});
    err_exp3 = abs(exp3.GEindex_mean_all_hue_mean{i} - exp3.CI95_GEindex_mean_all_hue_mean{i});
    err = [err_exp1, err_exp3];
    y = [exp1.GEindex_mean_all_hue_mean{i}, exp3.GEindex_mean_all_hue_mean{i}];
    
    b1 = bar(x(1),y(1), 'FaceColor',graph_color(1,:));
    errorbar(x(1),y(1), err(1,1), err(2,1), 'o', 'Color', [0,0,0]);
    b3 = bar(x(2),y(2), 'FaceColor',graph_color(2,:));
    errorbar(x(2),y(2), err(1,2), err(2,2), 'o', 'Color', [0,0,0]);
        
    xticks(x);
    xticklabels({'exp1', 'exp3'});
    %xtickangle(30);
    
end
clear x_exp1 x_exp3 y_exp1 y_exp3 err_exp1 err_exp3 x y

save('../../analysis_result/exp_realistic/all/GEindex_compair/exp1.mat', 'exp1'); % 実験1のGEindex（比較用に整理済み）
save('../../analysis_result/exp_realistic/all/GEindex_compair/exp3.mat', 'exp3');    

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
            
            sample_diff = exp1.BS_GEindex_hue_mean{i}(:,:,j,k) - exp3.BS_GEindex_hue_mean{i}(:,:,j,k);
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

save('../../analysis_result/exp_realistic/all/GEindex_compair/p.mat', 'p');
save('../../analysis_result/exp_realistic/all/GEindex_compair/sig_diff.mat', 'sig_diff');
save('../../analysis_result/exp_realistic/all/GEindex_compair/p_param.mat', 'p_param');
save('../../analysis_result/exp_realistic/all/GEindex_compair/sig_diff_param.mat', 'sig_diff_param');


% 素材条件間
comp_num = 2;
for i = 1:object_exp3.material_num
    
    sample_diff = exp1.BS_GEindex_mean_all_hue_mean{i} - exp3.BS_GEindex_mean_all_hue_mean{i};
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
save('../../analysis_result/exp_realistic/all/GEindex_compair/p_all_mean.mat', 'p_all_mean');
save('../../analysis_result/exp_realistic/all/GEindex_compair/sig_diff_all_mean.mat', 'sig_diff_all_mean');

clear sample_diff sdata alpha_holm id id_sort id_sort_all_mean
