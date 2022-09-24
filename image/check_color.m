%% 物体部分の色分布（輝度・彩度・色相）を確認する

%clear all;

flag_par = 3; % 実験番号
object = object_paramater(flag_par); % 各パラメータまとめ
idx = make_index(flag_par);
pass.mat = '../../mat/';

wp_xyz = whitepoint('d65')';
wp_uvl = tnt.three_channel_convert([], wp_xyz, @(c,d) XYZTouvY(d));

count = 0;

sat_mean = cell(1,2);
hue_mean = cell(1,2);
hue_mean_360 = cell(1,2);

for i = 1:2 % material
    
    if i == 1
        hue_name = object.hue;
        hue_num = object.hue_num;
    elseif i == 2
        hue_name = object.hue_metal;
        hue_num = object.hue_metal_num;
    end
    
    sat_mean_tmp = zeros(hue_num, object.light_num, object.rough_num);
    hue_mean_tmp = zeros(hue_num, object.light_num, object.rough_num);
    hue_mean_360_tmp = zeros(hue_num, object.light_num, object.rough_num);
    
    for j = 1:2 % light
        for k = 1:3 % roughness        
            %% 画像読み込み
            pass.object = strcat(pass.mat,object.shape(1),'/',object.material(i),'/',object.light(j),'/',object.rough(k),'/');
            load(strcat(pass.object,'stimuli_xyz.mat'));
            pass.stimuli = strcat('../../stimuli/',object.shape(1),'/',object.material(i),'/',object.light(j),'/',object.rough(k),'/');
            load(strcat(pass.stimuli,'stimuli.mat'));
            load('../../mat/mask/bunny_mask.mat');
            
            lum_max = max(stimuli_xyz(:,:,2,:), [], 'all');
            lum_range = [0, lum_max];
            sat_range = [0, 0.13]; % これより高彩度の部分もある
            
            %% Main
            for h = 1:hue_num %hue_num
                img = stimuli_xyz(:,:,:,h);
                
                % 輝度取得
                [lum_map, lum_list] = get_luminance(img, mask);
                
                % 彩度取得
                [sat_map, sat_list] = get_saturation(img, mask, wp_xyz);
                % 平均彩度
                sat_mean_tmp(h,j,k) = mean(sat_list);
                
                %[lum_map,lum_list,sat_map,sat_list] = plot_relation_lum_sat(img,mask,wp,lum_range,sat_range);
                
                %% 色相取得
                %{
                [hue_map, hue_list] = get_hue(img, mask, wp_xyz);
                hue_map = hue_map + standardizeMissing(mask,0);
                hue_map_deg = rad2deg(hue_map);
                hue_list_deg = rad2deg(hue_list);
                % 平均色相
                hue_mean_tmp(h,j,k) = mean(hue_list_deg);
                %}
                
                %{
                % u'v'の平均色度を求めてから色相を求める
                img_uvl = tnt.three_channel_convert([], img, @(c,d) XYZTouvY(d));
                mask_l = logical(mask);
                for p = 1:3
                    img_tmp = img_uvl(:,:,p);
                    img_uvl_list(p,:) = img_tmp(mask_l);
                end
                img_uvl_mean = mean(img_uvl_list, 2);
                [hue_mean_tmp(h,j,k), rho] = cart2pol(img_uvl_mean(1)-wp_uvl(1), img_uvl_mean(2)-wp_uvl(2));
                hue_mean_tmp(h,j,k) = rad2deg(hue_mean_tmp(h,j,k));
                %}
                
                % XYZの状態で物体の色平均取ってから色相を求める
                mask_l = logical(mask);
                for p = 1:3
                    img_tmp = img(:,:,p);
                    img_XYZ_list(p,:) = img_tmp(mask_l)';
                end
                img_XYZ_mean = mean(img_XYZ_list, 2);
                img_uvl_mean = XYZTouvY(img_XYZ_mean);
                [hue_mean_tmp(h,j,k), rho] = cart2pol(img_uvl_mean(1)-wp_uvl(1), img_uvl_mean(2)-wp_uvl(2));
                hue_mean_tmp(h,j,k) = rad2deg(hue_mean_tmp(h,j,k));
                %}
                
                % 0~360度に変換
                hue_mean_360_tmp(h,j,k) = hue_mean_tmp(h,j,k);
                if hue_mean_360_tmp(h,j,k) < 0
                    hue_mean_360_tmp(h,j,k) = hue_mean_360_tmp(h,j,k) + 360;
                end

                % 最大彩度の探索
                tmp = max(sat_map, [], 'all');
                if h == 1
                    sat_max = tmp;
                end
                if sat_max < tmp
                    sat_max = tmp;
                end
                
                %{
                %% プロット
                f = figure;
                
                % 輝度マップ
                subplot(2,3,1);
                imagesc(lum_map, lum_range);
                colormap jet;
                colorbar;
                title('luminance');
                
                % 彩度マップ
                subplot(2,3,2);
                imagesc(sat_map, sat_range);
                colormap jet;
                colorbar;
                title('saturation');
                
                % 色相マップ
                subplot(2,3,3);
                imagesc(hue_map_deg);
                colormap jet;
                colorbar;
                title('color direction');
                
                % 輝度-彩度
                subplot(2,3,4);
                scatter(lum_list, sat_list);
                %xlim(lum_range);
                %ylim(sat_range);
                title('luminance, saturation');
                xlabel('luminance');
                ylabel('saturation');
                
                % 色度プロットで色相と彩度確認
                img_uvl = tnt.three_channel_convert([], img, @(c,d) XYZTouvY(d));
                img_u = img_uvl(:,:,1);
                img_v = img_uvl(:,:,2);
                img_uvl_bunny(:,1) = img_u(logical(mask));
                img_uvl_bunny(:,2) = img_v(logical(mask));
                subplot(2,3,5);
                scatter(img_uvl_bunny(:,1), img_uvl_bunny(:,2));
                hold on;
                scatter(wp_uvl(1), wp_uvl(2), 48, [0,0,0], 'filled');
                hold off;
                xlim([0 0.41]);
                ylim([0.25 0.58]);
                title("u'v' coordinate");
                xlabel("u'");
                ylabel("v'");
                
                % 刺激画像表示
                subplot(2,3,6);
                image(stimuli(:,:,:,h));
                
                if i == 1
                    sg_txt = strcat("bunny, ", object.material(i), ", ", object.light(j), ", ", object.rough(k), ", ", object.hue(h));
                    fig_name = strcat('color_info_',object.material(i),'_',object.light(j),'_',object.rough(k),'_',object.hue(h),'.png');
                elseif i == 2
                    sg_txt = strcat("bunny, ", object.material(i), ", ", object.light(j), ", ", object.rough(k), ", ", object.hue_metal(h));
                    fig_name = strcat('color_info_',object.material(i),'_',object.light(j),'_',object.rough(k),'_',object.hue_metal(h),'.png');
                end
                sgtitle(sg_txt);
                
                f.WindowState = 'maximized';
                file_name = strcat('../../image/stimuli_color_information/',fig_name);
                saveas(gcf, file_name);
                close;
                %}
                
                fprintf('hue finish : %d/%d\n\n', h, hue_num);
            end
            
            clear stimuli_xyz stimuli;
            
            count = count+1;
            fprintf('material:%s,  light:%s,  roughness:%s\n', object.material(i), object.light(j), object.rough(k));
            fprintf('finish : %d/%d\n\n', count, object.all_num);
        end
    end
    
    sat_mean{i} = sat_mean_tmp;
    hue_mean{i} = hue_mean_tmp;
    hue_mean_360{i} = hue_mean_360_tmp;
    
end

%save('../../mat/stimuli_color/sat_mean.mat', 'sat_mean');
%save('../../mat/stimuli_color/hue_mean.mat', 'hue_mean');
%save('../../mat/stimuli_color/hue_mean_360.mat', 'hue_mean_360');

%% 実験1の刺激に対する設定
wp_xyz_exp1 = [19.3151, 20.0000, 30.5479];
