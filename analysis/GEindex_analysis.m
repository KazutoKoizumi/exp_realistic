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

% グラフ設定
graph_color = [[0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]];
sz.sgt = 12;
sz.lgd = 8; %16;

for i = 1:object.material_num
    
    hue_deg = hue_mean_360{i};
    
    %% 全結果
    f = figure;
    for j = 1:object.light_num
        subplot(2,1,j);
        for k = 1:object.rough_num
            
            hue_x = round(hue_deg(:,j,k));
            hue_x_label = hue_x;
            if hue_x(1) > 180
                hue_x(1) = hue_x(1) - 360;
            end
            
            GEindex_y = GEindex{i}(:,:,j,k);
            CI95_y = CI95_GEindex{i}(:,:,j,k);
            err = abs(GEindex_y - CI95_y);
            
            hue_num = 8;
            if i == 1 % プラスチック
                h(k) = errorbar(hue_x, GEindex_y, err(1,:), err(2,:), '-o', 'Color', graph_color(k,:));
                hold on;
                
            elseif i == 2 % 金属
                % マンセルプロット
                data_range = 1:hue_num;
                h(k) = errorbar(hue_x(data_range), GEindex_y(data_range), err(1,data_range), err(2,data_range), '-o', 'Color', graph_color(k,:));
                hold on;
                
                % 銅と金のプロット
                h_cuau(k) = errorbar(hue_x(9:10), GEindex_y(9:10), err(1,9:10), err(2,9:10), '--s', 'Color', graph_color(k,:));
                % 銅と金にテキスト
                if k == 1
                    text(hue_x(9)+2, GEindex_y(9), 'Cu');
                    text(hue_x(10)+2, GEindex_y(10), 'Au');
                end
            end
        end
        
        % サブプロットのタイトル
        t_txt = object.light(j);
        title(t_txt, 'FontSize', sz.sgt);
        
        % axis
        xlim([-10 360]);
        xlabel('Color direction (degree)');
        ylabel('GE index');
        
        % legend
        lgd = legend(h, num2cell(object.rough));
        lgd.NumColumns = 1;
        lgd.Title.String = 'roughness';
        lgd.Title.FontWeight = 'normal';
        lgd.FontSize = sz.lgd;
        lgd.Location = 'northeastoutside';
        
    end
    
    % save
    f.Position = [715,1081,1074,964];
    graphName = strcat('GEindex_',object.material(i),'.png');
    fileName = strcat('../../analysis_result/',exp,'/',sn,'/graph/GEindex/',graphName);
    saveas(gcf, fileName);
    
    
    %% 粗さ条件をまとめた平均
    f = figure;
    hue_deg_rough_mean = mean(hue_deg, 3);
    for j = 1:object.light_num
        hue_x = hue_deg_rough_mean(:,j);
        if hue_x(1) > 180
            hue_x(1) = hue_x(1) - 360;
        end
        
        GEindex_y = mean(GEindex{i}(:,:,j,:), 4);
        CI95_y = mean(CI95_GEindex{i}(:,:,j,:), 4);
        err = abs(GEindex_y - CI95_y);
        
        if i == 1 % プラスチック
            h(j) = errorbar(hue_x, GEindex_y, err(1,:), err(2,:), '-o', 'Color', graph_color(j,:));
            hold on;
        elseif i == 2 % 金属
            % マンセルプロット
            data_range = 1:hue_num;
            h(j) = errorbar(hue_x(data_range), GEindex_y(data_range), err(1,data_range), err(2,data_range), '-o', 'Color', graph_color(j,:));
            hold on;

            % 銅と金のプロット
            h_cuau(j) = errorbar(hue_x(9:10), GEindex_y(9:10), err(1,9:10), err(2,9:10), '--s', 'Color', graph_color(j,:));
            % 銅と金にテキスト
            if j == 1
                text(hue_x(9)+2, GEindex_y(9), 'Cu');
                text(hue_x(10)+2, GEindex_y(10), 'Au');
            end
        end
    end
        
    title('roughness mean');
    xlim([-10 360]);
    xlabel('Color direction (degree)');
    ylabel('GE index');
    
    % legend
    lgd = legend(h, num2cell(object.light));
    lgd.NumColumns = 1;
    lgd.Title.String = 'roughness';
    lgd.Title.FontWeight = 'normal';
    lgd.FontSize = sz.lgd;
    lgd.Location = 'northeastoutside';
    
    % save
    f.Position = [364,1499,866,550];
    graphName = strcat('GEindex_',object.material(i),'_mean.png');
    fileName = strcat('../../analysis_result/',exp,'/',sn,'/graph/GEindex/',graphName);
    saveas(gcf, fileName);
    
end

    