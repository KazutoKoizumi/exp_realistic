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
    
    if i == 1
        hue_name = object.hue;
        hue_num = object.hue_num;
    elseif i == 2
        hue_name = object.hue_metal;
        hue_num = object.hue_metal_num;
    end 
    
    for j = 1:2
        for k = 1:3
            
            pass.object = strcat(pass.mat,object.shape(1),'/',object.material(i),'/',object.light(j),'/',object.rough(k),'/');
            load(strcat(pass.object,'stimuli_xyz.mat'));
            
            stimuli_xyz = fillmissing(stimuli_xyz, 'previous');
            
            stimuli = zeros(img_y,img_x,3,hue_num*2, 'uint8');
            for l = 1:hue_num
                stimuli(:,:,:,l) = cast(conv_XYZ2RGB(stimuli_xyz(:,:,:,l)),'uint8');
                stimuli(:,:,:,hue_num+l) = cast(conv_XYZ2RGB(stimuli_xyz(:,:,:,hue_num+l)),'uint8');
            end
            pass.stimuli = strcat('../../stimuli/',object.shape(1),'/',object.material(i),'/',object.light(j),'/',object.rough(k),'/');
            
            save(strcat(pass.object,'stimuli_xyz.mat'), 'stimuli_xyz');
            save(strcat(pass.stimuli,'stimuli.mat'), 'stimuli');
        end
    end
end
