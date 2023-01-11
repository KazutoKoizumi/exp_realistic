%% 素材条件ごと平均した光沢感

clear all;

flag_par = 3;
object = object_paramater(flag_par); 

load('../../analysis_result/exp_realistic/all/psv.mat');
load('../../analysis_result/exp_realistic/all/BS_sample.mat');

%% 平均計算
for i = 1:object.material_num
    
    if i == 1
        num_chromatic = numel(object.hue);
    elseif i == 2
        num_chromatic = numel(object.hue_metal);
    end
    
    psv_mean{i} = mean(psv{i}, [3, 4]);
    BS_psv_mean{i} = mean(BS_sample{i}, [3, 4]);
    
    % 信頼区間計算
    for hue = 1:num_chromatic*2
        CI95_psv_mean{i}(:,hue) = CI95_bootstrap(BS_psv_mean{i}(:,hue))';
    end

end

%% プロット
% 金属、プラスチックの順番でプロット(CuとAuは除く)
load('../../mat/stimuli_color/hue_mean_360_mod.mat');
graph_color = [[0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]];
sz.sgt = 20;
sz.lgd = 18; %16;
sz.label = 20;
sz.ax = 18;
line_style = {'-o', '--o'};

f = figure;
for i = 1:2 % i==1のとき金属をプロット
    
    id_material = mod(i,2)+1;
    hue_deg = hue_mean_360_mod{id_material};
    
    hold on;
    x = mean(hue_deg, [2,3]);
    y = psv_mean{id_material};
    err = abs(psv_mean{id_material} - CI95_psv_mean{id_material});
    
    % 有彩色プロット
    g_color(i) = errorbar(x(1:8), y(1:8), err(1,1:8), err(2,1:8), '-o', 'Color', graph_color(i,:), 'LineWidth', 1.5);
    
    % 無彩色プロット
    if i == 1 % 金属
        g_gray(i) = errorbar(x(1:8), y(11:18), err(1,11:18), err(2,11:18), '--o', 'Color', graph_color(i,:), 'LineWidth', 1.5);
    elseif i == 2
        g_gray(i) = errorbar(x(1:8), y(9:end), err(1,9:end), err(2,9:end), '--o', 'Color', graph_color(i,:), 'LineWidth', 1.5);
    end

end

xlim([-20 360]);
%ylim([0 1.4]);
xlabel('Color direction (degree)', 'FontSize', 20);
ylabel('Preference scale value', 'FontSize', 20);

ax = gca;
ax.FontSize = 18;

g(1) = g_color(1);
g(2) = g_gray(1);
g(3) = g_color(2);
g(4) = g_gray(2);
lgd_txt = {'metal-color', 'metal-achromatic', 'plastic-color', 'plastic-achromatic'};
legend(g, lgd_txt, 'FontSize', 20, 'Location', 'northeastoutside');

