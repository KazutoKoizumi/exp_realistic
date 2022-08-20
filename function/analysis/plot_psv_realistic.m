% 選好尺度値プロット、実験3

% グラフ
%   行：照明
%   ライン：粗さ

% Input
%   psv_CI : 選好尺度値と信頼区間（素材間でサイズが異なるので1種ずつ呼び出す）
%               (16or20)*3*2*3
%   sig_diff : 有意差の有無
%   exp : 実験名
%   sn : 被験者名
%

function f = plot_psv_realistic(psv_CI,sig_diff,exp,sn,hue_name, hue_name_list)
    
    flag_par = 3;
    object = object_paramater(flag_par);    
    
    % グラフのパラメータ関係の設定
    color_num = 1:size(psv_CI, 1);
    color_num = [color_num-0.1; color_num; color_num+0.1];
    graph_color = [[0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]];
    
    % grayとの有意差
    %rows = sig_diff.hue1 == 'gray';
    %T = sig_diff(rows,:);
    %sa = [-0.1, 0, 0.1];
    
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
            
            psv_y = psv_CI(:,:,j,k);
            
            % プロット
            h(k) = errorbar(color_num(k,:), psv_y(:,3), -psv_y(:,1), psv_y(:,2), '-o', 'Color', graph_color(k,:));
            hold on;
            
            % 有彩色と無彩色間の有意差について図示？
            
        end
        ax = gca;
        
        % サブプロットのタイトル
        t_txt = object.light(j);
        title(t_txt, 'FontSize', sz.sgt);
        
        % 色相名
        hue_name_tmp = round(mean(hue_name_list(:,j,:), 3));
        hue_name_label = string(hue_name_tmp)';
        hue_name_label = cat(2, hue_name_label, append(hue_name_label, ' achromatic'));
        
        % axis
        xticks(color_num(2,:));
        xticklabels(hue_name_label);
        %xticklabels({'gray', '0', '45', '90', '135', '180', '225', '270', '315'})
        xlabel('Color direction (degree)','FontSize',sz.label);
        xtickangle(45);
        xlim([0 size(psv_CI, 1)+1]);
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
