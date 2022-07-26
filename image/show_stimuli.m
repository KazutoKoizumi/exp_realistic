%% 刺激画像確認用プログラム

clear all;

flag_par = 3;
object = object_paramater(flag_par); % 各パラメータまとめ
idx = make_index(flag_par);

id.material = 1;
id.light = 1;
id.rough = [1,2,3];
id.hue = 1;
id.hue_metal = 1;

img = zeros(720,960,3,numel(id.rough));

count = 1;
for i = id.material(1):id.material(end)
    for j = id.light(1):id.light(end)
        for k = id.rough(1):id.rough(end)
            pass.stimuli = strcat('../../stimuli/',object.shape(1),'/',object.material(i),'/',object.light(j),'/',object.rough(k),'/');
            load(strcat(pass.stimuli,'stimuli.mat'));
            
            if i == 1
                id_hue = id.hue;
            elseif i == 2
                id_hue = id.hue_metal;
            end
            
            img(:,:,:,count) = stimuli(:,:,:,id.hue);
            
            count = count + 1;
        end
    end
end