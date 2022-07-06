%% 画像の色相を取得する
% 色相：u'v'色度における白色点を中心とした角度 (-π ~ π)

% Input
%   img : XYZの画像データ
%   mask : 物体部分を示すマスク画像
%   wp : 白色点のXYZ値
%
% Output
%   sat_map : 物体部分の色相マップ（画像形式）
%   sat_list : 物体部分の色相リスト
%

function [hue_map, hue_list] = get_hue(img, mask, wp)
    
    % u'v'に変換
    img_uvl = tnt.three_channel_convert([], img, @(c,d) XYZTouvY(d));
    
    % 白色点
    wp_uvl = tnt.three_channel_convert([], wp, @(c,d) XYZTouvY(d))';
    
    % 色相計算
    [hue_map, rho] = cart2pol(img_uvl(:,:,1)- wp_uvl(1), img_uvl(:,:,2) - wp_uvl(2));
    hue_map = hue_map .* mask;
    
    hue_list = hue_map(logical(mask));
    
end