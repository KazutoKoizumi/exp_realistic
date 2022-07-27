%% 背景画像作成のプログラム
% 条件にあわせて平均輝度を修正する

clear all;

flag_par = 3; % 実験番号
object = object_paramater(flag_par); % 各パラメータまとめ
idx = make_index(flag_par);
pass.mat = '../../mat/';
img_y = 720;
img_x = 960;

pass.calibration = '/home/koizumi/experiment/';
spectrum_data = csvread(strcat(pass.calibration,'calibration/spectrum_data.csv'));
rgb_converter = tnt.RgbConverter(spectrum_data);
xyz_min = rgb_converter.linear_rgb_to_xyz([0,0,0]');
xyz_max = rgb_converter.linear_rgb_to_xyz([1,1,1]');
lum_range = [xyz_min(2), xyz_max(2)];

%% Main
back_stimuli_XYZ = zeros(img_y,img_x,3,object.material_num,object.light_num,object.rough_num);
back_stimuli = zeros(img_y,img_x,3,object.material_num,object.light_num,object.rough_num, 'uint8');

load('../../mat/mask/bunny_mask.mat');
mask_back = ~mask;

lum_mean_list = zeros(2,2,3); % material, light, roughness

for i = 1:2 % material
    for j = 1:2 % light
        
        % 背景画像のレンダリング結果読み込み
        load(strcat(pass.mat,'back/back_',object.light(j),'.mat'));
        back_img = xyz;
        
        for k = 1:3 % roughness
            %% 刺激画像の平均輝度を求める
            % 刺激画像読み込み
            pass.object = strcat(pass.mat,object.shape(1),'/',object.material(i),'/',object.light(j),'/',object.rough(k),'/');
            load(strcat(pass.object,'stimuli_xyz.mat'));
            
            % 背景部分の平均輝度を求める
            [lum_map, lum_list] = get_luminance(stimuli_xyz(:,:,:,1), mask_back);
            lum_mean_list(i,j,k) = mean(lum_list, 'all');
            
            %% 輝度修正等
            % 輝度修正（トーンマップ含む）
            lum_min = lum_range(1) + 0.01;
            lum_max = lum_range(2) - 15;
            img_lum_modified = renderXYZ_to_luminance(back_img, lum_min, lum_max);
            
            % 背景用の追加の輝度修正
            % 上で求めた刺激画像の平均輝度に背景画像の平均輝度を合わせる
            back_lum_mean = mean(img_lum_modified(:,:,2), 'all');
            coeff = lum_mean_list(i,j,k) / back_lum_mean
            img_lum_modified = img_lum_modified .* coeff;
            disp(mean(img_lum_modified(:,:,2),'all'));
            
            
            % 最低輝度を下回った部分の修正
            img_uvl = tnt.three_channel_convert([],img_lum_modified, @(c,d) XYZTouvY(d));
            lum = img_uvl(:,:,3);
            
            lum_min_map = lum > lum_min; % ディスプレイの最低輝度以下の部分を0にしたマップ
            lum_tmp = lum .* lum_min_map; % 0にする
            lum_min_map = ~ lum_min_map; % ディスプレイの最低輝度以下の部分が1のマップ
            lum_min_map = lum_min_map .* lum_min; % 最低輝度を入れる
            lum = lum_tmp + lum_min_map; % 最低輝度以下だった部分を最低輝度に合わせる
            
            img_uvl(:,:,3) = lum;
            img_lum_modified = tnt.three_channel_convert([], img_uvl, @(c,d) uvYToXYZ(d));
         
            
            % 低輝度側の色域調整
            lum_threshold = 15;
            img_modified = adjust_saturation(img_lum_modified, lum_threshold);
            
            
            disp(mean(img_modified(:,:,2),'all'));
            
            % 画像まとめ
            back_stimuli_XYZ(:,:,:,i,j,k) = img_modified;
            back_stimuli(:,:,:,i,j,k) = cast(conv_XYZ2RGB(back_stimuli_XYZ(:,:,:,i,j,k)), 'uint8');
            
        end
    end
end

save(strcat(pass.mat,'back/back_stimuli_XYZ.mat'), 'back_stimuli_XYZ');
save('../../stimuli/back/back_stimuli.mat', 'back_stimuli');
