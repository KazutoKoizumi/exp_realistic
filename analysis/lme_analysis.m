%% 線形混合モデル（実験3）
% 目的変数：光沢感変化量
% 固定効果：説明変数
% 変量効果：物体条件の切片と係数への効果

clear all;

flag_par = 3;
object = object_paramater(flag_par);
pass.mat = '../../mat/';

%% 変数準備
% 目的変数
load('../../analysis_result/exp_realistic/all/GEindex.mat');

% 説明変数
load('../../mat/regress_var/highlight_lum_diff.mat');
load('../../mat/regress_var/contrast_diff.mat');
load('../../mat/regress_var/color_diff.mat');


