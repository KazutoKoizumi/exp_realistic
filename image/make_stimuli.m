%% 刺激画像作成のプログラム
% レンダリング画像を読み込み、トーンマップ、無彩色化を行う

clear all;

flag_par = 3; % 実験番号
object = object_paramater(flag_par); % 各パラメータまとめ
idx = make_index(flag_par);
pass.mat = '../../mat/';
img_y = 720;
img_x = 960;

%% Main
% 素材ごとに刺激画像データ（RGB値）をまとめる
stimuli_plastic = zeros(img_y,img_x,3,object.hue_num*2,object.light_num,object.rough_num, 'uint8');
stimuli_metal = zeros(img_y,img_x,3,object.hue_num*2,object.light_num,object.rough_num, 'uint8');

count = 0;

for i = 1:1 % material
    for j = 2:2 % light
        for k = 1:1 % roughness
            stimuli_xyz = zeros(img_y,img_x,3,object.hue_num*2);
            stimuli = zeros(img_y,img_x,3,object.hue_num*2, 'uint8');
            for l = 1:object.hue_num
                pass.object = strcat(pass.mat,object.shape(1),'/',object.material(i),'/',object.light(j),'/',object.rough(k),'/');
                %mkdir(strcat(pass.object,'color'));
                %mkdir(strcat(pass.object,'gray'));

                % レンダリング画像読み込み
                load(strcat(pass.object,object.shape(1),'_',object.hue(l),'.mat'));
                img_xyz = xyz;

                %% 輝度修正（トーンマップ含む）
                load('../../mat/color_limit/lum_range.mat');
                lum_min = lum_range(1) + 0.1;
                lum_max = lum_range(2) - 10;
                img_lum_modified = renderXYZ_to_luminance(img_xyz, lum_min, lum_max);

                %% 無彩色化
                load('../../mat/mask/bunny_mask.mat');
                img_gray = colorize_achromatic(img_lum_modified, mask);
                
                %% 後処理1
                % 色相をまとめる
                stimuli_xyz(:,:,:,l) = img_lum_modified;
                stimuli_xyz(:,:,:,object.hue_num+l) = img_gray;
                
                stimuli(:,:,:,l) = cast(conv_XYZ2RGB(img_lum_modified),'uint8');
                stimuli(:,:,:,object.hue_num+l) = cast(conv_XYZ2RGB(img_gray),'uint8');
            end
            %% 後処理2
            % 色相以外のデータをまとめる
            if i == 1
                stimuli_plastic(:,:,:,:,j,k) = stimuli;
            elseif i == 2
                stimuli_metal(:,:,:,:,j,k) = stimuli;
            end   
            
            % 刺激保存
            pass.stimuli = strcat('../../stimuli/',object.shape(1),'/',object.material(i),'/',object.light(j),'/',object.rough(k),'/');
            save(strcat(pass.object,'stimuli_xyz.mat'), 'stimuli_xyz');
            save(strcat(pass.stimuli,'stimuli.mat'), 'stimuli');
            
            % 画像
            figure;
            montage(stimuli,'size',[4,4]);
            fig_name = strcat(object.shape(1),'_',object.material(i),'_',object.light(j),'_',object.rough(k),'.png');
            saveas(gcf,strcat('../../image/exp_stimuli/',fig_name));
            %close;
            
            count = count+1;
            fprintf('finish : %d/%d\n\n', count, object.all_num);
        end
    end
end

% まとめたデータを保存
save('../../stimuli/bunny/stimuli_plastic.mat', 'stimuli_plastic');
save('../../stimuli/bunny/stimuli_metal.mat', 'stimuli_metal');

