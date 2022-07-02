%% 物体部分の色分布（輝度・彩度）を確認する

clear all;

flag_par = 3; % 実験番号
object = object_paramater(flag_par); % 各パラメータまとめ
idx = make_index(flag_par);
pass.mat = '../../mat/';

wp = whitepoint('d65');

for i = 1:1 % material
    for j = 1:2 % light
        for k = 1:1 % roughness        
            %% 画像読み込み
            pass.object = strcat(pass.mat,object.shape(1),'/',object.material(i),'/',object.light(j),'/',object.rough(k),'/');
            load(strcat(pass.object,'stimuli_xyz.mat'));
            load('../../mat/mask/bunny_mask.mat');
            
            lum_max = max(stimuli_xyz(:,:,2,:), [], 'all');
            lum_range = [0, lum_max];
            sat_range = [0, 0.0880]; % 要確認
            %sat_range = [0, 0.1];
            
            %% Main
            for h = 1:size(stimuli_xyz,4)/2
                img = stimuli_xyz(:,:,:,h);
                
                [lum_map,lum_list,sat_map,sat_list] = plot_relation_lum_sat(img,mask,wp,lum_range,sat_range);
                
                
                % 最大彩度の探索
                tmp = max(sat_map, [], 'all');
                if h == 1
                    sat_max = tmp;
                end
                if sat_max < tmp
                    sat_max = tmp;
                end
            end
        end
    end
end

%% 実験1の刺激に対する設定
wp_xyz_exp1 = [19.3151, 20.0000, 30.5479];