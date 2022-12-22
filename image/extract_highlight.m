%% ハイライト領域の抽出
% ハイライト：輝度上位5%
% ハイライト周辺：輝度上位5~10%

clear all;

flag_par = 3; % 実験番号
object = object_paramater(flag_par); % 各パラメータまとめ
idx = make_index(flag_par);
pass.mat = '../../mat/';

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
            
            [iy,ix,~] = size(mask);
            
            for h = 1:hue_num
                img = stimuli_xyz(:,:,:,h);
                lum_map = img(:,:,2) .* mask;
                lum_list = lum_map(logical(mask));
                lum_list_sort = sort(lum_list);
                
                %{
                %% ハイライト領域輝度上位5%
                % ハイライト領域
                n = round(numel(lum_list_sort)*0.95);
                lum_threshold = lum_list_sort(n);
                tmp_HL = lum_map > lum_threshold;
                highlight_mask(:,:,h,i,j,k) = tmp_HL;
                
                % ハイライト周辺領域（輝度上位5~10%）
                n = [round(numel(lum_list_sort)*0.90), round(numel(lum_list_sort)*0.95)];
                lum_threshold = [lum_list_sort(n(1)), lum_list_sort(n(2))];
                tmp_HL_round = (lum_map > lum_threshold(1) & lum_map <= lum_threshold(2));
                highlight_round_mask(:,:,h,i,j,k) = tmp_HL_round;
                %}
                
                
                %% ハイライト領域別パターン
                % ハイライト領域（輝度上位30％）
                n = round(numel(lum_list_sort)*0.70);
                lum_threshold = lum_list_sort(n);
                tmp_HL = lum_map > lum_threshold;
                highlight_mask(:,:,h,i,j,k) = tmp_HL;
                
                % ハイライト周辺領域（輝度上位30~60%）
                n = [round(numel(lum_list_sort)*0.40), round(numel(lum_list_sort)*0.70)];
                lum_threshold = [lum_list_sort(n(1)), lum_list_sort(n(2))];
                tmp_HL_round = (lum_map > lum_threshold(1) & lum_map <= lum_threshold(2));
                highlight_round_mask(:,:,h,i,j,k) = tmp_HL_round;
                %}
       
                
                %% ハイライト周辺領域（ハイライトの周辺で物体部分を何ピクセルか）
                % 輝度上位5~10%の場合、プラスチック・環境照明の領域が微妙かも
                % -> 結果：あまり変化なし
                %{
                thr_pixel = 5;
                tmp_HL_round = zeros(iy,ix);
                for y = 1:iy
                    for x = 1:ix
                        if tmp_HL(y,x) == 1
                            % ハイライトの周辺'thr_pixel'分を周辺領域とする
                            for y_tmp = y-thr_pixel:y+thr_pixel
                                for x_tmp = x-thr_pixel:x+thr_pixel
                                    if mask(y_tmp,x_tmp)==1 & tmp_HL(y_tmp,x_tmp)==0
                                        tmp_HL_round(y_tmp,x_tmp) = 1;
                                    end
                                end
                            end
                        end
                    end
                end
                tmp_HL_round = logical(tmp_HL_round);
                highlight_round_mask(:,:,h,i,j,k) = tmp_HL_round;
                %}
            
                f = figure;
                subplot(1,2,1);
                imagesc(tmp_HL);
                title('highlight');
                %xticks([]);
                %yticks([]);
                subplot(1,2,2);
                imagesc(tmp_HL_round);
                title('arround highlight');
                %xticks([]);
                %yticks([]);
                
                f.Position = [197,480,1382,489];
                
                fig_name = strcat('mask_',object.material(i),'_',object.light(j),'_',object.rough(k),'_',hue_name(h),'.png');
                %file_name = strcat('../../image/exp_stimuli_mask/',fig_name);
                file_name = strcat('../../image/exp_stimuli_mask_30per/',fig_name);
                exportgraphics(f, file_name);
                close(f);
                %}
                
            end

        end
    end
    
end

%save('../../mat/mask/highlight_mask.mat', 'highlight_mask');
%save('../../mat/mask/highlight_round_mask.mat', 'highlight_round_mask');

save('../../mat/mask/HL_30per/highlight_mask.mat', 'highlight_mask');
save('../../mat/mask/HL_30per/highlight_round_mask.mat', 'highlight_round_mask');


