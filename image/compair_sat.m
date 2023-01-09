%% 実験1と実験3の刺激間で彩度を比較する
% ハイライト彩度

clear all;

pass.exp1_mat = '../../../exp_color_gloss/mat/';
pass.exp3_mat = '../../mat/';

load(strcat(pass.exp1_mat,'highlight/highlightSat.mat'));
load(strcat(pass.exp3_mat,'stimuli_color/sat_HL_mean.mat'));
load('../../mat/stimuli_color/hue_mean_360_mod.mat');

flag_par.exp1 = 1;
flag_par.exp3 = 3;

idx.exp1 = make_index(flag_par.exp1);

object.exp1 = object_paramater(flag_par.exp1);
object.exp3 = object_paramater(flag_par.exp3);

%% データ整理
% 実験1のハイライト彩度を拡散反射率については平均
% 形式を（彩色条件2×照明2×粗さ3）の形に整理、彩色条件は実験3の素材条件に合わせるために順番を反転させる
% 実験1の彩度は色相間では等しい
sat_HL_mean_exp1_tmp = zeros(object.exp1.method_num, object.exp1.light_num, object.exp1.diffuse_num, object.exp1.rough_num); % 彩色条件, 照明, 拡散反射率, 粗さ
for i = 1:1 % 形状
    for j = 1:object.exp1.light_num
        for k= 1:object.exp1.diffuse_num
            for l = 1:object.exp1.rough_num
                for m = 1:object.exp1.method_num
                    id = find(idx.exp1(:,1)==i & idx.exp1(:,2)==j & idx.exp1(:,3)==k & idx.exp1(:,4)==l & idx.exp1(:,5)==m);
                    if m == 1
                        id_material = 2;
                    elseif m == 2
                        id_material = 1;
                    end
                    
                    sat_HL_mean_exp1_tmp(id_material, j, k, l) = highlightSat(1,id);
                    
                end
            end
        end
    end
end
sat_HL_mean_exp1 = permute(mean(sat_HL_mean_exp1_tmp, 3), [1,2,4,3]);

% 色相について平均
for i = 1:object.exp3.material_num
    sat_HL_mean_exp3{i} = mean(sat_HL_mean{i}, 1);
end

clear sat_HL_mean_exp1_tmp;

%% プロット
graph_color = [[0 0.4470 0.7410]; [0.8500 0.3250 0.0980]];
sz.sgt = 12;
sz.lgd = 8; %16;
for i = 1:object.exp3.material_num
    
    %% 全プロット
    f = figure;
    bar_width = 0.3;
    txt_label = cell(1,6);
    count = 1;
    
    x = 1:6;
    x_exp1 = x-0.17;
    x_exp3 = x+0.17;
    
    for j = 1:object.exp3.light_num
        for k= 1:object.exp3.rough_num
            
            % 実験1の刺激の彩度
            sat_exp1(:,count) = sat_HL_mean_exp1(i,j,k);
            
            % 実験3の刺激の彩度
            sat_exp3(:,count) = sat_HL_mean_exp3{i}(:,j,k);
            
            txt_label(:,count) = {strcat(object.exp3.light(j)," ",object.exp3.rough(k))};
            
            count = count + 1;
        end
    end
    b1 = bar(x_exp1, sat_exp1, 'BarWidth',bar_width, 'FaceColor',graph_color(1,:));
    hold on;
    b3 = bar(x_exp3, sat_exp3, 'BarWidth',bar_width, 'FaceColor',graph_color(2,:));
    
    f.Position = [251,454,722,407];
    
    xticks(x);
    xticklabels(txt_label);
    xtickangle(30);
    
    ax = gca;
    ax.FontSize = 14;
    
end