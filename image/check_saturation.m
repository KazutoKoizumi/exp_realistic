%% 全体の彩度、ハイライト部の彩度を取得する

clear all;

flag_par = 3; % 実験番号
object = object_paramater(flag_par); % 各パラメータまとめ
idx = make_index(flag_par);
pass.mat = '../../mat/';

wp_xyz = whitepoint('d65')';
wp_uvl = tnt.three_channel_convert([], wp_xyz, @(c,d) XYZTouvY(d));

sat_mean = cell(1,2);
sat_HL_mean = cell(1,2);

for i = 1:2 % material
    
    if i == 1
        hue_name = object.hue;
        hue_num = object.hue_num;
    elseif i == 2
        hue_name = object.hue_metal;
        hue_num = object.hue_metal_num;
    end
    
    sat_mean_tmp = zeros(hue_num, object.light_num, object.rough_num);
    sat_HL_mean_tmp = zeros(hue_num, object.light_num, object.rough_num);
    
    for j = 1:2 % light
        for k = 1:3 % roughness        
            %% 画像読み込み
            pass.object = strcat(pass.mat,object.shape(1),'/',object.material(i),'/',object.light(j),'/',object.rough(k),'/');
            load(strcat(pass.object,'stimuli_xyz.mat'));
            load('../../mat/mask/bunny_mask.mat');
            load('../../mat/highlight/highlight_map.mat');
            
            %% Main
            for h = 1:hue_num
                img = stimuli_xyz(:,:,:,h);
                mask_HL = highlight_map{i}(:,:,h,j,k);
                
                % 全体の彩度
                [sat_map, sat_list] = get_saturation(img, mask, wp_xyz);
                sat_mean_tmp(h,j,k) = mean(sat_list);
                
                % ハイライトの彩度
                [sat_HL_map, sat_HL_list] = get_saturation(img, mask_HL, wp_xyz);
                sat_HL_mean_tmp(h,j,k) = mean(sat_HL_list);
                
            end
            
            
        end
    end
    
    sat_mean{i} = sat_mean_tmp;
    sat_HL_mean{i} = sat_HL_mean_tmp;
    
end

save('../../mat/stimuli_color/sat_HL_mean.mat', 'sat_HL_mean');
