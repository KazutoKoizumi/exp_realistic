% 選好尺度値プロット、実験3

% グラフ
%   行：照明
%   ライン：粗さ

% Input
%   psv_CI : 選好尺度値と信頼区間（素材間でサイズが異なるので1種ずつ呼び出す）
%               (16or20)*3*2*3
%   sig_diff : 有意差
%   exp : 実験名
%   sn : 被験者名
%

function f = plot_psv_realistic(psv_CI,sig_diff,exp,sn,hue_name, hue_name_label)
    
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
    figure;
    for j = 1:1 %object.light_num
        subplot(2,1,j);
        hold on;
        for k = 2:2 %object.rough_num
            
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
        
        % axis
        xticks(color_num(2,:));
        xticklabels(hue_name_label);
        %xticklabels({'gray', '0', '45', '90', '135', '180', '225', '270', '315'})
        xlabel('Color','FontSize',sz.label);
        xtickangle(45);
        xlim([0 size(psv_CI, 1)+1]);
        ylabel('PSV','FontSize',sz.label);
        %ylim([-2.5, 3.7]);
        ax.FontSize = sz.ax;
        
    end
    
    f = 1;
        
    
    %{
    for i = 1:object.shape_num % shape
        for j = 1:object.light_num % light
            f = figure; 
            for k = 1:object.diffuse_num % diffuse
                count = count + 1;
                for m = 1:object.method_num % method
                    subplot(3,2,2*(k-1)+m);
                    hold on;
                    for l = 1:object.rough_num % roughness
                        
                        id = (object.rough_num*object.method_num)*(count-1) + object.method_num*(l-1)+m;
                        psv_y = psv_CI(:,:,id);
                            
                        % プロット
                        h(l) = errorbar(color_num(l,1), psv_y(1,3), -psv_y(1,1), psv_y(1,2), '-o','Color',graph_color(l,:));
                        errorbar(color_num(l,2:9), psv_y(2:9,3), -psv_y(2:9,1), psv_y(2:9,2), '-o','Color',graph_color(l,:)); % 95%CI
                        hold on;
                        
                        % 有意差のある部分を塗りつぶす
                        rows = (T.shape==object.shape(i) & T.light==object.light(j) & T.diffuse==object.diffuse_v(k) & T.roughness==object.rough_v(l) & T.method==object.method(m));
                        grayT = T(rows,:);
                        for p = 1:8
                            if grayT.significantDifference(p) == 1 % 有意差あり
                                x = find(hue_name==grayT.hue2(p));
                                plot(x+sa(l),psv_y(x,3), 'o', 'Color',graph_color(l,:), 'MarkerFaceColor',graph_color(l,:));
                            
                                %noSigDiffNum(p) = noSigDiffNum(p)+1;
                            end
                        end
                        
                    end
                    ax = gca;
                    
                    % title
                    title(strcat(object.method(m),'   diffuse:',object.diffuse(k)), 'FontSize', sz.sgt);
                    
                    % axis
                    xticks(color_num(2,:));
                    xticklabels({'gray', '0', '45', '90', '135', '180', '225', '270', '315'})
                    xlabel('色相 (degree)','FontSize',sz.label);
                    xlim([0 10]);
                    ylabel('選好尺度値','FontSize',sz.label);
                    ylim([-vAbs, vAbs]);
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
            f.WindowState = 'maximized';
            graphName = strcat('psv_',object.shape(i),'_',object.light(j),'.png');
            fileName = strcat('../../analysis_result/',exp,'/',sn,'/graph/',graphName);
            saveas(gcf, fileName);
        end
    end
    %}
    
    % プロット 論文用
    %{
    figure;
    id.panel = 0;
    for i = 1:object_p.shape_num % shape
        for j = 1:object_p.light_num % light
            for l = 1:object_p.rough_num % roughness
                for k = 1:object_p.diffuse_num % diffuse
                    id.panel = id.panel + 1;
                    subplot(3,2,id.panel);
                    hold on;
                    id.graph = 0;
                    for m = 1:object_p.method_num % method
                        id.graph = id.graph + 1;
                        id.val = find(idx(:,3)==k & idx(:,4)==l & idx(:,5)==m);
                        psv_y = psv_CI(:,:,id.val);
                        psv_y(:,3) = psv_y(:,3) - psv_y(1,3);
                        
                        % プロット
                        h(m) = errorbar(color_num(m,1), psv_y(1,3), -psv_y(1,1), psv_y(1,2), '-o','Color',graph_color(m,:));
                        errorbar(color_num(m,2:9), psv_y(2:9,3), -psv_y(2:9,1), psv_y(2:9,2), '-o','Color',graph_color(m,:)); % 95%CI
                        hold on;
                        
                        % 有意差のある部分を塗りつぶす
                        rows = (T.shape==object_p.shape(i) & T.light==object_p.light(j) & T.diffuse==object_p.diffuse_v(k) & T.roughness==object_p.rough_v(l) & T.method==object_p.method(m));
                        grayT = T(rows,:);
                        for p = 1:8
                            if grayT.significantDifference(p) == 1 % 有意差あり
                                x = find(hue_name==grayT.hue2(p));
                                plot(x+sa(m),psv_y(x,3), 'o', 'Color',graph_color(m,:), 'MarkerFaceColor',graph_color(m,:));
                            
                                %noSigDiffNum(p) = noSigDiffNum(p)+1;
                            end
                        end
                
                    end
                    
                    ax = gca;
                    
                    % サブプロットのタイトル
                    t_txt = strcat('Diffuse reflectance:', num2str(object_p.diffuse_v(k)), '   Roughness:', num2str(object_p.rough_v(l)));
                    title(t_txt, 'FontSize', sz.sgt);
                    
                    % axis
                    xticks(color_num(2,:));
                    xticklabels({'gray', '0', '45', '90', '135', '180', '225', '270', '315'})
                    xlabel('Hue (degree)','FontSize',sz.label);
                    xlim([0 10]);
                    ylabel('PSV','FontSize',sz.label);
                    ylim([-2.5, 3.7]);
                    ax.FontSize = sz.ax;
                    
                    %{
                    % legend
                    %lgd = legend(h, {'0.05', '0.1', '0.2'});
                    lgd = legend(h, num2cell(object_p.rough));
                    lgd.NumColumns = 1;
                    lgd.Title.String = 'roughness';
                    lgd.Title.FontWeight = 'normal';
                    lgd.FontSize = sz.lgd;
                    lgd.Location = 'northeastoutside';
                    %}
                    
                    hold off;
                end
            end
        end
    end
    %}
    
end
