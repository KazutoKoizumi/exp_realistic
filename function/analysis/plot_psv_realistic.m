% 選好尺度値プロット、実験3

% グラフ
%   行：照明
%   ライン：粗さ

% Input
%   psv_CI : 選好尺度値と信頼区間（素材間でサイズが異なるので1種ずつ呼び出す）
%               (16or20)*3*2*3
%   hue_deg : 平均色相角

function f = plot_psv_realistic(psv_CI,hue_name, hue_deg)
    
    flag_par = 3;
    object = object_paramater(flag_par);
    material_num = size(psv_CI,1) / 2;
    
    % グラフのパラメータ関係の設定
    graph_color = [[0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]];
    %color_num = 1:size(psv_CI, 1);
    %color_num = round(hue_deg);
    %color_num = [color_num-0.1; color_num; color_num+0.1];
    
    % max min
    %v_max = max(reshape(max(max(psv_CI)), 1, object_p.all_num));
    %v_max = max(psv_CI(:,2,:) + psv_CI(:,3,:), [], 'all');
    %v_min = min(reshape(min(min(psv_CI)), 1, object_p.all_num));
    %v_min = min(psv_CI(:,1,:) + psv_CI(:,3,:), [], 'all');
    %vAbs = max(abs([v_min, v_max]));
    
    % プロット時のサイズ
    sz.t = 14; %22;
    sz.sgt = 12; %20;
    sz.label = 14; %22;
    sz.ax = 12; %20;
    sz.lgd = 8; %16;
    
    % プロット
    
    count = 0;
    f = figure;
    for j = 1:object.light_num
        subplot(2,1,j);
        hold on;
        
        for k = 1:object.rough_num
                    
            hue_x = round(hue_deg(:,j,k));
            hue_x_label = hue_x;
            
            if hue_x(1) > 180 % 色相インデックスが最初の刺激の平均色相が180~360度のとき調整
                hue_x(1) = hue_x(1) - 360;
            end
            
            hue_x = repmat(hue_x, [2 1]);
            hue_x_label = repmat(hue_x_label, [2 1]);
            
            psv_y = psv_CI(:,:,j,k);
            
            % 有彩色プロット
            p = 1;
            data_range = material_num*(p-1)+1:material_num*p;
            h(k) = errorbar(hue_x(data_range), psv_y(data_range,3), -psv_y(data_range,1), psv_y(data_range,2), '-o', 'Color', graph_color(k,:));
            hold on;
            
            % 無彩色プロット
            p = 2;
            data_range = material_num*(p-1)+1:material_num*p;
            h(k) = errorbar(hue_x(data_range), psv_y(data_range,3), -psv_y(data_range,1), psv_y(data_range,2), '--o', 'Color', graph_color(k,:));
            
        end
        ax = gca;
        
        % サブプロットのタイトル
        t_txt = object.light(j);
        title(t_txt, 'FontSize', sz.sgt);
        
        % 色相名;
        hue_name_label = string(hue_x_label)';
        hue_name_label = cat(2, hue_name_label, append(hue_name_label, ' achromatic'));
        
        % axis
        round(mean(hue_deg(:,j,:), 3))
        xticks();
        xticklabels(hue_name_label);
        xlabel('Color direction (degree)','FontSize',sz.label);
        xtickangle(45);
        xlim([0 360]);
        ylabel('PSV','FontSize',sz.label);
        %ylim([-2.5, 3.7]);
        ax.FontSize = sz.ax;
        
        % legend
        %lgd = legend(h, {'0.05', '0.1', '0.2'});
        lgd = legend(h, num2cell(object.rough));
        lgd.NumColumns = 1;
        lgd.Title.String = 'roughness';
        lgd.Title.FontWeight = 'normal';
        lgd.FontSize = sz.lgd;
        lgd.Location = 'northeastoutside';
        
        hold off;
    end
    
end
