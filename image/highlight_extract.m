%% 輝度閾値を設定してハイライト領域を取り出す
% ハイライト領域：上位5%の輝度をもつピクセル
% ハイライト周辺：ハイライト領域の周辺部をとる（20ピクセル程度？）

clear all;

flag_par = 3;
object = object_paramater(flag_par);
pass.mat = '../../mat/';

%% 
highlight_map = cell(1,2);

count = 0;
for i = 1:object.material_num
    
    if i == 1
        hue_name = object.hue;
        hue_num = object.hue_num;
    elseif i == 2
        hue_name = object.hue_metal;
        hue_num = object.hue_metal_num;
    end
    
    highlight_map_tmp = zeros(720,960,hue_num,object.light_num,object.rough_num);
    
    for j = 1:object.light_num
        for k = 1:object.rough_num
            % 画像読み込み
            pass.object = strcat(pass.mat,object.shape(1),'/',object.material(i),'/',object.light(j),'/',object.rough(k),'/');
            load(strcat(pass.object,'stimuli_xyz.mat'));
            load('../../mat/mask/bunny_mask.mat');
            
            for h = 1:hue_num
                img = stimuli_xyz(:,:,:,h);
                
                % 輝度閾値計算
                per_threshold = 7;
                [lum_map, lum_list] = get_luminance(img, mask);
                srt = sort(lum_list);
                idx = uint32(numel(srt)*(100-per_threshold)/100);
                lum_threshold = srt(idx);
                
                % ハイライト領域を抽出
                HL_map = lum_map;
                HL_map(HL_map < lum_threshold) = 0;
                HL_map(HL_map ~= 0) = 1;
                HL_map = logical(HL_map);
                highlight_map_tmp(:,:,h,j,k) = HL_map;
                
                % ハイライトの周辺領域を抽出
                
            end
            
            count = count + 1;
            fprintf('finish : %d / %d\n\n', count, object.all_num);
            
        end
    end
    
    highlight_map{i} = highlight_map_tmp;
    
end
