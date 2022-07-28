% 選考尺度値を求めプロットする, 実験3

% 勝敗表作成
% 選好尺度値を求める
% 有意差の有無の検定
% プロット

exp = 'exp_realistic';
sn = input('Sbuject Name?: ', 's');

mkdir(strcat('../../analysis_result/',exp,'/',sn));

%% パラメータ
flag_par = 3;
object = object_paramater(flag_par);

%% 勝敗表作成
standings = make_standings_realistic(sn);
save(strcat('../../data/',exp,'/',sn,'/standings'),'standings');

%% ここから
%% 選好尺度値を求める
tnum = 4; % 同じペアの比較数
[psv,psv_CI,BS_sample] = preference_scale_value(standings,object_p.hue_num,object_p.all_num,tnum);
save(strcat('../../analysis_result/',exp,'/',sn,'/psv'),'psv');
save(strcat('../../analysis_result/',exp,'/',sn,'/psv_CI'),'psv_CI');
save(strcat('../../analysis_result/',exp,'/',sn,'/BS_sample'),'BS_sample');

%% 有意差の有無の判定
[sig_diff,sig_diff_CGeffect] = significant_difference(BS_sample,object_p.hue_num,flag_par);
save(strcat('../../analysis_result/',exp,'/',sn,'/sig_diff'),'sig_diff');
save(strcat('../../analysis_result/',exp,'/',sn,'/sig_diff_CGeffect'),'sig_diff_CGeffect');

%% プロット
load(strcat('../../analysis_result/',exp,'/',sn,'/psv_CI.mat'));
load(strcat('../../analysis_result/',exp,'/',sn,'/sig_diff.mat'));
mkdir(strcat('../../analysis_result/',exp,'/',sn,'/graph'));
f = plot_psv(psv_CI,sig_diff,exp,sn,flag_par);


