% 選考尺度値を求めプロットする, 実験3

% 勝敗表作成
% 選好尺度値を求める
% 有意差の有無の検定
% プロット

clear all;

exp = 'exp_realistic';
sn = input('Sbuject Name?: ', 's');
sn_list = ["son", "morishita", "inoue", "horiuchi"];

N = size(sn_list,2); % 被験者数
num_compair = 2; % 1種の刺激対に対する1人あたりの応答回数

mkdir(strcat('../../data/',exp,'/',sn));
%mkdir(strcat('../../analysis_result/',exp,'/pre/',sn)); % 予備実験
mkdir(strcat('../../analysis_result/',exp,'/',sn));

% パラメータ
flag_par = 3;
object = object_paramater(flag_par); 

%% 勝敗表作成
standings = make_standings_realistic(sn, num_compair, sn_list);
save(strcat('../../data/',exp,'/',sn,'/standings'),'standings');

%% 選好尺度値を求める
% プラスチックと金属で比較する刺激数が異なることに注意
tnum = N * num_compair; % 同じペアの比較数
psv = cell(1,2);
psv_CI = cell(1,2);
BS_sample = cell(1,2);
for i = 1:object.material_num
    standings_material.mtx = standings.mtx{i};
    standings_material.out_of_num = standings.out_of_num{i};
    standings_material.num_greater = standings.num_greater{i};
    if i == 1
        num_sti = numel(object.hue_pair_list);
    elseif i == 2
        num_sti = numel(object.hue_metal_pair_list);
    end
    
    [psv_tmp, psv_CI_tmp, BS_sample_tmp] = preference_scale_value_realistic(standings_material, num_sti, object.light_num*object.rough_num, tnum);
    psv{i} = psv_tmp;
    psv_CI{i} = psv_CI_tmp;
    BS_sample{i} = BS_sample_tmp;
end
save(strcat('../../analysis_result/',exp,'/',sn,'/psv'),'psv');
save(strcat('../../analysis_result/',exp,'/',sn,'/psv_CI'),'psv_CI');
save(strcat('../../analysis_result/',exp,'/',sn,'/BS_sample'),'BS_sample');

%% 有意差の有無の判定
p = cell(1,2);
sig_diff = cell(1,2);
for i = 1:object.material_num
    if i == 1
        num_sti = numel(object.hue_pair_list);
    elseif i == 2
        num_sti = numel(object.hue_metal_pair_list);
    end
    
    [p_tmp, sig_diff_tmp] = significant_difference_realistic(BS_sample{i}, num_sti, flag_par);
    
    p{i} = p_tmp;
    sig_diff{i} = sig_diff_tmp;
end
save(strcat('../../analysis_result/',exp,'/',sn,'/p'),'p');
save(strcat('../../analysis_result/',exp,'/',sn,'/sig_diff'),'sig_diff');

%% プロット
load(strcat('../../analysis_result/',exp,'/',sn,'/psv_CI.mat'));
load(strcat('../../analysis_result/',exp,'/',sn,'/sig_diff.mat'));
mkdir(strcat('../../analysis_result/',exp,'/',sn,'/graph'));

% 色相名を角度に
load('../../mat/stimuli_color/hue_mean_360.mat');

for i = 1:2
    if i == 1
        hue_name = object.hue_pair_list;
        %hue_name_label = ["5R","75YR","10Y","25G","5BG","75B","10PB","25RP","5R achromatic","75YR achromatic","10Y achromatic","25G achromatic","5BG achromatic","75B achromatic","10PB achromatic","25RP achromatic"];
    elseif i == 2
        hue_name = object.hue_metal_pair_list;
        %hue_name_label = ["5R","75YR","10Y","25G","5BG","75B","10PB","25RP","Cu","Au","5R achromatic","75YR achromatic","10Y achromatic","25G achromatic","5BG achromatic","75B achromatic","10PB achromatic","25RP achromatic","Cu achromatic","Au achromatic"];
    end
    
    f = plot_psv_realistic(psv_CI{i},sig_diff,exp,sn,hue_name, hue_mean_360{i});
    
    f.WindowState = 'maximized';
    graphName = strcat('psv_',object.material(i),'.png');
    fileName = strcat('../../analysis_result/',exp,'/',sn,'/graph/',graphName);
    saveas(gcf, fileName);

end
