%% 刺激画像作成のプログラム
% レンダリング画像を読み込み、トーンマップ、無彩色化を行う

clear all;

flag_par = 3; % 実験番号
object = object_paramater(flag_par); % 各パラメータまとめ
idx = make_index(flag_par);
pass.mat = '../../mat/';

%% Main
i = 1;

% レンダリング画像読み込み
load(strcat(pass.mat,object.shape(idx(i,1)),'/',object.material(idx(i,2)),'/',object.light(idx(i,3)),'/',object.rough(idx(i,4)),'/',object.shape(idx(i,1)),'_',object.hue_n(idx(i,5)),'.mat'));
img_xyz = xyz;

%% 輝度修正（トーンマップ含む）
load('../../mat/color_limit/lum_range.mat');
lum_min = lum_range(1) + 0.1;
lum_max = lum_range(2) - 3;
img_lum_modified = renderXYZ_to_luminance(img_xyz, lum_min, lum_max);

%% 無彩色化
% 解像度上げるときにマスクまわりの設定要確認
load('../../mat/mask/bunny_mask.mat');
img_gray = colorize_achromatic(img_lum_modified);


%% 画像出力（仮）
img = conv_XYZ2RGB(img_gray);
figure;
image(img)