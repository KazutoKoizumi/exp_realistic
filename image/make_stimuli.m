%% 刺激画像作成のプログラム
% レンダリング画像を読み込み、トーンマップ、無彩色化を行う

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
% 素材ごとに刺激画像データ（RGB値）をまとめる
stimuli_plastic = zeros(img_y,img_x,3,object.hue_num*2,object.light_num,object.rough_num, 'uint8');
stimuli_metal = zeros(img_y,img_x,3,object.hue_metal_num*2,object.light_num,object.rough_num, 'uint8');

count = 0;

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
            
            stimuli_xyz = zeros(img_y,img_x,3,hue_num*2);
            stimuli = zeros(img_y,img_x,3,hue_num*2, 'uint8');
            
            for l = 1:hue_num 
                pass.object = strcat(pass.mat,object.shape(1),'/',object.material(i),'/',object.light(j),'/',object.rough(k),'/');
                %mkdir(strcat(pass.object,'color'));
                %mkdir(strcat(pass.object,'gray'));

                % レンダリング画像読み込み
                load(strcat(pass.object,object.shape(1),'_',hue_name(l),'.mat'));
                %{
                if flag_metal == 0
                    load(strcat(pass.object,object.shape(1),'_',object.hue(l),'.mat'));
                elseif i == 2 && flag_metal == 1 
                    load(strcat(pass.object,object.shape(1),'_Cu.mat'));
                end
                %}
                img_xyz = xyz;

                %% 輝度修正（トーンマップ含む）
                lum_min = lum_range(1) + 0.01;
                lum_max = lum_range(2) - 15;
                img_lum_modified = renderXYZ_to_luminance(img_xyz, lum_min, lum_max);
                
                %% 低輝度側の色域調整
                lum_threshold = 15;
                img_modified = adjust_saturation(img_lum_modified, lum_threshold);

                %% 無彩色化
                load('../../mat/mask/bunny_mask.mat');
                img_gray = colorize_achromatic(img_modified, mask);
                
                %% 後処理1
                % 色相をまとめる
                stimuli_xyz(:,:,:,l) = img_modified;
                stimuli_xyz(:,:,:,hue_num+l) = img_gray;
                
                stimuli(:,:,:,l) = cast(conv_XYZ2RGB(img_modified),'uint8');
                stimuli(:,:,:,hue_num+l) = cast(conv_XYZ2RGB(img_gray),'uint8');
                
                fprintf('hue finish : %d/%d\n\n', l, hue_num);
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
            
            %{
            if flag_metal == 0
                save(strcat(pass.object,'stimuli_xyz.mat'), 'stimuli_xyz');
                save(strcat(pass.stimuli,'stimuli.mat'), 'stimuli');
            elseif i == 2 && flag_metal == 1
                save(strcat(pass.object,'stimuli_xyz_preset.mat'), 'stimuli_xyz');
                save(strcat(pass.stimuli,'stimuli_preset.mat'), 'stimuli');
            end
            %}
            
            % 画像
            figure;
            if i == 1
                montage(stimuli,'size',[4,4]);
                fig_name = strcat(object.shape(1),'_',object.material(i),'_',object.light(j),'_',object.rough(k),'.png');
                saveas(gcf,strcat('../../image/exp_stimuli/',fig_name));
                % close
            elseif i == 2
                % マンセル色
                img = zeros(img_y, img_x, 3, object.hue_num*2, 'uint8');
                img(:,:,:,1:8) = stimuli(:,:,:,1:8);
                img(:,:,:,9:16) = stimuli(:,:,:,11:18);
                montage(img,'size',[4,4]);
                fig_name = strcat(object.shape(1),'_',object.material(i),'_',object.light(j),'_',object.rough(k),'.png');
                saveas(gcf,strcat('../../image/exp_stimuli/',fig_name));
                % close
                
                % CU, Au
                img = zeros(img_y, img_x, 3, 4, 'uint8');
                img(:,:,:,1:2) = stimuli(:,:,:,9:10);
                img(:,:,:,3:4) = stimuli(:,:,:,19:20);
                figure;
                montage(img,'size',[2,2]);
                fig_name = strcat(object.shape(1),'_',object.material(i),'_',object.light(j),'_',object.rough(k),'_preset.png');
                saveas(gcf,strcat('../../image/exp_stimuli/',fig_name));
                % close
            end
            
            %{
            if flag_metal == 0
                montage(stimuli,'size',[4,4]);
            elseif flag_metal == 1
                image(stimuli(:,:,:,1));
            end
            
            fig_name = strcat(object.shape(1),'_',object.material(i),'_',object.light(j),'_',object.rough(k),'.png');
            saveas(gcf,strcat('../../image/exp_stimuli/',fig_name));
            %close;
            %}
            
            count = count+1;
            fprintf('material:%s,  light:%s,  roughness:%s\n', object.material(i), object.light(j), object.rough(k));
            fprintf('finish : %d/%d\n\n', count, object.all_num);
        end
        
    end
end

% まとめたデータを保存
save('../../stimuli/bunny/stimuli_plastic.mat', 'stimuli_plastic');
save('../../stimuli/bunny/stimuli_metal.mat', 'stimuli_metal');

