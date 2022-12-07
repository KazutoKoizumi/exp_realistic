%% プロット時に使用する色相の値について整理
% 物体条件ごとに平均した場合に値がおかしくならないようにする

clear all;

flag_par = 3;
object = object_paramater(flag_par);

load('../../mat/stimuli_color/hue_mean_360.mat'); % オリジナル

%% 値修正
% プラスチック素材での色相5R（1番目）と金属素材でのCu（9番目）の色相が330~360deg付近の場合に値を負にする
hue_mean_360_mod = hue_mean_360;

for j = 1:object.light_num
    for k = 1:object.rough_num
        
        % プラスチック素材, 色相5R
        i = 1;
        h = 1;
        if hue_mean_360{i}(h,j,k) > 330
            hue_mean_360_mod{i}(h,j,k) = hue_mean_360{i}(h,j,k) - 360;
        end
        
        % 金属素材, Cu
        i = 2;
        h = 9;
        if hue_mean_360{i}(h,j,k) > 330
            hue_mean_360_mod{i}(h,j,k) = hue_mean_360{i}(h,j,k) - 360;
        end
        
    end
end

save('../../mat/stimuli_color/hue_mean_360_mod.mat', 'hue_mean_360_mod');


