%% ハイライト領域の抽出
% ハイライト：輝度上位5%
% ハイライト周辺：輝度上位5~10%

clear all;

flag_par = 3; % 実験番号
object = object_paramater(flag_par); % 各パラメータまとめ
idx = make_index(flag_par);
pass.mat = '../../mat/';

for i = 1:1 % material
    
    if i == 1
        hue_name = object.hue;
        hue_num = object.hue_num;
    elseif i == 2
        hue_name = object.hue_metal;
        hue_num = object.hue_metal_num;
    end
    
    for j = 1:1 % light
        for k = 1:1 % roughness
            % 画像読み込み
            pass.object = strcat(pass.mat,object.shape(1),'/',object.material(i),'/',object.light(j),'/',object.rough(k),'/');
            load(strcat(pass.object,'stimuli_xyz.mat'));
            load('../../mat/mask/bunny_mask.mat');
            
            for h = 1:hue_num
                img = stimuli_xyz(:,:,:,h);
                lum_map = img(:,:,2) .* mask;
                lum_list = lum_map(logical(mask));
                lum_list_sort = sort(lum_list);
                
                % ハイライト領域
                n = round(numel(lum_list_sort)*0.95);
                lum_threshold = lum_list_sort(n);
                tmp_HL = lum_map > lum_threshold;
                highlight_mask(:,:,h,i,j,k) = tmp_HL;
                
                % ハイライト周辺領域
                n = [round(numel(lum_list_sort)*0.90), round(numel(lum_list_sort)*0.95)];
                lum_threshold = [lum_list_sort(n(1)), lum_list_sort(n(2))];
                tmp_HL_round = (lum_map > lum_threshold(1) & lum_map <= lum_threshold(2));
                highlight_round_mask(:,:,h,i,j,k) = tmp_HL_round;
                
                figure;
                subplot(1,2,1);
                imagesc(tmp_HL);
                subplot(1,2,2);
                imagesc(tmp_HL_round);
                
            end
                
            
            
            
        end
    end
end







