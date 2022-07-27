%% 画像の輝度を取得する

% Input
%   img : XYZの画像データ
%   mask : 指定部分を示すマスク画像
%
% Output
%   lum_map : 指定部分の輝度マップ（画像形式）
%   lum_list : 指定部分の輝度リスト
%

function [lum_map, lum_list] = get_luminance(img, mask)
    
    lum_map = img(:,:,2) .* mask;
    
    mask_l = logical(mask);
    lum_list = lum_map(mask_l); 


end