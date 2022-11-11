%% 説明変数を計算する
clear all

exp = 'exp_realistic';

flag_par = 3;
object = object_paramater(flag_par);
pass.mat = '../../mat/';

spectrum_data = csvread('../../../calibration/spectrum_data.csv');
rgb_converter = tnt.RgbConverter(spectrum_data);
xyz_max = rgb_converter.linear_rgb_to_xyz([1,1,1]');

% L*a*b*変換時の白色点設定
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
            % 画像読み込み
            pass.object = strcat(pass.mat,object.shape(1),'/',object.material(i),'/',object.light(j),'/',object.rough(k),'/');
            load(strcat(pass.object,'stimuli_xyz.mat'));
            pass.stimuli = strcat('../../stimuli/',object.shape(1),'/',object.material(i),'/',object.light(j),'/',object.rough(k),'/');
            load(strcat(pass.stimuli,'stimuli.mat'));
            load('../../mat/mask/bunny_mask.mat');
            load('../../mat/mask/highlight_mask.mat');
            load('../../mat/mask/highlight_round_mask.mat');
            
            [iy, ix, ~] = size(mask);
            
            for h = 1:hue_num*2 % 有彩色 + 無彩色
                img = stimuli_xyz(:,:,:,h);
                
                % ハイライト・周辺領域のマスク
                h_tmp = rem(h,hue_num);
                if h_tmp == 0
                    h_tmp = hue_num;
                end
                mask_HL = highlight_mask(:,:,h_tmp,i,j,k);
                mask_HL_near = highlight_round_mask(:,:,h_tmp,i,j,k);
                mask_body = mask - mask_HL;
                
                %% HK効果の大きさを画像データと同じ形式で求める
                % 彩度、色相を求める
                [sat_map, sat_list] = get_saturation(img, mask, wp.d65_XYZ_disp');
                [hue_map, hue_list] = get_hue(img, mask, wp.d65_XYZ_disp'); % 色相：radian
                hue_map_deg = rad2deg(hue_map);
                hue_list_deg = rad2deg(hue_list);
                
                % HKの大きさを求める
                HK_map = ones(iy,ix);
                for y = 1:iy
                    for x = 1:ix
                        if mask(y,x)
                            HK_map(y,x) = HKeffect_mod(sat_map(y,x), hue_map_deg(y,x)); % 物体部分以外はすべて1
                        end
                    end
                end
                
                %% HK輝度を求める
                % uvlに変換
                img_uvl = tnt.three_channel_convert([], img, @(c,d) XYZTouvY(d));
                
                % HK輝度を求める
                lum_original.all = img_uvl(:,:,3);
                lum_HK.all = HK_map .* lum_original.all;
                
                %% ハイライト領域・それ以外の領域それぞれで元の輝度、HK輝度を求める
                % 元輝度・ハイライト領域
                lum_original.HL.all = lum_original.all .* mask_HL;
                lum_original.HL.all_list = lum_original.HL.all(mask_HL==1);
                lum_original.HL.mean = mean(lum_original.HL.all_list);
                lum_original.HL.log_all_list = log10(lum_original.HL.all_list);
                lum_original.HL.log_mean = mean(lum_original.HL.log_all_list);

                % 元輝度・body領域
                lum_original.body.all = lum_original.all .* mask_body;
                lum_original.body.all_list = lum_original.body.all(mask_body==1);
                lum_original.body.mean = mean(lum_original.body.all_list);
                lum_original.body.log_all_list = log10(lum_original.body.all_list);
                lum_original.body.log_mean = mean(lum_original.body.log_all_list);
                
                % HK輝度・ハイライト領域
                lum_HK.HL.all = lum_HK.all .* mask_HL;
                lum_HK.HL.all_list = lum_HK.HL.all(mask_HL==1);
                lum_HK.HL.mean = mean(lum_HK.HL.all_list);
                lum_HK.HL.log_all_list = log10(lum_HK.HL.all_list);
                lum_HK.HL.log_mean = mean(lum_HK.HL.log_all_list);
                
                % HK輝度・body領域
                lum_HK.body.all = lum_HK.all .* mask_body;
                lum_HK.body.all_list = lum_HK.body.all(mask_body==1);
                lum_HK.body.mean = mean(lum_HK.body.all_list);
                lum_HK.body.log_all_list = log10(lum_HK.body.all_list);
                lum_HK.body.log_mean = mean(lum_HK.body.log_all_list);

                
                %% 明るさ (ハイライトのlog輝度で定義)
                if h <= hue_num % 有彩色 -> HK輝度を使用
                    highlight_lum_tmp(:,h,j,k) = lum_HK.HL.log_mean;
                else
                    highlight_lum_tmp(:,h,j,k) = lum_original.HL.log_mean;
                end
                
                %% 明るさコントラスト (log輝度の差として定義)
                if h <= hue_num % 有彩色 -> HK輝度を使用
                    contrast_tmp(:,h,j,k) = lum_HK.HL.log_mean - lum_HK.body.log_mean;
                else % 無彩色 -> 元の輝度を使用
                    contrast_tmp(:,h,j,k) = lum_original.HL.log_mean - lum_original.body.log_mean;
                end
                    
                %% 色コントラスト
                
                % L*a*b*に変換
                img_lab = tnt.three_channel_convert([], img, @(c,d) XYZToLab(d, wp.d65_XYZ_disp'));
                
                % 各領域の平均色度を算出
                for p = 1:3 % L*a*b*
                    % ハイライト領域
                    tmp_img = img_lab(:,:,p);
                    img_lab_highlihgt_nnz(:,p) = tmp_img(mask_HL);
                    
                    % 周辺領域
                    img_lab_near_nnz(:,p) = tmp_img(mask_HL_near);
                end
                mean_lab.highlight = mean(img_lab_highlihgt_nnz);
                mean_lab.near = mean(img_lab_near_nnz);
                
                % CIE DE2000に基づき色差（色コントラスト）を計算
                dE = imcolordiff(mean_lab.highlight, mean_lab.near, 'Standard','CIEDE2000', 'isInputLab', true);
                
                color_difference_tmp(:,h,j,k) = dE;
                %}
               
            end
            
            fprintf('finish : %d/%d\n\n', count, object.all_num);
            count = count + 1;

        end
    end
    
    highlight_lum{i} = highlight_lum_tmp;
    contrast_lum{i} = contrast_tmp;
    color_difference{i} = color_difference_tmp;
    
end

%% 説明変数計算
for i = 1:object.material_num
    
    if i == 1
        hue_name = object.hue;
        hue_num = object.hue_num;
    elseif i == 2
        hue_name = object.hue_metal;
        hue_num = object.hue_metal_num;
    end
    
    highlight_lum_diff_tmp = zeros(1,hue_num,object.light_num,object.rough_num);
    contrast_diff_tmp = zeros(1,hue_num,object.light_num,object.rough_num);
    color_diff_tmp = zeros(1,hue_num,object.light_num,object.rough_num);
    
    for j = 1:object.light_num
        for k = 1:object.rough_num
            %% 明るさ変化
            highlight_lum_diff_tmp(:,:,j,k) = highlight_lum{i}(:,1:hue_num,j,k) - highlight_lum{i}(:,hue_num+1:end,j,k);

            %% 明るさコントラスト変化
            contrast_diff_tmp(:,:,j,k) = contrast_lum{i}(:,1:hue_num,j,k) - contrast_lum{i}(:,hue_num+1:end,j,k);
            
            %% 色コントラスト変化
            color_diff_tmp(:,:,j,k) = color_difference{i}(:,1:hue_num,j,k) - color_difference{i}(:,hue_num+1:end,j,k);
            
        end
    end
    
    highlight_lum_diff{i} = highlight_lum_diff_tmp;
    contrast_diff{i} = contrast_diff_tmp;
    color_diff{i} = color_diff_tmp;
    
end

%% 保存
save('../../mat/regress_var/highlight_lum_diff.mat', 'highlight_lum_diff');
save('../../mat/regress_var/contrast_diff.mat', 'contrast_diff');
save('../../mat/regress_var/color_diff.mat', 'color_diff');

%% 可視化
load('../../mat/stimuli_color/hue_mean_360.mat');
clear txt
for p = 1:3
    
    switch p
        case 1
            val = highlight_lum_diff;
            txt.title = 'highlight brightness diff';
        case 2
            val = contrast_diff;
            txt.title = 'contrast diff';
        case 3
            val = color_diff;
            txt.title = 'color contrast diff';
    end
    
    for i = 1:object.material_num
        figure;
        hold on;
        
        if i == 1
            hue_name = object.hue;
            hue_num = object.hue_num;
        elseif i == 2
            hue_name = object.hue_metal;
            hue_num = object.hue_metal_num;
        end
        
        count = 1;
        for j = 1:object.light_num
            for k = 1:object.rough_num
                
                x = hue_mean_360{i}(:,j,k);
                y = val{i}(:,:,j,k);
                
                if x(1)> 315
                    x(1) = x(1) - 360;
                end
                
                h(count) = plot(x(1:8), y(1:8));
                
                txt.lgd(count) = strcat(object.light(j),"  ",object.rough(k));
                count = count + 1;
            end
        end
        
        xlim([-10 360])
        
        title(strcat(txt.title," ",object.material(i)));
        
        lgd = legend(h, num2cell(txt.lgd));
        lgd.NumColumns = 1;
        lgd.Title.FontWeight = 'normal';
        lgd.Location = 'best';
        
    end
    
end

