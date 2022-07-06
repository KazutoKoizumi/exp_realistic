%% CIE DE2000の色差式に基づいて色差計算

clear all;

flag_par = 3; % 実験番号
object = object_paramater(flag_par); % 各パラメータまとめ
idx = make_index(flag_par);

pass.mat = '../../mat/';
load('../../mat/mask/highlight/highlightMap.mat');

pass.calibration = '/home/koizumi/experiment/';
spectrum_data = csvread(strcat(pass.calibration,'calibration/spectrum_data.csv'));
rgb_converter = tnt.RgbConverter(spectrum_data);
xyz_min = rgb_converter.linear_rgb_to_xyz([0,0,0]');
xyz_max = rgb_converter.linear_rgb_to_xyz([1,1,1]');
lum_range = [xyz_min(2), xyz_max(2)];

wp_xyz = whitepoint('d65')';
wp_xyz_cd = wp_xyz * (lum_range(2)-10);

%% Main

for i = 1:2 % material
    
    if i == 1
        hue_name = object.hue;
        hue_num = object.hue_num;
    elseif i == 2
        hue_name = object.hue_metal;
        hue_num = object.hue_metal_num;
    end 
    
    for j = 1:2 % light
        for k = 1:3 % roughness
            % 画像読み込み
            pass.object = strcat(pass.mat,object.shape(1),'/',object.material(i),'/',object.light(j),'/',object.rough(k),'/');
            load(strcat(pass.object,'stimuli_xyz.mat'));
            load('../../mat/mask/bunny_mask.mat');
            
            for h = 1:hue_num
                img = stimuli_xyz(:,:,:,h);
                
                % L*a*b*に変換
                img_lab = xyz2lab(img, 'WhitePoint', wp_xyz_cd);
                
                % 各領域の平均色度を算出
                % ハイライト領域
                mask = highlightMap(:,:,1,1,j,3);
                
                
            end
            
        
            
            
            
        end
    end
end