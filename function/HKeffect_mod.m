% 色相の補正をかけたH-K効果の大きさを求める関数
% 彩度、色相(degree)をもとに補正

% Output
%   val_HK : 補正後のHK
%   val_HK_tmp : 補正前のHK

function [val_HK, val_HK_tmp] = HKeffect_mod(sat, hue)

    load('../../../exp_color_gloss/mat/HKeffect/cf.mat'); % 実験で測定したデータから回帰したHK効果（8色相）
    hue_original = [0, 45, 90, 135, 180, 225, 270, 315]; % 測定した8色相
    
    %% 基準にする色相のインデックスを決定
    sa = abs(hue - hue_original);
    if sa(1) > 315
        sa(1) = abs(hue - 360);
    end
    [~, idx_hue] = min(sa);
    
    %% 色相補正前のH-K効果の大きさを求める
    val_HK_tmp = cf(1,idx_hue) + cf(2,idx_hue).*sat;
    
    %% 色相の補正をかける
    depend_tmp = HK_hue_dependency(hue_original(idx_hue));
    depend = HK_hue_dependency(hue);
    val_HK = (depend / depend_tmp) .* val_HK_tmp;

end