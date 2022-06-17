%% 画像の彩度を取得する
% 彩度：u'v'色度のユークリッド距離

% Input
%   img : XYZの画像データ
%   mask : 物体部分を示すマスク画像
%
% Output
%   sat_map : 物体部分の輝度マップ（画像形式）
%   sat_list : 物体部分の輝度リスト
%

function [sat_map, sat_list] = get_saturation(img, mask, wp)

    arguments
        img = zeros(100,100);
        mask = zeros(100,100);
        wp = whitepoint('d65');
    end
    
    % u'v'に変換
    cx2u = makecform('xyz2upvpl');
    upvpl = applycform(img,cx2u);
    
    % 白色点
    wp_uvl = applycform(wp, cx2u);
    
    % 彩度計算
    delta_u = upvpl(:,:,1) - wp_uvl(1);
    delta_v = upvpl(:,:,2) - wp_uvl(2);
    sat_map = sqrt(delta_u.^2 + delta_v.^2);
    
    sat_map = sat_map .* mask;
    
    mask_l = logical(mask);
    sat_list = sat_map(mask_l); 
        
    

end