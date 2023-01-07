% 選好尺度値プロット、実験3

% グラフ
%   行：照明
%   ライン：粗さ

% Input
%   psv_CI : 選好尺度値と信頼区間（素材間でサイズが異なるので1種ずつ呼び出す）
%               (16or20)*3*2*3
%   hue_deg : 平均色相角

function f = plot_psv_realistic(psv_CI, flag_material, hue_deg)
    
    flag_par = 3;
    object = object_paramater(flag_par);
    %material_num = 8;
    
    % グラフのパラメータ関係の設定
    graph_color = [[0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]];
    
    % max min
    %v_max = max(reshape(max(max(psv_CI)), 1, object_p.all_num));
    %v_max = max(psv_CI(:,2,:) + psv_CI(:,3,:), [], 'all');
    %v_min = min(reshape(min(min(psv_CI)), 1, object_p.all_num));
    %v_min = min(psv_CI(:,1,:) + psv_CI(:,3,:), [], 'all');
    %vAbs = max(abs([v_min, v_max]));
    
    % プロット時のサイズ
    sz.t = 22; %22;
    sz.sgt = 20; %20;
    sz.label = 22; %22;
    sz.ax = 20; %20;
    sz.lgd = 20; %16;
    
    % プロット
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
            
            hue_num = 8;
            if flag_material == 1
                % 有彩色プロット
                p = 1;
                data_range = hue_num*(p-1)+1:hue_num*p;
                h_color(k) = errorbar(hue_x(data_range), psv_y(data_range,3), -psv_y(data_range,1), psv_y(data_range,2), '-o', 'Color', graph_color(k,:));
                hold on;
                % 無彩色プロット
                p = 2;
                data_range = hue_num*(p-1)+1:hue_num*p;
                h_gray(k) = errorbar(hue_x(data_range), psv_y(data_range,3), -psv_y(data_range,1), psv_y(data_range,2), '--o', 'Color', graph_color(k,:));
            
            elseif flag_material == 2
                % 有彩色プロット
                p = 1;
                data_range = hue_num*(p-1)+1:hue_num*p;
                h_color(k) = errorbar(hue_x(data_range), psv_y(data_range,3), -psv_y(data_range,1), psv_y(data_range,2), '-o', 'Color', graph_color(k,:));
                % 無彩色プロット
                data_range = 11:18;
                h_gray(k) = errorbar(hue_x(data_range), psv_y(data_range,3), -psv_y(data_range,1), psv_y(data_range,2), '--o', 'Color', graph_color(k,:));
                
                % 銅と金のプロット
                % 有彩色
                %h_color_cuau(k) = errorbar(hue_x(9:10), psv_y(9:10,3), -psv_y(9:10,1), psv_y(9:10,2), '-s', 'Color', graph_color(k,:));
                h_color_cuau(1) = errorbar(hue_x(9), psv_y(9,3), -psv_y(9,1), psv_y(9,2), 's', 'Color', graph_color(k,:));
                h_color_cuau(2) = errorbar(hue_x(10), psv_y(10,3), -psv_y(10,1), psv_y(10,2), 'd', 'Color', graph_color(k,:));
                % 無彩色
                %h_gray_cuau(k) = errorbar(hue_x(19:20), psv_y(19:20,3), -psv_y(19:20,1), psv_y(19:20,2), '--s', 'Color', graph_color(k,:));
                h_gray_cuau(1) = errorbar(hue_x(19), psv_y(19,3), -psv_y(19,1), psv_y(19,2), 's', 'Color', graph_color(k,:));
                h_gray_cuau(2) = errorbar(hue_x(20), psv_y(20,3), -psv_y(20,1), psv_y(20,2), 'd', 'Color', graph_color(k,:));
                % 銅と金にテキスト
                if k == 1
                    text(hue_x(9)+3, psv_y(9,3), 'Cu', 'FontSize', 14);
                    text(hue_x(10)+3, psv_y(10,3), 'Au', 'FontSize', 14);
                end
            end
            
        end
        ax = gca;
        
        % サブプロットのタイトル
        t_txt = object.light(j);
        title(t_txt, 'FontSize', sz.sgt);
        
        % axis
        xlabel('Color direction (degree)','FontSize',sz.label);
        xlim([-20 360]);
        ylim([-2 2]);
        %ylabel('PSV','FontSize',sz.label);
        ylabel('Preference scale value','FontSize',sz.label);
        ax.FontSize = sz.ax;
        
        % legend
        lgd = legend(h_color, num2cell(object.rough));
        lgd.NumColumns = 1;
        lgd.Title.String = 'roughness';
        lgd.Title.FontWeight = 'normal';
        lgd.FontSize = sz.lgd;
        lgd.Location = 'northeastoutside';
        
        hold off;
    end
    
end
