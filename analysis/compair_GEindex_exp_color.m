%% 実験1と選好尺度値を比較する

clear all;

exp = 'exp_realistic';
sn = 'all';

flag_par = 3;
object = object_paramater(flag_par);
object_exp1 = object_paramater(1);
idx_exp1 = make_index(1);

% 実験1の結果
load('../../../exp_luminance_gloss/data/for_paper/exp1/CG_effect.mat');
load('../../../exp_luminance_gloss/data/for_paper/exp1/BS.mat');
load('../../../exp_luminance_gloss/mat/regress_var/gloss_diff.mat');

% 実験3の結果
load('../../analysis_result/exp_realistic/all/GEindex/GEindex.mat');
load('../../analysis_result/exp_realistic/all/GEindex/GEindex_mean_all.mat');
load('../../analysis_result/exp_realistic/all/GEindex/BS_GEindex.mat');
load('../../analysis_result/exp_realistic/all/GEindex/BS_GEindex_mean_all.mat');
load('../../analysis_result/exp_realistic/all/GEindex/CI95_GEindex.mat');
load('../../analysis_result/exp_realistic/all/GEindex/CI95_GEindex_mean_all.mat');

% 色相名を角度に
load('../../mat/stimuli_color/hue_mean_360.mat');

% グラフ設定
graph_color = [[0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]];
sz.sgt = 12;
sz.lgd = 8; %16;

%% 色相ごとの光沢感変化量の単純な比較
for i = 1:object.material_num
    
    % プラスチック・金属とD・SD条件の対応
    if i == 1
        m = 2;
    elseif i == 2
        m = 1;
    end
    
    hue_deg = hue_mean_360{i};
    hue_num = 8;
    
    %% 全プロット
    f = figure;
    count = 1;
    for j = 1:object.light_num
        subplot(2,1,j);
        for k = 1:object.rough_num
            
            idx_method = idx_exp1(m:2:end,:);
            
            % 実験1の結果（拡散反射率については平均を取る）
            id_exp1 = find(idx_method(:,1)==1 & idx_method(:,2)==j & idx_method(:,4)==k & idx_method(:,5)==m); 
            GEindex_exp1 = mean(gloss_diff.all(id_exp1,:,m),1);
            GEindex_exp1_method(count,:,i) = GEindex_exp1; % 1:D条件、2:SD条件 (プラスチック条件と金属条件に順番を対応させる)
            count = count + 1;
            
            % 平均した値の95%信頼区間
            
            % 実験3の結果（金属のCu,Auの結果は除く）
            GEindex_exp3 = GEindex{i}(:,1:8,j,k);
            CI95_exp3 = CI95_GEindex{i}(:,1:8,j,k);
            err_exp3 = abs(GEindex_exp3 - CI95_exp3);
            
            % 横軸の色相
            hue_x_exp1 = [0,45,90,135,180,225,270,315];
            hue_x_exp3 = round(hue_deg(1:8,j,k));
            if hue_x_exp3(1) > 180
                hue_x_exp3(1) = hue_x_exp3(1) - 360;
            end
            
            % プロット
            hold on;
            h_exp1(k) = plot(hue_x_exp1, GEindex_exp1, '--o', 'Color', graph_color(k,:));
            h_exp3(k) = errorbar(hue_x_exp3, GEindex_exp3, err_exp3(1,:), err_exp3(2,:), '-o', 'Color', graph_color(k,:));
            
        end
        
        % サブプロットのタイトル
        t_txt = object.light(j);
        title(t_txt, 'FontSize', sz.sgt);
        
        % axis
        xlim([-10 360]);
        xlabel('Color direction (degree)');
        ylabel('GE index');
        
        % legend
        lgd = legend(h_exp3, num2cell(object.rough));
        lgd.NumColumns = 1;
        lgd.Title.String = 'roughness';
        lgd.Title.FontWeight = 'normal';
        lgd.FontSize = sz.lgd;
        lgd.Location = 'northeastoutside';
        
        % save
        f.Position = [715,1081,1074,964];
        graphName = strcat('GEindex_compair_',object.material(i),'.png');
        fileName = strcat('../../analysis_result/',exp,'/',sn,'/graph/GEindex_compair/',graphName);
        saveas(gcf, fileName);
        
    end
    
    %% 粗さ条件をまとめた平均をプロット
    f = figure;
    hue_deg_rough_mean = mean(hue_deg, 3);
    for j = 1:object.light_num
        
        % 実験1の結果（拡散反射率,粗さについて平均を取る）
        id_exp1 = find(idx_method(:,1)==1 & idx_method(:,2)==j & idx_method(:,4)==k & idx_method(:,5)==m); 
        GEindex_mean_exp1 = mean(gloss_diff.all(id_exp1,:,m),1);
        
        % 実験3の結果（粗さについて平均）
        %GEindex_mean_exp3 = GEindex_mean_all{i}(1:8);
        %err_exp3 = abs(GEindex_mean_all{i}(1:8) - CI95_GEindex_mean_all{i}(:,1:8));
        GEindex_mean_exp3 = mean(GEindex{i}(:,1:8,j,:),4);
        CI95_mean_exp3 = mean(CI95_GEindex{i}(:,1:8,j,:), 4);
        err_exp3 = abs(GEindex_mean_exp3 - CI95_mean_exp3);
        
        % 横軸の色相
        hue_x_exp1 = [0,45,90,135,180,225,270,315];
        hue_x_exp3 = hue_deg_rough_mean(1:8,j);
        if hue_x_exp3(1) > 180
            hue_x_exp3(1) = hue_x_exp3(1) - 360;
        end
        
        % プロット
        hold on;
        h_exp1(j) = plot(hue_x_exp1, GEindex_mean_exp1, '--o', 'Color', graph_color(j,:));
        h_exp3(j) = errorbar(hue_x_exp3, GEindex_mean_exp3, err_exp3(1,:), err_exp3(2,:), '-o', 'Color', graph_color(j,:));
        
    end
    
    title('roughness mean')
    xlim([-10 360]);
    xlabel('Color direction (degree)');
    ylabel('GE index');
    
    % legend
    lgd = legend(h_exp3, num2cell(object.light));
    lgd.NumColumns = 1;
    lgd.Title.String = 'roughness';
    lgd.Title.FontWeight = 'normal';
    lgd.FontSize = sz.lgd;
    lgd.Location = 'northeastoutside';
    
    % save
    f.Position = [364,1499,866,550];
    graphName = strcat('GEindex_compair_',object.material(i),'_mean.png');
    fileName = strcat('../../analysis_result/',exp,'/',sn,'/graph/GEindex_compair/',graphName);
    saveas(gcf, fileName);
    
end

%% 相関
%{
for i = 1:object.material_num
    
    if i == 1
        m = 2;
    elseif i == 2
        m = 1;
    end
    
    hue_num = 8;
    figure;
    hold on;
    count = 1;
    for j = 1:object.light_num
        for k = 1:object.rough_num
            
            idx_method = idx_exp1(m:2:end,:);
            
            % 実験1の結果
            id_diff_ref = 1; % 実験1の拡散反射率(1:0.1, 2:0.3, 3:0.5)
            id_exp1 = find(idx_method(:,1)==1 & idx_method(:,2)==j & idx_method(:,3)==id_diff_ref & idx_method(:,4)==k & idx_method(:,5)==m); 
            GEindex_exp1 = gloss_diff.all(id_exp1,:,m);
            
            % 実験3の結果
            GEindex_exp3 = GEindex{i}(:,1:8,j,k);
            CI95_exp3 = CI95_GEindex{i}(:,1:8,j,k);
            err = abs(GEindex_exp3 - CI95_exp3);
            
            lgd_txt{count} = strcat(object.light(j), '  roughness:', num2str(object.rough_v(k)));
            
            % 散布図
            scatter(GEindex_exp1, GEindex_exp3);
            
            count = count+1;
        end
    end
    
    xlabel('GEindex exp1');
    ylabel('GEindex exp3');
    
    legend(lgd_txt);
end
%}
