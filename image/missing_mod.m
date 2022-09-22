%% 板の下に生じている欠損値の補完
% XYZからu'v'への変換を行う際にPTBの関数のXYZTouvYを使用すると欠損値が生じた。matlab関数では生じない
% 物体とは関係のない板の下の暗い領域のためfillmissingを使用して欠損値を補完

clear all

flag_par = 3; % 実験番号
object = object_paramater(flag_par); % 各パラメータまとめ
idx = make_index(flag_par);
pass.mat = '../../mat/';
img_y = 720;
img_x = 960;

%% Main
for i = 1:2
    for j = 1:2
        for k = 1:3
            
            pass.object = strcat(pass.mat,object.shape(1),'/',object.material(i),'/',object.light(j),'/',object.rough(k),'/');
            load(strcat(pass.object,'stimuli_xyz.mat'));
            
            stimuli_xyz = fillmissing(stimuli_xyz, 'previous');
            
            save(strcat(pass.object,'stimuli_xyz.mat'), 'stimuli_xyz');
        end
    end
end
