%% HKの大きさの補正に関する調査
% 各刺激のハイライト領域彩度
% 補正前のHK効果の大きさ（ハイライト）
% 補正後のHK効果の大きさ（ハイライト）

clear all;

flag_par = 3;
object = object_paramater(flag_par);
pass.mat = '../../mat/';

spectrum_data = csvread('../../../calibration/spectrum_data.csv');
rgb_converter = tnt.RgbConverter(spectrum_data);
xyz_max = rgb_converter.linear_rgb_to_xyz([1,1,1]');

wp.d65_XYZ = whitepoint('d65');
wp.d65_XYZ_disp = wp.d65_XYZ * xyz_max(2);

%% 刺激画像のループ
count = 1;
for i = 1:object.material_num
    
    if i == 1
        hue_name = object.hue;
        hue_num = object.hue_num;
    elseif i == 2
        hue_name = object.hue_metal;
        hue_num = object.hue_metal_num;
    end
    
    for j = 1:object.light_num
        for k = 1:object.rough_num
            
            pass.object = strcat(pass.mat,object.shape(1),'/',object.material(i),'/',object.light(j),'/',object.rough(k),'/');
            load(strcat(pass.object,'stimuli_xyz.mat'));
            
            load('../../mat/mask/bunny_mask.mat');
            load('../../mat/mask/highlight_mask.mat');
            load('../../mat/mask/highlight_round_mask.mat');
            
            [iy, ix, ~] = size(mask);
            
            for h = 1:hue_num % 有彩色
                img = stimuli_xyz(:,:,:,h);
                
                % ハイライト・周辺領域のマスク
                h_tmp = rem(h,hue_num);
                if h_tmp == 0
                    h_tmp = hue_num;
                end
                mask_HL = highlight_mask(:,:,h_tmp,i,j,k);
                
                %% 彩度とHKの大きさを求める
                % 彩度, 色相
                [sat_map, sat_list] = get_saturation(img, mask, wp.d65_XYZ_disp');
                [hue_map, hue_list] = get_hue(img, mask, wp.d65_XYZ_disp'); % 色相：radian
                hue_map_deg = rad2deg(hue_map);
                
                % HK
                HK_map = ones(iy,ix); % 補正後
                HK_tmp_map = ones(iy,ix); % 補正前
                for y = 1:iy
                    for x = 1:ix
                        if mask(y,x)
                            [HK_map(y,x), HK_tmp_map(y,x)] = HKeffect_mod(sat_map(y,x), hue_map_deg(y,x)); % 物体部分以外はすべて1
                        end
                    end
                end
                
                %% ハイライト領域の平均値を抽出
                sat_HL_tmp(:,h,j,k) = mean(sat_map(mask_HL));
                HK_original_HL_tmp(:,h,j,k) = mean(HK_tmp_map(mask_HL));
                HK_mod_HL_tmp(:,h,j,k) = mean(HK_map(mask_HL));
                
            end
            
            fprintf('finish : %d/%d\n\n', count, object.all_num);
            count = count + 1;
            
        end
    end
    
    sat_HL{i} = sat_HL_tmp;
    HK_original_HL{i} = HK_original_HL_tmp;
    HK_mod_HL{i} = HK_mod_HL_tmp;
    
end

save('../../mat/stimuli_color/color_HL/sat_HL.mat', 'sat_HL');
save('../../mat/stimuli_color/color_HL/HK_original_HL.mat', 'HK_original_HL');
save('../../mat/stimuli_color/color_HL/HK_mod_HL.mat', 'HK_mod_HL');

%% 彩度変化 プロット
graph_color = [[0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]];
load('../../mat/stimuli_color/hue_mean_360.mat');
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
            if x(1)> 315
                x(1) = x(1) - 360;
            end
            
            y(:,1) = sat_HL{i}(:,:,j,k)';
            
            for n = 1:1
                switch i
                    case 1
                        h_color(n) = plot(x, y(:,n), '-o', 'Color', graph_color(n,:));
                    case 2
                        h_color(n) = plot(x(1:8), y(1:8,n), '-o', 'Color', graph_color(n,:));
                        
                        h_cuau(1) = plot(x(9), y(9,n), 's', 'Color', graph_color(n,:));
                        h_cuau(2) = plot(x(10), y(10,n), 'd', 'Color', graph_color(n,:));
                        
                end
            end
            
            xlabel('Color direction (degree)');
            xlim([-10 360]);
            ylabel('Value');
            ylim([0.01 0.1]);
            
            title(strcat(object.material(i), ', ', object.light(j), ', roughness:', num2str(object.rough_v(k))));
            
            
            lgd_txt = {'saturation'};
            %legend(h_color, lgd_txt, 'FontSize', 14, 'Location', 'eastoutside');
            %{
            if i == 2
                t = {'Cu', 'Au'};
                legend(h_cuau, t, 'FontSize', 14, 'Location', 'eastoutside');
            end
            %}
            
            clear y
        end
    end
    
    sgtitle('saturation');
end

%% HK プロット
graph_color = [[0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]];
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
            if x(1)> 315
                x(1) = x(1) - 360;
            end
            
            y(:,1) = HK_original_HL{i}(:,:,j,k)';
            y(:,2) = HK_mod_HL{i}(:,:,j,k)';
            
            for n = 1:2
                switch i
                    case 1
                        h_color(n) = plot(x, y(:,n), '-o', 'Color', graph_color(n,:));
                    case 2
                        h_color(n) = plot(x(1:8), y(1:8,n), '-o', 'Color', graph_color(n,:));
                        
                        h_cuau(1) = plot(x(9), y(9,n), 's', 'Color', graph_color(n,:));
                        h_cuau(2) = plot(x(10), y(10,n), 'd', 'Color', graph_color(n,:));
                        
                end
            end
            
            xlabel('Color direction (degree)');
            xlim([-10 360]);
            ylabel('Value');
            
            title(strcat(object.material(i), ', ', object.light(j), ', roughness:', num2str(object.rough_v(k))));
            
            
            lgd_txt = {'HK original', 'HK mod'};
            legend(h_color, lgd_txt, 'FontSize', 14, 'Location', 'eastoutside');
            %{
            if i == 2
                t = {'Cu', 'Au'};
                legend(h_cuau, t, 'FontSize', 14, 'Location', 'eastoutside');
            end
            %}
            
            clear y
        end
    end
    
    sgtitle('H-K effect');
end