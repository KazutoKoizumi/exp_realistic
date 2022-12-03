%% 色コントラストを変化率として計算
% CIE DE2000を使用

clear all

flag_par = 3;
object = object_paramater(flag_par);
pass.mat = '../../mat/';

load('../../mat/regress_var/val/color_difference.mat');
load('../../mat/stimuli_color/hue_mean_360.mat');

%% Main
for i = 1:object.material_num
    
    if i == 1
        hue_name = object.hue;
        hue_num = object.hue_num;
    elseif i == 2
        hue_name = object.hue_metal;
        hue_num = object.hue_metal_num;
    end
    
    % 色コントラスト変化（有彩色と無彩色の色コントラストの差）
    color_diff_tmp = color_difference{i}(:,1:hue_num,:,:) - color_difference{i}(:,hue_num+1:end,:,:);
    
    % 色コントラスト変化率（有彩色と無彩色の色コントラストの比）
    color_ratio_tmp = color_difference{i}(:,1:hue_num,:,:) ./ color_difference{i}(:,hue_num+1:end,:,:);
end

%% プロット : 元々の色コントラスト
graph_color = [[0 0.4470 0.7410]; [0 0 0]];
for i = 1:object.material_num
    figure;
    count_panel = 0;
    
    if i == 1
        hue_name = object.hue;
        hue_num = object.hue_num;
    elseif i == 2
        hue_name = object.hue_metal;
        hue_num = object.hue_metal_num;
    end
    
    for j = 1:object.light_num
        for k = 1:object.rough_num
            count_panel = count_panel + 1;
            subplot(2,3, count_panel);
            hold on;

            x = hue_mean_360{i}(:,j,k);
            y(:,1) = color_difference{i}(:,1:hue_num,j,k);
            y(:,2) = color_difference{i}(:,hue_num+1:end,j,k);

            if x(1)> 315
                x(1) = x(1) - 360;
            end
            
            for n = 1:2 % 有彩色, 無彩色
                switch i
                    case 1
                        h(n) = plot(x, y(:,n), '-o', 'Color', graph_color(n,:));
                    case 2
                        h(n) = plot(x(1:8), y(1:8,n), '-o', 'Color', graph_color(n,:));
                        
                        h_cuau(1) = plot(x(9), y(9,n), 's', 'Color', graph_color(n,:));
                        h_cuau(2) = plot(x(10), y(10,n), 'd', 'Color', graph_color(n,:));
                        
                end
            end
            
            title(strcat(object.material(i), ', ', object.light(j), ', roughness:', num2str(object.rough_v(k))));
            
            clear y;
        end
    end
    
    
end
    