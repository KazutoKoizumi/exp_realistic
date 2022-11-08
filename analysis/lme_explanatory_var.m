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
            
            for h = 1:hue_num*2 % 有彩色 + 無彩色
                img = stimuli_xyz(:,:,:,h);
                
                % ハイライト・周辺領域のマスク
                h_tmp = rem(h,hue_num);
                if h_tmp == 0
                    h_tmp = hue_num;
                end
                mask_HL = highlight_mask(:,:,h_tmp,i,j,k);
                mask_HL_near = highlight_round_mask(:,:,h_tmp,i,j,k);
            
                %% 明るさ
                

                %% 明るさコントラスト

                %% 色コントラスト
                %{
                % L*a*b*に変換
                %img_lab = xyz2lab(img, 'WhitePoint', wp.d65_XYZ);
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
                
                % CIE DE2000に基づき色差を計算
                dE = imcolordiff(mean_lab.highlight, mean_lab.near, 'Standard','CIEDE2000', 'isInputLab', true);
                
                color_difference_tmp(:,h,j,k) = dE;
                %}
               
            end
            
        end
    end
    
    %color_difference{i} = color_difference_tmp;
    
    
end

